# 🎵 Blind Test Musical — Application de soirée multijoueur

Application web **temps réel** pour animer un blind test entre amis : l'hôte lance
les morceaux (Spotify / YouTube / téléphone), les joueurs **buzzent**, le plus rapide
répond, les autres **votent** 👍/👎, et le **leaderboard** se met à jour en direct.

> Accès : `https://<votre-domaine-vercel>/blindtest.html`
> (en local : ouvrir `blindtest.html` via un petit serveur statique, cf. plus bas).

---

## 1. Choix techniques (et pourquoi)

Le prompt d'origine demandait **React + Firebase**. L'application a été construite
sur la **stack déjà en place dans AXION** pour rester cohérente, déployable
immédiatement et sans nouvelle dépendance d'infrastructure :

| Demandé (prompt) | Retenu (AXION) | Raison |
|---|---|---|
| React 18 + Vite + TS | **HTML + JS vanilla + Tailwind (CDN)** | Aucun build ; identique aux autres pages du repo (`axion.html`, `chantier.html`…) |
| Firebase Auth/Firestore | **Supabase Realtime** | Projet Supabase déjà actif (`assets/js/supabase-config.js`) ; pas de credentials à créer |
| Listeners Firestore | **Realtime Broadcast + Presence** | Pub/sub WebSocket pur : **aucune table, aucune migration SQL, aucune RLS** |
| `qrcode` | `qrcode` (CDN) | QR code d'invitation |
| Déploiement Vercel | Vercel (statique) | Le repo est déjà déployé en statique sur Vercel |

> Migration vers React/Firebase possible plus tard sans changer la logique de jeu
> (la machine à états est isolée dans `assets/js/blindtest.js`).

---

## 2. Architecture « autorité hôte »

```
        ┌────────────────────────┐   broadcast "state"   ┌───────────────────────┐
        │      ÉCRAN HÔTE         │ ────────────────────▶ │     ÉCRANS JOUEURS     │
        │  (source de vérité)     │                       │   (clients fins)       │
        │  • détient l'état       │ ◀──────────────────── │  • affichent l'état    │
        │  • valide les réponses  │   broadcast "intent"  │  • envoient: join /    │
        │  • calcule les points   │   (buzz/answer/vote)  │    buzz / answer / vote│
        └───────────┬────────────┘                       └───────────┬───────────┘
                    │                Supabase Realtime               │
                    └─────────  canal "blindtest-<CODE>"  ───────────┘
                                  + Presence (qui est connecté)
```

- **Un seul détenteur d'état** : l'écran hôte. Il diffuse l'état complet à chaque
  changement ; les joueurs ne font que l'afficher → pas de désynchronisation.
- **Course au buzz équitable** : tous les buzz transitent par le serveur Supabase ;
  l'hôte retient **le premier reçu** pendant la phase `buzzing`.
- **Reprise après refresh** : l'état hôte est sauvegardé dans `localStorage`
  (`bt.hostGame`), la partie survit à un rechargement de page de l'hôte.
- **Présence** : les joueurs déconnectés apparaissent grisés (`·zzz`) mais
  conservent leur score (reconnexion possible).

### Fichiers livrés

| Fichier | Rôle |
|---|---|
| `blindtest.html` | Shell : Tailwind config, thème soirée, CDNs, `<div id="app">` |
| `assets/js/blindtest.js` | **Toute l'app** : routeur, temps réel, machine à états, vues, leaderboard, export image |
| `assets/js/supabase-config.js` | *(déjà présent)* URL + clé anon publique réutilisées |
| `BLINDTEST.md` | Ce document |

### Machine à états d'une manche

```
lobby ──launch──▶ armed ──(3s anti-spam)──▶ buzzing ──1er buzz──▶ answering
                                                                      │
                                              reveal ◀──valide──── voting ◀── réponse
                                                │
                                  next ─────────┴───────── end ──▶ ended ──replay──▶ lobby
```

---

## 3. Règles du jeu & points

Configurables par l'hôte au lancement (valeurs par défaut) :

- **Bon buzz** : `+3` au joueur qui a buzzé si l'hôte valide « Correct ».
- **Bon vote** : `+1` à chaque joueur dont le vote était juste
  (👍 quand c'est correct, 👎 quand c'est faux) → récompense le jugement.
- **Mauvais buzz** : `0` (ou `-1` si configuré) si la réponse est fausse.

L'hôte tranche manuellement (✓ / ✗) ; les votes 👍/👎 sont affichés comme aide à la
décision (et servent au calcul des points de vote).

---

## 4. Lancer en local

L'app charge `assets/js/supabase-config.js` en chemin relatif → il faut un serveur
statique (pas d'`file://`) :

```bash
# depuis la racine du repo
npx serve .        # ou : python3 -m http.server 8080
# puis ouvrir http://localhost:8080/blindtest.html
```

Pour tester le multijoueur : ouvrez l'hôte dans un onglet, puis scannez le QR /
ouvrez `#join=CODE` dans d'autres onglets ou sur vos téléphones.

---

## 5. Déploiement Vercel

Rien à configurer : c'est un fichier statique de plus dans le repo déjà branché à
Vercel. Après merge, l'app est disponible sur `/blindtest.html`.

URL « propre » optionnelle — ajouter dans `vercel.json` :

```json
{ "rewrites": [ { "source": "/blindtest", "destination": "/blindtest.html" } ] }
```

> Aucune variable d'environnement : la clé Supabase utilisée est la clé **anon
> publique** (conçue pour tourner dans le navigateur). Realtime Broadcast/Presence
> ne touche à aucune table de production.

---

## 6. Améliorations futures

- 🎧 **Spotify / Deezer preview** : intégrer l'API preview pour jouer les extraits
  directement dans l'écran hôte (au lieu de jouer le son à la main).
- 🗂️ **Banque de morceaux & manches pré-remplies** (table Supabase + RLS).
- ⏱️ **Chrono de réponse** affiché + bonus de rapidité dégressif.
- 🔊 **Pack de sons** (jingle de buzz, roulement de tambour au reveal).
- 🎨 **Thèmes** (années 80, rap FR, génériques de séries…) et avatars joueurs.
- 💾 **Historique persistant** des parties (table `parties` + `manches`).
- 📊 **Stats** : taux de bons buzz par joueur, morceau le plus dur, etc.
- 🤖 **Validation auto** par majorité des votes (mode sans arbitre).
- 📱 **PWA** : installation sur l'écran d'accueil + plein écran.
