# 🏗️ AXION — Portail de pilotage de chantier · CADENCE Architectes

> **Source de vérité du projet.** Lire ce document AVANT toute action sur AXION.
> À mettre à jour à chaque décision structurante.

**Dernière mise à jour** : 10 juin 2026 · Florian Clarisse

---

## 1. Vision produit

> *« Le meilleur programme pour le suivi de chantier avec les entreprises et la maîtrise d'ouvrage. »*

Un seul endroit pour :
- **Planning** (lien CADENCE Flow)
- **Plans EXE** (PDF + DWG, hébergés sur SharePoint Cadence)
- **Comptes-rendus** (export Word → dossier SharePoint partagé)
- **Notices** descriptives
- **Plans de vente**

Pour : **MOE Cadence** → **Entreprises** sous-traitantes → **MOA** (et plus tard BET, bureaux de contrôle).

**Esprit** : architecture nocturne, matériaux nobles (bleu nuit + or + argent), géométrie épurée. Voir skill `axion-brand` pour la charte.

---

## 2. Stack & infrastructure

| Couche | Solution | URL / Référence |
|---|---|---|
| Portail (front) | HTML/Tailwind via CDN (pas de build) | https://axion-chantier.vercel.app |
| Auth + BDD + RLS | **Supabase** | projet ref `phfdrgvdfhwtyycxpahq` |
| Hébergement | **Vercel** (auto-deploy GitHub) | projet `axion-chantier` |
| Repo | **GitHub** | https://github.com/architechfr/AXION-CHANTIER |
| Docs (PDF/DWG) | **SharePoint OneDrive perso** Cadence | liens externes en BDD |
| Planning live | Vercel séparé (LIVE — **non touché**) | https://planning-lisa.vercel.app |
| Planning protégé (futur) | dossier local `AXION-PLANNING/` | pas encore déployé |
| Clé Supabase publique (anon) | `sb_publishable_GD32kGL-4Et4FEAAOQQrBQ_zClazT3V` | OK à mettre dans le client |

---

## 3. Modèle de données (Supabase, schéma `public`)

```
auth.users           ← géré par Supabase Auth
  └─ id (uuid), email, email_confirmed_at, …

user_profiles        ← profil métier
  └─ id (= auth.users.id), email, full_name, role, company_id

companies
  └─ id, name, trade, created_at
  ⚠️ il manque : type (à ajouter en Étape Refonte)

projects
  └─ id, name, slug, created_at
  + enrichis : status, description, address, moa, mission,
              units, units_detail, surface, surface_unit,
              budget, budget_unit, delivery, delivery_detail,
              location, cover_url

project_companies    ← table de liaison N:N (chantier ↔ entreprise)
  └─ project_id, company_id, created_at

documents
  └─ id, project_id, company_id, title (NOT NULL),
     file_path (NOT NULL), category, created_at, updated_at
```

**RLS** : activée sur les 4 tables principales. Une policy `up_self_read` permet à un user de lire SON propre profil. Une policy `admins_can_do_everything_*` utilise la fonction `is_admin()` SECURITY DEFINER (pas de récursion).

---

## 4. Modèle de rôles (refonte EN COURS — `moe` déjà actif en BDD)

| Rôle | Qui | Périmètre | Création |
|---|---|---|---|
| `admin` | `f.clarisse@cadence-architectes.fr` (1 seul) | Tout : gestion users, config, accès total | Manuel |
| `moe` | Tous les `@cadence-architectes.fr` (architectes + MOE Cadence) | Tous les chantiers Cadence en édition, peuvent inviter entreprises/BET/MOA sur LEURS chantiers | Lien d'invitation par admin (futur) |
| `partner` | Entreprises, BET, MOA, bureaux de contrôle | Uniquement leur(s) chantier(s) affecté(s) — sous-type via `companies.type` | Lien d'invitation par MOE/admin |
| `viewer` | Consultation pure (futur) | Lecture stricte | Lien d'invitation |

**État réel (vérifié 09/06/2026)** : le rôle `moe` existe et est **actif** en base — `c.havet` est `moe` (et non plus `admin`). **Constat RLS** : un compte `moe` **peut créer un projet** (`insert` sur `public.projects` autorisé) — vérifié en créant « Villages d'Or - Noisy » depuis la session `c.havet`. La migration admin/user → admin/moe/partner/viewer est donc partiellement faite. Reste à confirmer le rôle BDD réel des autres comptes.

---

## 5. Comptes utilisateurs créés (Supabase Auth)

