-- ==========================================
-- Pincus Work Enterprise
-- Migration 013
-- Baustellenakte
-- ==========================================

-- Baustellen Dokumente / Fotos

CREATE TABLE IF NOT EXISTS public.baustellen_dokumente (

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    company_id UUID NOT NULL
    REFERENCES public.companies(id)
    ON DELETE CASCADE,

    baustelle_id UUID NOT NULL
    REFERENCES public.baustellen(id)
    ON DELETE CASCADE,

    uploaded_by UUID
    REFERENCES public.profiles(id)
    ON DELETE SET NULL,

    datei_typ TEXT NOT NULL DEFAULT 'foto',

    datei_url TEXT NOT NULL,

    titel TEXT,

    beschreibung TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW()

);

CREATE INDEX IF NOT EXISTS idx_baustellen_dokumente_project
ON public.baustellen_dokumente(baustelle_id);

-- ==========================================
-- Baustellen Checklisten
-- ==========================================

CREATE TABLE IF NOT EXISTS public.baustellen_checklisten (

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    company_id UUID NOT NULL
    REFERENCES public.companies(id)
    ON DELETE CASCADE,

    baustelle_id UUID NOT NULL
    REFERENCES public.baustellen(id)
    ON DELETE CASCADE,

    titel TEXT NOT NULL,

    status TEXT DEFAULT 'offen'
    CHECK (
        status IN (
            'offen',
            'in_bearbeitung',
            'erledigt'
        )
    ),

    erstellt_von UUID
    REFERENCES public.profiles(id),

    created_at TIMESTAMPTZ DEFAULT NOW()

);

-- ==========================================
-- Baustellen Mängel
-- ==================================

CREATE TABLE IF NOT EXISTS public.baustellen_maengel (

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    company_id UUID NOT NULL
    REFERENCES public.companies(id)
    ON DELETE CASCADE,

    baustelle_id UUID NOT NULL
    REFERENCES public.baustellen(id)
    ON DELETE CASCADE,

    titel TEXT NOT NULL,

    beschreibung TEXT,

    prioritaet TEXT DEFAULT 'mittel'
    CHECK (
        prioritaet IN (
            'niedrig',
            'mittel',
            'hoch'
        )
    ),

    status TEXT DEFAULT 'offen'
    CHECK (
        status IN (
            'offen',
            'bearbeitung',
            'erledigt'
        )
    ),

    erstellt_von UUID
    REFERENCES public.profiles(id),

    created_at TIMESTAMPTZ DEFAULT NOW()

);

-- ==========================================
-- Mitarbeiter Baustellen Zuordnung
-- ==================================

CREATE TABLE IF NOT EXISTS public.baustellen_mitarbeiter (

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    company_id UUID NOT NULL
    REFERENCES public.companies(id)
    ON DELETE CASCADE,

    baustelle_id UUID NOT NULL
    REFERENCES public.baustellen(id)
    ON DELETE CASCADE,

    mitarbeiter_id UUID NOT NULL
    REFERENCES public.profiles(id)
    ON DELETE CASCADE,

    rolle TEXT DEFAULT 'mitarbeiter',

    created_at TIMESTAMPTZ DEFAULT NOW()

);

-- ==========================================
-- Row Level Security
-- ==================================

ALTER TABLE public.baustellen_dokumente ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.baustellen_checklisten ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.baustellen_maengel ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.baustellen_mitarbeiter ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Tenant isolation dokumente"
ON public.baustellen_dokumente
FOR ALL
USING (
    company_id = (
        SELECT company_id
        FROM public.profiles
        WHERE id = auth.uid()
    )
);

CREATE POLICY "Tenant isolation checklist"
ON public.baustellen_checklisten
FOR ALL
USING (
    company_id = (
        SELECT company_id
        FROM public.profiles
        WHERE id = auth.uid()
    )
);

CREATE POLICY "Tenant isolation maengel"
ON public.baustellen_maengel
FOR ALL
USING (
    company_id = (
        SELECT company_id
        FROM public.profiles
        WHERE id = auth.uid()
    )
);

CREATE POLICY "Tenant isolation mitarbeiter"
ON public.baustellen_mitarbeiter
FOR ALL
USING (
    company_id = (
        SELECT company_id
        FROM public.profiles
        WHERE id = auth.uid()
    )
);
