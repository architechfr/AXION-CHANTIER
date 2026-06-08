-- ============================================================================
-- AXION — Bootstrap chantier « Les Jardins d'Iris » (Pontault-Combault)
-- Source : CR n°01 du 04/06/2026 (CADENCE Architectes / France Pierre)
-- À exécuter dans Supabase → SQL Editor (projet phfdrgvdfhwtyycxpahq), role postgres.
-- IDEMPOTENT : relançable sans créer de doublons.
-- ============================================================================

-- 1) PROJET -------------------------------------------------------------------
insert into public.projects
  (name, slug, status, description, address, moa, mission, units, units_detail, surface_unit, location)
select
  'Les Jardins d''Iris','jardins-iris','Chantier en cours',
  'Opération mixte · 5 bâtiments (cages A–E) · RE2020 · 1 local ERP',
  '15-23 avenue Jacques Heuclin, 77340 Pontault-Combault',
  'France Pierre (SCCV Le Domaine de Noémie)',
  'MOE d''exécution',
  '120','84 accession · 36 sociaux','m² SDP','Pontault-Combault (77)'
where not exists (select 1 from public.projects where slug = 'jardins-iris');

-- 2) ENTREPRISES & INTERVENANTS (table companies, partagée entre chantiers) ----
insert into public.companies (name, trade)
select v.name, v.trade from (values
  ('ROISSY TP','Lot 01a · Terrassement / VRD / Voiles contre terre'),
  ('MTR BATIMENT','Lot 01b · Gros-Œuvre'),
  ('AJB ISOLATION','Lot 01c · Flocage'),
  ('SPCC','Lots 02/03b/04b · Charpente bois / Couverture / Bardage'),
  ('LES TOITS D''ORIVANA','Lot 03a · Étanchéité'),
  ('STRP','Lot 04a · Ravalement'),
  ('LCI CONCEPT','Lot 05 · Menuiseries extérieures'),
  ('SDP ENGINEERING','Lot 06 · Serrurerie'),
  ('CRISTAL','Lot 07 · Porte de garage'),
  ('EPC MENUISERIE','Lots 08/09 · Cloisons-Doublages-Plafonds / Menuiseries int.'),
  ('DECORATION DE SOUSA','Lots 11/12/13 · Carrelage-Faïence / Sols souples / Peinture'),
  ('LED','Lot 14 · Électricité'),
  ('APM','Lots 15a/15b/15c · Plomberie / VMC / Chauffage Gaz-PAC'),
  ('SOVIDES','Lot 16 · Ascenseur / Motorisation portail'),
  ('SOCOTEC','Bureau de contrôle'),
  ('CLT IDF','Coordonnateur SPS'),
  ('France Pierre','Maîtrise d''ouvrage'),
  ('CADENCE Architectes Associés','Maîtrise d''œuvre')
) as v(name, trade)
where not exists (select 1 from public.companies c where c.name = v.name);

-- 3) LIAISON chantier <-> entreprises -----------------------------------------
insert into public.project_companies (project_id, company_id)
select p.id, c.id
from public.projects p
join public.companies c on c.name in (
  'ROISSY TP','MTR BATIMENT','AJB ISOLATION','SPCC','LES TOITS D''ORIVANA','STRP',
  'LCI CONCEPT','SDP ENGINEERING','CRISTAL','EPC MENUISERIE','DECORATION DE SOUSA',
  'LED','APM','SOVIDES','SOCOTEC','CLT IDF','France Pierre','CADENCE Architectes Associés'
)
where p.slug = 'jardins-iris'
  and not exists (
    select 1 from public.project_companies pc
    where pc.project_id = p.id and pc.company_id = c.id
  );

-- 4) ANNUAIRE DÉTAILLÉ DES INTERVENANTS (nouvelle table, par chantier) ---------
create table if not exists public.project_contacts (
  id          uuid primary key default gen_random_uuid(),
  project_id  uuid not null references public.projects(id) on delete cascade,
  role        text,          -- MOA · MOE · Bureau de contrôle · SPS · Entreprise
  lot         text,          -- code lot (01a, 01b, …) ou null
  company     text,
  address     text,
  full_name   text,
  email       text,
  phone       text,
  sort_order  int default 0,
  created_at  timestamptz not null default now()
);
alter table public.project_contacts enable row level security;
drop policy if exists project_contacts_moe_all on public.project_contacts;
create policy project_contacts_moe_all on public.project_contacts
  for all to authenticated
  using      (exists (select 1 from public.user_profiles up where up.id = auth.uid() and up.role in ('admin','moe')))
  with check (exists (select 1 from public.user_profiles up where up.id = auth.uid() and up.role in ('admin','moe')));

-- Purge + recharge des contacts d'Iris (idempotent)
delete from public.project_contacts
where project_id = (select id from public.projects where slug = 'jardins-iris');

