-- =============================================================================
--  AXION — AUDIT RLS (LECTURE SEULE)
--  ⚠️ NE MODIFIE RIEN. Aucun DDL, aucune création/suppression de policy.
--     Le schéma et les policies sont DÉJÀ EN PLACE et validés en production.
--     Ce fichier ne contient que des requêtes d'inspection (SELECT).
--
--  Modèle de rôles en vigueur : 'admin' (accès total) · 'user' (entreprise, RLS).
--  À exécuter dans Supabase → SQL Editor pour vérifier l'état courant.
-- =============================================================================

-- 1) RLS bien activée sur les 6 tables ?
select relname as table_name, relrowsecurity as rls_active
from pg_class
where relnamespace = 'public'::regnamespace
  and relname in ('user_profiles','companies','projects','project_companies','documents','planning_tasks')
order by relname;

-- 2) Inventaire des policies en place (par table, par commande)
select tablename, policyname, cmd, roles, qual is not null as has_using, with_check is not null as has_check
from pg_policies
where schemaname = 'public'
  and tablename in ('user_profiles','companies','projects','project_companies','documents','planning_tasks')
order by tablename, policyname;

-- 3) Fonctions utilitaires éventuelles (is_admin, auth_company_id…) si elles existent
select proname, prosecdef as security_definer
from pg_proc
where pronamespace = 'public'::regnamespace
  and proname in ('is_admin','auth_role','auth_company_id')
order by proname;

-- 4) Détection d'une éventuelle récursion : les policies de user_profiles
--    qui ré-interrogent user_profiles SANS passer par une fonction SECURITY DEFINER
--    sont à risque. On affiche leur expression pour contrôle visuel.
select policyname, cmd, pg_get_expr(polqual, polrelid) as using_expr
from pg_policy
join pg_class on pg_class.oid = pg_policy.polrelid
where pg_class.relname = 'user_profiles';
