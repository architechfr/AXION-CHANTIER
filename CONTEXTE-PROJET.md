# 🏗️ AXION — Portail de pilotage de chantier · CADENCE Architectes

> **Source de vérité du projet.** Lire ce document AVANT toute action sur AXION.
> À mettre à jour à chaque décision structurante.

**Dernière mise à jour** : 2 juin 2026 · Florian Clarisse

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

## 4. Modèle de rôles (DÉCIDÉ — pas encore en BDD)

| Rôle | Qui | Périmètre | Création |
|---|---|---|---|
| `admin` | `f.clarisse@cadence-architectes.fr` (1 seul) | Tout : gestion users, config, accès total | Manuel |
| `moe` | Tous les `@cadence-architectes.fr` (architectes + MOE Cadence) | Tous les chantiers Cadence en édition, peuvent inviter entreprises/BET/MOA sur LEURS chantiers | Lien d'invitation par admin (futur) |
| `partner` | Entreprises, BET, MOA, bureaux de contrôle | Uniquement leur(s) chantier(s) affecté(s) — sous-type via `companies.type` | Lien d'invitation par MOE/admin |
| `viewer` | Consultation pure (futur) | Lecture stricte | Lien d'invitation |

**Aujourd'hui (à migrer)** : on a juste `admin` et `user`. Migration prévue (voir §8).

---

## 5. Comptes utilisateurs créés (Supabase Auth)

| Email | Rôle BDD actuel | Rôle cible (refonte) | Status |
|---|---|---|---|
| `f.clarisse@cadence-architectes.fr` | admin | admin | ✅ actif, connecté |
| `c.havet@cadence-architectes.fr` | admin | moe | ✅ actif (bêta-test) |
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

---

## 7. Structure du repo `AXION-CHANTIER`

```
AXION-CHANTIER/
├── axion.html              ← landing publique (sans login)
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
