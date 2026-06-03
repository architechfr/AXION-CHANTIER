-- =============================================================================
--  AXION — Bootstrap des Notices descriptives « Les Jardins de Lisa »
--  Source : OneDrive synchronisé f.clarisse,
--    FRANCE-PIERRE/Jardins de Lisa -HF/03 - NOTICES DESCRIPTIVES/
--  Idempotent : NOT EXISTS sur (project_id, file_path) — relançable sans risque.
--  Pré-requis : projet « Les Jardins de Lisa » avec slug='jardins-de-lisa'.
--
--  2 « fonctions » : Accession + Social. Les V4 (2 fév. 2026) sont les versions
--  actives. Les V3 et anciens nommages sont des archives.
-- =============================================================================

WITH proj AS (SELECT id FROM public.projects WHERE slug = 'jardins-de-lisa' LIMIT 1),
src AS (
  SELECT proj.id AS project_id, t.title, t.url, t.dt::timestamptz AS dt
  FROM proj, (VALUES
   -- V4 actives (les notices de référence aujourd'hui)
   ('Notice Accession — V4',
    'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/03%20-%20NOTICES%20DESCRIPTIVES/LISA%20ACCESSION%20-%20V4.pdf',
    '2026-02-02 14:58+02')
  ,('Notice Social — V4',
    'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/03%20-%20NOTICES%20DESCRIPTIVES/LISA%20SOCIAL%20-%20V4.pdf',
    '2026-02-02 14:58+02')
   -- Archives : V3 récente (nom court)
  ,('Notice Accession — V3',
    'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/03%20-%20NOTICES%20DESCRIPTIVES/_Archives/LISA%20ACCESSION%20-%20V3.pdf',
    '2025-12-03 11:19+02')
   -- Archives : V3 ancien nommage (10 fév. 2025)
  ,('Notice Accession — V3 (ancien format)',
    'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/03%20-%20NOTICES%20DESCRIPTIVES/_Archives/Notice%20descriptive%20-%20OZOIR-LA-FERRIERE%20-%20LES%20JARDINS%20DE%20LISA%20-%20logements%20collectif%20Acession%20-%20V3.pdf',
    '2025-02-10 18:11+02')
  ,('Notice Social — V3 (ancien format)',
    'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/03%20-%20NOTICES%20DESCRIPTIVES/_Archives/Notice%20descriptive%20-%20OZOIR-LA-FERRIERE%20-%20LES%20JARDINS%20DE%20LISA%20-%20logements%20collectif%20Social%20-%20V3.pdf',
    '2025-02-10 18:11+02')
  ) AS t(title, url, dt)
)
INSERT INTO public.documents (project_id, title, file_path, category, created_at)
SELECT src.project_id, src.title, src.url, 'Notice notaire', src.dt
FROM src
WHERE NOT EXISTS (
  SELECT 1 FROM public.documents d
  WHERE d.project_id = src.project_id AND d.file_path = src.url
);
