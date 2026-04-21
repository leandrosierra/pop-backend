USE `poplitic_db`;

SET NAMES utf8mb4;

SET @user_role_id = (SELECT `id_role` FROM `ROLES` WHERE `code` = 'USER' LIMIT 1);
SET @active_status_id = (SELECT `id_statut` FROM `STATUT_REF` WHERE `code` = 'ACTIF' LIMIT 1);
SET @fr_pays_id = (SELECT `id_pays` FROM `PAYS_REF` WHERE `code` = 'FR' LIMIT 1);

CREATE TEMPORARY TABLE `tmp_live_digits` (`n` INT NOT NULL PRIMARY KEY) ENGINE = MEMORY;
INSERT INTO `tmp_live_digits` (`n`)
VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

CREATE TEMPORARY TABLE `tmp_live_users` (`n` INT NOT NULL PRIMARY KEY) ENGINE = MEMORY;
INSERT INTO `tmp_live_users` (`n`)
SELECT tens.`n` * 10 + ones.`n` + 1
FROM `tmp_live_digits` tens
CROSS JOIN `tmp_live_digits` ones
WHERE tens.`n` * 10 + ones.`n` + 1 BETWEEN 1 AND 100;

CREATE TEMPORARY TABLE `tmp_live_question_numbers` (`n` INT NOT NULL PRIMARY KEY) ENGINE = MEMORY;
INSERT INTO `tmp_live_question_numbers` (`n`)
SELECT `n` + 1
FROM `tmp_live_digits`;

CREATE TEMPORARY TABLE `tmp_live_priorities` (`n` INT NOT NULL PRIMARY KEY) ENGINE = MEMORY;
INSERT INTO `tmp_live_priorities` (`n`)
VALUES (1),(2),(3);

CREATE TEMPORARY TABLE `tmp_live_question_priorities` (`n` INT NOT NULL PRIMARY KEY) ENGINE = MEMORY;
INSERT INTO `tmp_live_question_priorities` (`n`)
VALUES (1),(2);

CREATE TEMPORARY TABLE `tmp_live_cities` (
  `city_index` INT NOT NULL PRIMARY KEY,
  `city_code` VARCHAR(45) NOT NULL,
  `city_name` VARCHAR(45) NOT NULL,
  `postal_code` VARCHAR(45) NOT NULL
) ENGINE = MEMORY;

INSERT INTO `tmp_live_cities` (`city_index`, `city_code`, `city_name`, `postal_code`)
VALUES
  (1, '75056', 'Paris', '75011'),
  (2, '69123', 'Lyon', '69003'),
  (3, '13055', 'Marseille', '13006'),
  (4, '44109', 'Nantes', '44000'),
  (5, '33063', 'Bordeaux', '33000'),
  (6, '59350', 'Lille', '59000'),
  (7, '31555', 'Toulouse', '31000'),
  (8, '35238', 'Rennes', '35000'),
  (9, '67482', 'Strasbourg', '67000');

CREATE TEMPORARY TABLE `tmp_live_interests` (
  `interest_index` INT NOT NULL PRIMARY KEY,
  `interest_code` VARCHAR(45) NOT NULL
) ENGINE = MEMORY;

INSERT INTO `tmp_live_interests` (`interest_index`, `interest_code`)
VALUES
  (1, 'Ecologie'),
  (2, 'Education'),
  (3, 'Santé'),
  (4, 'Agriculture'),
  (5, 'Economie'),
  (6, 'Fiscalité'),
  (7, 'Droit travail'),
  (8, 'Budget'),
  (9, 'Culture'),
  (10, 'Vie politique');

INSERT INTO `VILLE_REF` (`id_dept`, `code`, `libelle`)
SELECT d.`id_dept`, '75056', 'Paris'
FROM `DEPT_REF` d
WHERE d.`code` = '75'
  AND NOT EXISTS (SELECT 1 FROM `VILLE_REF` WHERE `code` = '75056');

