CREATE TABLE public.profiles (

id UUID PRIMARY KEY
REFERENCES auth.users(id)
ON DELETE CASCADE,

company_id UUID
REFERENCES public.companies(id)
ON DELETE CASCADE,


first_name TEXT NOT NULL,

last_name TEXT NOT NULL,


role TEXT NOT NULL DEFAULT 'employee',


created_at TIMESTAMPTZ DEFAULT NOW()

);


ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
