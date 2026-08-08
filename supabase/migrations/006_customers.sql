CREATE TABLE IF NOT EXISTS public.kunden (

    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    company_id UUID NOT NULL
    REFERENCES public.companies(id)
    ON DELETE CASCADE,

    name TEXT NOT NULL,

    contact_person TEXT,

    email TEXT,

    phone TEXT,

    address TEXT,

    notes TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),

    updated_at TIMESTAMPTZ DEFAULT NOW()

);


CREATE INDEX IF NOT EXISTS idx_kunden_company
ON public.kunden(company_id);


ALTER TABLE public.kunden ENABLE ROW LEVEL SECURITY;


CREATE POLICY "Tenant isolation kunden"

ON public.kunden

FOR ALL

USING (

    company_id = (
        SELECT company_id
        FROM public.profiles
        WHERE id = auth.uid()
    )

);
