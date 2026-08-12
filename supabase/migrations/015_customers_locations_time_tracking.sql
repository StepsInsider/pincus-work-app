create table if not exists public.standorte (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  kunden_id uuid not null references public.kunden(id) on delete cascade,
  name text not null,
  strasse text,
  plz text,
  ort text,
  latitude double precision,
  longitude double precision,
  notizen text,
  aktiv boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (company_id, kunden_id, name)
);

alter table public.baustellen
  add column if not exists standort_id uuid references public.standorte(id) on delete set null;

alter table public.zeiterfassung
  add column if not exists standort_id uuid references public.standorte(id) on delete set null;

alter table public.zeiterfassung
  alter column baustelle_id drop not null;

create index if not exists idx_standorte_company on public.standorte(company_id);
create index if not exists idx_standorte_kunden on public.standorte(kunden_id);
create index if not exists idx_baustellen_standort on public.baustellen(standort_id);
create index if not exists idx_zeiterfassung_standort on public.zeiterfassung(standort_id);

alter table public.standorte enable row level security;

drop policy if exists "Tenant isolation standorte" on public.standorte;
create policy "Tenant isolation standorte"
on public.standorte
for all
to authenticated
using (company_id = (select profiles.company_id from public.profiles where profiles.id = auth.uid()))
with check (company_id = (select profiles.company_id from public.profiles where profiles.id = auth.uid()));

insert into public.companies (name)
select 'Pincus Work'
where not exists (select 1 from public.companies);

with company as (
  select id from public.companies order by created_at nulls first limit 1
), kunden_seed(name) as (
  values
    ('Altenheim Dortmund (Dorstfeld/Huckarde)'),
    ('Altenheim Unna'),
    ('Altenheim Berkamen'),
    ('Beck'),
    ('Drea 63'),
    ('Drea 112'),
    ('Frau vom Brun'),
    ('Jonn weil'),
    ('Kieschoweit'),
    ('Lünen Garmen'),
    ('Meiwald'),
    ('Ochzen'),
    ('Peter Unger'),
    ('Rechtsanwalt'),
    ('Stein Unna'),
    ('Weber'),
    ('Werner'),
    ('Wickede')
)
insert into public.kunden (company_id, name, firmenname)
select company.id, kunden_seed.name, kunden_seed.name
from company cross join kunden_seed
where not exists (
  select 1 from public.kunden k
  where k.company_id = company.id and coalesce(k.name, k.firmenname, k.ansprechpartner) = kunden_seed.name
);

with company as (
  select id from public.companies order by created_at nulls first limit 1
), customer_locations(customer_name, location_name) as (
  values
    ('Altenheim Dortmund (Dorstfeld/Huckarde)', 'Dorstfeld/Huckarde'),
    ('Altenheim Unna', 'Altenheim Unna'),
    ('Altenheim Berkamen', 'Altenheim Berkamen'),
    ('Beck', 'Beck'),
    ('Drea 63', 'Drea 63'),
    ('Drea 112', 'Drea 112'),
    ('Frau vom Brun', 'Frau vom Brun'),
    ('Jonn weil', 'Jonn weil'),
    ('Kieschoweit', 'Kieschoweit'),
    ('Lünen Garmen', 'Lünen Garmen'),
    ('Meiwald', 'Meiwald'),
    ('Ochzen', 'Ochzen'),
    ('Peter Unger', 'Peter Unger'),
    ('Rechtsanwalt', 'Rechtsanwalt'),
    ('Stein Unna', 'Stein Unna'),
    ('Weber', 'Weber'),
    ('Werner', 'Werner'),
    ('Wickede', 'Wickede')
)
insert into public.standorte (company_id, kunden_id, name)
select company.id, k.id, cl.location_name
from company
join customer_locations cl on true
join public.kunden k on k.company_id = company.id and coalesce(k.name, k.firmenname, k.ansprechpartner) = cl.customer_name
where not exists (
  select 1 from public.standorte s
  where s.company_id = company.id and s.kunden_id = k.id and s.name = cl.location_name
);
