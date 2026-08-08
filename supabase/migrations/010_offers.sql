CREATE TABLE IF NOT EXISTS public.angebote (

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    company_id UUID NOT NULL
    REFERENCES public.companies(id)
    ON DELETE CASCADE,

    kunden_id UUID NOT NULL
    REFERENCES public.kunden(id)
    ON DELETE CASCADE,

    angebotsnummer TEXT UNIQUE,

    titel TEXT NOT NULL,

    beschreibung TEXT,

    status TEXT NOT NULL DEFAULT 'entwurf'
    CHECK (
        status IN (
            'entwurf',
            'versendet',
            'angenommen',
            'abgelehnt'
        )
    ),

    netto NUMERIC(12,2) DEFAULT 0,

    mwst NUMERIC(12,2) DEFAULT 0,

    brutto NUMERIC(12,2) DEFAULT 0,

    erstellt_von UUID
    REFERENCES public.profiles(id),

    erstellt_am TIMESTAMPTZ DEFAULT NOW(),

    aktualisiert_am TIMESTAMPTZ DEFAULT NOW()

);

CREATE INDEX IF NOT EXISTS idx_angebote_company
ON public.angebote(company_id);

CREATE INDEX IF NOT EXISTS idx_angebote_kunde
ON public.angebote(kunden_id);

ALTER TABLE public.angebote ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Tenant isolation angebote"

ON public.angebote

FOR ALL

USING (
    company_id = (
        SELECT company_id
        FROM public.profiles
        WHERE id = auth.uid()
    )
);

