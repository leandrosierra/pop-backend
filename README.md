<div align="center">

# POP — Backend

**L'API qui rend la voix aux citoyens.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Java](https://img.shields.io/badge/Java-8-orange.svg)](https://www.oracle.com/java/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-2.2-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![MySQL](https://img.shields.io/badge/MySQL-5.x-4479A1.svg)](https://www.mysql.com/)

[Frontend mobile](https://github.com/leandrosierra/pop-mobile) · [Démo en ligne](https://pop.leandro-sierra.com) · [API live](https://api.pop.leandro-sierra.com)

</div>

---

## Le projet

> *« La souveraineté nationale appartient au peuple. »*  
> — Constitution française, article 3

Aujourd'hui, on confie un mandat de cinq ans à une poignée d'élus, et on traverse la moitié d'un quinquennat à découvrir des décisions qu'on n'a jamais débattues. Entre deux votes, le citoyen n'a aucune prise. **POP propose autre chose.**

POP est une plateforme de **démocratie semi-directe** : chacun peut **proposer une mesure**, en **débattre publiquement**, **lancer un référendum citoyen**, et **voter** sur les propositions des autres. Pas une pétition de plus — un véritable outil de délibération collective, pensé pour passer du défoulement Twitter à la décision argumentée.

Ce dépôt contient le **backend** : l'API REST Spring Boot qui gère l'authentification, les questions, les votes, la géographie citoyenne et les centres d'intérêt. Le client mobile / web vit dans [`pop-mobile`](https://github.com/leandrosierra/pop-mobile).

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
│   Expo / RN / Web   │  HTTPS  │   Spring Boot · Java 8   │
└─────────────────────┘         └────────────┬─────────────┘
                                             │ JPA / Hibernate
                                             ▼
                                  ┌──────────────────────┐
                                  │   MySQL 5.x          │
                                  │   (poplitic schema)  │
                                  └──────────────────────┘
```

### Stack

- **Spring Boot 2.2** — packaging WAR, Tomcat embarqué ou externe
- **Spring Data JPA + Hibernate** — accès données, naming strategy custom (tables en UPPER_CASE)
- **Spring Security + JWT** (`com.auth0:java-jwt`) — auth stateless
- **OAuth natifs** — Google · Apple · Facebook · Instagram (via `jwks-rsa` côté backend)
- **MySQL 5.x** — schéma `poplitic` (cf. `SQL/DB_CREATION.sql`)
- **Maven Wrapper** — `./mvnw` (Linux/Mac) ou `mvnw.cmd` (Windows), aucune install Maven globale requise

### Endpoints (extrait)

| Domaine | Route | Description |
|---|---|---|
| Auth | `POST /api/auth/login` | Email + password → JWT |
| Auth | `POST /api/auth/oauth/{provider}` | Login OAuth natif (google/apple/facebook/instagram) |
| Auth | `POST /api/auth/signup` | Création de compte |
| Auth | `POST /api/auth/forgot-password` | Email de reset |
| Civic | `GET /api/civic/questions` | Liste paginée des questions ouvertes |
| Civic | `POST /api/civic/questions` | Proposer une question |
| Civic | `POST /api/civic/questions/{id}/vote` | Voter |
| Setup | `GET/POST /api/setup/geography` | Profil géographique citoyen |
| Setup | `GET/POST /api/setup/interests` | Centres d'intérêt |
| Admin | `*` | Backoffice modération |

L'API complète est documentée par le code (annotations Spring `@RestController`). Une OpenAPI/Swagger est dans la roadmap.

## Démarrage rapide

### Prérequis

- **Java 8** (`java -version` doit afficher `1.8.x`)
- **MySQL 5.7+** local ou distant
- **Maven** *(optionnel — le wrapper `./mvnw` fonctionne sans)*

### 1. Cloner et préparer la base

```bash
git clone https://github.com/leandrosierra/pop-backend.git
cd pop-backend

# Créer le schéma + tables
mysql -u root -p < SQL/DB_CREATION.sql

# (optionnel) Charger un seed de dev local
mysql -u root -p poplitic < SQL/LOCAL_DEV_SEED.sql
```

### 2. Variables d'environnement

POP ne stocke **aucun secret dans le code**. Tout est injecté via env vars :

```bash
export POP_DB_URL="jdbc:mysql://localhost:3306/poplitic?useSSL=false&serverTimezone=UTC"
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
./mvnw spring-boot:run        # mode dev
# ou
./mvnw package
java -jar target/app-server-1.0.0.war
```

L'API tourne par défaut sur `http://localhost:8080`. Le frontend Expo (cf. [`pop-mobile`](https://github.com/leandrosierra/pop-mobile)) pointera dessus via `EXPO_PUBLIC_POP_API_ORIGIN`.

### 4. Tests

```bash
./mvnw test
```

## Déploiement

Le `Dockerfile` à la racine bâtit une image **Tomcat 9 + Java 8** prête pour [Coolify](https://coolify.io/), [Caprover](https://caprover.com/), Render ou n'importe quel hôte Docker.

Pour l'instance officielle (`api.pop.leandro-sierra.com`), le déploiement passe par Coolify avec :
- DB MySQL externe
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