INSERT INTO `VILLE_REF` (`id_dept`, `code`, `libelle`)
SELECT d.`id_dept`, '69123', 'Lyon'
FROM `DEPT_REF` d
WHERE d.`code` = '69'
  AND NOT EXISTS (SELECT 1 FROM `VILLE_REF` WHERE `code` = '69123');

INSERT INTO `VILLE_REF` (`id_dept`, `code`, `libelle`)
SELECT d.`id_dept`, '13055', 'Marseille'
FROM `DEPT_REF` d
WHERE d.`code` = '13'
  AND NOT EXISTS (SELECT 1 FROM `VILLE_REF` WHERE `code` = '13055');

INSERT INTO `VILLE_REF` (`id_dept`, `code`, `libelle`)
SELECT d.`id_dept`, '44109', 'Nantes'
FROM `DEPT_REF` d
WHERE d.`code` = '44'
  AND NOT EXISTS (SELECT 1 FROM `VILLE_REF` WHERE `code` = '44109');

INSERT INTO `VILLE_REF` (`id_dept`, `code`, `libelle`)
SELECT d.`id_dept`, '33063', 'Bordeaux'
FROM `DEPT_REF` d
WHERE d.`code` = '33'
  AND NOT EXISTS (SELECT 1 FROM `VILLE_REF` WHERE `code` = '33063');

INSERT INTO `VILLE_REF` (`id_dept`, `code`, `libelle`)
SELECT d.`id_dept`, '59350', 'Lille'
FROM `DEPT_REF` d
WHERE d.`code` = '59'
  AND NOT EXISTS (SELECT 1 FROM `VILLE_REF` WHERE `code` = '59350');

INSERT INTO `VILLE_REF` (`id_dept`, `code`, `libelle`)
SELECT d.`id_dept`, '31555', 'Toulouse'
FROM `DEPT_REF` d
WHERE d.`code` = '31'
  AND NOT EXISTS (SELECT 1 FROM `VILLE_REF` WHERE `code` = '31555');

INSERT INTO `VILLE_REF` (`id_dept`, `code`, `libelle`)
SELECT d.`id_dept`, '35238', 'Rennes'
FROM `DEPT_REF` d
WHERE d.`code` = '35'
  AND NOT EXISTS (SELECT 1 FROM `VILLE_REF` WHERE `code` = '35238');

INSERT INTO `VILLE_REF` (`id_dept`, `code`, `libelle`)
SELECT d.`id_dept`, '67482', 'Strasbourg'
FROM `DEPT_REF` d
WHERE d.`code` = '67'
  AND NOT EXISTS (SELECT 1 FROM `VILLE_REF` WHERE `code` = '67482');

INSERT IGNORE INTO `USERS` (`id_role`, `login`, `nom`, `prenom`, `genre`, `email`, `numero_electeur`, `password`, `actif`)
SELECT
  @user_role_id,
  CONCAT('sim.user', LPAD(u.`n`, 3, '0')),
  CONCAT('Demo', LPAD(u.`n`, 3, '0')),
  CASE MOD(u.`n`, 12)
    WHEN 0 THEN 'Alice'
    WHEN 1 THEN 'Hugo'
    WHEN 2 THEN 'Ines'
    WHEN 3 THEN 'Noah'
    WHEN 4 THEN 'Lea'
    WHEN 5 THEN 'Yanis'
    WHEN 6 THEN 'Mila'
    WHEN 7 THEN 'Adam'
    WHEN 8 THEN 'Nora'
    WHEN 9 THEN 'Elias'
    WHEN 10 THEN 'Jade'
    ELSE 'Sacha'
  END,
  CASE MOD(u.`n`, 3) WHEN 0 THEN 'F' WHEN 1 THEN 'M' ELSE 'N/A' END,
  CONCAT('sim.user', LPAD(u.`n`, 3, '0'), '@pop.local'),
  CONCAT('POP-SIM-', LPAD(u.`n`, 4, '0')),
  'user',
  1
