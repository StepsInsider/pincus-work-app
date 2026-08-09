ALTER TABLE public.baustellen
    ADD COLUMN IF NOT EXISTS company_id UUID;

ALTER TABLE public.baustellen
    ADD COLUMN IF NOT EXISTS title TEXT;

ALTER TABLE public.baustellen
    ADD COLUMN IF NOT EXISTS client_name TEXT;

ALTER TABLE public.baustellen
    ADD COLUMN IF NOT EXISTS address TEXT;

ALTER TABLE public.baustellen
    ADD COLUMN IF NOT EXISTS budget NUMERIC(12,2);

ALTER TABLE public.baustellen
    ADD COLUMN IF NOT EXISTS start_date DATE;

ALTER TABLE public.baustellen
    ADD COLUMN IF NOT EXISTS end_date DATE;

ALTER TABLE public.baustellen
    ALTER COLUMN status SET DEFAULT 'active';

ALTER TABLE public.baustellen
    ADD CONSTRAINT baustellen_company_id_fkey
    FOREIGN KEY (company_id)
    REFERENCES public.companies(id)
    ON DELETE CASCADE;
