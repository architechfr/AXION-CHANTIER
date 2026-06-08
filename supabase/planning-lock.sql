-- ═══════════════════════════════════════════════════════════
-- VERROU « PLANNING VALIDÉ » — empêche la régénération accidentelle
-- ───────────────────────────────────────────────────────────
-- Quand le MOE/admin est satisfait d'un planning (validé avec les
-- entreprises et la MOA), il le VERROUILLE depuis la fiche chantier.
-- Effet : le bouton « Régénérer » disparaît et le configurateur refuse
-- d'écraser le snapshot. Réversible (« Déverrouiller ») à tout moment.
-- À exécuter une fois dans l'éditeur SQL Supabase.
-- ═══════════════════════════════════════════════════════════
alter table public.projects
  add column if not exists planning_locked boolean not null default false;

-- (optionnel) verrouiller tout de suite un planning déjà validé, ex. Lisa :
-- update public.projects set planning_locked = true where slug = 'jardins-de-lisa';

-- vérif : select slug, planning_locked from public.projects order by name;
