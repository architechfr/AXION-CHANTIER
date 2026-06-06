# 🗓️ AXION — Architecture du Planning multi-chantier (Phase 2)

> Document d'architecture. Décisions prises avec Florian Clarisse les 06/06.
> Préalable à la construction de l'app dans le repo **`Planning`**.
> Source de vérité produit : `CONTEXTE-PROJET.md`. Ce fichier détaille **le planning**.

---

## 1. Principe fondateur : **1 planning ↔ 1 projet**

Un planning n'existe **jamais seul** : il appartient toujours à un projet (`project_id`).

- **Pas de planning orphelin.** On ne crée pas un planning « dans le vide » puis on cherche à quoi le rattacher — c'est l'inverse : on part d'un **projet** (qui existe déjà dans AXION) et on lui **crée** son planning.
- **Un seul planning courant par projet** (décidé le 06/06). La gestion de versions/variantes reste interne à CADENCE Flow (fonction « Versions » déjà présente), pas au niveau base.
- **Clé d'unicité = `project_id`** partout (table `planning_snapshots`, paramètre `?project=`, RLS).

---

## 2. Modèle de données (Supabase)

| Table | Rôle | Clé |
|---|---|---|
| `projects` | Le chantier. Porte `planning_url` (Phase 1, déjà livré). | `id` |
| `planning_snapshots` | **Copie persistée** du planning (JSON ChantierFlow `/api/state`). 1 ligne / projet. | `project_id` (PK) |
| `task_progress` | Pointage MOE (override de statut par tâche). Déjà en place. | `(project_id, task_uid)` |

```
projects (1) ───< planning_snapshots (0..1)      ← 1 planning courant max
projects (1) ───< task_progress (0..N)           ← pointages MOE
```

`planning_snapshots` (cf. `supabase/planning-snapshots.sql`) :
`project_id` · `snapshot jsonb` · `source_url` · `updated_by` · `updated_at`.

**Fin du localStorage comme source.** Aujourd'hui `chantierflow-lisa.html` stocke tout dans le navigateur (`cf_v5`, `cf_proj_<key>`) → invisible pour les autres utilisateurs. La persistance passe dans `planning_snapshots` → partageable + contrôlée par RLS.

---

## 3. Flux 1 — Création (depuis un projet SANS planning)

```
Fiche chantier (chantier.html) · onglet Planning · projet sans planning
   │
   ├─ rôle entreprise/MOA  → « Planning en préparation »   (lecture seule, RAS)
   │
   └─ rôle MOE/admin       → bouton « Créer le planning »
                                │  ouvre le configurateur AVEC le project_id
                                ▼
        configurateur (« Nouveau planning ») — repo Planning
          • s'adapte à project.status :
              - étude / DCE        → planning prévisionnel macro
              - démarrage chantier → planning d'exécution détaillé
          • generate() → planning TCE
                                │  « Ouvrir dans le planning → »
                                ▼
        ATTACHE au projet (sans toucher aux autres) :
          1. upsert planning_snapshots(project_id, snapshot)
          2. set projects.planning_url = '<app Planning>/?project=<slug>'
                                │
                                ▼
        Le projet « a » désormais son planning. Isolation garantie par project_id.
```

> **Isolation** : créer/éditer le planning du projet A n'altère jamais le planning du projet B. C'est la correction directe du défaut localStorage actuel (clés partagées qui s'écrasent).

L'état « Planning en préparation » livré en Phase 1 devient donc, **pour MOE/admin**, le point d'entrée « Créer le planning ».

---

## 4. Flux 2 — Consultation / édition

```
Onglet Planning → projects.planning_url → app Planning (repo Planning)
   │  handoff SSO (déjà codé : axion-auth.planningHandoffUrl) :
   │     #sb_at=<token>&sb_rt=<refresh>&sb_role=<role>  + &project=<slug>
   ▼
App Planning :
   1. restaure la session Supabase depuis le hash
   2. SELECT sur planning_snapshots WHERE project_id = … → RLS tranche l'accès
        • non affecté au chantier → AUCUNE donnée (« Accès refusé »)
   3. rend le Gantt :
        • MOE/admin → ÉDITION (tâches, dates, jalons) + pointage
        • entreprise/MOA → LECTURE SEULE, filtrée à leurs chantiers
```

Le contrôle d'accès est **serveur (RLS)**, jamais par masquage d'URL.

---

## 5. Matrice des droits

| Action | admin | moe | moa | entreprise |
|---|:--:|:--:|:--:|:--:|
| Voir le planning de SES chantiers | ✅ (tous) | ✅ (tous Cadence) | ✅ (les siens) | ✅ (les siens) |
| Créer un planning (configurateur) | ✅ | ✅ | ❌ | ❌ |
| Éditer tâches/dates/jalons | ✅ | ✅ | ❌ | ❌ |
| Pointer l'avancement | ✅ | ✅ | ❌ | ❌ |
| Voir un chantier non affecté | ✅ | ✅ | ❌ | ❌ |

(Alignée sur le modèle de rôles cible — `CONTEXTE-PROJET.md` §4.)

---

## 6. Repo `Planning` — point de départ

- **Base** : `chantierflow-lisa.html` (l'éditeur ChantierFlow actuel, 729 l.).
- **À faire évoluer** :
  1. Multi-projet : charger par `?project=<slug>` au lieu du Lisa codé en dur.
  2. Persistance : lire/écrire `planning_snapshots` (Supabase) au lieu du localStorage.
  3. Garde d'accès : restaurer la session via le handoff, appliquer les droits par rôle.
  4. Brancher le configurateur (`configurateur.html`) pour qu'il attache au projet.
- **Lisa = exception** : reste sur `planning-lisa.vercel.app` tant qu'on n'a pas migré son planning dans `planning_snapshots`. Les **nouveaux** plannings naissent directement dans le repo `Planning`.

---

## 7. Découpage de mise en œuvre

| Étape | Contenu | Périmètre |
|---|---|---|
| **2a** | App `Planning` : chargement multi-projet (`?project=`) + lecture `planning_snapshots` + garde d'accès | repo `Planning` |
| **2b** | Édition + sauvegarde dans `planning_snapshots` (MOE/admin) | repo `Planning` |
| **2c** | Configurateur lancé depuis la fiche chantier (project_id) + attache (snapshot + planning_url), adapté à `project.status` | `axion-chantier` + `Planning` |
| **2d** | Finaliser la RLS `planning_snapshots` avec la refonte des rôles | Supabase |
| **2e** | (optionnel) Migrer Lisa de planning-lisa → `planning_snapshots` | Supabase |

⚠️ Les étapes touchant le repo `Planning` nécessitent de **l'ajouter au périmètre de la session**.
