USE `poplitic_db`;

SET NAMES utf8mb4;

DROP TEMPORARY TABLE IF EXISTS `tmp_feature_territories`;
DROP TEMPORARY TABLE IF EXISTS `tmp_feature_years`;
DROP TEMPORARY TABLE IF EXISTS `tmp_feature_budget_postes`;
DROP TEMPORARY TABLE IF EXISTS `tmp_feature_budget_impacts`;
DROP TEMPORARY TABLE IF EXISTS `tmp_feature_comments`;
DROP TEMPORARY TABLE IF EXISTS `tmp_feature_meetings`;
DROP TEMPORARY TABLE IF EXISTS `tmp_feature_actualites`;
DROP TEMPORARY TABLE IF EXISTS `tmp_feature_suggestions`;
DROP TEMPORARY TABLE IF EXISTS `tmp_feature_lois`;
DROP TEMPORARY TABLE IF EXISTS `tmp_feature_incoherences`;
DROP TEMPORARY TABLE IF EXISTS `tmp_feature_propositions`;

CREATE TEMPORARY TABLE `tmp_feature_territories` (
  `niveau` VARCHAR(20) NOT NULL,
  `code` VARCHAR(45) NOT NULL,
  `libelle` VARCHAR(255) NOT NULL,
  `montant_base` DECIMAL(15,2) NOT NULL,
  PRIMARY KEY (`niveau`, `code`)
) ENGINE = InnoDB;

INSERT INTO `tmp_feature_territories` (`niveau`, `code`, `libelle`, `montant_base`)
VALUES
  ('VILLE', '75056', 'Paris', 11100000000.00),
  ('VILLE', '69123', 'Lyon', 950000000.00),
  ('VILLE', '13055', 'Marseille', 1700000000.00),
  ('VILLE', '44109', 'Nantes', 590000000.00),
  ('VILLE', '33063', 'Bordeaux', 620000000.00),
  ('VILLE', '59350', 'Lille', 550000000.00),
  ('VILLE', '31555', 'Toulouse', 980000000.00),
  ('VILLE', '35238', 'Rennes', 520000000.00),
  ('VILLE', '67482', 'Strasbourg', 560000000.00),
  ('DEPT', '75', 'Paris', 8900000000.00),
  ('DEPT', '69', 'Rhone', 2100000000.00),
  ('DEPT', '13', 'Bouches-du-Rhone', 2900000000.00),
  ('DEPT', '44', 'Loire-Atlantique', 1650000000.00),
  ('DEPT', '33', 'Gironde', 2100000000.00),
  ('DEPT', '59', 'Nord', 3600000000.00),
  ('DEPT', '31', 'Haute-Garonne', 1900000000.00),
  ('DEPT', '35', 'Ille-et-Vilaine', 1350000000.00),
  ('DEPT', '67', 'Bas-Rhin', 1400000000.00),
  ('REGION', '11', 'Ile-de-France', 5500000000.00),
  ('REGION', '84', 'Auvergne-Rhone-Alpes', 4100000000.00),
  ('REGION', '93', 'Provence-Alpes-Cote d Azur', 2900000000.00),
  ('REGION', '52', 'Pays de la Loire', 1900000000.00),
  ('REGION', '75', 'Nouvelle-Aquitaine', 3200000000.00),
  ('REGION', '32', 'Hauts-de-France', 3300000000.00),
  ('REGION', '76', 'Occitanie', 3100000000.00),
  ('REGION', '53', 'Bretagne', 1800000000.00),
  ('REGION', '44', 'Grand Est', 3000000000.00),
  ('PAYS', 'FR', 'France', 550000000000.00);

CREATE TEMPORARY TABLE `tmp_feature_years` (
  `annee` INT NOT NULL PRIMARY KEY,
  `coefficient` DECIMAL(8,4) NOT NULL
) ENGINE = InnoDB;

INSERT INTO `tmp_feature_years` (`annee`, `coefficient`)
VALUES
  (2026, 1.0000),
  (2025, 0.9620);

INSERT INTO `BUDGETS` (`niveau`, `code_territoire`, `libelle_territoire`, `annee`, `montant_total`, `date_creation`)
SELECT t.`niveau`, t.`code`, t.`libelle`, y.`annee`, ROUND(t.`montant_base` * y.`coefficient`, 2), NOW()
FROM `tmp_feature_territories` t
JOIN `tmp_feature_years` y
WHERE NOT EXISTS (
  SELECT 1
  FROM `BUDGETS` b
  WHERE b.`niveau` = t.`niveau`
    AND b.`code_territoire` = t.`code`
    AND b.`annee` = y.`annee`
);

CREATE TEMPORARY TABLE `tmp_feature_budget_postes` (
  `code` VARCHAR(45) NOT NULL PRIMARY KEY,
  `libelle` VARCHAR(255) NOT NULL,
  `description` TEXT NOT NULL,
  `ratio` DECIMAL(8,5) NOT NULL
) ENGINE = InnoDB;

INSERT INTO `tmp_feature_budget_postes` (`code`, `libelle`, `description`, `ratio`)
VALUES
  ('EDUCATION', 'Education et jeunesse', 'Ecoles, activites periscolaires, jeunesse et restauration collective.', 0.18000),
  ('SOLIDARITES', 'Solidarites', 'Action sociale, aides aux familles, accompagnement des personnes fragiles.', 0.17000),
  ('TRANSPORTS', 'Transports et voirie', 'Voirie, mobilites collectives, velo, entretien et securisation des deplacements.', 0.15000),
  ('LOGEMENT', 'Logement et urbanisme', 'Renovation, habitat, amenagement, foncier et qualite urbaine.', 0.12000),
  ('SECURITE', 'Securite et prevention', 'Police municipale, mediation, prevention et gestion des risques.', 0.08000),
  ('SANTE', 'Sante et proximite', 'Maisons de sante, prevention, acces aux soins et hygiene publique.', 0.07000),
  ('ENVIRONNEMENT', 'Environnement', 'Espaces verts, energie, dechets, biodiversite et adaptation climatique.', 0.09000),
  ('CULTURE', 'Culture et sport', 'Bibliotheques, patrimoine, vie culturelle, clubs sportifs et equipements.', 0.05000),
  ('ECONOMIE', 'Economie locale', 'Commerce, emploi, tourisme, innovation et soutien aux acteurs locaux.', 0.04000),
  ('DETTE', 'Dette et reserves', 'Remboursement de la dette, marges de securite et capacite d investissement.', 0.05000);

INSERT INTO `BUDGET_POSTES` (`id_budget`, `code`, `libelle`, `description`, `montant_actuel`)
SELECT b.`id_budget`, p.`code`, p.`libelle`, p.`description`, ROUND(b.`montant_total` * p.`ratio`, 2)
FROM `BUDGETS` b
JOIN `tmp_feature_territories` t ON t.`niveau` = b.`niveau` AND t.`code` = b.`code_territoire`
JOIN `tmp_feature_budget_postes` p
WHERE b.`annee` IN (2025, 2026)
  AND NOT EXISTS (
    SELECT 1
    FROM `BUDGET_POSTES` bp
    WHERE bp.`id_budget` = b.`id_budget`
      AND bp.`code` = p.`code`
  );