FROM `tmp_live_users` u;

UPDATE `USERS` user_row
JOIN `tmp_live_users` u ON user_row.`login` = CONCAT('sim.user', LPAD(u.`n`, 3, '0'))
SET user_row.`id_role` = @user_role_id,
    user_row.`nom` = CONCAT('Demo', LPAD(u.`n`, 3, '0')),
    user_row.`password` = 'user',
    user_row.`actif` = 1,
    user_row.`date_suppression` = NULL;

UPDATE `USER_PARAMETRES` p
JOIN `USERS` user_row ON user_row.`id_parametre` = p.`id_parametre`
JOIN `tmp_live_users` u ON user_row.`login` = CONCAT('sim.user', LPAD(u.`n`, 3, '0'))
SET p.`notifications` = IF(MOD(u.`n`, 2) = 0, 1, 0),
    p.`anonymat` = IF(MOD(u.`n`, 5) = 0, 1, 0);

UPDATE `USER_POSITION` p
JOIN `USERS` user_row ON user_row.`id_position` = p.`id_position`
JOIN `tmp_live_users` u ON user_row.`login` = CONCAT('sim.user', LPAD(u.`n`, 3, '0'))
SET p.`latitude` = 43.1 + (MOD(u.`n`, 24) * 0.18),
    p.`longitude` = -1.8 + (MOD(u.`n`, 32) * 0.21);

UPDATE `USER_ADRESSE` a
JOIN `USERS` user_row ON user_row.`id_user` = a.`id_user`
JOIN `tmp_live_users` u ON user_row.`login` = CONCAT('sim.user', LPAD(u.`n`, 3, '0'))
JOIN `tmp_live_cities` c ON c.`city_index` = MOD(u.`n` - 1, 9) + 1
SET a.`rue` = CONCAT(10 + u.`n`, ' rue des Citoyens'),
    a.`complement` = IF(MOD(u.`n`, 4) = 0, 'Batiment B', NULL),
    a.`ville` = c.`city_name`,
    a.`codepostal` = c.`postal_code`,
    a.`pays` = 'France',
    a.`telephone` = CONCAT('06', LPAD(10000000 + u.`n` * 7919, 8, '0'));

INSERT IGNORE INTO `USER_CHOIX_GEO` (`id_user`, `id_ville`, `id_pays`, `id_dept`, `USER_CHOIX_GEOcol`)
SELECT user_row.`id_user`, v.`id_ville`, @fr_pays_id, d.`id_dept`, 'principal'
FROM `tmp_live_users` u
JOIN `USERS` user_row ON user_row.`login` = CONCAT('sim.user', LPAD(u.`n`, 3, '0'))
JOIN `tmp_live_cities` c ON c.`city_index` = MOD(u.`n` - 1, 9) + 1
JOIN `VILLE_REF` v ON v.`code` = c.`city_code`
JOIN `DEPT_REF` d ON d.`id_dept` = v.`id_dept`;

INSERT IGNORE INTO `USER_CHOIX_GEO` (`id_user`, `id_ville`, `id_pays`, `id_dept`, `USER_CHOIX_GEOcol`)
SELECT user_row.`id_user`, v.`id_ville`, @fr_pays_id, d.`id_dept`, 'secondaire'
FROM `tmp_live_users` u
JOIN `USERS` user_row ON user_row.`login` = CONCAT('sim.user', LPAD(u.`n`, 3, '0'))
JOIN `tmp_live_cities` c ON c.`city_index` = MOD(u.`n` + 2, 9) + 1
JOIN `VILLE_REF` v ON v.`code` = c.`city_code`
JOIN `DEPT_REF` d ON d.`id_dept` = v.`id_dept`
WHERE MOD(u.`n`, 3) = 0;

