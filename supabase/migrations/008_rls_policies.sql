CREATE POLICY "company isolation baustellen"

ON public.baustellen

FOR ALL

USING (

company_id =
(
SELECT company_id
FROM public.profiles
WHERE id = auth.uid()
)

);
