create table if not exists public.mitarbeiter (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  rolle text not null default 'Mitarbeiter',
  telefon text,
  status text not null default 'Aktiv',
  created_at timestamptz not null default now()
);

alter table public.mitarbeiter enable row level security;

drop policy if exists "Authenticated users can read employees"
on public.mitarbeiter;

create policy "Authenticated users can read employees"
on public.mitarbeiter
for select
to authenticated
using (true);

insert into public.mitarbeiter (name, rolle, telefon, status)
select
  'Marcel',
  'Garten- & Landschaftsbau',
  null,
  'Aktiv'
where not exists (
  select 1
  from public.mitarbeiter
  where name = 'Marcel'
);
