<div align="center">

# POP — Backend

**L'API qui rend la voix aux citoyens.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Node.js](https://img.shields.io/badge/Node.js-22-339933.svg)](https://nodejs.org/)
[![Express](https://img.shields.io/badge/Express-4-000000.svg)](https://expressjs.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17-4169E1.svg)](https://www.postgresql.org/)

[Frontend mobile](https://github.com/leandrosierra/pop-mobile) · [Démo en ligne](https://pop.leandro-sierra.com) · [API live](https://api.pop.leandro-sierra.com)

</div>

---

## Le projet

> *« La souveraineté nationale appartient au peuple. »*  
> — Constitution française, article 3

Aujourd'hui, on confie un mandat de cinq ans à une poignée d'élus, et on traverse la moitié d'un quinquennat à découvrir des décisions qu'on n'a jamais débattues. Entre deux votes, le citoyen n'a aucune prise. **POP propose autre chose.**

POP est une plateforme de **démocratie semi-directe** : chacun peut **proposer une mesure**, en **débattre publiquement**, **lancer un référendum citoyen**, et **voter** sur les propositions des autres. Pas une pétition de plus — un véritable outil de délibération collective, pensé pour passer du défoulement Twitter à la décision argumentée.

Ce dépôt contient le **backend** : l'API REST Node.js qui gère l'authentification, les questions, les votes, la géographie citoyenne et les centres d'intérêt. Le client mobile / web vit dans [`pop-mobile`](https://github.com/leandrosierra/pop-mobile).

## Pourquoi c'est open source

Une plateforme qui prétend rendre la voix aux citoyens **doit être vérifiable par eux**. Le code est ouvert pour :

- **Auditer** comment les votes sont comptés, stockés, sécurisés
- **Forker** : un collectif local, une commune, une assoc peuvent monter leur propre instance
- **Contribuer** : la démocratie n'appartient à personne — ce code non plus
- **Apprendre** : si POP inspire un projet voisin, tant mieux

License : **MIT**. Utilise, modifie, redistribue. La seule chose qu'on demande : ne prétends pas l'avoir écrit.

## Architecture

```
┌─────────────────────┐         ┌──────────────────────────┐
│   pop-mobile        │◄───────►│   pop-backend (CE REPO)  │
│   Expo / RN / Web   │  HTTPS  │   Node.js · Express      │
└─────────────────────┘         └────────────┬─────────────┘
                                             │ pg
                                             ▼
                                  ┌──────────────────────┐
                                  │   PostgreSQL         │
                                  │   (poplitic schema)  │
                                  └──────────────────────┘
```

### Stack

- **Node.js 22** — runtime léger pour le serveur Coolify
- **Express 4** — API HTTP
- **pg** — accès PostgreSQL direct sur le schéma existant
- **bcryptjs** — vérification des mots de passe historiques
- **PostgreSQL** — schéma `pop` (cf. `SQL/DB_CREATION.sql`)
- **Dockerfile** — image Node Alpine prête pour Coolify

### Endpoints (extrait)

| Domaine | Route | Description |
|---|---|---|
| Health | `GET /health` | Healthcheck Coolify |
| Auth | `POST /user/login` | Email + password -> token |
| Auth | `POST /user/create` | Création de compte |
| Auth | `POST /user/oauth/login` | Endpoint OAuth réservé |
| User | `GET /user/{id}` | Profil utilisateur |
| Civic | `GET /question` | Liste paginée des questions |
| Civic | `POST /question` | Proposer une question |
| Civic | `GET /loi` | Lois et textes associés |
| Budget | `GET /budget` | Données budget |
| News | `GET /actualite` | Actualités |
| Discussion | `GET /discussion` | Discussions |

L'API complète est documentée par le code dans `node/server.js`. Une OpenAPI/Swagger est dans la roadmap.

## Démarrage rapide

### Prérequis

- **Node.js 22**
- **PostgreSQL** local ou distant

### 1. Cloner et préparer la base

```bash
git clone https://github.com/leandrosierra/pop-backend.git
cd pop-backend
npm ci

# Créer le schéma + tables
psql "$POP_DB_URL" -f SQL/DB_CREATION.sql

# (optionnel) Charger un seed de dev local
psql "$POP_DB_URL" -f SQL/LOCAL_DEV_SEED.sql
```

### 2. Variables d'environnement

POP ne stocke **aucun secret dans le code**. Tout est injecté via env vars :

```bash
export POP_DB_URL="jdbc:postgresql://localhost:5432/pop"
export POP_DB_USERNAME="pop"
export POP_DB_PASSWORD="<un_vrai_mot_de_passe>"
export POP_TOKEN_SECRET="<au moins 32 caractères aléatoires>"
export POP_TOKEN_TTL_SECONDS=86400

# OAuth (laisser vide pour désactiver un provider)
export POP_GOOGLE_OAUTH_CLIENT_IDS="123-abc.apps.googleusercontent.com"
export POP_APPLE_OAUTH_CLIENT_IDS=""
export POP_FACEBOOK_APP_ID=""
export POP_FACEBOOK_APP_SECRET=""
export POP_INSTAGRAM_APP_ID=""
export POP_INSTAGRAM_APP_SECRET=""
```

### 3. Lancer

```bash
npm start
```

L'API tourne par défaut sur `http://localhost:8080`. Le frontend Expo (cf. [`pop-mobile`](https://github.com/leandrosierra/pop-mobile)) pointera dessus via `EXPO_PUBLIC_POP_API_ORIGIN`.

### 4. Vérification syntaxe

```bash
npm run check
```

## Déploiement

Le `Dockerfile` à la racine bâtit une image **Node.js 22 Alpine** prête pour [Coolify](https://coolify.io/) ou n'importe quel hôte Docker.

Pour l'instance officielle (`api.pop.leandro-sierra.com`), le déploiement passe par Coolify avec :
- DB PostgreSQL externe
- Toutes les vars d'env définies en *Application Settings*
- HTTPS via Let's Encrypt (Traefik intégré)

## Roadmap

V1 (actuel) couvre l'essentiel : auth, propositions, votes, géographie/intérêts. La feuille de route co-construite avec [Guillaume Andrieux](https://github.com/) court jusqu'à V14 et inclut entre autres :

- 🗺️ Cartographie interactive des votes par circonscription
- 🤝 Délégation de vote thématique (Liquid Democracy)
- 📊 Statistiques publiques de participation
- 🇨🇭 Adaptation Suisse (Pétition CH) — système politique fédéraliste
- 🌍 i18n complet (FR, EN, DE, IT déjà câblés côté mobile)
- 🔍 Modération communautaire transparente

## Contribuer

Tout le monde est bienvenu : citoyen, dev, juriste, designer, traducteur. Lis [CONTRIBUTING.md](CONTRIBUTING.md) pour le workflow, et [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) pour le contrat moral.

Tu trouves un bug ? Tu as une idée ? Ouvre une [issue](https://github.com/leandrosierra/pop-backend/issues) — il y a des templates pour t'aider.

## Sécurité

Une vulnérabilité ? Merci de **ne pas l'ouvrir en issue publique** — lis [SECURITY.md](SECURITY.md) pour la procédure de divulgation responsable.

## Licence

[MIT](LICENSE) © Léandro Sierra & contributeurs.

---

<div align="center">

*« On ne change pas la société par décret. »* — Michel Crozier  
*Alors changeons-la par code.*

</div>
