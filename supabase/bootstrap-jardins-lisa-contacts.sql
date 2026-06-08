-- ============================================================================
-- AXION — Annuaire des intervenants « Les Jardins de Lisa » (Ozoir-la-Ferrière)
-- Source : CR n°49 du 03/06/2026 (CADENCE Architectes / France Pierre 2)
-- À exécuter dans Supabase → SQL Editor (role postgres). IDEMPOTENT.
-- project_id Lisa = 3e232eeb-b930-473e-abe3-faec79cd5bd5 (slug jardins-de-lisa)
-- ============================================================================

-- 1) Sociétés manquantes (les autres existent déjà via le bootstrap Iris) -------
insert into public.companies (name, trade)
select v.name, v.trade from (values
  ('TT-TP','Lot 00 · Terrassement / VRD'),
  ('AGZ','Lot 01 · Gros-Œuvre'),
  ('EPC','Lot 08 · Cloisons-Doublages-Plafonds'),
  ('PLURIAL NOVILIA','Bailleur social'),
  ('C2-IMMOBILIER','Coordonnateur SPS'),
  ('IGEOTEX','BET Sol (G2/G3)'),
  ('CGP','BET Thermique'),
  ('FRANCE PIERRE 2','Maîtrise d''ouvrage')
) as v(name, trade)
where not exists (select 1 from public.companies c where c.name = v.name);

-- 2) Liaison Lisa <-> entreprises ---------------------------------------------
insert into public.project_companies (project_id, company_id)
select p.id, c.id
from public.projects p
join public.companies c on c.name in (
  'TT-TP','AGZ','AJB ISOLATION','LES TOITS D''ORIVANA','STRP','SPCC','LCI CONCEPT',
  'SDP ENGINEERING','EPC','EPC MENUISERIE','DECORATION DE SOUSA','LED','APM','SOVIDES',
  'CRISTAL','SOCOTEC','C2-IMMOBILIER','IGEOTEX','CGP','FRANCE PIERRE 2','PLURIAL NOVILIA',
  'CADENCE Architectes Associés'
)
where p.slug = 'jardins-de-lisa'
  and not exists (select 1 from public.project_companies pc where pc.project_id = p.id and pc.company_id = c.id);

-- 3) Annuaire détaillé (project_contacts) — purge + recharge ------------------
delete from public.project_contacts
where project_id = (select id from public.projects where slug = 'jardins-de-lisa');

