CREATE TABLE public.baustellen (

id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

company_id UUID NOT NULL
REFERENCES public.companies(id)
ON DELETE CASCADE,


title TEXT NOT NULL,


client_name TEXT NOT NULL,


address TEXT NOT NULL,


status TEXT DEFAULT 'active',


latitude DOUBLE PRECISION,

longitude DOUBLE PRECISION,


budget NUMERIC(12,2),


start_date DATE,

end_date DATE,


created_at TIMESTAMPTZ DEFAULT NOW(),

updated_at TIMESTAMPTZ DEFAULT NOW()

);


ALTER TABLE public.baustellen ENABLE ROW LEVEL SECURITY;
