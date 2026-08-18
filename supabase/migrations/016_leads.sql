-- Marketing / website lead pipeline for Pincus Work.
-- Public website submits through create_public_lead(); internal users use tenant RLS.

create table if not exists public.leads (
  id uuid primary key default extensions.uuid_generate_v4(),
  company_id uuid not null references public.companies(id) on delete cascade,
  customer_id uuid references public.kunden(id) on delete set null,
  status text not null default 'neu' check (status in ('neu','kontakt','besichtigung','angebot','auftrag','abgeschlossen','verloren')),
  service text not null,
  city text,
  postcode text,
  address text,
  project_size text,
  desired_period text,
  description text,
  photo_urls text[] not null default '{}',
  contact_name text not null,
  phone text,
  email text,
  source text,
  landing_page text,
  campaign text,
  keyword text,
  gclid text,
  fbclid text,
  lead_score integer not null default 0 check (lead_score between 0 and 100),
  assigned_to uuid references auth.users(id) on delete set null,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_leads_company_status on public.leads(company_id, status);
create index if not exists idx_leads_company_created on public.leads(company_id, created_at desc);
create index if not exists idx_leads_source on public.leads(source);
create index if not exists idx_leads_landing_page on public.leads(landing_page);

alter table public.leads enable row level security;

drop policy if exists "Tenant isolation leads" on public.leads;
create policy "Tenant isolation leads"
on public.leads
for all
to authenticated
using (company_id = (select profiles.company_id from public.profiles where profiles.id = auth.uid()))
with check (company_id = (select profiles.company_id from public.profiles where profiles.id = auth.uid()));

create or replace function public.create_public_lead(payload jsonb)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  target_company uuid;
  new_lead uuid;
begin
  select id into target_company
  from public.companies
  where lower(name) = lower('Pincus Work')
  order by created_at nulls first
  limit 1;

  if target_company is null then
    raise exception 'Pincus company not configured';
  end if;

  if coalesce(trim(payload->>'contact_name'), '') = '' then
    raise exception 'contact_name is required';
  end if;

  if coalesce(trim(payload->>'service'), '') = '' then
    raise exception 'service is required';
  end if;

  insert into public.leads (
    company_id, status, service, city, postcode, address, project_size,
    desired_period, description, photo_urls, contact_name, phone, email,
    source, landing_page, campaign, keyword, gclid, fbclid, lead_score
  ) values (
    target_company,
    'neu',
    trim(payload->>'service'),
    nullif(trim(payload->>'city'), ''),
    nullif(trim(payload->>'postcode'), ''),
    nullif(trim(payload->>'address'), ''),
    nullif(trim(payload->>'project_size'), ''),
    nullif(trim(payload->>'desired_period'), ''),
    nullif(trim(payload->>'description'), ''),
    coalesce(array(select jsonb_array_elements_text(payload->'photo_urls')), '{}'),
    trim(payload->>'contact_name'),
    nullif(trim(payload->>'phone'), ''),
    nullif(trim(payload->>'email'), ''),
    nullif(trim(payload->>'source'), ''),
    nullif(trim(payload->>'landing_page'), ''),
    nullif(trim(payload->>'campaign'), ''),
    nullif(trim(payload->>'keyword'), ''),
    nullif(trim(payload->>'gclid'), ''),
    nullif(trim(payload->>'fbclid'), ''),
    greatest(0, least(100, coalesce((payload->>'lead_score')::integer, 0)))
  ) returning id into new_lead;

  return new_lead;
end;
$$;

revoke all on function public.create_public_lead(jsonb) from public;
grant execute on function public.create_public_lead(jsonb) to anon, authenticated;