insert into public.project_contacts (project_id, role, lot, company, address, full_name, email, phone, sort_order)
select (select id from public.projects where slug = 'jardins-de-lisa'), v.* from (values
  ('MOA',null,'FRANCE PIERRE 2','12 rue des Prés de l''Hôpital, ZI des Graviers, 94194 Villeneuve-Saint-Georges','Dany De Oliveira','dany.deoliveira@france-pierre.fr','06 23 45 07 92',1),
  ('MOA',null,'FRANCE PIERRE 2',null,'Alexandra Coluccia','alexandra.coluccia@france-pierre.fr','01 43 86 30 33',2),
  ('MOA',null,'FRANCE PIERRE 2',null,'Maeva De Passos','maeva.depassos@france-pierre.fr',null,3),
  ('Bailleur social',null,'PLURIAL NOVILIA','2 Place Paul Jamot, CS 80017, 51723 Reims Cedex','Jordan Bouget','jordan.bouget@plurial.fr','06 89 87 86 59',4),
  ('MOE',null,'CADENCE Architectes Associés','16-18 rue Dubrunfaut, 75012 Paris','Florian Clarisse','f.clarisse@cadence-architectes.fr','06 69 14 34 18',5),
  ('MOE',null,'CADENCE Architectes Associés',null,'Camille Havet','c.havet@cadence-architectes.fr',null,6),
  ('MOE',null,'CADENCE Architectes Associés',null,'Oscar Pénarette','o.penarette@cadence-architectes.fr','07 68 41 48 32',7),
  ('Bureau de contrôle',null,'SOCOTEC','580 rue Georges Clémenceau, BP 1918, ZI de Vaux-le-Pénil, 77019 Melun Cedex','Lucia Pestana Abreu','lucia.pestanaabreu@socotec.com','06 17 98 52 20',8),
  ('AMO',null,'SOCOTEC — NF Habitat HQE',null,'Eleonora Brizio','eleonora.brizio@socotec.com','06 40 87 96 67',9),
  ('SPS',null,'C2-IMMOBILIER','31 rue Didot Saint-Léger, 91100 Corbeil-Essonnes','Laurent Thomas','clt.idf@yahoo.com','06 24 17 29 47',10),
  ('BET',null,'IGEOTEX — étude de sol','8 rue Maurice, 91160 Longjumeau','Clovis Nguiessi','contact@igeotex.fr','06 66 35 80 98',11),
  ('BET',null,'CGP — thermique','2 Ter rue René Cassin, 77000 Melun','Christophe Renault','christophe.renault@cgp-ing.net','01 60 65 80 85',12),
  ('Entreprise','00','TT-TP','20 av Clément Ader, 94420 Le Plessis-Trévise','Thiago Ribeiro','contact@tt-tp.fr','06 75 56 32 75',13),
  ('Entreprise','01','AGZ','2 Boulevard d''Arcole, 95290 L''Isle-Adam','Daniel Pires','d.pires@agz-construction.com','06 48 96 53 32',14),
  ('Entreprise','01c','AJB ISOLATION','67 rue d''Epluches, 95480 Pierrelaye','David Belhassen','isolations.ajb@orange.fr','06 63 63 69 52',15),
  ('Entreprise','02','LES TOITS D''ORIVANA','145 avenue Charles Rouxel, 77340 Pontault-Combault','Guillaume Zamo','g.zamo@lestoitsdorivana.com','06 70 53 03 52',16),
  ('Entreprise','03/17','STRP','180 rue de Savoie, 93410 Vaujours','Michael Tavares','m.tavares@strp.fr','06 35 02 80 58',17),
  ('Entreprise','04','SPCC','45 allée du Clos des Charmes, ZA Les Portes de la Forêt, 77090 Collégien','Manuel Rodrigues','contact@spcc-sasu.fr','06 29 64 54 92',18),
  ('Entreprise','05','LCI CONCEPT','11 allée des Thuyas, 77400 Thorigny-sur-Marne','Igor Cerjak','lci-concept@hotmail.com','06 68 71 42 65',19),
  ('Entreprise','06','SDP ENGINEERING','4-6 rue de l''Industrie, 77173 Chevry-Cossigny',null,'h.lopes@sdp77.com','06 84 99 88 01',20),
  ('Entreprise','08','EPC','145 avenue Charles Rouxel, 77340 Pontault-Combault','Jean-Pierre Coelho','etsepc@gmail.com','06 14 62 14 55',21),
  ('Entreprise','09','EPC MENUISERIE','145 avenue Charles Rouxel, 77340 Pontault-Combault','Filipe Mendes De Sousa','epc.menuiserie@gmail.com','06 07 12 09 99',22),
  ('Entreprise','11/12/13','DECORATION DE SOUSA','12 rue des prés de l''Hôpital, ZI des Graviers, 94194 Villeneuve-Saint-Georges','Fernand De Sousa','sandrine.rabin@decoration-de-sousa.fr','01 43 86 30 00',23),
  ('Entreprise','14','LED','15 rue Robert Schuman, 77330 Ozoir-la-Ferrière','Cristiano Cardoso','cardoso@led77.fr','06 34 25 01 78',24),
  ('Entreprise','15','APM','13 rue Robert Schuman, 77330 Ozoir-la-Ferrière','Jacques Dos Santos','j.dossantos@apm7.fr','06 03 87 32 93',25),
  ('Entreprise','16','SOVIDES','7 avenue James de Rothschild, 77164 Ferrières-en-Brie','Paolo Manuel Luis','paul.luis@sovides.com','01 60 35 36 20',26),
  ('Entreprise','Porte parking','CRISTAL','4 rue Aminata Traoré, 94460 Valenton','Alberto','travaux@cristalsas.fr','01 43 89 38 82',27)
) as v(role, lot, company, address, full_name, email, phone, sort_order);

-- Vérif : select count(*) from public.project_contacts
--   where project_id=(select id from public.projects where slug='jardins-de-lisa');  -- attendu 27