CREATE TEMPORARY TABLE `tmp_feature_budget_impacts` (
  `code` VARCHAR(45) NOT NULL,
  `sens` VARCHAR(20) NOT NULL,
  `libelle` VARCHAR(255) NOT NULL,
  `description` TEXT NOT NULL,
  `seuil` DECIMAL(7,2) NOT NULL,
  PRIMARY KEY (`code`, `sens`)
) ENGINE = InnoDB;

INSERT INTO `tmp_feature_budget_impacts` (`code`, `sens`, `libelle`, `description`, `seuil`)
VALUES
  ('EDUCATION', 'POSITIF', 'Meilleure continuite educative', 'Plus de moyens pour les classes, le periscolaire et la restauration scolaire.', 8.00),
  ('EDUCATION', 'NEGATIF', 'Pression sur les ecoles', 'Risque de reports de travaux, de menus moins qualitatifs ou de services reduits.', 8.00),
  ('SOLIDARITES', 'POSITIF', 'Filets sociaux renforces', 'Accompagnement plus rapide des familles, seniors et publics precaires.', 8.00),
  ('SOLIDARITES', 'NEGATIF', 'Aides moins accessibles', 'Delais plus longs et priorisation plus stricte des dossiers sociaux.', 8.00),
  ('TRANSPORTS', 'POSITIF', 'Mobilite plus fiable', 'Renforcement des lignes, pistes cyclables et entretien de la voirie.', 8.00),
  ('TRANSPORTS', 'NEGATIF', 'Entretien reporte', 'Risque de degradation des routes, arrets et connexions interquartiers.', 8.00),
  ('LOGEMENT', 'POSITIF', 'Renovation acceleree', 'Plus de logements adaptes, moins de vacance et des quartiers mieux equipes.', 8.00),
  ('LOGEMENT', 'NEGATIF', 'Projets urbains ralentis', 'Moins de reserves foncieres et de renovations thermiques lancees.', 8.00),
  ('SECURITE', 'POSITIF', 'Presence de terrain accrue', 'Mediation, prevention et interventions locales mieux couvertes.', 8.00),
  ('SECURITE', 'NEGATIF', 'Prevention reduite', 'Moins de mediation et de capacite de reponse sur les points sensibles.', 8.00),
  ('SANTE', 'POSITIF', 'Acces aux soins facilite', 'Soutien aux structures de proximite et aux actions de prevention.', 8.00),
  ('SANTE', 'NEGATIF', 'Offre de proximite fragilisee', 'Moins de permanences et de prevention dans les quartiers.', 8.00),
  ('ENVIRONNEMENT', 'POSITIF', 'Transition acceleree', 'Renovation energetique, vegetation et gestion des dechets mieux financees.', 8.00),
  ('ENVIRONNEMENT', 'NEGATIF', 'Adaptation climatique retardee', 'Moins de chantiers sur ilots de chaleur, energie et biodiversite.', 8.00),
  ('CULTURE', 'POSITIF', 'Vie locale plus accessible', 'Horaires, equipements et offres culturelles ou sportives renforces.', 8.00),
  ('CULTURE', 'NEGATIF', 'Offre locale reduite', 'Programmation et soutien associatif plus limites.', 8.00),
  ('ECONOMIE', 'POSITIF', 'Activite locale soutenue', 'Plus d aide aux commerces, a l emploi et aux initiatives de proximite.', 8.00),
  ('ECONOMIE', 'NEGATIF', 'Moins de soutien economique', 'Accompagnement reduit pour commerces, tourisme et innovation locale.', 8.00),
  ('DETTE', 'POSITIF', 'Marge financiere securisee', 'Plus de reserve pour absorber les imprevus et financer les investissements.', 8.00),
  ('DETTE', 'NEGATIF', 'Risque financier accru', 'Moins de marge en cas de choc de depenses ou de baisse de recettes.', 8.00);

INSERT INTO `BUDGET_IMPACTS` (`id_budget_poste`, `sens`, `libelle`, `description`, `seuil_pourcentage`)
SELECT bp.`id_budget_poste`, i.`sens`, i.`libelle`, i.`description`, i.`seuil`
FROM `BUDGET_POSTES` bp
JOIN `BUDGETS` b ON b.`id_budget` = bp.`id_budget`
JOIN `tmp_feature_territories` t ON t.`niveau` = b.`niveau` AND t.`code` = b.`code_territoire`
JOIN `tmp_feature_budget_impacts` i ON i.`code` = bp.`code`
WHERE NOT EXISTS (
  SELECT 1
  FROM `BUDGET_IMPACTS` bi
  WHERE bi.`id_budget_poste` = bp.`id_budget_poste`
    AND bi.`sens` = i.`sens`
    AND bi.`libelle` = i.`libelle`
);

CREATE TEMPORARY TABLE `tmp_feature_comments` (
  `question_code` VARCHAR(45) NOT NULL,
  `login` VARCHAR(45) NOT NULL,
  `contenu` TEXT NOT NULL,
  `parent_contenu` TEXT NULL,
  `hours_ago` INT NOT NULL
) ENGINE = InnoDB;