insert into public.project_contacts (project_id, role, lot, company, address, full_name, email, phone, sort_order)
select (select id from public.projects where slug = 'jardins-iris'), v.*
from (values
  ('MOA',                null,         'SCCV Le Domaine de Noémie (France Pierre)','12 rue des Près de l''Hôpital, ZI des Graviers, 94194 Villeneuve-Saint-Georges','Carlos Gomes','carlos.gomes@france-pierre.fr','06 25 82 11 80', 1),
  ('MOA',                null,         'SCCV Le Domaine de Noémie (France Pierre)',null,'Maeva De Passos','maeva.depassos@france-pierre.fr',null, 2),
  ('MOE',                null,         'CADENCE Architectes Associés','16-18 rue Dubrunfaut, 75012 Paris','Pierre Depreux','p.depreux@cadence-architectes.fr','06 67 37 26 36', 3),
  ('MOE',                null,         'CADENCE Architectes Associés',null,'Oscar Pénarette','o.penarette@cadence-architectes.fr','07 58 41 48 32', 4),
  ('Bureau de contrôle', null,         'SOCOTEC','4 allée du Trait d''Union, 77127 Lieusaint','Lucia Pestana Abreu','lucia.pestanaabreu@socotec.com','06 17 98 52 20', 5),
  ('Bureau de contrôle', null,         'SOCOTEC',null,'Seydina Faye','seydina.faye@socotec.com','06 29 92 06 41', 6),
  ('SPS',                null,         'CLT IDF','31 rue Didot Saint-Léger, 91100 Corbeil-Essonnes','Laurent Thomas','clt.idf@yahoo.com','06 24 17 29 47', 7),
  ('Entreprise',         '01a',        'ROISSY TP','1 rue du Grand Puits, 95380 Villeron','Mickaël Roux','m.roux@roissy-tp.com','06 69 61 58 29', 8),
  ('Entreprise',         '01b',        'MTR BATIMENT','9 rue René Cassin, 77173 Chevry-Cossigny','Joffrey Touchard','j.touchard@mtrbatiment.com','06 79 30 96 87', 9),
  ('Entreprise',         '01c',        'AJB ISOLATION','67 rue d''Epluches, 95480 Pierrelaye',null,'isolations.ajb@orange.fr','01 30 31 32 51', 10),
  ('Entreprise',         '02/03b/04b', 'SPCC','44 allée du Clos des Charmes, ZA Les Portes de la Forêt, 77090 Collégien',null,'contact@spcc-sasu.fr','01 60 05 20 64', 11),
  ('Entreprise',         '03a',        'LES TOITS D''ORIVANA','145 avenue Charles Rouxel, 77340 Pontault-Combault','Guillaume Zamo','g.zamo@lestoitsdorivana.com','06 70 53 03 52', 12),
  ('Entreprise',         '04a',        'STRP','180 rue de Savoie, 93410 Vaujours','Philippe Domingues','contact@strp.fr','06 11 79 41 97', 13),
  ('Entreprise',         '05',         'LCI CONCEPT','11 allée des Thuyas, 77400 Thorigny-sur-Marne',null,'lci-concept@hotmail.com','06 68 71 42 65', 14),
  ('Entreprise',         '06',         'SDP ENGINEERING','4-6 rue de l''Industrie, 77173 Chevry-Cossigny',null,'sdp.beto@gmail.com','06 84 99 88 01', 15),
  ('Entreprise',         '07',         'CRISTAL','4 rue Aminata Traoré, 94460 Valenton',null,'commercial@cristalsas.fr','01 43 89 38 82', 16),
  ('Entreprise',         '08/09',      'EPC MENUISERIE','145 avenue Charles Rouxel, 77340 Pontault-Combault',null,'etsepc@gmail.com','01 60 34 69 00', 17),
  ('Entreprise',         '11/12/13',   'DECORATION DE SOUSA','12 rue des prés de l''Hôpital, ZI des Graviers, 94194 Villeneuve-Saint-Georges','Marie-Christine Campello','mc.campello@decoration-de-sousa.fr','01 43 86 30 00', 18),
  ('Entreprise',         '14',         'LED','15 rue Robert Schuman, 77330 Ozoir-la-Ferrière',null,'contact@led77.fr','01 64 40 69 65', 19),
  ('Entreprise',         '15a/15b/15c','APM','13 rue Robert Schuman, 77330 Ozoir-la-Ferrière','Jacques Dos Santos','j.dossantos@apm7.fr','01 60 34 42 93', 20),
  ('Entreprise',         '16',         'SOVIDES','7 avenue James de Rothschild, 77164 Ferrières-en-Brie','Cédric Louchart (ascenseur) · Philippe Da Silva (portail)','cedric.louchart@sovides.com','07 49 62 78 01', 21)
) as v(role, lot, company, address, full_name, email, phone, sort_order);

-- ============================================================================
-- Vérifications post-exécution :
--   select name, slug, moa from public.projects where slug='jardins-iris';
--   select count(*) from public.project_companies
--     where project_id=(select id from public.projects where slug='jardins-iris');   -- attendu : 18
--   select role, lot, company, full_name from public.project_contacts
--     where project_id=(select id from public.projects where slug='jardins-iris')
--     order by sort_order;                                                            -- attendu : 21
-- ============================================================================
