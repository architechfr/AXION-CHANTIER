-- =============================================================================
--  AXION — AUDIT AVANT SOCLE MULTI-TENANT  (LECTURE SEULE, aucun DDL)
--  UNE SEULE requête → UN SEUL tableau (section | item | detail).
--  Coller dans Supabase → SQL Editor, cliquer Run, copier tout le résultat.
-- =============================================================================
select section, item, detail from (
  -- 1) Rôles réellement présents
  select '1·role'    as section, role as item, count(*)::text as detail
    from public.user_profiles group by role
  union all
  -- 2) Contrainte CHECK sur user_profiles.role (rôles autorisés aujourd'hui)
  select '2·contrainte', conname, pg_get_constraintdef(oid)
    from pg_constraint
    where conrelid = 'public.user_profiles'::regclass and contype = 'c'
  union all
  -- 3) RLS activée sur les tables cibles
  select '3·rls', relname, relrowsecurity::text
    from pg_class
    where relnamespace = 'public'::regnamespace
      and relname in ('user_profiles','companies','projects','project_companies',
                      'documents','planning_tasks','project_members','document_types')
  union all
  -- 4) Policies en place (avec leur expression)
  select '4·policy', tablename || ' / ' || policyname || ' [' || cmd || ']',
         left(coalesce(qual,'∅') || '   ||CHECK:: ' || coalesce(with_check,'∅'), 500)
    from pg_policies
    where schemaname = 'public'
      and tablename in ('user_profiles','companies','projects','project_companies',
                        'documents','planning_tasks')
  union all
  -- 5) Fonctions utilitaires déjà présentes
  select '5·fonction', proname, prosecdef::text
    from pg_proc
    where pronamespace = 'public'::regnamespace
      and proname in ('is_admin','account_role','auth_role','is_member','my_company','auth_company_id')
  union all
  -- 6) Colonnes réelles (pour brancher type/sensibilité/lot)
  select '6·colonne', table_name || '.' || column_name, data_type
    from information_schema.columns
    where table_schema = 'public'
      and table_name in ('documents','planning_tasks','projects','project_companies')
) q
order by section, item;