INSERT INTO `tmp_feature_comments` (`question_code`, `login`, `contenu`, `parent_contenu`, `hours_ago`)
VALUES
  ('Q-LOCAL-001', 'user', 'Je prioriserais les ecoles et la renovation energetique, mais avec un plafond clair sur la dette.', NULL, 96),
  ('Q-LOCAL-001', 'camille.martin', 'Le budget devrait distinguer investissement utile et depense recurrente avant le vote.', NULL, 90),
  ('Q-LOCAL-001', 'julien.moreau', 'Il manque souvent une vue par quartier pour comprendre qui beneficie vraiment des arbitrages.', NULL, 84),
  ('Q-LOCAL-001', 'nora.benali', 'D accord sur la vue par quartier, surtout pour comparer mobilite et espaces verts.', 'Il manque souvent une vue par quartier pour comprendre qui beneficie vraiment des arbitrages.', 78),
  ('Q-LOCAL-001', 'mod.pop', 'Bonne piste: on pourrait demander une simulation avec trois scenarios et des impacts visibles.', NULL, 72),
  ('Q-LOCAL-001', 'samir.durand', 'Pour moi la priorite reste les services du quotidien: cantines, proprete, voirie.', NULL, 66),
  ('Q-LOCAL-001', 'admin', 'La question sera utile si chacun precise ce qu il reduit pour financer sa priorite.', NULL, 60),
  ('Q-LOCAL-001', 'l.sierra', 'La reduction ne doit pas toujours tomber sur la culture ou le sport, il faut regarder les effets sociaux.', 'La question sera utile si chacun precise ce qu il reduit pour financer sa priorite.', 54),
  ('Q-LOCAL-001', 'sim.user001', 'Je testerais un scenario avec transports +10 pour cent et dette stable.', NULL, 48),
  ('Q-LOCAL-001', 'sim.user014', 'Un debat physique aiderait a expliquer les montants, les millions sont difficiles a lire.', NULL, 42),
  ('Q-LOCAL-001', 'sim.user027', 'Les impacts positifs et negatifs doivent etre affiches avant validation, pas apres.', NULL, 36),
  ('Q-LOCAL-001', 'sim.user040', 'Je veux surtout voir les engagements deja votes pour eviter les promesses impossibles.', NULL, 30),
  ('Q-LOCAL-002', 'admin', 'Le renforcement des transports doit inclure la regularite, pas seulement de nouvelles lignes.', NULL, 88),
  ('Q-LOCAL-002', 'nora.benali', 'Les correspondances entre bus, velo et train sont le vrai sujet du quotidien.', NULL, 82),
  ('Q-LOCAL-002', 'user', 'Il faudrait tester une priorite sur les axes les plus utilises aux heures de pointe.', NULL, 76),
  ('Q-LOCAL-002', 'julien.moreau', 'Attention a ne pas oublier les communes autour du centre-ville.', 'Il faudrait tester une priorite sur les axes les plus utilises aux heures de pointe.', 70),
  ('Q-LOCAL-004', 'camille.martin', 'Les cantines durables doivent rester accessibles, sinon la mesure sera rejetee.', NULL, 64),
  ('Q-LOCAL-004', 'user', 'On peut combiner produits locaux et lutte contre le gaspillage pour limiter le cout.', NULL, 58),
  ('Q-LOCAL-005', 'nora.benali', 'Les pistes cyclables doivent former un reseau continu, pas des fragments isoles.', NULL, 52),
  ('Q-LOCAL-005', 'sim.user018', 'La securite des croisements devrait etre traitee avant les extensions longues.', NULL, 46),
  ('Q-LOCAL-006', 'julien.moreau', 'Reserve jeunesse oui, mais avec accompagnement pour monter les dossiers.', NULL, 40),
  ('Q-LOCAL-006', 'admin', 'Le dispositif pourrait avoir un jury mixte jeunes, associations et services.', NULL, 34),
  ('Q-LOCAL-008', 'mod.pop', 'La maison de sante doit etre pensee avec horaires et professionnels disponibles.', NULL, 28),
  ('Q-LOCAL-008', 'sim.user033', 'Un diagnostic par quartier serait plus utile qu une reponse generale.', NULL, 22),
  ('ADMIN-Q-01', 'sim.user006', 'La synthese nationale devrait expliquer les transferts entre Etat et collectivites.', NULL, 18),
  ('ADMIN-Q-01', 'admin', 'Le module budget peut servir de base commune pour comparer les scenarios.', NULL, 12);

INSERT INTO `QUESTION_COMMENTS` (`id_question`, `id_user`, `contenu`, `date_creation`)
SELECT q.`id_question`, u.`id_user`, c.`contenu`, DATE_SUB(NOW(), INTERVAL c.`hours_ago` HOUR)
FROM `tmp_feature_comments` c
JOIN `QUESTIONS` q ON q.`code` = c.`question_code`
JOIN `USERS` u ON u.`login` = c.`login`
WHERE c.`parent_contenu` IS NULL
  AND NOT EXISTS (
    SELECT 1
    FROM `QUESTION_COMMENTS` existing_comment
    WHERE existing_comment.`id_question` = q.`id_question`
      AND existing_comment.`contenu` = c.`contenu`
  );

INSERT INTO `QUESTION_COMMENTS` (`id_question`, `id_user`, `id_parent_comment`, `contenu`, `date_creation`)
SELECT q.`id_question`, u.`id_user`, parent_comment.`id_comment`, c.`contenu`, DATE_SUB(NOW(), INTERVAL c.`hours_ago` HOUR)
FROM `tmp_feature_comments` c
JOIN `QUESTIONS` q ON q.`code` = c.`question_code`
JOIN `USERS` u ON u.`login` = c.`login`
JOIN `QUESTION_COMMENTS` parent_comment
  ON parent_comment.`id_question` = q.`id_question`
 AND parent_comment.`contenu` = c.`parent_contenu`
WHERE c.`parent_contenu` IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM `QUESTION_COMMENTS` existing_comment
    WHERE existing_comment.`id_question` = q.`id_question`
      AND existing_comment.`contenu` = c.`contenu`
  );

CREATE TEMPORARY TABLE `tmp_feature_meetings` (
  `question_code` VARCHAR(45) NOT NULL,
  `login` VARCHAR(45) NOT NULL,
  `type_meeting` VARCHAR(20) NOT NULL,
  `titre` VARCHAR(255) NOT NULL,
  `description` TEXT NOT NULL,
  `lieu` VARCHAR(255) NULL,
  `url` TEXT NULL,
  `day_offset` INT NOT NULL,
  `heure_debut` VARCHAR(5) NOT NULL,
  `heure_fin` VARCHAR(5) NOT NULL
) ENGINE = InnoDB;

INSERT INTO `tmp_feature_meetings` (`question_code`, `login`, `type_meeting`, `titre`, `description`, `lieu`, `url`, `day_offset`, `heure_debut`, `heure_fin`)
VALUES
  ('Q-LOCAL-001', 'admin', 'VIRTUEL', 'Atelier budget: lire les postes', 'Session courte pour comprendre le budget public et preparer les scenarios.', NULL, 'https://meet.pop.local/budget-paris', 3, '18:00', '19:00'),
  ('Q-LOCAL-001', 'user', 'PHYSIQUE', 'Debat budget de quartier', 'Echange sur les priorites: ecoles, voirie, environnement et dette.', 'Maison de la vie associative, Paris', NULL, 6, '19:00', '20:30'),
  ('Q-LOCAL-001', 'julien.moreau', 'VIRTUEL', 'Simulation budget participatif', 'Comparaison de trois arbitrages et discussion des impacts.', NULL, 'https://meet.pop.local/scenario-budget', 9, '12:30', '13:15'),
  ('Q-LOCAL-001', 'mod.pop', 'PHYSIQUE', 'Permanence budget ouvert', 'Questions libres sur les montants, les contraintes et les choix possibles.', 'Bibliotheque centrale, Paris', NULL, 13, '10:00', '12:00'),
  ('Q-LOCAL-002', 'nora.benali', 'PHYSIQUE', 'Marche exploratoire mobilite', 'Observation des ruptures de parcours et des points dangereux.', 'Place Bellecour, Lyon', NULL, 4, '17:30', '19:00'),
  ('Q-LOCAL-002', 'admin', 'VIRTUEL', 'Transports: prioriser les axes', 'Discussion en ligne sur regularite, desserte et correspondances.', NULL, 'https://meet.pop.local/mobilite-lyon', 8, '18:15', '19:15'),
  ('Q-LOCAL-004', 'camille.martin', 'PHYSIQUE', 'Cantines durables avec parents', 'Atelier cout, approvisionnement local et lutte contre le gaspillage.', 'Ecole Anatole France, Bordeaux', NULL, 5, '18:00', '19:30'),
  ('Q-LOCAL-005', 'nora.benali', 'VIRTUEL', 'Plan velo: reseau continu', 'Cartographie collective des coupures cyclables prioritaires.', NULL, 'https://meet.pop.local/velo-lille', 7, '18:45', '20:00'),
  ('Q-LOCAL-006', 'julien.moreau', 'PHYSIQUE', 'Budget jeunesse: ideation', 'Temps de travail avec jeunes, associations et services municipaux.', 'Maison des jeunes, Toulouse', NULL, 10, '16:00', '18:00'),
  ('Q-LOCAL-008', 'mod.pop', 'VIRTUEL', 'Maison de sante: horaires et besoins', 'Recueil des besoins sur soins non programmes, prevention et proximite.', NULL, 'https://meet.pop.local/sante-quartier', 11, '19:00', '20:00'),
  ('ADMIN-Q-01', 'admin', 'VIRTUEL', 'Synthese budgetaire nationale', 'Presentation des niveaux ville, departement, region et pays dans POP.', NULL, 'https://meet.pop.local/budget-national', 14, '12:00', '13:00'),
  ('ADMIN-Q-08', 'admin', 'PHYSIQUE', 'Participation des jeunes', 'Rencontre de cadrage sur les formats et lieux de participation.', 'Salle citoyenne, Paris', NULL, 16, '18:00', '20:00');

