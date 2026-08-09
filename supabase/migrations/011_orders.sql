CREATE TABLE IF NOT EXISTS public.auftraege (

    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),

    company_id UUID NOT NULL
    REFERENCES public.companies(id)
    ON DELETE CASCADE,

    kunden_id UUID NOT NULL
    REFERENCES public.kunden(id)
    ON DELETE CASCADE,

    angebot_id UUID
    REFERENCES public.angebote(id)
    ON DELETE SET NULL,

    auftragsnummer TEXT UNIQUE,

    titel TEXT NOT NULL,

    beschreibung TEXT,

    status TEXT DEFAULT 'offen'
    CHECK (
        status IN (
            'offen',
            'geplant',
            'aktiv',
            'abgeschlossen',
            'storniert'
        )
    ),

    startdatum DATE,

    enddatum DATE,

    budget NUMERIC(12,2),

    baustelle_id UUID
    REFERENCES public.baustellen(id)
    ON DELETE SET NULL,

    erstellt_von UUID
    REFERENCES public.profiles(id),

    created_at TIMESTAMPTZ DEFAULT NOW(),

    updated_at TIMESTAMPTZ DEFAULT NOW()

);

CREATE INDEX IF NOT EXISTS idx_auftraege_company
ON public.auftraege(company_id);

CREATE INDEX IF NOT EXISTS idx_auftraege_kunden
ON public.auftraege(kunden_id);

ALTER TABLE public.auftraege ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Tenant isolation auftraege"

ON public.auftraege

FOR ALL

USING (
    company_id = (
        SELECT company_id
        FROM public.profiles
        WHERE id = auth.uid()
    )
);
