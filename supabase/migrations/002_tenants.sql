CREATE TABLE public.companies (

id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

name TEXT NOT NULL,

address TEXT,

phone TEXT,

email TEXT,

created_at TIMESTAMPTZ DEFAULT NOW(),

updated_at TIMESTAMPTZ DEFAULT NOW()

);


ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;