| Email | Rôle BDD actuel | Rôle cible (refonte) | Status |
|---|---|---|---|
| `f.clarisse@cadence-architectes.fr` | admin | admin | ✅ actif, connecté |
| `c.havet@cadence-architectes.fr` | **moe** (vérifié 09/06) | moe | ✅ actif (bêta-test) |
| `o.penarette@cadence-architectes.fr` | admin | moe | ✅ actif (bêta-test) |
| `d.clarisse@cadence-architectes.fr` | admin | moe | ⚠️ **À CRÉER** (manuel, prochaine étape) |
| `p.depreux@cadence-architectes.fr` | — | moe | ❌ pas créé |
| `j.jaegle@cadence-architectes.fr` | — | moe | ❌ pas créé |
| `r.belabbassi@cadence-architectes.fr` | — | moe | ❌ pas créé |

**Mot de passe provisoire universel** : `Axion2026!` (à faire changer via Module 1).

---

## 6. Données métier en place

### Entreprise Cadence
- `companies` : *Cadence Architectes* · trade *Maîtrise d'œuvre*

### Chantier en ligne : Les Jardins de Lisa
- Slug : `jardins-de-lisa`
- Adresse : Rue Henri-François, 77330 Ozoir-la-Ferrière
- MOA : France Pierre · 150 logements (dont 83 sociaux) · 9 150 m² SDP · 15,6 M€ HT · livraison 2027
- Cover : `/assets/img/cover-lisa.png` (servie par Vercel)

### Documents Les Jardins de Lisa (5 catégories, liens SharePoint)
| Catégorie | Titre | Onglet de destination |
|---|---|---|
| PDF | Plans EXE — PDF (lecture seule) | Plans & EXE |
| DWG | Plans EXE — DWG (téléchargeable) | Plans & EXE |
| CR | Comptes-rendus de chantier | Comptes-rendus |
| Notice | Notices descriptives | Notice notaire |
| Vente | Plans de vente | Plan de vente |

### Chantier : Les Villages d'Or - Noisy  (✅ CRÉÉ EN BASE le 09/06/2026)
- Slug : `villages-or-noisy` · `projects.id` = `2f4691b5-1c78-4065-ad0a-dee35890327d`
- Localisation : Noisy-le-Grand (93) · réf. interne lot **M6.2** · Mission Cadence : MOE d'exécution
- MOA / programme (logements, SDP, livraison) : **à renseigner** (coquille volontairement légère)
- Cover : `/assets/img/cover-villages-or-noisy.png` (déployée Vercel, HTTP 200)
- Source : e-mail O. Pénarette du 09/06. **4 documents par défaut** = liens vers dossiers SharePoint (`:f:`) :
  Plans de vente (`Vente`) · Notice descriptive (`Notice notaire`) · Plans EXE DWG (`DWG`) · Plans EXE PDF (`PDF`). Pas encore de CR.
- **Création effectuée en base** via la session `c.havet` (rôle `moe`) — `insert` projet + 4 documents. Le script `supabase/bootstrap-villages-or-noisy.sql` est conservé comme **référence** (idempotent) ; inutile de le rejouer.

### Intervenants — SOURCE UNIQUE = table `project_contacts` (décision 06/06/2026)
> ⚠️ **DÉCISION (F. Clarisse, 06/06)** : deux sessions Claude ont traité les intervenants en parallèle → doublon. Tranché : la **table `project_contacts`** (annuaire PAR CHANTIER : `role, lot, company, address, full_name, email, phone, sort_order`) est la **seule source de vérité**. **NE PAS exécuter** `bootstrap-entreprises-jardins-lisa.sql` (enrichissement de `companies` = approche abandonnée — un même prestataire peut avoir lot/contact différents selon le chantier, donc ça ne peut pas vivre dans la table `companies` globale). Les colonnes `companies.lot/contact_name/email/phone` n'ont jamais été créées : ne pas les créer.
- **Affichage** : `chantier.html` onglet **Membres** (`loadAnnuaire`, groupé par rôle puis par société) + `entreprises.html` (fusionne les contacts depuis `project_contacts` par nom de société). RLS `project_contacts_moe_all` (admin+moe).
- **Méthode « CR → annuaire »** : tableau d'intervenants en tête de CR (`.docx` OU PDF) → extraction (`.docx` via regex `<w:t...>` sur `word/document.xml` ; PDF via PyMuPDF `fitz`) → bootstrap SQL `project_contacts` par chantier (`delete`+`insert`, idempotent). Données en base : Iris 21 contacts, Lisa 27. Fichiers : `bootstrap-jardins-iris.sql`, `bootstrap-jardins-lisa-contacts.sql` (NON committés — PII).
- ⚠️ **Écart données projet** : le CR n°49 indique **141 logements dont 79 sociaux · 8 750,50 m² SDP** (≠ 150/83/9 150 m² actuellement en base). À trancher avec la MOA avant de corriger la fiche projet.

