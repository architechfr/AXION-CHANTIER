-- =============================================================================
-- AXION — Table de POINTAGE d'avancement (override par tâche du planning)
-- -----------------------------------------------------------------------------
-- But : permettre au MOE de pointer l'avancement (ex. « terminée ») DEPUIS AXION
--       sans toucher à la structure du planning ChantierFlow.
--
-- Principe (cf. mémoire axion-coherence-interactive / axion-planning-architecture) :
--   • La STRUCTURE du planning reste maître côté ChantierFlow (snapshot /api/state).
--   • Le POINTAGE devient maître côté AXION via cette table (override par task_uid).
--   • Statut effectif d'une tâche = task_progress.status si présent, sinon task.sts
--     du snapshot.
--
-- ⚠️ Vocabulaire des statuts ALIGNÉ sur ChantierFlow (et non en_cours/bloque) pour
--    que la fusion côté client soit une simple substitution de `sts` :
--      ns = non démarré · dn = terminé · ec = en cours · bl = bloqué
--    (V1 AXION n'écrit que 'dn' ; les autres sont prévus pour la suite.)
--
-- À exécuter dans Supabase → SQL Editor (projet phfdrgvdfhwtyycxpahq).
-- =============================================================================

create table if not exists public.task_progress (
  project_id uuid        not null references public.projects(id) on delete cascade,
  task_uid   text        not null,                       -- = task.uid du snapshot ChantierFlow
  status     text        not null check (status in ('ns','dn','ec','bl')),
  comment    text,                                       -- optionnel (UI à venir : « décalé pour intempéries »)
  updated_by uuid        references public.user_profiles(id) on delete set null,
  updated_at timestamptz not null default now(),
  primary key (project_id, task_uid)
);

comment on table public.task_progress is
  'Pointage d''avancement AXION : override du statut d''une tâche du planning ChantierFlow, par (project_id, task_uid).';

-- Lecture rapide de tous les pointages d''un chantier
create index if not exists task_progress_project_idx on public.task_progress (project_id);

-- -----------------------------------------------------------------------------
-- RLS : V1 = admin + MOE peuvent tout faire sur le pointage.
--   (Les comptes MOE bêta sont encore 'admin' en base ; on inclut 'moe' pour la
--    refonte de rôles à venir. moa / entreprise = restrictions à détailler plus tard.)
-- -----------------------------------------------------------------------------
alter table public.task_progress enable row level security;

drop policy if exists task_progress_moe_all on public.task_progress;
create policy task_progress_moe_all on public.task_progress
  for all
  to authenticated
  using (
    exists (
      select 1 from public.user_profiles up
      where up.id = auth.uid() and up.role in ('admin','moe')
    )
  )
  with check (
    exists (
      select 1 from public.user_profiles up
      where up.id = auth.uid() and up.role in ('admin','moe')
    )
  );
