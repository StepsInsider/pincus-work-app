CREATE POLICY "Users can read own profile"
ON public.profiles
FOR SELECT
USING (
  id = auth.uid()
);