---

## 7. Structure du repo `AXION-CHANTIER`

```
AXION-CHANTIER/
├── axion.html              ← landing publique (sans login)
├── metiers.html            ← roue des métiers publique (11 métiers → annuaire filtré)
├── login.html              ← page de connexion (split visuel)
├── reset.html              ← page de reset mot de passe (Module 1)
├── compte.html             ← page « Mon compte » (changer mdp)
├── app.html                ← dashboard post-login
├── chantier.html           ← page chantier (?id=UUID) — 6 onglets + sidebar
├── vercel.json             ← / → axion.html
├── assets/
│   ├── img/
│   │   ├── logo-axion-dark.png
│   │   ├── logo-axion-light.png
│   │   ├── logo-axion-icon.png
│   │   ├── logo-axion-hero.png
│   │   ├── login-bg.png       ← fond login (building wireframe)
│   │   └── cover-lisa.png     ← cover Les Jardins de Lisa
│   └── js/
│       ├── supabase-config.js  ← URL + clé anon + getAxionSupabase()
│       └── axion-auth.js       ← signIn / signOut / fetchProfile / routeByRole
├── supabase/               ← scripts SQL d'audit (lecture seule)
│   ├── policies.sql
│   ├── seed-accounts.sql
│   ├── verify-rls.sql
│   └── INTEGRATION-SUPABASE.md
└── CONTEXTE-PROJET.md      ← CE FICHIER
```

---

## 8. État d'avancement

### ✅ Livré et fonctionnel
- Landing + login (split visuel building wireframe + card glass-strong)
- Dashboard avec chantiers filtrés par RLS
- Page chantier complète : cover band, 6 onglets, sidebar enrichie (Intervenants + Activité récente)
- Documents catégorisés (PDF/DWG/CR/Notice/Vente) avec icônes & chips colorés
- Routage par onglet selon catégorie
- Module 1 : **reset password + page Mon compte**
- 3 comptes utilisateurs actifs (f.clarisse, c.havet, o.penarette)
- Charte graphique formalisée (skill `axion-brand`)
- **4 chantiers en base** : Les Jardins de Lisa · Les Jardins d'Iris · Domaine des Gueules Cassées · **Les Villages d'Or - Noisy** (créé 09/06)
- **Simulateur bas-carbone** (`simulateur.html`) : bouton retour contextuel — « ← Retour au chantier » si ouvert depuis un chantier (`?project=`), « ← Retour à AXION » (→ `app.html`) si ouvert depuis l'accès rapide du tableau de bord (corrigé 09/06).
- **Suivi carbone collaboratif** (`cumul-carbone.html`, Phase 1 — 09/06) : persistance **Supabase** (fini le localStorage), **partagé** par chantier. Tables `carbon_products` / `carbon_catalog` (base produits réutilisable partagée) / `carbon_settings` (objectif kg/m² + SDP). RLS : lecture scoppée au chantier (sous-select sur `projects`), **écriture MOE/admin**. Champ **Entreprise** (datalist `project_companies`), **« vue entreprise »** par lot (bandeau + cumul du lot, démontre le cloisonnement), exports CSV/JSON/PDF conservés. ⚠️ **Activation** : `supabase/carbon-suivi.sql` (exécuté le 09/06). Testé bout-en-bout sur Iris (données de test nettoyées). **Phase 2** (à venir) : rôle `partner` → écriture stricte par entreprise limitée à son lot. Distinct de la **Prescription CCTP** (`simulateur.html`, conception) : ici = suivi des produits réellement posés (exécution).
- **Dashboard — comptage docs/CR corrigé** (09/06) : les catégories « Dossier … » (boutons « Ouvrir le dossier OneDrive ») ne sont plus comptées comme documents/CR (ex. Iris affichait 3 CR → 2).
- **Espace LABEL** (`chantier.html`, onglet « Espace LABEL » + onglet Membres — Phase 1, 09/06) : cloud par entreprise via **liens OneDrive** (table `label_spaces`, `supabase/label-spaces.sql`). Trois types : `lecture` (dossier parent, AMO/MOE), `entreprise` (édition d'un sous-dossier, la société), `moe` (édition complète du dossier parent — **affiché MOE/admin uniquement**, un lien d'édition global ne doit jamais fuiter vers une entreprise). **Lisa** : les liens parent `lecture` + `moe` sont en place (sous-dossiers entreprise à créer). **Formulaire MOE autonome** (coller un lien, choisir société/lot) ; bouton « Espace LABEL » par société dans Membres (matché par nom). RLS : lecture membres du chantier, **écriture MOE/admin**. ⚠️ **AXION ne gère jamais les droits de partage** (faits dans OneDrive par la MOE) — il ne fait que stocker/présenter l'URL. Testé sur Lisa (données nettoyées). **Phase 2** (`partner`) : chaque entreprise ne verra que sa carte.

