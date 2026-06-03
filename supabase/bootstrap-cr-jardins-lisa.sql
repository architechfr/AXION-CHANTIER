-- =============================================================================
--  AXION — Bootstrap des 48 comptes-rendus « Les Jardins de Lisa »
--  Source : OneDrive synchronisé f.clarisse, dossier FRANCE-PIERRE/CR/PDF/
--  Idempotent : NOT EXISTS sur (project_id, file_path) — relançable sans risque,
--  les CR déjà présents en base sont ignorés silencieusement.
--
--  URLs : construites vers OneDrive personnel f.clarisse. Fonctionnelles pour
--  l'admin tout de suite ; pour les partenaires, activer le partage du dossier
--  /CR/PDF/ en « Tout le monde, sans connexion » une fois sur SharePoint.
--
--  Pré-requis : projet « Les Jardins de Lisa » avec slug='jardins-lisa'.
-- =============================================================================

WITH proj AS (SELECT id FROM public.projects WHERE slug = 'jardins-lisa' LIMIT 1),
src AS (
  SELECT proj.id AS project_id, t.title, t.url, t.dt::timestamptz AS dt
  FROM proj, (VALUES
   ('CR n°00 — 19 mars 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR00.pdf', '2025-03-19 18:32+02')
  ,('CR n°01 — 1er avril 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR01.pdf', '2025-04-01 09:35+02')
  ,('CR n°02 — 4 avril 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR02.pdf', '2025-04-04 13:12+02')
  ,('CR n°03 — 10 avril 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR03.pdf', '2025-04-10 17:58+02')
  ,('CR n°05 — 5 mai 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR05.pdf', '2025-05-05 14:57+02')
  ,('CR n°06 — 19 mai 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR06.pdf', '2025-05-19 15:15+02')
  ,('CR n°07 — 5 juin 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR07.pdf', '2025-06-05 17:20+02')
  ,('CR n°08 — 17 juin 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR08.pdf', '2025-06-17 10:07+02')
  ,('CR n°09 — 19 juin 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR09.pdf', '2025-06-19 11:13+02')
  ,('CR n°10 — 7 juillet 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR10.pdf', '2025-07-07 19:52+02')
  ,('CR n°11 — 15 juillet 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR11.pdf', '2025-07-15 16:18+02')
  ,('CR n°12 — 18 juillet 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR12.pdf', '2025-07-18 15:44+02')
  ,('CR n°13 — 25 juillet 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR13.pdf', '2025-07-25 17:37+02')
  ,('CR n°14 — 25 août 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR14.pdf', '2025-08-25 17:57+02')
  ,('CR n°15 — 29 août 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR15.pdf', '2025-08-29 16:52+02')
  ,('CR n°16 — 5 septembre 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR16.pdf', '2025-09-05 17:05+02')
  ,('CR n°17 — 15 septembre 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR17.pdf', '2025-09-15 17:27+02')
  ,('CR n°18 — 30 septembre 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR18.pdf', '2025-09-30 09:38+02')
  ,('CR n°19 — 7 octobre 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR19.pdf', '2025-10-07 14:46+02')
  ,('CR n°20 — 13 octobre 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR20.pdf', '2025-10-13 14:51+02')
  ,('CR n°21 — 17 octobre 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR21.pdf', '2025-10-17 17:19+02')
  ,('CR n°22 — 27 octobre 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR22.pdf', '2025-10-27 16:07+02')
  ,('CR n°23 — 30 octobre 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR23.pdf', '2025-10-30 10:36+02')
  ,('CR n°24 — 17 novembre 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR24.pdf', '2025-11-17 16:32+02')
  ,('CR n°25 — 24 novembre 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR25.pdf', '2025-11-24 12:41+02')
  ,('CR n°26 — 1er décembre 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR26.pdf', '2025-12-01 15:14+02')
  ,('CR n°27 — 5 décembre 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR27.pdf', '2025-12-05 17:16+02')
  ,('CR n°28 — 12 décembre 2025', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR28.pdf', '2025-12-12 15:30+02')
  ,('CR n°29 — 12 janvier 2026', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR29.pdf', '2026-01-12 15:04+02')
  ,('CR n°30 — 19 janvier 2026', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR30.pdf', '2026-01-19 12:04+02')
  ,('CR n°31 — 28 janvier 2026', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR31.pdf', '2026-01-28 10:24+02')
  ,('CR n°32 — 30 janvier 2026', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR32.pdf', '2026-01-30 16:47+02')
  ,('CR n°33 — 6 février 2026', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR33.pdf', '2026-02-06 14:35+02')
  ,('CR n°34 — 16 février 2026', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR34.pdf', '2026-02-16 12:55+02')
  ,('CR n°35 — 24 février 2026', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR35.pdf', '2026-02-24 09:56+02')
  ,('CR n°36 — 2 mars 2026', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR36.pdf', '2026-03-02 12:55+02')
  ,('CR n°37 — 6 mars 2026', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR37.pdf', '2026-03-06 17:14+02')
  ,('CR n°38 — 13 mars 2026', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR38.pdf', '2026-03-13 09:51+02')
  ,('CR n°39 — 20 mars 2026', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR39.pdf', '2026-03-20 11:05+02')
  ,('CR n°40 — 27 mars 2026', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR40.pdf', '2026-03-27 17:26+02')
  ,('CR n°41 — 10 avril 2026', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR41.pdf', '2026-04-10 14:56+02')
  ,('CR n°42 — 20 avril 2026', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR42.pdf', '2026-04-20 17:44+02')
  ,('CR n°43 — 27 avril 2026', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR43.pdf', '2026-04-27 17:24+02')
  ,('CR n°44 — 29 avril 2026', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR44.pdf', '2026-04-29 17:54+02')
  ,('CR n°45 — 7 mai 2026', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR45.pdf', '2026-05-07 16:15+02')
  ,('CR n°46 — 13 mai 2026', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR46.pdf', '2026-05-13 18:55+02')
  ,('CR n°47 — 22 mai 2026', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR47.pdf', '2026-05-22 15:30+02')
  ,('CR n°48 — 1er juin 2026', 'https://cadencearchitectes-my.sharepoint.com/personal/f_clarisse_cadence-architectes_fr/Documents/FRANCE-PIERRE/Jardins%20de%20Lisa%20-HF/CR/PDF/Les%20Jardins%20de%20Lisa%20-%20OZOIR%20LA%20FERRIERE%20CR48.pdf', '2026-06-01 09:40+02')
  ) AS t(title, url, dt)
)
INSERT INTO public.documents (project_id, title, file_path, category, created_at)
SELECT src.project_id, src.title, src.url, 'Compte-rendu', src.dt
FROM src
WHERE NOT EXISTS (
  SELECT 1 FROM public.documents d
  WHERE d.project_id = src.project_id AND d.file_path = src.url
);

-- Vérification (à exécuter ensuite si vous voulez) :
-- SELECT count(*) AS nb_cr FROM public.documents d
--  JOIN public.projects p ON p.id = d.project_id
--  WHERE p.slug='jardins-lisa' AND d.category='Compte-rendu';
