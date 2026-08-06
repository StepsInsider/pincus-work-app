CREATE OR REPLACE FUNCTION public.create_baustelle_from_order()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$

DECLARE
    new_baustelle_id UUID;

BEGIN

    -- Nur bei aktiven Aufträgen automatisch Baustelle erzeugen
    IF NEW.status = 'aktiv'
       AND NEW.baustelle_id IS NULL
    THEN

        INSERT INTO public.baustellen (

            company_id,
            title,
            client_name,
            address,
            status,
            budget,
            start_date

        )

        SELECT

            NEW.company_id,
            NEW.titel,
            k.name,
            COALESCE(k.address, ''),
            'geplant',
            NEW.budget,
            NEW.startdatum

        FROM public.kunden k

        WHERE k.id = NEW.kunden_id

        RETURNING id INTO new_baustelle_id;

        UPDATE public.auftraege

        SET

            baustelle_id = new_baustelle_id,
            updated_at = NOW()

        WHERE id = NEW.id;

    END IF;

    RETURN NEW;

END;

$$;

DROP TRIGGER IF EXISTS trigger_create_baustelle_from_order
ON public.auftraege;

CREATE TRIGGER trigger_create_baustelle_from_order

AFTER INSERT OR UPDATE OF status

ON public.auftraege

FOR EACH ROW

EXECUTE FUNCTION public.create_baustelle_from_order();
