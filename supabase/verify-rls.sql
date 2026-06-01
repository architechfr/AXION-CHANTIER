-- =============================================================================
--  AXION — VÉRIFICATION DE L'ISOLEMENT RLS (LECTURE SEULE)
--  ⚠️ NE MODIFIE AUCUNE DONNÉE. Les tests tournent dans une transaction
--     systématiquement ROLLBACK ; ils ne contiennent que des SELECT.
--     On "devient" un utilisateur en simulant son JWT (auth.uid() lit
--     request.jwt.claims->>'sub'), puis on observe ce qu'il voit.
--
--  Modèle : 'admin' (voit tout) · 'user' (entreprise, périmètre RLS).
--  Tables : user_profiles, companies, projects, project_companies,
--           documents, planning_tasks.
-- =============================================================================

-- 0) Récupérer des UUID de test :
--    select id, email, role, company_id from public.user_profiles order by role;

-- =============================================================================
--  TEST A — un utilisateur 'user' ne voit QUE son périmètre
--  Remplacer :UID_USER par l'UUID d'un user_profiles.role = 'user'.
-- =============================================================================
begin;
  set local role authenticated;
  select set_config('request.jwt.claims',
    json_build_object('sub', ':UID_USER', 'role', 'authenticated')::text, true);

  select 'profils visibles (attendu = 1)'      as test, count(*) from public.user_profiles;
  select 'entreprises visibles (attendu = 1)'  as test, count(*) from public.companies;
  select 'chantiers visibles (les siens)'      as test, count(*) from public.projects;
  select 'liaisons visibles (les siennes)'     as test, count(*) from public.project_companies;
  select 'documents visibles'                  as test, count(*) from public.documents;
  select 'tâches planning visibles'            as test, count(*) from public.planning_tasks;
rollback;

-- =============================================================================
--  TEST B — étanchéité : aucune fuite vers une AUTRE entreprise
--  Remplacer :UID_USER (entreprise A). Les drapeaux doivent être false/NULL.
-- =============================================================================
begin;
  set local role authenticated;
  select set_config('request.jwt.claims',
    json_build_object('sub', ':UID_USER', 'role', 'authenticated')::text, true);

  -- aucun profil d'un autre utilisateur ne doit apparaître
  select 'FUITE profils ?' as test, bool_or(id <> auth.uid()) as fuite
  from public.user_profiles;

  -- aucune tâche d'un chantier non autorisé ne doit apparaître
  -- (toutes les tâches visibles doivent appartenir aux projets visibles)
  select 'FUITE tâches ?' as test,
         bool_or(project_id not in (select id from public.projects)) as fuite
  from public.planning_tasks;
rollback;

-- =============================================================================
--  TEST C — l'ADMIN voit tout
--  Remplacer :UID_ADMIN par l'UUID de archi.tech.fr@gmail.com.
-- =============================================================================
begin;
  set local role authenticated;
  select set_config('request.jwt.claims',
    json_build_object('sub', ':UID_ADMIN', 'role', 'authenticated')::text, true);

  select 'admin — profils'      as test, count(*) from public.user_profiles;
  select 'admin — entreprises'  as test, count(*) from public.companies;
  select 'admin — chantiers'    as test, count(*) from public.projects;
  select 'admin — documents'    as test, count(*) from public.documents;
  select 'admin — tâches'       as test, count(*) from public.planning_tasks;
rollback;

-- =============================================================================
--  Lecture des résultats :
--   TEST A : profils=1, entreprises=1, le reste = sous-ensemble autorisé
--   TEST B : fuite = false (ou NULL si 0 ligne) partout
--   TEST C : compteurs = totaux de chaque table
--  ⚠️ Le TEST B sur planning_tasks suppose une colonne project_id ; adapter
--     le nom si la table utilise une autre clé (ex. chantier_id).
-- =============================================================================