INSERT IGNORE INTO `USER_INTERETS` (`id_user`, `id_interet`, `priorite`)
SELECT user_row.`id_user`, ref.`id_interet`, p.`n`
FROM `tmp_live_users` u
JOIN `USERS` user_row ON user_row.`login` = CONCAT('sim.user', LPAD(u.`n`, 3, '0'))
JOIN `tmp_live_priorities` p
JOIN `tmp_live_interests` interest_row ON interest_row.`interest_index` = MOD(u.`n` + p.`n` * 3 - 2, 10) + 1
JOIN `USER_INTERETS_REF` ref ON ref.`code` = interest_row.`interest_code`;

INSERT INTO `QUESTIONS` (`id_user`, `id_statut`, `code`, `libelle`, `description`, `image`, `forwards`, `date_expiration`)
SELECT
  user_row.`id_user`,
  @active_status_id,
  CONCAT('SIM-U', LPAD(u.`n`, 3, '0'), '-Q', LPAD(qn.`n`, 2, '0')),
  CASE MOD(qn.`n`, 10)
    WHEN 0 THEN CONCAT('Vie de quartier ', LPAD(u.`n`, 3, '0'))
    WHEN 1 THEN CONCAT('Mobilite locale ', LPAD(u.`n`, 3, '0'))
    WHEN 2 THEN CONCAT('Budget citoyen ', LPAD(u.`n`, 3, '0'))
    WHEN 3 THEN CONCAT('Ecoles et familles ', LPAD(u.`n`, 3, '0'))
    WHEN 4 THEN CONCAT('Sante de proximite ', LPAD(u.`n`, 3, '0'))
    WHEN 5 THEN CONCAT('Commerce local ', LPAD(u.`n`, 3, '0'))
    WHEN 6 THEN CONCAT('Culture accessible ', LPAD(u.`n`, 3, '0'))
    WHEN 7 THEN CONCAT('Services publics ', LPAD(u.`n`, 3, '0'))
    WHEN 8 THEN CONCAT('Transition ecologique ', LPAD(u.`n`, 3, '0'))
    ELSE CONCAT('Securite et mediation ', LPAD(u.`n`, 3, '0'))
  END,
  CASE MOD(qn.`n`, 10)
    WHEN 0 THEN 'Faut-il renforcer les actions de proximite dans les quartiers ?'
    WHEN 1 THEN 'Souhaitez-vous plus de transports et de pistes cyclables entre les quartiers ?'
    WHEN 2 THEN 'Une part plus importante du budget doit-elle etre soumise au vote citoyen ?'
    WHEN 3 THEN 'Les horaires et services autour des ecoles doivent-ils etre adaptes ?'
    WHEN 4 THEN 'Votre commune doit-elle investir dans une offre de sante de proximite ?'
    WHEN 5 THEN 'Faut-il soutenir davantage les commerces et producteurs locaux ?'
    WHEN 6 THEN 'Les lieux culturels doivent-ils etre plus accessibles en soiree ?'
    WHEN 7 THEN 'Les demarches administratives locales doivent-elles etre simplifiees ?'
    WHEN 8 THEN 'Faut-il accelerer les projets de transition ecologique locale ?'
    ELSE 'Faut-il renforcer la mediation dans les espaces publics ?'
  END,
  NULL,
  MOD(u.`n` * 11 + qn.`n` * 7, 80),
  DATE_ADD(NOW(), INTERVAL (15 + MOD(u.`n` + qn.`n` * 3, 75)) DAY)
FROM `tmp_live_users` u
JOIN `tmp_live_question_numbers` qn
JOIN `USERS` user_row ON user_row.`login` = CONCAT('sim.user', LPAD(u.`n`, 3, '0'))
WHERE NOT EXISTS (
  SELECT 1
  FROM `QUESTIONS` existing_question
  WHERE existing_question.`code` = CONCAT('SIM-U', LPAD(u.`n`, 3, '0'), '-Q', LPAD(qn.`n`, 2, '0'))
);