INSERT INTO `QUESTION_MEETINGS` (`id_question`, `id_user`, `type_meeting`, `titre`, `description`, `lieu`, `url`, `date_debut`, `date_fin`, `date_creation`)
SELECT
  q.`id_question`,
  u.`id_user`,
  m.`type_meeting`,
  m.`titre`,
  m.`description`,
  m.`lieu`,
  m.`url`,
  STR_TO_DATE(CONCAT(DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL m.`day_offset` DAY), '%Y-%m-%d'), ' ', m.`heure_debut`), '%Y-%m-%d %H:%i'),
  STR_TO_DATE(CONCAT(DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL m.`day_offset` DAY), '%Y-%m-%d'), ' ', m.`heure_fin`), '%Y-%m-%d %H:%i'),
  NOW()
FROM `tmp_feature_meetings` m
JOIN `QUESTIONS` q ON q.`code` = m.`question_code`
JOIN `USERS` u ON u.`login` = m.`login`
WHERE NOT EXISTS (
  SELECT 1
  FROM `QUESTION_MEETINGS` existing_meeting
  WHERE existing_meeting.`id_question` = q.`id_question`
    AND existing_meeting.`titre` = m.`titre`
);

CREATE TEMPORARY TABLE `tmp_feature_actualites` (
  `source` VARCHAR(255) NOT NULL,
  `titre` VARCHAR(255) NOT NULL,
  `resume` TEXT NOT NULL,
  `url` TEXT NOT NULL,
  `hours_ago` INT NOT NULL
) ENGINE = InnoDB;

INSERT INTO `tmp_feature_actualites` (`source`, `titre`, `resume`, `url`, `hours_ago`)
VALUES
  ('Data.gouv.fr', 'Nouveaux jeux de donnees sur les budgets locaux', 'Les donnees ouvertes permettent de comparer depenses, dette et investissements par territoire.', 'https://www.data.gouv.fr/', 5),
  ('Vie-publique', 'Participation citoyenne et budgets participatifs', 'Plusieurs collectivites experimentent des dispositifs plus lisibles pour arbitrer les projets proposes.', 'https://www.vie-publique.fr/', 9),
  ('ANCT', 'Revitalisation des centres-villes', 'Les communes cherchent a combiner commerce, mobilite, logement et espaces publics.', 'https://agence-cohesion-territoires.gouv.fr/', 13),
  ('Ministere Transition ecologique', 'Adaptation climatique des villes', 'Les ilots de chaleur, la vegetation et la renovation energetique deviennent des priorites budgétaires.', 'https://www.ecologie.gouv.fr/', 18),
  ('INSEE', 'Evolution demographique des metropoles', 'Les dynamiques de population modifient les besoins en ecoles, transports et sante de proximite.', 'https://www.insee.fr/', 24),
  ('Service-public.fr', 'Demarches locales et acces numerique', 'La simplification des services publics reste un enjeu d inclusion pour les habitants.', 'https://www.service-public.fr/', 31),
  ('Cour des comptes', 'Soutenabilite des finances publiques locales', 'La trajectoire de dette et les investissements doivent etre explicites pour rendre les choix comparables.', 'https://www.ccomptes.fr/', 37),
  ('Senat', 'Mission sur la participation des jeunes', 'Les dispositifs de consultation cherchent a mieux inclure les 16-25 ans.', 'https://www.senat.fr/', 44),
  ('Assemblee nationale', 'Debats sur la transparence de l action publique', 'Les textes examinent acces a l information, evaluation et consultation citoyenne.', 'https://www.assemblee-nationale.fr/', 51),
  ('CNIL', 'Donnees personnelles et outils civiques', 'Les plateformes de participation doivent articuler securite, consentement et sobriete des donnees.', 'https://www.cnil.fr/', 58),
  ('ARCOM', 'Information locale et pluralisme', 'L acces a une information fiable conditionne la qualite des consultations publiques.', 'https://www.arcom.fr/', 65),
  ('Banque des territoires', 'Financer les mobilites du quotidien', 'Les projets de transport local sont analyses selon cout, usage et impact environnemental.', 'https://www.banquedesterritoires.fr/', 72),
  ('France Strategie', 'Evaluation des politiques publiques', 'La mesure des effets positifs et negatifs devient centrale pour arbitrer les depenses.', 'https://www.strategie.gouv.fr/', 84),
  ('Conseil d Etat', 'Qualite de la norme et simplification', 'La coherence des lois et la securite juridique sont des leviers de confiance democratique.', 'https://www.conseil-etat.fr/', 96),
  ('HALDE archives', 'Egalite d acces aux services publics', 'Les choix locaux doivent tenir compte des impacts sur les publics les plus fragiles.', 'https://www.defenseurdesdroits.fr/', 108),
  ('France Urbaine', 'Sante de proximite dans les territoires', 'Les maisons de sante et permanences locales deviennent des outils contre les deserts medicaux.', 'https://franceurbaine.org/', 120),
  ('Association des maires de France', 'Vie associative et lien local', 'Le soutien aux associations demeure une attente forte dans les consultations de proximite.', 'https://www.amf.asso.fr/', 132),
  ('ADEME', 'Sobriete energetique des equipements publics', 'Les collectivites arbitrent entre renovation, maintenance et confort des usagers.', 'https://www.ademe.fr/', 144);

