-- ============================================================================
-- AXION — Bootstrap chantier « Les Villages d'Or - Noisy » (Noisy-le-Grand)
-- Source : e-mail Oscar Pénarette du 09/06/2026 (chantier Noisy M6.2).
-- À exécuter dans Supabase → SQL Editor (projet phfdrgvdfhwtyycxpahq), role postgres.
-- IDEMPOTENT : relançable sans créer de doublons.
--
-- Portée : COQUILLE + 4 documents par défaut (Plans de vente, Notice, DWG, PDF).
-- Adresse exacte / MOA / programme (logements, SDP, livraison) à enrichir plus tard.
-- Cover : déposer l'image sur  assets/img/cover-villages-or-noisy.png
--         (convention reprise automatiquement par app.html et chantier.html).
-- ============================================================================

-- 1) PROJET -------------------------------------------------------------------
insert into public.projects
  (name, slug, status, mission, location)
select
  'Les Villages d''Or - Noisy','villages-or-noisy','Chantier en cours',
  'MOE d''exécution','Noisy-le-Grand (93)'
where not exists (select 1 from public.projects where slug = 'villages-or-noisy');

-- 2) DOCUMENTS PAR DÉFAUT ------------------------------------------------------
-- Liens vers les DOSSIERS SharePoint (partage « c.havet »). Catégories alignées
-- sur le routage de chantier.html :
--   'Vente'         -> onglet Plan de vente
--   'Notice notaire'-> onglet Notice notaire
--   'DWG' / 'PDF'   -> onglet Plans & EXE
-- Idempotent : NOT EXISTS sur (project_id, file_path).
with proj as (select id from public.projects where slug = 'villages-or-noisy' limit 1),
src as (
  select proj.id as project_id, t.title, t.url, t.category
  from proj, (values
    ('Plans de vente','Vente',
     'https://cadencearchitectes-my.sharepoint.com/:f:/g/personal/c_havet_cadence-architectes_fr/IgCPte-00Q-sQoZEklLRI1UsAfc55YM8WikH-RmCBJS4VsQ?e=Uo6w3E'),
    ('Notice descriptive','Notice notaire',
     'https://cadencearchitectes-my.sharepoint.com/:f:/g/personal/c_havet_cadence-architectes_fr/IgBQmg_65LS2RLQfpsmbp24-AdS5sIY9zMzWQoHZF4iwvn8?e=ZfogxE'),
    ('Plans EXE — DWG','DWG',
     'https://cadencearchitectes-my.sharepoint.com/:f:/g/personal/c_havet_cadence-architectes_fr/IgChVmTVVP5PSZsmw5avc2oyAdQ6OryM2Ef83ooQ86vigeI?e=hsF5e0'),
    ('Plans EXE — PDF','PDF',
     'https://cadencearchitectes-my.sharepoint.com/:f:/g/personal/c_havet_cadence-architectes_fr/IgDKoEIIuwe2T6O9f5XptyTQAU4rkgX5mwzuEEU6azVejBQ?e=VQj1bV')
  ) as t(title, category, url)
)
insert into public.documents (project_id, title, file_path, category)
select src.project_id, src.title, src.url, src.category
from src
where not exists (
  select 1 from public.documents d
  where d.project_id = src.project_id and d.file_path = src.url
);

-- ============================================================================
-- Vérifications post-exécution :
--   select name, slug, status, location from public.projects where slug='villages-or-noisy';
--   select title, category, file_path from public.documents
--     where project_id=(select id from public.projects where slug='villages-or-noisy')
--     order by category;                                                       -- attendu : 4 lignes
-- ============================================================================
