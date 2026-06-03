-- =============================================================================
--  AXION — Activation de la RLS (étape 1 / cloisonnement multi-tenant)
--  Date : 2026-06-04
--
--  Pré-requis vérifiés :
--    - admins ont déjà admins_can_do_everything_* (ALL) sur toutes les tables
--    - non-admins ont déjà SELECT via :
--        projects        · projects_select    → is_admin() OR is_member(id)
--                        · company_users_can_read_assigned_projects (JOIN)
--        project_members · pm_select          → is_admin() OR is_member(project_id)
--        user_profiles   · up_self_read       → id = auth.uid()
--        documents       · documents_select   (cf. audit)
--                        · company_users_can_read_common_and_own_documents
--        planning_tasks  · (policy SELECT à vérifier après bascule)
--
--  Donc activer la RLS NE CASSE PAS l'accès des comptes existants :
--    - les 4 admins gardent tout
--    - les non-admins (à créer) verront via les policies SELECT déjà posées
--
--  Idempotent : ENABLE ROW LEVEL SECURITY ne plante pas si déjà activée.
-- =============================================================================

ALTER TABLE public.projects        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.planning_tasks  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.project_members ENABLE ROW LEVEL SECURITY;

-- =============================================================================
--  ROLLBACK (si un compte non-admin a un accès cassé après création)
--  À exécuter table par table selon le besoin.
-- =============================================================================
-- ALTER TABLE public.projects        DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.documents       DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.planning_tasks  DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.project_members DISABLE ROW LEVEL SECURITY;