INSERT INTO `ACTUALITES` (`source`, `titre`, `resume`, `url`, `date_publication`, `date_creation`)
SELECT a.`source`, a.`titre`, a.`resume`, a.`url`, DATE_SUB(NOW(), INTERVAL a.`hours_ago` HOUR), NOW()
FROM `tmp_feature_actualites` a
WHERE NOT EXISTS (
  SELECT 1
  FROM `ACTUALITES` existing_actualite
  WHERE existing_actualite.`titre` = a.`titre`
);

CREATE TEMPORARY TABLE `tmp_feature_suggestions` (
  `actualite_titre` VARCHAR(255) NOT NULL,
  `question_code` VARCHAR(45) NOT NULL,
  `titre` VARCHAR(255) NOT NULL,
  `description` TEXT NOT NULL,
  `statut` VARCHAR(45) NOT NULL,
  `hours_ago` INT NOT NULL
) ENGINE = InnoDB;

INSERT INTO `tmp_feature_suggestions` (`actualite_titre`, `question_code`, `titre`, `description`, `statut`, `hours_ago`)
VALUES
  ('Nouveaux jeux de donnees sur les budgets locaux', 'Q-LOCAL-001', 'Comment rendre le budget municipal comprehensible avant le vote ?', 'La question propose un arbitrage budgetaire lisible avec impacts par poste.', 'PUBLIEE', 4),
  ('Participation citoyenne et budgets participatifs', 'Q-LOCAL-006', 'Faut-il reserver une enveloppe citoyenne aux 16-25 ans ?', 'L actualite relance le debat sur la place des jeunes dans les budgets participatifs.', 'PUBLIEE', 8),
  ('Revitalisation des centres-villes', 'SIM-U001-Q06', 'Quels commerces et marches locaux faut-il prioriser ?', 'La suggestion relie commerce, agriculture locale et animation des centres.', 'PROPOSEE', 12),
  ('Adaptation climatique des villes', 'Q-LOCAL-005', 'Quels axes velo et espaces verts doivent passer en priorite ?', 'Les choix de mobilite et de vegetation sont relies aux ilots de chaleur.', 'PUBLIEE', 17),
  ('Evolution demographique des metropoles', 'Q-LOCAL-004', 'Les cantines et ecoles doivent-elles etre adaptees aux nouveaux besoins ?', 'La croissance de population pousse a reevaluer les services scolaires.', 'PROPOSEE', 23),
  ('Demarches locales et acces numerique', 'ADMIN-Q-09', 'Faut-il renforcer l accessibilite numerique des services publics ?', 'La simplification ne doit pas exclure les citoyens moins equipes ou moins a l aise.', 'PUBLIEE', 30),
  ('Soutenabilite des finances publiques locales', 'ADMIN-Q-01', 'Quelle trajectoire de dette est acceptable pour financer les priorites ?', 'La proposition invite a comparer dette, reserves et investissements utiles.', 'PUBLIEE', 36),
  ('Mission sur la participation des jeunes', 'ADMIN-Q-08', 'Quels formats donnent vraiment la parole aux jeunes ?', 'La consultation peut combiner ateliers physiques et participation en ligne.', 'PROPOSEE', 43),
  ('Debats sur la transparence de l action publique', 'ADMIN-Q-04', 'Quels indicateurs publics doivent etre publies par les services locaux ?', 'La transparence gagne en valeur si les indicateurs sont compris par les habitants.', 'PUBLIEE', 50),
  ('Donnees personnelles et outils civiques', 'ADMIN-Q-06', 'Quelles garanties pour les donnees des plateformes citoyennes ?', 'La question porte sur minimisation, consentement et controle des donnees.', 'PROPOSEE', 57),
  ('Information locale et pluralisme', 'ADMIN-Q-03', 'Comment mieux relier actualite locale et questions citoyennes ?', 'L objectif est de transformer l information fiable en debat actionnable.', 'PROPOSEE', 64),
  ('Financer les mobilites du quotidien', 'Q-LOCAL-002', 'Faut-il prioriser regularite ou extension des transports collectifs ?', 'Les budgets transports gagnent a distinguer usage, maillage et maintenance.', 'PUBLIEE', 71),
  ('Evaluation des politiques publiques', 'ADMIN-Q-07', 'Quels impacts faut-il afficher avant de voter une politique publique ?', 'Le module peut exposer effets attendus, risques et indicateurs de suivi.', 'PUBLIEE', 83),
  ('Qualite de la norme et simplification', 'ADMIN-Q-02', 'Comment detecter les incoherences entre textes existants ?', 'La suggestion lance le travail sur la qualite juridique des propositions.', 'PROPOSEE', 95),
  ('Sante de proximite dans les territoires', 'Q-LOCAL-008', 'Quels services doit proposer une maison de sante de quartier ?', 'La consultation precise horaires, prevention et professionnels attendus.', 'PUBLIEE', 119);

INSERT INTO `QUESTION_SUGGESTIONS` (`id_actualite`, `id_question`, `statut`, `titre`, `description`, `date_creation`)
SELECT a.`id_actualite`, q.`id_question`, s.`statut`, s.`titre`, s.`description`, DATE_SUB(NOW(), INTERVAL s.`hours_ago` HOUR)
FROM `tmp_feature_suggestions` s
JOIN `ACTUALITES` a ON a.`titre` = s.`actualite_titre`
JOIN `QUESTIONS` q ON q.`code` = s.`question_code`
WHERE NOT EXISTS (
  SELECT 1
  FROM `QUESTION_SUGGESTIONS` existing_suggestion
  WHERE existing_suggestion.`id_actualite` = a.`id_actualite`
);

CREATE TEMPORARY TABLE `tmp_feature_lois` (
  `code` VARCHAR(45) NOT NULL PRIMARY KEY,
  `titre` VARCHAR(255) NOT NULL,
  `contenu` TEXT NOT NULL,
  `source` VARCHAR(255) NOT NULL,
  `days_ago` INT NOT NULL
) ENGINE = InnoDB;

