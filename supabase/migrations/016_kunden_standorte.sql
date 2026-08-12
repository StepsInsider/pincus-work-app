-- ============================================================
-- PINCUS WORK
-- Kunden- und Standortverwaltung
-- Migration 016
-- ============================================================

create table if not exists public.kunden (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    aktiv boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create unique index if not exists kunden_name_unique
    on public.kunden (lower(name));

create table if not exists public.standorte (
    id uuid primary key default gen_random_uuid(),
    kunde_id uuid not null references public.kunden(id) on delete cascade,
    name text not null,
    adresse text,
    aktiv boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create unique index if not exists standorte_kunde_name_unique
    on public.standorte (kunde_id, lower(name));

alter table public.kunden enable row level security;
alter table public.standorte enable row level security;

drop policy if exists "kunden_authenticated_select"
    on public.kunden;

create policy "kunden_authenticated_select"
    on public.kunden
    for select
    to authenticated
    using (true);

drop policy if exists "kunden_authenticated_insert"
    on public.kunden;

create policy "kunden_authenticated_insert"
    on public.kunden
    for insert
    to authenticated
    with check (true);

drop policy if exists "kunden_authenticated_update"
    on public.kunden;

create policy "kunden_authenticated_update"
    on public.kunden
    for update
    to authenticated
    using (true)
    with check (true);

drop policy if exists "standorte_authenticated_select"
    on public.standorte;

create policy "standorte_authenticated_select"
    on public.standorte
    for select
    to authenticated
    using (true);

drop policy if exists "standorte_authenticated_insert"
    on public.standorte;

create policy "standorte_authenticated_insert"
    on public.standorte
    for insert
    to authenticated
    with check (true);

drop policy if exists "standorte_authenticated_update"
    on public.standorte;

create policy "standorte_authenticated_update"
    on public.standorte
    for update
    to authenticated
    using (true)
    with check (true);

-- ============================================================
-- KUNDEN
-- ============================================================

insert into public.kunden (name)
values
    ('Altenheim Dortmund'),
    ('Altenheim Unna'),
    ('Altenheim Berkamen'),
    ('Beck'),
    ('Drea'),
    ('Frau vom Brun'),
    ('Jonn weil'),
    ('Kieschoweit'),
    ('Lünen Garmen'),
    ('Meiwald'),
    ('Ochzen'),
    ('Peter Unger'),
    ('Rechtsanwalt'),
    ('Stein'),
    ('Weber'),
    ('Werner'),
    ('Wickede')
on conflict ((lower(name))) do nothing;

-- ============================================================
-- STANDORTE
-- ============================================================

insert into public.standorte (kunde_id, name)
select k.id, 'Dorstfeld/Huckarde'
from public.kunden k
where lower(k.name) = lower('Altenheim Dortmund')
and not exists (
    select 1
    from public.standorte s
    where s.kunde_id = k.id
      and lower(s.name) = lower('Dorstfeld/Huckarde')
);

insert into public.standorte (kunde_id, name)
select k.id, 'Drea 63'
from public.kunden k
where lower(k.name) = lower('Drea')
and not exists (
    select 1
    from public.standorte s
    where s.kunde_id = k.id
      and lower(s.name) = lower('Drea 63')
);

insert into public.standorte (kunde_id, name)
select k.id, 'Drea 112'
from public.kunden k
where lower(k.name) = lower('Drea')
and not exists (
    select 1
    from public.standorte s
    where s.kunde_id = k.id
      and lower(s.name) = lower('Drea 112')
);

insert into public.standorte (kunde_id, name)
select k.id, 'Unna'
from public.kunden k
where lower(k.name) = lower('Stein')
and not exists (
    select 1
    from public.standorte s
    where s.kunde_id = k.id
      and lower(s.name) = lower('Unna')
);

-- ============================================================
-- EINDEUTIGE EINTRÄGE ALS STANDARD-STANDORT ANLEGEN
-- ============================================================

insert into public.standorte (kunde_id, name)
select k.id, k.name
from public.kunden k
where not exists (
    select 1
    from public.standorte s
    where s.kunde_id = k.id
);

