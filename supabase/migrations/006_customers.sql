ALTER TABLE public.kunden
    ADD COLUMN IF NOT EXISTS company_id UUID;

ALTER TABLE public.kunden
    ADD COLUMN IF NOT EXISTS name TEXT;

ALTER TABLE public.kunden
    ADD COLUMN IF NOT EXISTS contact_person TEXT;

ALTER TABLE public.kunden
    ADD COLUMN IF NOT EXISTS phone TEXT;

ALTER TABLE public.kunden
    ADD COLUMN IF NOT EXISTS address TEXT;

ALTER TABLE public.kunden
    ADD COLUMN IF NOT EXISTS notes TEXT;

ALTER TABLE public.kunden
    ALTER COLUMN company_id SET NOT NULL;

ALTER TABLE public.kunden
    ADD CONSTRAINT kunden_company_id_fkey
    FOREIGN KEY (company_id)
    REFERENCES public.companies(id)
    ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_kunden_company
ON public.kunden(company_id);

ALTER TABLE public.kunden ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authentifizierte Benutzer haben Vollzugriff auf Kunden"
ON public.kunden;

DROP POLICY IF EXISTS "Authenticated users full access kunden"
ON public.kunden;

DROP POLICY IF EXISTS "Tenant isolation kunden"
ON public.kunden;

CREATE POLICY "Tenant isolation kunden"
ON public.kunden
FOR ALL
USING (
    company_id = (
        SELECT company_id
        FROM public.profiles
        WHERE id = auth.uid()
    )
)
WITH CHECK (
    company_id = (
        SELECT company_id
        FROM public.profiles
        WHERE id = auth.uid()
    )
);