INSERT INTO `QUESTION_CHOIX_GEO` (`id_question`, `id_ville`, `id_pays`, `id_dept`)
SELECT question_row.`id_question`, v.`id_ville`, @fr_pays_id, d.`id_dept`
FROM `tmp_live_users` u
JOIN `tmp_live_question_numbers` qn
JOIN `QUESTIONS` question_row ON question_row.`code` = CONCAT('SIM-U', LPAD(u.`n`, 3, '0'), '-Q', LPAD(qn.`n`, 2, '0'))
JOIN `tmp_live_cities` c ON c.`city_index` = MOD(u.`n` + qn.`n`, 9) + 1
JOIN `VILLE_REF` v ON v.`code` = c.`city_code`
JOIN `DEPT_REF` d ON d.`id_dept` = v.`id_dept`
WHERE NOT EXISTS (
  SELECT 1
  FROM `QUESTION_CHOIX_GEO` qcg
  WHERE qcg.`id_question` = question_row.`id_question`
);

INSERT IGNORE INTO `QUESTION_INTERETS` (`id_question`, `id_interet`, `priorite`)
SELECT question_row.`id_question`, ref.`id_interet`, qp.`n`
FROM `tmp_live_users` u
JOIN `tmp_live_question_numbers` qn
JOIN `tmp_live_question_priorities` qp
JOIN `QUESTIONS` question_row ON question_row.`code` = CONCAT('SIM-U', LPAD(u.`n`, 3, '0'), '-Q', LPAD(qn.`n`, 2, '0'))
JOIN `tmp_live_interests` interest_row ON interest_row.`interest_index` = MOD(u.`n` + qn.`n` + qp.`n` * 4 - 1, 10) + 1
JOIN `USER_INTERETS_REF` ref ON ref.`code` = interest_row.`interest_code`;

INSERT INTO `QUESTIONS_STAT` (`id_question`, `id_answer`, `id_user`)
SELECT
  question_row.`id_question`,
  answer_row.`id_answer`,
  respondent_row.`id_user`
FROM `tmp_live_users` owner_number
JOIN `tmp_live_question_numbers` qn
JOIN `tmp_live_users` respondent_number
JOIN `QUESTIONS` question_row ON question_row.`code` = CONCAT('SIM-U', LPAD(owner_number.`n`, 3, '0'), '-Q', LPAD(qn.`n`, 2, '0'))
JOIN `USERS` respondent_row ON respondent_row.`login` = CONCAT('sim.user', LPAD(respondent_number.`n`, 3, '0'))
JOIN `ANSWER_REF` answer_row ON answer_row.`code` = CASE
  WHEN MOD(respondent_number.`n` + owner_number.`n` + qn.`n`, 10) IN (0, 1) THEN 'NON'
  WHEN MOD(respondent_number.`n` * 2 + owner_number.`n` + qn.`n`, 10) IN (0, 1, 2) THEN 'NEUTRE'
  ELSE 'OUI'
END
WHERE respondent_number.`n` <> owner_number.`n`
  AND MOD(respondent_number.`n` * 7 + owner_number.`n` * 3 + qn.`n`, 10) < 3
  AND NOT EXISTS (
    SELECT 1
    FROM `QUESTIONS_STAT` existing_stat
    WHERE existing_stat.`id_question` = question_row.`id_question`
      AND existing_stat.`id_user` = respondent_row.`id_user`
  );

DROP TEMPORARY TABLE IF EXISTS `tmp_live_question_priorities`;
DROP TEMPORARY TABLE IF EXISTS `tmp_live_priorities`;
DROP TEMPORARY TABLE IF EXISTS `tmp_live_interests`;
DROP TEMPORARY TABLE IF EXISTS `tmp_live_cities`;
DROP TEMPORARY TABLE IF EXISTS `tmp_live_question_numbers`;
DROP TEMPORARY TABLE IF EXISTS `tmp_live_users`;
DROP TEMPORARY TABLE IF EXISTS `tmp_live_digits`;