INSERT INTO `tmp_feature_lois` (`code`, `titre`, `contenu`, `source`, `days_ago`)
VALUES
  ('CONST-1', 'Constitution - souverainete nationale', 'Principe de participation des citoyens par leurs representants et par referendum.', 'Conseil constitutionnel', 380),
  ('CONST-34', 'Constitution - domaine de la loi', 'La loi fixe les regles concernant droits civiques, fiscalite, collectivites et garanties fondamentales.', 'Conseil constitutionnel', 365),
  ('CGCT-L1111', 'Collectivites territoriales - libre administration', 'Les collectivites s administrent librement dans les conditions prevues par la loi.', 'Legifrance', 250),
  ('CGCT-L2312', 'Budgets locaux - presentation et vote', 'Le budget local doit etre presente, debattu et vote selon les regles applicables.', 'Legifrance', 240),
  ('CRPA-L131', 'Relations public administration - participation', 'Les consultations ouvertes doivent definir objet, modalites et restitution.', 'Legifrance', 220),
  ('CRPA-L312', 'Acces aux documents administratifs', 'Les documents administratifs sont communicables sous reserve des exceptions legales.', 'Legifrance', 210),
  ('CENV-L110', 'Environnement - principes generaux', 'Les politiques publiques integrent prevention, precaution et participation.', 'Legifrance', 205),
  ('CENV-L123', 'Participation du public environnement', 'Les projets ayant une incidence environnementale organisent une information du public.', 'Legifrance', 198),
  ('CSP-L1411', 'Sante publique - prevention', 'La politique de sante contribue a la prevention et a la reduction des inegalites.', 'Legifrance', 190),
  ('EDU-L551', 'Education - activites periscolaires', 'Les activites educatives locales peuvent etre organisees avec les collectivites.', 'Legifrance', 180),
  ('NUM-L100', 'Services publics numeriques', 'Les services numeriques doivent etre accessibles, securises et comprehensibles.', 'Journal officiel', 160),
  ('DATA-L200', 'Donnees civiques et minimisation', 'Les plateformes civiques collectent les donnees strictement necessaires aux finalites declarees.', 'Journal officiel', 140),
  ('ASSO-L10', 'Vie associative - soutien local', 'Les aides publiques aux associations respectent egalite, transparence et interet general.', 'Journal officiel', 120),
  ('FIN-L300', 'Evaluation financiere des propositions', 'Tout texte creant une charge nouvelle indique une estimation et des ressources possibles.', 'Journal officiel', 90);

INSERT INTO `LOIS` (`code`, `titre`, `contenu`, `source`, `date_publication`, `date_creation`)
SELECT l.`code`, l.`titre`, l.`contenu`, l.`source`, DATE_SUB(CURDATE(), INTERVAL l.`days_ago` DAY), NOW()
FROM `tmp_feature_lois` l
WHERE NOT EXISTS (
  SELECT 1
  FROM `LOIS` existing_loi
  WHERE existing_loi.`code` = l.`code`
);

CREATE TEMPORARY TABLE `tmp_feature_incoherences` (
  `code_loi` VARCHAR(45) NOT NULL,
  `code_reference` VARCHAR(45) NOT NULL,
  `description` TEXT NOT NULL,
  `correction` TEXT NOT NULL,
  `statut` VARCHAR(45) NOT NULL,
  `hours_ago` INT NOT NULL
) ENGINE = InnoDB;

INSERT INTO `tmp_feature_incoherences` (`code_loi`, `code_reference`, `description`, `correction`, `statut`, `hours_ago`)
VALUES
  ('DATA-L200', 'CRPA-L312', 'La minimisation des donnees doit etre articulee avec le droit d acces aux documents produits par la consultation.', 'Ajouter une clause separant donnees personnelles non communicables et syntheses publiques communicables.', 'CORRECTION_PROPOSEE', 6),
  ('FIN-L300', 'CONST-34', 'L evaluation financiere doit rester dans le domaine de la loi sans imposer une procedure trop lourde aux initiatives locales.', 'Limiter l obligation aux textes creant une charge significative et publier un modele simplifie.', 'A_REVOIR', 11),
  ('NUM-L100', 'CRPA-L131', 'Une consultation numerique accessible ne suffit pas si aucune modalite physique alternative n est prevue.', 'Prevoir au moins un canal non numerique pour les consultations locales importantes.', 'PRIORITAIRE', 17),
  ('CENV-L123', 'CRPA-L131', 'Les consultations environnementales et generales utilisent des delais differents peu lisibles pour les citoyens.', 'Harmoniser les delais minimaux ou afficher explicitement le regime applicable.', 'CORRECTION_PROPOSEE', 23),
  ('ASSO-L10', 'CGCT-L1111', 'Le soutien associatif local doit respecter la libre administration tout en evitant les criteres opaques.', 'Introduire une grille publique de criteres et une motivation sommaire des refus.', 'A_REVOIR', 29),
  ('EDU-L551', 'CGCT-L2312', 'Les engagements periscolaires peuvent etre annonces sans impact budgetaire detaille.', 'Conditionner les nouveaux dispositifs a une annexe budgetaire lisible.', 'CORRECTION_PROPOSEE', 35),
  ('CSP-L1411', 'CGCT-L1111', 'Les actions de sante de proximite croisent competences locales et nationales sans repartition claire.', 'Identifier dans le texte les actions de coordination et celles relevant de financement national.', 'A_REVOIR', 41),
  ('CENV-L110', 'FIN-L300', 'Les objectifs environnementaux peuvent generer des depenses sans trajectoire pluriannuelle.', 'Ajouter une trajectoire financiere et des indicateurs d impact a trois ans.', 'CORRECTION_PROPOSEE', 47),
  ('CRPA-L312', 'DATA-L200', 'La publication brute peut exposer indirectement des donnees de contributeurs dans les petites communes.', 'Imposer anonymisation et seuil minimal d agregation avant publication.', 'PRIORITAIRE', 53),
  ('CGCT-L2312', 'FIN-L300', 'La presentation budgetaire et l evaluation des propositions utilisent des categories differentes.', 'Aligner les postes budgetaires de simulation sur la nomenclature de presentation.', 'CORRECTION_PROPOSEE', 59),
  ('NUM-L100', 'DATA-L200', 'La securisation des services numeriques n indique pas explicitement la duree de conservation.', 'Fixer une duree maximale et un mecanisme de suppression a la demande.', 'A_REVOIR', 65),
  ('CRPA-L131', 'CONST-1', 'La restitution des consultations peut rester trop vague pour garantir un lien effectif avec la decision.', 'Publier une reponse argumentee indiquant les propositions retenues, ecartees et modifiees.', 'CORRECTION_PROPOSEE', 71);

INSERT INTO `LOI_INCOHERENCES` (`id_loi`, `id_loi_reference`, `description`, `correction_proposee`, `statut`, `date_creation`)
SELECT loi.`id_loi`, reference_loi.`id_loi`, i.`description`, i.`correction`, i.`statut`, DATE_SUB(NOW(), INTERVAL i.`hours_ago` HOUR)
FROM `tmp_feature_incoherences` i
JOIN `LOIS` loi ON loi.`code` = i.`code_loi`
JOIN `LOIS` reference_loi ON reference_loi.`code` = i.`code_reference`
WHERE NOT EXISTS (
  SELECT 1
  FROM `LOI_INCOHERENCES` existing_incoherence
  WHERE existing_incoherence.`id_loi` = loi.`id_loi`
    AND existing_incoherence.`id_loi_reference` = reference_loi.`id_loi`
    AND existing_incoherence.`description` = i.`description`
);