- **Roue des métiers** (`metiers.html`, page publique — 10/06) : roue interactive des 11 métiers d'un projet (MOA, AMO, Architecte, Économiste, MOEX, SPS, BET, Entreprises, Fournisseurs, Concessionnaire, Administratif), drawer fiche métier (rôle, missions, phase) → lien vers l'annuaire **filtré** (`entreprises.html?type=…` ou `?q=…`, chip de filtre déjà géré côté annuaire). Données dans `assets/js/metiers-data.js`, logique `assets/js/roue.js`. Lien « Les métiers » ajouté à la nav d'`axion.html`. **La même roue est embarquée en tête de `entreprises.html`** (panneau repliable, préférence localStorage `axionWheelOpen`, scrim dédié `wheelScrim`, mode `?demo=1` conservé dans les liens). **Complète l'annuaire, ne le remplace pas** (l'annuaire reste la donnée Supabase + gestion). ⚠️ Textes des fiches métiers = placeholder à valider Cadence. ⚠️ Les filtres `moex` / `q=économiste|fournisseur|concessionnaire|administratif` renverront « aucune entreprise » tant que ces types/mots-clés n'existent pas en base.
- **Atelier MOE — Cohérence planning** (`moe-coherence.html`) : lit le snapshot live ChantierFlow, dérives par phase, jalons. **+ Pointage interactif (04/06)** : le MOE peut marquer une tâche « terminée » depuis AXION (table `task_progress`, override par `task_uid`) sans toucher au planning. Bouton sur chaque dérive, garde-fou dépendances (confirm si un prédécesseur n'est pas fini), section « Pointages AXION » avec annulation, audit `updated_by`/`updated_at`. Statut effectif = override sinon `task.sts`. ⚠️ **Activation** : exécuter `supabase/task_progress.sql` dans le SQL Editor.

### ⏳ En cours / prochaine étape immédiate
1. **Débloquer Didier Clarisse** : créer son compte Auth + insert profile (manuel pour l'instant)
2. **Refonte modèle de rôles** : passer admin/user → admin/moe/partner/viewer
3. **Système d'invitation** : interface admin/MOE → lien magique vers `inscription.html` qui crée le compte + l'affecte aux chantiers autorisés

### 🔮 À venir (backlog)
- Module Documents enrichi (filtres avancés, recherche)
- Page admin globale (gestion users)
- Planning protégé connecté à AXION (handoff SSO)
- Notifications mail (publication de doc, ajout d'un membre)
- Dashboard MOA dédié (vision avancement + budget)

---

## 9. Décisions structurantes prises (à respecter)

| Décision | Date | Détail |
|---|---|---|
| ❌ Pas de rédaction de CR dans AXION | 02/06 | Les CR restent rédigés en Word, export PDF déposé dans dossier SharePoint synchronisé. Bouton « Nouveau CR » retiré. |
| ✅ Documents = liens externes (SharePoint) | 02/06 | Pas d'hébergement local des PDF/DWG. La table `documents` stocke `file_path` = URL SharePoint. |
| ✅ Mode lien SharePoint « Tout le monde, ne nécessite pas de connexion » | 02/06 | Validé en navigation privée — pas de mur Microsoft pour les externes. |
| ✅ Hiérarchique strict pour invitations | 02/06 | admin invite tout · MOE Cadence invite entreprises/BET/MOA sur SES chantiers · les autres n'invitent personne. |
| ✅ Lien d'invitation = page d'inscription dédiée | 02/06 | L'invité reçoit un lien → page où il définit son mot de passe → compte créé + affecté aux chantiers que l'inviteur a autorisés. La page d'accueil de l'invité s'adapte aux chantiers reçus. |
| ✅ Planning live planning-lisa.vercel.app — **NON TOUCHÉ** | (depuis le début) | Le dépôt `architechfr/Planning-Lisa` reste à l'état d'origine. Le portail AXION ne pointe vers planning live qu'en lecture seule. |
| ✅ Pointage = override AXION, pas modification du planning | 04/06 | Le pointage MOE vit dans `task_progress` (Supabase), keyé `(project_id, task_uid)`. La structure reste maître côté ChantierFlow. Statuts alignés sur ChantierFlow (`ns/dn/ec/bl`) pour fusion triviale. V1 n'écrit que `dn` (terminée). En cours/bloqué = itération suivante (moteur binaire aujourd'hui). |
| ✅ Planning multi-chantier = visualiseur unique gardé (Piste 2) | 06/06 | Un seul visualiseur (repo `Planning`) param. par `?project=<slug>`, protégé par la session AXION ; l'accès est garanti par RLS Supabase (`planning_snapshots` keyé `project_id`), pas par masquage d'URL. CADENCE Flow **reste l'éditeur** (snapshot `/api/state` publié dans `planning_snapshots`). Écarte la Piste 1 (tout migrer dans Supabase) qui réécrirait l'app live et inverserait la décision du 04/06. |
| ✅ Lien planning PAR chantier (`projects.planning_url`) | 06/06 | **Phase 1 livrée** : `chantier.html` ne pointe plus Lisa en dur. Lien piloté par `projects.planning_url` (Lisa = lien live actuel ; autres = NULL → « Planning en préparation »). Voir `supabase/planning-url.sql`. Schéma Phase 2 prêt : `supabase/planning-snapshots.sql`. |
| ✅ Suivi carbone collaboratif = base, écriture MOE (étagé) | 09/06 | On migre le Suivi carbone en Supabase **maintenant** (écriture MOE/admin + « vue entreprise » par lot pour la démo), et on **reporte** l'écriture stricte par entreprise à la Phase 2 (rôle `partner`). Permet une démo rapide sans bloquer sur la refonte des rôles. |
| 🧭 Modèle d'interaction carbone MOE/AMO/MOA/Entreprises | 09/06 | **Entreprises** alimentent (chacune son lot + fiches FDES/PEP) · **MOE** consolide/pilote · **AMO** audite/alerte (lecture + export) · **MOA** décide. Traduction rôles : AMO = `partner` type « AMO » (lecture projet + export) ; entreprise = `partner` limité à son lot. |
| ✅ « LABEL » = cloud entreprises via liens OneDrive | 09/06 | **Phase 1 LIVRÉE** (`label_spaces` + onglet + Membres + formulaire MOE). Un dossier `LABEL/<entreprise>` par chantier : lien **édition** du sous-dossier pour l'entreprise (son espace seul), lien **lecture** du LABEL pour l'AMO/MOE, propriétaire = MOE. Gratuit, fidèle à « documents = liens externes, saisie manuelle ». **AXION ne touche pas aux droits de partage** (faits dans OneDrive). Vigilance : lien d'édition « sans connexion » = mettre expiration. Phase 2 = cloisonnement strict par entreprise (rôle `partner`). |
| 🔭 Besoin transverse : édition MOE/admin sans Claude Code | 09/06 | Constat (cas « 3 CR ») : l'admin doit pouvoir corriger les données depuis l'UI (infos chantier, documents : ajout/suppression/recatégorisation, liens LABEL). Le Suivi carbone donne déjà cette autonomie sur le carbone (ajout/suppression produits, objectif). À généraliser. |

---

## 10. Pour reprendre une session Claude Code propre

**Phrase magique au début d'une nouvelle conversation** :

> *« On continue le projet AXION (Cadence). Lis CONTEXTE-PROJET.md à la racine du repo `AXION-CHANTIER`. »*

Le skill `axion-portail` se déclenchera automatiquement. Indique ensuite ce sur quoi tu veux travailler.

**Référentiels skill associés** :
- `axion-brand` — charte graphique (palette, typo, composants)
- `axion-portail` — contexte produit, état d'avancement, décisions

**Workflow Git habituel** :
```bash
cd "C:\Users\fclar\OneDrive - CADENCE ARCHITECTES\Documents\CLAUDE-projet\AXION-CHANTIER"
git status
# … modifications …
git add <fichiers>
git commit -m "…"
git push    # Vercel redéploie auto en ~30s
```

---

## 11. Contacts & ressources

- **Florian Clarisse** (cogérant, admin AXION) — `f.clarisse@cadence-architectes.fr`
- **CADENCE Architectes Associés** — 16/18 rue Dubrunfaut, 75012 Paris
- Site : `www.cadence-architectes.fr`
- Email agence : `agence@cadence-architectes.fr`
