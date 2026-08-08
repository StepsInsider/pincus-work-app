CREATE TABLE IF NOT EXISTS public.arbeitszeiten (

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    company_id UUID NOT NULL
    REFERENCES public.companies(id)
    ON DELETE CASCADE,


    mitarbeiter_id UUID NOT NULL
    REFERENCES public.profiles(id)
    ON DELETE CASCADE,


    baustelle_id UUID
    REFERENCES public.baustellen(id)
    ON DELETE SET NULL,


    arbeitsbeginn TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    arbeitsende TIMESTAMPTZ,


    pause_minuten INTEGER NOT NULL DEFAULT 0,


    gesamtstunden NUMERIC(5,2),


    gps_start_lat NUMERIC(10,7),

    gps_start_lng NUMERIC(10,7),


    gps_end_lat NUMERIC(10,7),

    gps_end_lng NUMERIC(10,7),


    notiz TEXT,


    created_at TIMESTAMPTZ DEFAULT NOW(),

    updated_at TIMESTAMPTZ DEFAULT NOW()

);


CREATE INDEX IF NOT EXISTS idx_arbeitszeiten_company
ON public.arbeitszeiten(company_id);


CREATE INDEX IF NOT EXISTS idx_arbeitszeiten_mitarbeiter
ON public.arbeitszeiten(mitarbeiter_id);


CREATE INDEX IF NOT EXISTS idx_arbeitszeiten_baustelle
ON public.arbeitszeiten(baustelle_id);



ALTER TABLE public.arbeitszeiten ENABLE ROW LEVEL SECURITY;



CREATE POLICY "Tenant isolation arbeitszeiten"

ON public.arbeitszeiten

FOR ALL

USING (

    company_id = (
        SELECT company_id
        FROM public.profiles
        WHERE id = auth.uid()
    )

);