CREATE TEMPORARY TABLE `tmp_feature_propositions` (
  `question_code` VARCHAR(45) NOT NULL,
  `login` VARCHAR(45) NOT NULL,
  `titre` VARCHAR(255) NOT NULL,
  `expose_motifs` TEXT NOT NULL,
  `dispositif` TEXT NOT NULL,
  `analyse_conformite` TEXT NOT NULL,
  `statut` VARCHAR(45) NOT NULL,
  `hours_ago` INT NOT NULL
) ENGINE = InnoDB;

INSERT INTO `tmp_feature_propositions` (`question_code`, `login`, `titre`, `expose_motifs`, `dispositif`, `analyse_conformite`, `statut`, `hours_ago`)
VALUES
  ('Q-LOCAL-001', 'user', 'Transparence prealable des budgets locaux', 'Les citoyens doivent connaitre les postes, marges et impacts avant de voter une priorite budgetaire.', 'Article 1: toute consultation budgetaire publie un budget de reference, les postes modifiables et une estimation des impacts. Article 2: une synthese des arbitrages retenus est publiee.', 'Compatible avec la libre administration car le texte encadre la transparence sans imposer le choix final.', 'EN_RELECTURE', 7),
  ('Q-LOCAL-001', 'user', 'Publication des arbitrages non retenus', 'La confiance augmente si les citoyens savent pourquoi certaines options n ont pas ete retenues.', 'Article 1: la restitution d une consultation budgetaire indique les propositions retenues, modifiees et ecartees. Article 2: chaque rejet est accompagne d un motif synthetique.', 'Respecte la libre administration car la collectivite conserve son pouvoir de decision.', 'BROUILLON', 9),
  ('Q-LOCAL-001', 'admin', 'Annexe citoyenne aux budgets participatifs', 'Les choix participatifs gagnent en legitimite si les effets positifs et negatifs sont visibles.', 'Article unique: chaque projet soumis au vote comporte cout, delai, impact recurrent et services responsables.', 'Le dispositif releve de l information du public et respecte le domaine de la loi.', 'PUBLIEE', 14),
  ('Q-LOCAL-001', 'julien.moreau', 'Scenario budgetaire equilibre', 'Un vote budgetaire doit garder une trajectoire soutenable.', 'Article 1: les plateformes civiques signalent tout depassement du budget total. Article 2: elles affichent au moins un scenario equilibre.', 'Conforme aux exigences de bonne information et sans atteinte aux competences locales.', 'BROUILLON', 21),
  ('Q-LOCAL-002', 'user', 'Tableau public de regularite des transports', 'Les habitants doivent pouvoir comparer la regularite avant de choisir entre maintenance et extension.', 'Article 1: les autorites publient un indicateur mensuel de regularite par axe. Article 2: les consultations de mobilite affichent l impact attendu de chaque arbitrage.', 'Compatible avec les competences de transport et le droit a l information.', 'EN_RELECTURE', 24),
  ('Q-LOCAL-002', 'nora.benali', 'Priorisation des mobilites essentielles', 'Les transports du quotidien doivent etre evalues sur regularite, accessibilite et securite.', 'Article 1: les plans locaux de mobilite publient trois indicateurs de regularite. Article 2: les points dangereux font l objet d une priorisation publique.', 'Respecte les competences locales et renforce l information des usagers.', 'EN_RELECTURE', 28),
  ('Q-LOCAL-004', 'user', 'Prix social garanti dans les cantines durables', 'La qualite alimentaire ne doit pas exclure les familles modestes.', 'Article 1: toute hausse liee a l approvisionnement durable preserve les tarifs sociaux. Article 2: le taux de gaspillage est suivi pour financer une partie de la mesure.', 'Conforme au principe d egalite si les criteres tarifaires sont objectifs.', 'BROUILLON', 31),
  ('Q-LOCAL-004', 'camille.martin', 'Approvisionnement durable des cantines', 'Les cantines peuvent soutenir producteurs locaux, qualite alimentaire et maitrise des couts.', 'Article 1: les collectivites publient la part locale, durable et le taux de gaspillage. Article 2: les hausses de cout sont accompagnees d une mesure de compensation.', 'Compatible avec egalite des usagers si les tarifs sociaux sont preserves.', 'BROUILLON', 35),
  ('Q-LOCAL-005', 'user', 'Securisation prioritaire des carrefours cyclables', 'Les usagers renoncent au velo quand les ruptures dangereuses restent non traitees.', 'Article 1: les carrefours dangereux sont classes avant les extensions de reseau. Article 2: chaque projet publie son effet sur la continuite cyclable.', 'S inscrit dans les objectifs de securite publique et de transition ecologique.', 'A_COMPLETER', 38),
  ('Q-LOCAL-005', 'nora.benali', 'Continuite cyclable prioritaire', 'Un reseau cyclable est utile seulement s il supprime les ruptures de parcours.', 'Article 1: les plans velo identifient les coupures prioritaires. Article 2: la securite des intersections est evaluee avant toute extension.', 'S inscrit dans les objectifs environnementaux et de securite publique.', 'PUBLIEE', 42),
  ('Q-LOCAL-006', 'user', 'Accompagnement obligatoire des projets jeunesse', 'Une enveloppe jeunesse ne suffit pas si les porteurs ne savent pas formaliser leur projet.', 'Article 1: chaque consultation jeunesse inclut un accompagnement budgetaire et juridique. Article 2: un retour motive est transmis a chaque equipe.', 'Mesure proportionnee a l objectif d egal acces a la participation.', 'BROUILLON', 45),
  ('Q-LOCAL-006', 'julien.moreau', 'Droit d initiative budgetaire jeunesse', 'Les jeunes doivent acceder aux moyens et a l accompagnement necessaires pour proposer des projets.', 'Article 1: une part du budget participatif peut etre reservee aux 16-25 ans. Article 2: un accompagnement methodologique est propose.', 'Mesure facultative et non discriminatoire si les criteres sont publics.', 'EN_RELECTURE', 49),
  ('Q-LOCAL-008', 'user', 'Diagnostic territorial avant maison de sante', 'Les maisons de sante doivent repondre aux besoins reels et non seulement a une opportunite immobiliere.', 'Article 1: le projet publie diagnostic, plages horaires visees et specialites recherchees. Article 2: un bilan d usage est etabli au bout d un an.', 'Compatible avec la coordination locale de sante et l information du public.', 'EN_RELECTURE', 52),
  ('Q-LOCAL-008', 'mod.pop', 'Maisons de sante de proximite', 'Les besoins de sante varient selon les quartiers et doivent etre documentes.', 'Article 1: tout projet de maison de sante publie horaires cibles, besoins couverts et partenaires. Article 2: un bilan annuel est presente aux habitants.', 'Compatible avec les competences de coordination locale et les objectifs de sante publique.', 'BROUILLON', 56),
  ('ADMIN-Q-01', 'user', 'Nomenclature citoyenne commune', 'Les comparaisons nationales exigent les memes categories de lecture.', 'Article 1: les budgets presentes dans une consultation utilisent une nomenclature citoyenne commune. Article 2: les ecarts avec la nomenclature officielle sont expliques.', 'N altere pas les regles budgetaires et renforce la lisibilite.', 'BROUILLON', 59),
  ('ADMIN-Q-01', 'admin', 'Comparabilite nationale des budgets publics', 'Les citoyens doivent pouvoir comparer ville, departement, region et pays avec les memes categories.', 'Article 1: une nomenclature citoyenne commune est publiee pour les simulations budgetaires. Article 2: chaque poste renvoie a la nomenclature officielle.', 'Le texte organise une presentation pedagogique sans modifier les nomenclatures obligatoires.', 'PUBLIEE', 63),
  ('ADMIN-Q-02', 'user', 'Signalement public des contradictions normatives', 'Les citoyens doivent comprendre quelle incoherence est detectee et quelle correction est proposee.', 'Article 1: tout signalement juridique publie textes concernes, nature du conflit et correction proposee. Article 2: le statut de traitement est affiche.', 'Renforce l intelligibilite de la loi sans produire d effet normatif direct.', 'A_COMPLETER', 66),
  ('ADMIN-Q-02', 'admin', 'Detection des incoherences normatives', 'La qualite de la loi suppose de reperer contradictions, doublons et lacunes avant adoption.', 'Article 1: toute proposition issue d une consultation comporte un controle de coherence avec les textes existants. Article 2: les corrections proposees sont tracees.', 'Conforme au principe de clarte et d intelligibilite de la norme.', 'EN_RELECTURE', 70),
  ('ADMIN-Q-03', 'user', 'Validation humaine des questions d actualite', 'Une suggestion automatique doit rester explicable et moderable.', 'Article 1: chaque question issue de l actualite mentionne source et motif. Article 2: les themes sensibles sont valides par moderation avant publication.', 'Compatible avec la liberte d expression si les criteres sont publics et proportionnes.', 'EN_RELECTURE', 73),
  ('ADMIN-Q-03', 'sim.user006', 'Questions citoyennes liees a l actualite', 'L actualite locale doit alimenter des questions utiles sans saturer les citoyens.', 'Article 1: les suggestions automatiques mentionnent source, date et motif. Article 2: un humain valide les questions sensibles.', 'Respecte le pluralisme si plusieurs sources et une validation transparente sont prevues.', 'BROUILLON', 77),
  ('ADMIN-Q-04', 'user', 'Fiche de lecture des indicateurs publics', 'Un indicateur public doit etre compris avant d etre discute.', 'Article 1: tout indicateur publie dans une consultation affiche definition, source et limite. Article 2: une version courte est proposee pour le grand public.', 'Conforme au droit d acces a l information administrative.', 'BROUILLON', 80),
  ('ADMIN-Q-04', 'sim.user011', 'Indicateurs publics lisibles', 'Les services publics publient beaucoup de donnees mais peu d indicateurs comprehensibles.', 'Article 1: chaque indicateur publie indique definition, frequence et limite. Article 2: les citoyens peuvent proposer un indicateur complementaire.', 'Renforce l acces a l information administrative sans imposer de resultat.', 'BROUILLON', 84),
  ('ADMIN-Q-06', 'user', 'Recours rapide sur moderation citoyenne', 'La moderation doit proteger le debat sans supprimer la capacite de contestation.', 'Article 1: chaque decision de moderation indique motif et voie de recours. Article 2: le recours est examine dans un delai proportionne a la duree de la consultation.', 'Compatible avec les libertes publiques si les restrictions sont necessaires et proportionnees.', 'A_COMPLETER', 87),
  ('ADMIN-Q-06', 'sim.user019', 'Garanties de moderation civique', 'Les plateformes de debat ont besoin de moderation claire et contestable.', 'Article 1: toute suppression indique le motif. Article 2: un recours simple est propose dans un delai raisonnable.', 'Compatible avec les libertes publiques si les motifs sont proportionnes.', 'A_COMPLETER', 91),
  ('ADMIN-Q-07', 'sim.user024', 'Evaluation d impact obligatoire', 'Les politiques publiques doivent exposer leurs effets attendus avant la decision.', 'Article 1: chaque consultation majeure publie effets positifs, risques et indicateurs de suivi. Article 2: un bilan est produit apres execution.', 'Conforme aux objectifs de bonne administration et de transparence.', 'EN_RELECTURE', 98),
  ('ADMIN-Q-08', 'sim.user031', 'Participation effective des jeunes', 'Les jeunes participent davantage quand les formats sont courts, concrets et hybrides.', 'Article 1: les consultations jeunesse prevoient au moins un format physique et un format numerique. Article 2: les resultats sont restitues dans les lieux participants.', 'Mesure proportionnee a l objectif d egal acces a la participation.', 'BROUILLON', 105),
  ('ADMIN-Q-09', 'sim.user037', 'Accessibilite numerique civique', 'Une plateforme citoyenne doit rester utilisable par les personnes eloignees du numerique.', 'Article 1: toute consultation numerique indique une alternative d accompagnement. Article 2: les interfaces respectent un socle d accessibilite.', 'Conforme au principe d egalite d acces aux services publics.', 'PUBLIEE', 112);

