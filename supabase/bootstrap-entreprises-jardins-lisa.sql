-- =============================================================================
--  AXION — Bootstrap des intervenants « Les Jardins de Lisa »
--  Source : Compte-rendu de chantier CR n°49 (03/06/2026) — tableau des intervenants.
--  Idempotent :
--    · colonnes ajoutées via ADD COLUMN IF NOT EXISTS
--    · entreprises insérées seulement si le nom n'existe pas déjà (lower(name))
--    · liaisons project_companies insérées seulement si absentes
--  Pré-requis : projet avec slug = 'jardins-de-lisa'.
--  À lancer dans Supabase → SQL Editor.
-- =============================================================================

-- 1) Enrichissement du schéma companies (annuaire = nom + corps d'état + contact)
alter table public.companies add column if not exists type         text;  -- moa | bailleur | moe | controle | sps | bet | entreprise
alter table public.companies add column if not exists lot          text;  -- n° de lot travaux (entreprises)
alter table public.companies add column if not exists contact_name text;
alter table public.companies add column if not exists email        text;
alter table public.companies add column if not exists phone        text;

-- 2) Insertion des intervenants + rattachement au chantier
with proj as (
  select id from public.projects where slug = 'jardins-de-lisa' limit 1
),
src(name, trade, type, lot, contact_name, email, phone) as (
  values
  -- ── Maîtrise d'ouvrage / partenaires ──────────────────────────────────────
   ('FRANCE PIERRE 2',              'Maîtrise d''ouvrage',          'moa',       null,   'Dany De Olivera',        'dany.deoliveira@france-pierre.fr',          '06 23 45 07 92')
  ,('PLURIAL NOVILIA',              'Bailleur social',              'bailleur',  null,   'Jordan Bouget',          'jordan.bouget@plurial.fr',                  '06 89 87 86 59')
  ,('CADENCE Architectes Associés', 'Maîtrise d''œuvre',            'moe',       null,   'Florian Clarisse',       'f.clarisse@cadence-architectes.fr',         '06 69 14 34 18')
  ,('SOCOTEC',                      'Bureau de contrôle · AMO NF Habitat', 'controle', null, 'Lucia Pestana Abreu', 'lucia.pestanaabreu@socotec.com',            '06 17 98 52 20')
  ,('C2-IMMOBILIER',                'Coordonnateur SPS',            'sps',       null,   'Laurent Thomas',         'clt.idf@yahoo.com',                         '06 24 17 29 47')
  ,('IGEOTEX',                      'Bureau d''étude de sol',       'bet',       null,   'Clovis Nguiessi',        'contact@igeotex.fr',                        '06 66 35 80 98')
  ,('CGP',                          'Bureau d''étude thermique',    'bet',       null,   'Christophe Renault',     'christophe.renault@cgp-ing.net',            '01 60 65 80 85')
  -- ── Entreprises de travaux (par lot) ──────────────────────────────────────
  ,('TT-TP',                        'Terrassement · VRD',           'entreprise','00',   'Thiago Ribeiro',         'contact@tt-tp.fr',                          '06 75 56 32 75')
  ,('AGZ',                          'Gros-œuvre',                   'entreprise','01',   'Daniel Pires',           'd.pires@agz-construction.com',              '06 48 96 53 32')
  ,('AJB ISOLATIONS',               'Flocage',                      'entreprise','01c',  'David Belhassen',        'isolations.ajb@orange.fr',                  '06 63 63 69 52')
  ,('LES TOITS D''ORIVANA',         'Étanchéité',                   'entreprise','02',   'Guillaume Zamo',         'g.zamo@lestoitsdorivana.com',               '06 70 53 03 52')
  ,('STRP',                         'Ravalement · Échafaudage',     'entreprise','03 / 17','Michael Tavares',      'm.tavares@strp.fr',                         '06 35 02 80 58')
  ,('SPCC',                         'Bardage extérieur',            'entreprise','04',   'Manuel Rodrigues',       'contact@spcc-sasu.fr',                      '06 29 64 54 92')
  ,('LCI CONCEPT',                  'Menuiseries extérieures',      'entreprise','05',   'Igor Cerjak',            'lci-concept@hotmail.com',                   '06 68 71 42 65')
  ,('SDP ENGINEERING',              'Serrurerie · Métallerie',      'entreprise','06',   'H. Lopes',               'h.lopes@sdp77.com',                         '06 84 99 88 01')
  ,('EPC',                          'Cloisons · Doublages · Plafonds','entreprise','08', 'Jean-Pierre Coelho',     'etsepc@gmail.com',                          '06 14 62 14 55')
  ,('EPC MENUISERIE',               'Menuiseries intérieures',      'entreprise','09',   'Filipe Mendes De Sousa', 'epc.menuiserie@gmail.com',                  '06 07 12 09 99')
  ,('DECORATION DE SOUSA',          'Revêtements de sols · Peinture','entreprise','11 / 12 / 13','Fernand De Sousa','sandrine.rabin@decoration-de-sousa.fr',     '01 43 86 30 00')
  ,('LED',                          'Électricité',                  'entreprise','14',   'Cristiano Cardoso',      'cardoso@led77.fr',                          '06 34 25 01 78')
  ,('APM',                          'Plomberie · CVC',              'entreprise','15',   'Jacques Dos Santos',     'j.dossantos@apm7.fr',                       '06 03 87 32 93')
  ,('SOVIDES',                      'Ascenseur',                    'entreprise','16',   'Paolo Manuel Luis',      'paul.luis@sovides.com',                     '01 60 35 36 20')
  ,('CRISTAL',                      'Porte de parking',             'entreprise',null,   'Alberto',                'travaux@cristalsas.fr',                     '01 43 89 38 82')
),
ins as (
  insert into public.companies (name, trade, type, lot, contact_name, email, phone)
  select s.name, s.trade, s.type, s.lot, s.contact_name, s.email, s.phone
  from src s
  where not exists (
    select 1 from public.companies c where lower(c.name) = lower(s.name)
  )
  returning id, name
),
resolved as (
  select c.id
  from public.companies c
  where exists (select 1 from src s where lower(s.name) = lower(c.name))
)
insert into public.project_companies (project_id, company_id)
select (select id from proj), r.id
from resolved r
where (select id from proj) is not null
  and not exists (
    select 1 from public.project_companies pc
    where pc.project_id = (select id from proj) and pc.company_id = r.id
  );

-- 3) Vérification rapide (optionnel)
-- select c.lot, c.name, c.trade, c.type, c.email
-- from public.companies c
-- join public.project_companies pc on pc.company_id = c.id
-- join public.projects p on p.id = pc.project_id and p.slug = 'jardins-de-lisa'
-- order by c.type, nullif(regexp_replace(coalesce(c.lot,'99'), '\D', '', 'g'), '')::int nulls last, c.name;
