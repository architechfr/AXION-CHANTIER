-- =============================================================================
--  AXION — AUDIT DES COMPTES (LECTURE SEULE)
--  ⚠️ NE MODIFIE RIEN. Aucun INSERT/UPDATE/DDL. Comptes & rôles déjà en place.
--     Ce fichier ne contient que des requêtes d'inspection (SELECT).
--
--  Modèle de rôles : 'admin' (archi.tech.fr@gmail.com) · 'user' (entreprises).
-- =============================================================================

-- 1) Liste des profils et de leur rôle
select email, role, company_id, full_name
from public.user_profiles
order by role, email;

-- 2) L'admin principal est-il bien admin ?
select email, role
from public.user_profiles
where email = 'archi.tech.fr@gmail.com';

-- 3) Répartition des rôles (doit ne contenir que 'admin' et 'user')
select role, count(*) as nb
from public.user_profiles
group by role
order by role;

-- 4) Entreprises et rattachement des utilisateurs
select c.name as entreprise, c.trade, count(up.id) as nb_utilisateurs
from public.companies c
left join public.user_profiles up on up.company_id = c.id
group by c.id, c.name, c.trade
order by c.name;

-- 5) Affectation des entreprises aux chantiers
select p.name as chantier, p.slug, c.name as entreprise
from public.project_companies pc
join public.projects p  on p.id = pc.project_id
join public.companies c on c.id = pc.company_id
order by p.name, c.name;