INSERT INTO `PROPOSITIONS_LOI` (`id_question`, `id_user`, `titre`, `expose_motifs`, `dispositif`, `analyse_conformite`, `statut`, `date_creation`)
SELECT q.`id_question`, u.`id_user`, p.`titre`, p.`expose_motifs`, p.`dispositif`, p.`analyse_conformite`, p.`statut`, DATE_SUB(NOW(), INTERVAL p.`hours_ago` HOUR)
FROM `tmp_feature_propositions` p
JOIN `QUESTIONS` q ON q.`code` = p.`question_code`
JOIN `USERS` u ON u.`login` = p.`login`
WHERE NOT EXISTS (
  SELECT 1
  FROM `PROPOSITIONS_LOI` existing_proposition
  WHERE existing_proposition.`id_question` = q.`id_question`
    AND existing_proposition.`titre` = p.`titre`
);

DROP TEMPORARY TABLE IF EXISTS `tmp_feature_propositions`;
DROP TEMPORARY TABLE IF EXISTS `tmp_feature_incoherences`;
DROP TEMPORARY TABLE IF EXISTS `tmp_feature_lois`;
DROP TEMPORARY TABLE IF EXISTS `tmp_feature_suggestions`;
DROP TEMPORARY TABLE IF EXISTS `tmp_feature_actualites`;
DROP TEMPORARY TABLE IF EXISTS `tmp_feature_meetings`;
DROP TEMPORARY TABLE IF EXISTS `tmp_feature_comments`;
DROP TEMPORARY TABLE IF EXISTS `tmp_feature_budget_impacts`;
DROP TEMPORARY TABLE IF EXISTS `tmp_feature_budget_postes`;
DROP TEMPORARY TABLE IF EXISTS `tmp_feature_years`;
DROP TEMPORARY TABLE IF EXISTS `tmp_feature_territories`;
