-- =============================================================================
-- AXION — Lien planning PAR CHANTIER (Phase 1)
-- -----------------------------------------------------------------------------
-- But : supprimer le lien planning codé en dur (qui pointait Lisa pour TOUS les
--       chantiers) et le piloter par une colonne propre à chaque projet.
--
-- Comportement côté portail (chantier.html, onglet Planning) :
--   • planning_url renseigné → bouton « Ouvrir le planning (lecture seule) »
--   • planning_url vide/NULL → message « Planning en préparation pour ce chantier »
--
-- Forward-compatible Piste 2 : quand le visualiseur multi-chantier (repo Planning)
-- sera déployé, planning_url pourra pointer vers lui (handoff SSO + ?project=slug)
-- au lieu d'une URL live directe.
--
-- À exécuter dans Supabase → SQL Editor (projet phfdrgvdfhwtyycxpahq).
-- Idempotent : ré-exécutable sans effet de bord.
-- =============================================================================

-- 1) Colonne (nullable). select('*') la récupère automatiquement côté client.
alter table public.projects
  add column if not exists planning_url text;

-- 2) Les Jardins de Lisa conserve son planning live actuel (inchangé, lecture seule).
--    ⚠️ planning-lisa.vercel.app reste le planning LIVE public — NON touché.
update public.projects
   set planning_url = 'https://planning-lisa.vercel.app/?mode=lecteur'
 where slug = 'jardins-de-lisa';

-- 3) Les autres chantiers (Iris, Gueules Cassées…) restent à NULL pour l'instant
--    → ils afficheront « Planning en préparation » jusqu'à leur propre publication.

-- Vérification :
-- select slug, planning_url from public.projects order by name;
