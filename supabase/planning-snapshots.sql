-- =============================================================================
-- AXION — Snapshots de planning par chantier (Phase 2 — PRÉPARATION)
-- -----------------------------------------------------------------------------
-- But : stocker, par chantier, une COPIE publiée du snapshot ChantierFlow
--       (format /api/state, JSON) afin que le visualiseur multi-chantier (repo
--       Planning) la serve UNIQUEMENT aux utilisateurs autorisés sur ce chantier.
--
-- Principe (Piste 2) :
--   • La STRUCTURE reste maître côté ChantierFlow (cf. task_progress.sql, §9).
--   • Cette table ne contient qu'une copie publiée + horodatée du snapshot.
--   • Le CONTRÔLE D'ACCÈS = la RLS ci-dessous (par project_id). Pas de masquage
--     d'URL : un utilisateur non affecté au chantier ne reçoit aucune donnée.
--
-- ⚠️ NE PAS exécuter tel quel tout de suite : la policy d'accès dépend du modèle
--    de rôles cible (admin / moe / partner) qui n'est pas encore migré en base
--    (cf. CONTEXTE-PROJET.md §4 et §8). À finaliser EN MÊME TEMPS que la refonte
--    des rôles. Ce fichier fige le schéma et l'intention d'accès.
-- =============================================================================

-- 1) Table : un snapshot courant par projet.
create table if not exists public.planning_snapshots (
  project_id  uuid primary key references public.projects(id) on delete cascade,
  snapshot    jsonb       not null,           -- payload /api/state (chantierflow-snapshot)
  source_url  text,                           -- d'où vient le snapshot (traçabilité)
  updated_by  uuid references auth.users(id),
  updated_at  timestamptz not null default now()
);

alter table public.planning_snapshots enable row level security;

-- 2) Lecture : un utilisateur voit le snapshot d'un chantier si…
--    • il est admin, OU
--    • il est MOE Cadence (voit tous les chantiers Cadence), OU
--    • sa société est affectée à CE chantier (project_companies).
--
-- NB : s'appuie sur is_admin() (SECURITY DEFINER, déjà en place, sans récursion).
--      La branche « MOE » suppose le rôle 'moe' migré en base ; tant que le modèle
--      reste admin/user, n'activer que les branches admin + affectation société.
create policy "planning_snapshots_read"
  on public.planning_snapshots
  for select
  using (
    public.is_admin()
    or exists (
      select 1
        from public.user_profiles up
       where up.id = auth.uid()
         and up.role = 'moe'
    )
    or exists (
      select 1
        from public.project_companies pc
        join public.user_profiles up on up.id = auth.uid()
       where pc.project_id = planning_snapshots.project_id
         and pc.company_id = up.company_id
    )
  );

-- 3) Écriture (publication d'un snapshot) : admin + MOE uniquement.
create policy "planning_snapshots_write"
  on public.planning_snapshots
  for all
  using (
    public.is_admin()
    or exists (
      select 1 from public.user_profiles up
       where up.id = auth.uid() and up.role = 'moe'
    )
  )
  with check (
    public.is_admin()
    or exists (
      select 1 from public.user_profiles up
       where up.id = auth.uid() and up.role = 'moe'
    )
  );
