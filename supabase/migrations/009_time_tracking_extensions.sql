ALTER TABLE public.arbeitszeiten
ADD COLUMN IF NOT EXISTS leistung_typ TEXT;


CREATE INDEX IF NOT EXISTS idx_arbeitszeiten_leistung_typ
ON public.arbeitszeiten(leistung_typ);
