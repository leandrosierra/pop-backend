# Contribuer à POP — Backend

Merci d'envisager de contribuer ! POP est un projet citoyen avant d'être un projet technique : toute aide est précieuse, qu'elle soit en code, en doc, en design, en traduction ou en relecture juridique.

## Avant de commencer

1. **Lis le [Code de conduite](CODE_OF_CONDUCT.md).** On y est tenu·e·s, sans exception.
2. **Cherche dans les [issues existantes](https://github.com/leandrosierra/pop-backend/issues)** — peut-être que ton idée est déjà discutée.
3. **Ouvre une issue avant un gros chantier.** On préfère discuter une approche en amont que rejeter une PR de 2000 lignes après coup.

## Workflow

```
1. Fork → 2. Branche feature → 3. Code + tests → 4. Lint/build → 5. PR
```

### 1. Fork & clone

```bash
git clone https://github.com/<ton-handle>/pop-backend.git
cd pop-backend
git remote add upstream https://github.com/leandrosierra/pop-backend.git
```

### 2. Branche

Pas de commits directs sur `main`. Une branche par feature/fix :

```bash
git checkout -b feature/ajout-export-csv
# ou
git checkout -b fix/auth-token-refresh
```

### 3. Code

- **Java 8** est la baseline (compatibilité Tomcat). Pas de syntaxe Java 11+.
- Suis les conventions Spring Boot existantes : `@RestController` pour les endpoints, `@Service` pour la logique, `@Repository` pour l'accès données.
- Garde les controllers fins — toute logique métier va en service.
- Pas de SQL en dur — JPA / Spring Data ou `@Query` annotée si vraiment nécessaire.
- **Aucun secret en dur** — tout passe par les variables d'env (`${POP_*}` dans `application.properties`).

### 4. Tests

Ajoute des tests pour ton code dans `src/test/java/`. Lance la suite avant de PR :

```bash
./mvnw test
```

Pour un build complet (WAR + tests) :

```bash
./mvnw package
```

### 5. Commit

Messages clairs, présent de l'indicatif, ≤72 caractères pour la ligne 1 :

```
feat(civic): ajoute pagination sur le flux de questions
fix(auth): corrige refresh token expirant trop tôt
docs(readme): clarifie le setup MySQL
```

Types reconnus : `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`.

### 6. PR

- Titre clair, description du **pourquoi** (pas du **quoi** — ça se lit dans le diff)
- Lien vers l'issue concernée (`Closes #42`)
- Captures d'écran si UI ou format de réponse API modifié
- Une checklist :
  - [ ] Les tests passent (`./mvnw test`)
  - [ ] Pas de secret en dur
  - [ ] Doc mise à jour si endpoint changé
  - [ ] Migrations SQL fournies si schéma modifié

## Setup dev rapide

```bash
# MySQL en local
docker run -d --name pop-mysql -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=poplitic \
  mysql:5.7

# Charge le schéma
mysql -u root -p poplitic < SQL/DB_CREATION.sql

# Lance le backend
export POP_DB_URL="jdbc:mysql://localhost:3306/poplitic?useSSL=false&serverTimezone=UTC"
export POP_DB_USERNAME=root
export POP_DB_PASSWORD=root
export POP_TOKEN_SECRET=$(openssl rand -hex 32)
./mvnw spring-boot:run
```

## Sujets ouverts au contributif

Ces sujets sont labelés ["good first issue"](https://github.com/leandrosierra/pop-backend/labels/good%20first%20issue) ou ["help wanted"](https://github.com/leandrosierra/pop-backend/labels/help%20wanted) :

- 📄 Documentation OpenAPI/Swagger (Springfox ou springdoc-openapi)
- 🔧 Mise à jour Spring Boot 2.2 → 2.7 (LTS) puis 3.x
- 🧪 Étendre la couverture de tests unitaires + intégration
- 🌐 Internationalisation des messages d'erreur API
- ⚡ Audit perf des requêtes JPA (N+1 ?)

## Questions ?

Ouvre une [Discussion](https://github.com/leandrosierra/pop-backend/discussions) GitHub — c'est l'endroit pour les questions ouvertes, contrairement aux issues qui ciblent un bug/feature précis.

Merci pour ton temps. Une démocratie meilleure se construit aussi en commits.
