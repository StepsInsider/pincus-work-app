insert into storage.buckets (id, name, public)
values ('lead-photos', 'lead-photos', false)
on conflict (id) do nothing;

-- Uploads are intentionally not granted to anon/authenticated clients.
-- The Netlify lead function uses the Supabase service role to upload files.
