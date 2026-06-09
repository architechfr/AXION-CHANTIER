-- ============================================================================
-- AXION — Suivi carbone collaboratif (Phase 1)
-- À exécuter dans Supabase → SQL Editor (projet phfdrgvdfhwtyycxpahq).
-- IDEMPOTENT : relançable sans casse.
--
-- Phase 1 (étagée) : données en base + partagées.
--   • Lecture : tout utilisateur authentifié QUI VOIT le chantier (RLS projects
--     s'applique au sous-select) → cloisonnement par chantier respecté.
--   • Écriture : MOE / admin uniquement.
--   • La « vue entreprise » (filtre par lot) est gérée côté front pour la démo.
-- Phase 2 (plus tard, avec le rôle `partner`) : écriture stricte par entreprise
--   limitée à son lot (policy à ajouter sur carbon_products).
-- ============================================================================

-- 1) Objectif + SDP par chantier ---------------------------------------------
create table if not exists public.carbon_settings (
  project_id  uuid primary key references public.projects(id) on delete cascade,
  obj_kg_m2   numeric,           -- objectif carbone de l'opération (kg CO2 / m² SDP)
  sdp         numeric,           -- surface de plancher retenue pour le calcul
  updated_by  uuid default auth.uid(),
  updated_at  timestamptz not null default now()
);

-- 2) Produits réellement posés (le cumul) ------------------------------------
create table if not exists public.carbon_products (
  id              uuid primary key default gen_random_uuid(),
  project_id      uuid not null references public.projects(id) on delete cascade,
  lot             text,
  company_id      uuid references public.companies(id) on delete set null,
  designation     text not null,
  quantity        numeric not null default 1,
  unit            text,
  kg_co2_per_unit numeric not null default 0,   -- depuis fiche FDES/PEP
  source          text,
  created_by      uuid default auth.uid(),
  created_at      timestamptz not null default now()
);
create index if not exists carbon_products_project_idx on public.carbon_products(project_id);

-- 3) Base produits réutilisable, PARTAGÉE entre chantiers --------------------
create table if not exists public.carbon_catalog (
  id              uuid primary key default gen_random_uuid(),
  designation     text not null,
  unit            text,
  kg_co2_per_unit numeric not null default 0,
  lot             text,
  source          text,
  updated_by      uuid default auth.uid(),
  updated_at      timestamptz not null default now()
);
create unique index if not exists carbon_catalog_des_uidx
  on public.carbon_catalog (lower(btrim(designation)));

-- 4) RLS ---------------------------------------------------------------------
alter table public.carbon_settings enable row level security;
alter table public.carbon_products enable row level security;
alter table public.carbon_catalog  enable row level security;

-- Lecture : scoppée aux chantiers visibles (la RLS de projects filtre le sous-select)
drop policy if exists carbon_settings_read on public.carbon_settings;
create policy carbon_settings_read on public.carbon_settings for select to authenticated
  using (exists (select 1 from public.projects p where p.id = carbon_settings.project_id));

drop policy if exists carbon_products_read on public.carbon_products;
create policy carbon_products_read on public.carbon_products for select to authenticated
  using (exists (select 1 from public.projects p where p.id = carbon_products.project_id));

-- Le catalogue est global (réutilisable tous chantiers) : lecture pour tout authentifié
drop policy if exists carbon_catalog_read on public.carbon_catalog;
create policy carbon_catalog_read on public.carbon_catalog for select to authenticated using (true);

-- Écriture : MOE / admin (même motif que project_contacts, pas de récursion)
drop policy if exists carbon_settings_write on public.carbon_settings;
create policy carbon_settings_write on public.carbon_settings for all to authenticated
  using      (exists (select 1 from public.user_profiles up where up.id = auth.uid() and up.role in ('admin','moe')))
  with check (exists (select 1 from public.user_profiles up where up.id = auth.uid() and up.role in ('admin','moe')));

drop policy if exists carbon_products_write on public.carbon_products;
create policy carbon_products_write on public.carbon_products for all to authenticated
  using      (exists (select 1 from public.user_profiles up where up.id = auth.uid() and up.role in ('admin','moe')))
  with check (exists (select 1 from public.user_profiles up where up.id = auth.uid() and up.role in ('admin','moe')));

drop policy if exists carbon_catalog_write on public.carbon_catalog;
create policy carbon_catalog_write on public.carbon_catalog for all to authenticated
  using      (exists (select 1 from public.user_profiles up where up.id = auth.uid() and up.role in ('admin','moe')))
  with check (exists (select 1 from public.user_profiles up where up.id = auth.uid() and up.role in ('admin','moe')));

-- ============================================================================
-- Vérifs :
--   select * from public.carbon_settings;
--   select lot, designation, quantity, unit, kg_co2_per_unit from public.carbon_products;
--   select count(*) from public.carbon_catalog;
-- ============================================================================
