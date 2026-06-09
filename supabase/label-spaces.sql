-- ============================================================================
-- AXION — Espace « LABEL » : cloud par entreprise via liens OneDrive
-- À exécuter dans Supabase → SQL Editor (projet phfdrgvdfhwtyycxpahq).
-- IDEMPOTENT.
--
-- Modèle : un dossier OneDrive « LABEL » par chantier, avec :
--   • kind='lecture'    → lien LECTURE du dossier parent (AMO / MOE)
--   • kind='entreprise' → lien ÉDITION d'un sous-dossier (l'entreprise du lot)
-- AXION ne fait que STOCKER et PRÉSENTER les liens (les droits de partage sont
-- gérés dans OneDrive par la MOE — AXION ne touche jamais aux permissions).
--
-- Phase 1 : lecture pour les membres du chantier, écriture MOE/admin.
-- Phase 2 (rôle `partner`) : une entreprise ne verra QUE sa propre carte.
-- ============================================================================

create table if not exists public.label_spaces (
  id           uuid primary key default gen_random_uuid(),
  project_id   uuid not null references public.projects(id) on delete cascade,
  kind         text not null default 'entreprise',     -- 'entreprise' | 'lecture'
  company_id   uuid references public.companies(id) on delete set null,
  company_name text,                                    -- libellé société (affichage)
  lot          text,
  title        text,
  url          text not null,
  created_by   uuid default auth.uid(),
  created_at   timestamptz not null default now()
);
create index if not exists label_spaces_project_idx on public.label_spaces(project_id);

alter table public.label_spaces enable row level security;

-- Lecture : membres qui voient le chantier (RLS projects filtre le sous-select)
drop policy if exists label_spaces_read on public.label_spaces;
create policy label_spaces_read on public.label_spaces for select to authenticated
  using (exists (select 1 from public.projects p where p.id = label_spaces.project_id));

-- Écriture : MOE / admin
drop policy if exists label_spaces_write on public.label_spaces;
create policy label_spaces_write on public.label_spaces for all to authenticated
  using      (exists (select 1 from public.user_profiles up where up.id = auth.uid() and up.role in ('admin','moe')))
  with check (exists (select 1 from public.user_profiles up where up.id = auth.uid() and up.role in ('admin','moe')));

-- ============================================================================
-- Vérif : select kind, company_name, lot, url from public.label_spaces;
-- ============================================================================
