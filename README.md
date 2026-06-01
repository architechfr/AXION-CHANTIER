# AXION-CHANTIER — Portail de pilotage de chantier

Portail d'accès unique des chantiers Cadence Architectes, adossé à **Supabase**
(authentification + rôles + permissions RLS).

## Contenu
- `axion.html` — portail public + **connexion Supabase** (e-mail / mot de passe).
- `app.html` — espace de travail post-login (contenu selon le rôle) + récupération
  des **chantiers autorisés** via RLS + accès au module planning.
- `assets/js/supabase-config.js` — config Supabase (URL + clé publishable publique).
- `assets/js/axion-auth.js` — couche auth (login, profil, redirection par rôle, handoff SSO).
- `vercel.json` — `/` → `axion.html`.
- `supabase/` — **audits SQL en lecture seule** + doc d'intégration (le schéma et les
  policies sont déjà en place côté Supabase ; ces fichiers ne modifient rien).

## Rôles
- `admin` (`archi.tech.fr@gmail.com`) — accès total ; planning en édition ; gestion des comptes.
- `user` (entreprises) — lecture seule, **périmètre limité par RLS** à leurs chantiers.

## Modules liés
- **Planning protégé** : déployé séparément (dépôt `AXION-PLANNING`). Renseigner son
  URL dans `assets/js/supabase-config.js` → `planningUrl` pour activer la tuile.
- **Planning live** (`planning-lisa.vercel.app`) : **non modifié**, en production.

## Déploiement
Connecter ce dépôt à un projet **Vercel** (Root Directory = racine). Chaque `push`
redéploie automatiquement. La clé `publishable` est publique par conception ; la
sécurité réelle vient de la **RLS** côté Supabase.
