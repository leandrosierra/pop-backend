# Politique de sécurité

POP traite des données citoyennes sensibles : identifiants, géographie, opinions politiques, votes. La sécurité du backend n'est pas une fonctionnalité, c'est une condition d'existence du projet.

## Versions supportées

| Version | Support |
| ------- | ------- |
| `main` (latest) | ✅ |
| Anciennes branches | ❌ |

Tant que le projet est en V1, seule la branche `main` reçoit les correctifs de sécurité.

## Signaler une vulnérabilité

**Ne pas ouvrir d'issue publique** pour une faille de sécurité.

Envoie un email à **leandrosierra1@gmail.com** avec :

- Une description claire du problème
- Les étapes pour le reproduire (ou un POC si tu l'as)
- L'impact estimé (lecture de votes, vol de comptes, escalade de privilèges, DoS…)
- Ta version / commit / environnement

### Engagements

- **Accusé de réception** sous **72h ouvrées**
- **Première évaluation** sous **7 jours**
- **Correctif déployé** dans un délai proportionnel à la gravité :
  - Critique (RCE, escalade admin, fuite massive de données) : **<7 jours**
  - Élevée (auth bypass, IDOR sur ressources sensibles) : **<14 jours**
  - Moyenne (XSS, CSRF sur action non critique) : **<30 jours**
  - Faible : prochaine release planifiée

### Divulgation responsable

On suit le principe de **divulgation coordonnée** : tu nous laisses le temps de patcher avant publication. En retour, tu seras crédité·e dans le `CHANGELOG.md` et le commit de correctif (sauf si tu préfères l'anonymat).

Pas de programme de bug bounty financier à ce stade (projet open source bénévole), mais notre reconnaissance publique et un remerciement franc.

## Zone d'attention particulière

Si tu fouilles le backend, ces surfaces méritent une attention spéciale :

- **Auth** : `src/main/java/com/lsi/server/security/*` (JWT, OAuth, filtres d'authentification)
- **Vote** : intégrité du décompte, prévention du double-vote, audit trail
- **Données personnelles** : géolocalisation, adresses, contenus de propositions
- **Injection** : SQL (JPA mais aussi requêtes natives), header injection, deserialization
- **Dépendances vieillissantes** : Spring Boot 2.2 est ancien — les CVE applicatives nous intéressent

## En dehors du scope

- Vulnérabilités sur des forks tiers (signale-les à leurs mainteneurs)
- Bugs fonctionnels sans impact sécurité (passe par une issue classique)
- DoS via traffic massif (c'est de l'infra, pas du code applicatif)

Merci de protéger le projet — et les citoyens qui l'utiliseront.
