# AXION — Intégration Supabase (authentification, rôles, permissions)

Supabase est la **source unique de vérité** : auth, rôles, entreprises, chantiers, permissions.
Le portail **AXION** authentifie ; le **Planning Lisa** devient un module protégé piloté par le rôle.

---

## 1. Architecture finale (production)

```
                         ┌──────────────────────────────┐
                         │   SUPABASE (phfdrgvdfhwtyy…)   │
                         │  auth.users + user_profiles   │
                         │  companies / projects /        │
                         │  project_companies  + RLS      │
                         └───────────────┬───────────────┘
                                         │ JWT + RLS
        ┌────────────────────────────────┼────────────────────────────────┐
        │                                 │                                 │
┌───────▼────────┐               ┌────────▼─────────┐             ┌─────────▼─────────┐
│  AXION portail  │  handoff SSO  │  Planning Lisa    │   POST JWT  │  /api/state        │
│  axion.html     │ ─(hash #sb_*)▶│  index.html       │ ───vérif──▶ │  (Vercel serverless)│
│  app.html       │               │  auth-guard.js    │             │  publication admin  │
└────────────────┘               └──────────────────┘             └────────────────────┘
   axion-sand-iota.vercel.app     planning-axion.vercel.app (NOUVEAU, protégé)
                                  ⚠️ ≠ planning-lisa.vercel.app (live, public, intact)
```

**Flux de connexion :**
1. L'utilisateur arrive sur `axion.html`, saisit e-mail / mot de passe → `signInWithPassword`.
2. Lecture de `user_profiles` (rôle + entreprise) → redirection `app.html`.
3. Depuis `app.html`, le bouton **Planning** ouvre `planning-lisa.vercel.app/#sb_at=…&sb_rt=…&sb_role=…`.
4. `auth-guard.js` établit la session (`setSession`), nettoie l'URL, relit le rôle (RLS), fixe le mode :
   - `admin` → mode **moe** (édition + publication, accès total) — *archi.tech.fr@gmail.com*
   - `user` → mode **lecteur** (consultation seule, périmètre limité par RLS) — *entreprises*
5. Sans session → redirection automatique vers le portail. Le planning n'est **plus public**.

---

## 2. Fichiers livrés

### Dépôt `architechfr/axion`
| Fichier | Rôle |
|---|---|
| `axion.html` | Portail public + login Supabase |
| `app.html` | Dashboard post-login (contenu selon rôle) + lien planning (handoff) |
| `assets/js/supabase-config.js` | Config partagée (URL + clé anon publique) |
| `assets/js/axion-auth.js` | signIn / profil / redirection par rôle / handoff |
| `supabase/policies.sql` | **AUDIT RLS — LECTURE SEULE** (schéma & policies déjà en place) |
| `supabase/seed-accounts.sql` | **AUDIT comptes — LECTURE SEULE** |
| `supabase/verify-rls.sql` | Tests d'isolement (SELECT only, transaction rollback) |

### ⚠️ Planning : le LIVE n'est PAS touché
`https://planning-lisa.vercel.app/?mode=lecteur` reste **en production, public,
utilisé par les entreprises**. Le dépôt `architechfr/Planning-Lisa` n'a **aucune
modification**. La version protégée est une **copie indépendante** :

### Nouveau dépôt `AXION-PLANNING` (futur `architechfr/planning-axion`)
Copie complète du planning + auth Supabase. **Nouveau projet Vercel + nouveau store Blob.**
| Fichier | Rôle |
|---|---|
| `supabase-config.js` | Copie de la config (domaine séparé) |
| `auth-guard.js` | Garde-barrière SSO + mode par rôle + signature des POST |
| `index.html` (modifié) | Scripts d'auth en `<head>` ; `APP_MODE` piloté par `AXION_ROLE` |
| `api/state.js` (modifié) | Publication (POST) réservée au rôle `admin` (vérif JWT) |

Voir `AXION-PLANNING/README-AXION.md` pour la mise en service détaillée.

---

## 3. Étapes de mise en service (à faire une fois)

### 3.1 Supabase — SQL (LECTURE SEULE)
> ✅ Le schéma et les policies RLS sont **déjà en place et validés**. On ne touche
> plus à la base. Les fichiers `supabase/*.sql` sont désormais des **audits en
> lecture seule** (aucun DDL) pour vérifier l'état courant.

Dans **SQL Editor** (optionnel, vérification) :
1. `supabase/policies.sql` — inventaire RLS + policies des 6 tables.
2. `supabase/seed-accounts.sql` — comptes, rôles (`admin`/`user`), entreprises, affectations.
3. `supabase/verify-rls.sql` — tests d'isolement (remplacer les `:UID_*` par des UUID réels).

### 3.2 Supabase — Auth
- **Authentication → URL Configuration → Redirect URLs** : ajouter
  `https://axion-sand-iota.vercel.app/*` et l'URL du **nouveau** planning protégé
  (ex. `https://planning-axion.vercel.app/*`). **Ne PAS** ajouter le live `planning-lisa`.
- Comptes : `archi.tech.fr@gmail.com` = `role='admin'` ; entreprises = `role='user'`
  rattachées à un `company_id` et à leurs chantiers via `project_companies`.

### 3.3 Vercel — projet `axion-sand-iota`
- **Root Directory** = racine du dépôt `axion` (pour servir `axion.html`, `app.html`, `assets/`).
- Redéployer.

### 3.4 Vercel — NOUVEAU projet planning protégé (dépôt `AXION-PLANNING`)
- Créer un **nouveau** projet Vercel lié au nouveau dépôt (≠ projet `planning-lisa`).
- Lier un **store Vercel Blob** (état indépendant du live).
- (Optionnel) Variables `SUPABASE_URL` / `SUPABASE_ANON_KEY`.
- Récupérer l'URL → la mettre dans `assets/js/supabase-config.js` (`planningUrl`).
- ⚠️ **Ne pas toucher** au projet Vercel `planning-lisa` (production en cours).

---

## 4. Sécurité — points clés

- La clé `anon`/`publishable` est **publique par conception** ; la protection vient de la **RLS**.
- **Jamais** exposer la clé `service_role`.
- Défense en profondeur côté publication : `roBlock()` (client) **+** vérification JWT `admin` (serveur).
- Le `?mode=…` d'URL n'a plus d'effet en production (mode déduit du rôle) ; conservé en repli
  dev local via `?noauth=1` sur `localhost`.

---

## 5. Phase 2 (non incluse — à planifier)

- Filtrage **fin du planning par entreprise** : ajouter `company_id` sur les tâches,
  migrer le stockage `Vercel Blob → table Supabase`, filtrer via RLS.
- Documents communs / privés par entreprise (Supabase Storage + RLS).
- Multi-chantiers (le planning est aujourd'hui mono-chantier « Les Jardins de Lisa »).
