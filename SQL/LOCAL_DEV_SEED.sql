USE `poplitic_db`;

SET NAMES utf8mb4;

SET @admin_role_id = (SELECT `id_role` FROM `ROLES` WHERE `code` = 'ADMIN' LIMIT 1);
SET @user_role_id = (SELECT `id_role` FROM `ROLES` WHERE `code` = 'USER' LIMIT 1);
SET @admin_password_hash = '$2a$12$B.L4NsQXNhBrCVRyAEq/Yu4k6InJcKrByQihTU9lYHiMtNKloD5hS';
SET @user_password_hash = '$2a$12$ezNWmur7lKIVPok4XpBTo.ojgyV73kCiCYUTHfe7wLfnIGWso0QWu';
SET @default_password_hash = '$2a$12$zFYMf2HGDbuXDp8dq6tplesCg9xq2DVTEEDqVS9yT8yf36Ctq.uIO';

ALTER TABLE `USERS` MODIFY `password` VARCHAR(100) NOT NULL;

INSERT IGNORE INTO `USERS` (`id_role`, `login`, `nom`, `prenom`, `genre`, `email`, `numero_electeur`, `password`, `actif`)
VALUES (@admin_role_id, 'admin', 'Admin', 'Pop', 'N/A', 'admin@pop.local', 'POP-ADMIN-0001', @admin_password_hash, 1);

INSERT IGNORE INTO `USERS` (`id_role`, `login`, `nom`, `prenom`, `genre`, `email`, `numero_electeur`, `password`, `actif`)
VALUES (@user_role_id, 'user', 'User', 'Pop', 'N/A', 'user@pop.local', 'POP-USER-0001', @user_password_hash, 1);

UPDATE `USERS`
SET `password` = CASE `login`
    WHEN 'admin' THEN @admin_password_hash
    WHEN 'user' THEN @user_password_hash
    ELSE @default_password_hash
END
WHERE `login` IN ('admin', 'user', 'l.sierra', 'g.andrieux');

UPDATE `USER_PARAMETRES` p
JOIN `USERS` u ON u.`id_parametre` = p.`id_parametre`
SET p.`notifications` = CASE WHEN u.`login` = 'admin' THEN 1 ELSE 0 END,
    p.`anonymat` = CASE WHEN u.`login` = 'user' THEN 1 ELSE 0 END
WHERE u.`login` IN ('admin', 'user', 'l.sierra', 'g.andrieux');

UPDATE `USER_POSITION` p
JOIN `USERS` u ON u.`id_position` = p.`id_position`
SET p.`latitude` = CASE u.`login`
    WHEN 'admin' THEN 48.8566
    WHEN 'user' THEN 45.7640
    WHEN 'l.sierra' THEN 43.2965
    ELSE 47.2184
END,
    p.`longitude` = CASE u.`login`
    WHEN 'admin' THEN 2.3522
    WHEN 'user' THEN 4.8357
    WHEN 'l.sierra' THEN 5.3698
    ELSE -1.5536
END
WHERE u.`login` IN ('admin', 'user', 'l.sierra', 'g.andrieux');

UPDATE `USER_ADRESSE` a
JOIN `USERS` u ON u.`id_user` = a.`id_user`
SET a.`rue` = CASE u.`login`
    WHEN 'admin' THEN '1 rue de la Republique'
    WHEN 'user' THEN '12 avenue des Lumiere'
    WHEN 'l.sierra' THEN '8 boulevard du Port'
    ELSE '25 rue des Createurs'
END,
    a.`complement` = CASE WHEN u.`login` = 'admin' THEN 'Siege local' ELSE NULL END,
    a.`ville` = CASE u.`login`
    WHEN 'admin' THEN 'Paris'
    WHEN 'user' THEN 'Lyon'
    WHEN 'l.sierra' THEN 'Marseille'
    ELSE 'Nantes'
END,
    a.`codepostal` = CASE u.`login`
    WHEN 'admin' THEN '75001'
    WHEN 'user' THEN '69002'
    WHEN 'l.sierra' THEN '13001'
    ELSE '44000'
END,
    a.`pays` = 'France',
    a.`telephone` = CASE u.`login`
    WHEN 'admin' THEN '0100000001'
    WHEN 'user' THEN '0100000002'
    WHEN 'l.sierra' THEN '0100000003'
    ELSE '0100000004'
END
WHERE u.`login` IN ('admin', 'user', 'l.sierra', 'g.andrieux');

INSERT INTO `LANGUES_REF` (`code`, `libelle`) VALUES
('FR', 'Français'),
('EN', 'Anglais'),
('DE', 'Allemand'),
('ES', 'Espagnol'),
('IT', 'Italien'),
('PT', 'Portugais'),
('NL', 'Néerlandais'),
('SV', 'Suédois'),
('DA', 'Danois'),
('FI', 'Finnois'),
('NO', 'Norvégien'),
('IS', 'Islandais'),
('GA', 'Irlandais'),
('PL', 'Polonais'),
('CS', 'Tchèque'),
('SK', 'Slovaque'),
('HU', 'Hongrois'),
('RO', 'Roumain'),
('BG', 'Bulgare'),
('EL', 'Grec'),
('HR', 'Croate'),
('SL', 'Slovène'),
('LT', 'Lituanien'),
('LV', 'Letton'),
('ET', 'Estonien'),
('MT', 'Maltais'),
('SQ', 'Albanais'),
('SR', 'Serbe'),
('BS', 'Bosnien'),
('MK', 'Macédonien'),
('UK', 'Ukrainien'),
('RU', 'Russe'),
('TR', 'Turc'),
('LB', 'Luxembourgeois'),
('BE', 'Biélorusse'),
('CA', 'Catalan')
ON DUPLICATE KEY UPDATE `libelle` = VALUES(`libelle`);

INSERT INTO `USER_PARAMETRES_LANGUE` (`id_parametre`, `id_langue`, `ordre`)
SELECT u.`id_parametre`, l.`id_langue`, 2
FROM `USERS` u
JOIN `LANGUES_REF` l ON l.`code` = 'EN'
WHERE u.`login` IN ('admin', 'user')
  AND NOT EXISTS (
    SELECT 1
    FROM `USER_PARAMETRES_LANGUE` upl
    WHERE upl.`id_parametre` = u.`id_parametre`
      AND upl.`id_langue` = l.`id_langue`
  );

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

INSERT INTO `USER_CHOIX_GEO` (`id_user`, `id_ville`, `id_pays`, `id_dept`, `USER_CHOIX_GEOcol`)
SELECT u.`id_user`, v.`id_ville`, p.`id_pays`, d.`id_dept`, 'principal'
FROM `USERS` u
JOIN `PAYS_REF` p ON p.`code` = 'FR'
JOIN `VILLE_REF` v ON v.`code` = CASE u.`login`
    WHEN 'admin' THEN '75056'
    WHEN 'user' THEN '69123'
    WHEN 'l.sierra' THEN '13055'
    ELSE '44109'
END
JOIN `DEPT_REF` d ON d.`id_dept` = v.`id_dept`
WHERE u.`login` IN ('admin', 'user', 'l.sierra', 'g.andrieux')
  AND NOT EXISTS (
    SELECT 1
    FROM `USER_CHOIX_GEO` cg
    WHERE cg.`id_user` = u.`id_user`
      AND cg.`USER_CHOIX_GEOcol` = 'principal'
  );

INSERT INTO `USER_INTERETS` (`id_user`, `id_interet`, `priorite`)
SELECT u.`id_user`, i.`id_interet`, 1
FROM `USERS` u
JOIN `USER_INTERETS_REF` i ON i.`code` = CASE u.`login`
    WHEN 'admin' THEN 'Vie politique'
    WHEN 'user' THEN 'Ecologie'
    WHEN 'l.sierra' THEN 'Economie'
    ELSE 'Culture'
END
WHERE u.`login` IN ('admin', 'user', 'l.sierra', 'g.andrieux')
  AND NOT EXISTS (
    SELECT 1
    FROM `USER_INTERETS` ui
    WHERE ui.`id_user` = u.`id_user`
      AND ui.`id_interet` = i.`id_interet`
  );

INSERT INTO `QUESTIONS` (`id_user`, `id_statut`, `code`, `libelle`, `description`, `image`, `forwards`, `date_expiration`)
SELECT u.`id_user`, s.`id_statut`, 'Q-LOCAL-001', 'Priorite budget municipal', 'Quelle priorite donner au prochain budget municipal ?', NULL, 14, DATE_ADD(NOW(), INTERVAL 30 DAY)
FROM `USERS` u
JOIN `STATUT_REF` s ON s.`code` = 'ACTIF'
WHERE u.`login` = 'admin'
  AND NOT EXISTS (SELECT 1 FROM `QUESTIONS` WHERE `code` = 'Q-LOCAL-001');

INSERT INTO `QUESTIONS` (`id_user`, `id_statut`, `code`, `libelle`, `description`, `image`, `forwards`, `date_expiration`)
SELECT u.`id_user`, s.`id_statut`, 'Q-LOCAL-002', 'Mobilite du quotidien', 'Faut-il renforcer les transports collectifs locaux ?', NULL, 9, DATE_ADD(NOW(), INTERVAL 21 DAY)
FROM `USERS` u
JOIN `STATUT_REF` s ON s.`code` = 'ACTIF'
WHERE u.`login` = 'user'
  AND NOT EXISTS (SELECT 1 FROM `QUESTIONS` WHERE `code` = 'Q-LOCAL-002');

INSERT INTO `QUESTIONS` (`id_user`, `id_statut`, `code`, `libelle`, `description`, `image`, `forwards`, `date_expiration`)
SELECT u.`id_user`, s.`id_statut`, 'Q-LOCAL-003', 'Vie associative', 'Souhaitez-vous plus de soutien aux associations locales ?', NULL, 3, DATE_ADD(NOW(), INTERVAL 45 DAY)
FROM `USERS` u
JOIN `STATUT_REF` s ON s.`code` = 'BROUILLON'
WHERE u.`login` = 'l.sierra'
  AND NOT EXISTS (SELECT 1 FROM `QUESTIONS` WHERE `code` = 'Q-LOCAL-003');

INSERT INTO `QUESTION_CHOIX_GEO` (`id_question`, `id_ville`, `id_pays`, `id_dept`)
SELECT q.`id_question`, v.`id_ville`, p.`id_pays`, d.`id_dept`
FROM `QUESTIONS` q
JOIN `PAYS_REF` p ON p.`code` = 'FR'
JOIN `VILLE_REF` v ON v.`code` = CASE q.`code`
    WHEN 'Q-LOCAL-001' THEN '75056'
    WHEN 'Q-LOCAL-002' THEN '69123'
    ELSE '13055'
END
JOIN `DEPT_REF` d ON d.`id_dept` = v.`id_dept`
WHERE q.`code` IN ('Q-LOCAL-001', 'Q-LOCAL-002', 'Q-LOCAL-003')
  AND NOT EXISTS (
    SELECT 1
    FROM `QUESTION_CHOIX_GEO` qcg
    WHERE qcg.`id_question` = q.`id_question`
  );

INSERT INTO `QUESTION_INTERETS` (`id_question`, `id_interet`, `priorite`)
SELECT q.`id_question`, i.`id_interet`, 1
FROM `QUESTIONS` q
JOIN `USER_INTERETS_REF` i ON i.`code` = CASE q.`code`
    WHEN 'Q-LOCAL-001' THEN 'Budget'
    WHEN 'Q-LOCAL-002' THEN 'Ecologie'
    ELSE 'Culture'
END
WHERE q.`code` IN ('Q-LOCAL-001', 'Q-LOCAL-002', 'Q-LOCAL-003')
  AND NOT EXISTS (
    SELECT 1
    FROM `QUESTION_INTERETS` qi
    WHERE qi.`id_question` = q.`id_question`
      AND qi.`id_interet` = i.`id_interet`
  );

INSERT INTO `QUESTIONS_STAT` (`id_question`, `id_answer`, `id_user`)
SELECT q.`id_question`, a.`id_answer`, u.`id_user`
FROM `QUESTIONS` q
JOIN `ANSWER_REF` a ON a.`code` = CASE q.`code`
    WHEN 'Q-LOCAL-001' THEN 'OUI'
    WHEN 'Q-LOCAL-002' THEN 'NON'
    ELSE 'NEUTRE'
END
JOIN `USERS` u ON u.`login` = CASE q.`code`
    WHEN 'Q-LOCAL-001' THEN 'user'
    WHEN 'Q-LOCAL-002' THEN 'admin'
    ELSE 'g.andrieux'
END
WHERE q.`code` IN ('Q-LOCAL-001', 'Q-LOCAL-002', 'Q-LOCAL-003')
  AND NOT EXISTS (
    SELECT 1
    FROM `QUESTIONS_STAT` qs
    WHERE qs.`id_question` = q.`id_question`
      AND qs.`id_user` = u.`id_user`
  );

INSERT IGNORE INTO `USERS` (`id_role`, `login`, `nom`, `prenom`, `genre`, `email`, `numero_electeur`, `password`, `actif`)
VALUES
  (@user_role_id, 'camille.martin', 'Martin', 'Camille', 'F', 'camille.martin@pop.local', 'POP-USER-0002', @default_password_hash, 1),
  (@user_role_id, 'nora.benali', 'Benali', 'Nora', 'F', 'nora.benali@pop.local', 'POP-USER-0003', @default_password_hash, 1),
  (@user_role_id, 'julien.moreau', 'Moreau', 'Julien', 'M', 'julien.moreau@pop.local', 'POP-USER-0004', @default_password_hash, 1),
  (@user_role_id, 'samir.durand', 'Durand', 'Samir', 'M', 'samir.durand@pop.local', 'POP-USER-0005', @default_password_hash, 1),
  (@admin_role_id, 'mod.pop', 'Moderateur', 'Pop', 'N/A', 'moderateur@pop.local', 'POP-ADMIN-0002', @default_password_hash, 1);

UPDATE `USERS`
SET `password` = @default_password_hash
WHERE `login` IN ('camille.martin', 'nora.benali', 'julien.moreau', 'samir.durand', 'mod.pop');

UPDATE `USER_POSITION` p
JOIN `USERS` u ON u.`id_position` = p.`id_position`
SET p.`latitude` = CASE u.`login`
    WHEN 'camille.martin' THEN 44.8378
    WHEN 'nora.benali' THEN 50.6292
    WHEN 'julien.moreau' THEN 43.6047
    WHEN 'samir.durand' THEN 48.1173
    WHEN 'mod.pop' THEN 48.5734
    ELSE p.`latitude`
END,
    p.`longitude` = CASE u.`login`
    WHEN 'camille.martin' THEN -0.5792
    WHEN 'nora.benali' THEN 3.0573
    WHEN 'julien.moreau' THEN 1.4442
    WHEN 'samir.durand' THEN -1.6778
    WHEN 'mod.pop' THEN 7.7521
    ELSE p.`longitude`
END
WHERE u.`login` IN ('camille.martin', 'nora.benali', 'julien.moreau', 'samir.durand', 'mod.pop');

UPDATE `USER_ADRESSE` a
JOIN `USERS` u ON u.`id_user` = a.`id_user`
SET a.`rue` = CASE u.`login`
    WHEN 'camille.martin' THEN '14 cours Victor Hugo'
    WHEN 'nora.benali' THEN '6 place du Theatre'
    WHEN 'julien.moreau' THEN '19 allee Jean Jaures'
    WHEN 'samir.durand' THEN '3 mail Francois Mitterrand'
    WHEN 'mod.pop' THEN '5 quai des Bateliers'
    ELSE a.`rue`
END,
    a.`ville` = CASE u.`login`
    WHEN 'camille.martin' THEN 'Bordeaux'
    WHEN 'nora.benali' THEN 'Lille'
    WHEN 'julien.moreau' THEN 'Toulouse'
    WHEN 'samir.durand' THEN 'Rennes'
    WHEN 'mod.pop' THEN 'Strasbourg'
    ELSE a.`ville`
END,
    a.`codepostal` = CASE u.`login`
    WHEN 'camille.martin' THEN '33000'
    WHEN 'nora.benali' THEN '59000'
    WHEN 'julien.moreau' THEN '31000'
    WHEN 'samir.durand' THEN '35000'
    WHEN 'mod.pop' THEN '67000'
    ELSE a.`codepostal`
END,
    a.`pays` = 'France'
WHERE u.`login` IN ('camille.martin', 'nora.benali', 'julien.moreau', 'samir.durand', 'mod.pop');

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

INSERT INTO `USER_CHOIX_GEO` (`id_user`, `id_ville`, `id_pays`, `id_dept`, `USER_CHOIX_GEOcol`)
SELECT u.`id_user`, v.`id_ville`, p.`id_pays`, d.`id_dept`, 'principal'
FROM `USERS` u
JOIN `PAYS_REF` p ON p.`code` = 'FR'
JOIN `VILLE_REF` v ON v.`code` = CASE u.`login`
    WHEN 'camille.martin' THEN '33063'
    WHEN 'nora.benali' THEN '59350'
    WHEN 'julien.moreau' THEN '31555'
    WHEN 'samir.durand' THEN '35238'
    ELSE '67482'
END
JOIN `DEPT_REF` d ON d.`id_dept` = v.`id_dept`
WHERE u.`login` IN ('camille.martin', 'nora.benali', 'julien.moreau', 'samir.durand', 'mod.pop')
  AND NOT EXISTS (
    SELECT 1
    FROM `USER_CHOIX_GEO` cg
    WHERE cg.`id_user` = u.`id_user`
      AND cg.`USER_CHOIX_GEOcol` = 'principal'
  );

INSERT INTO `USER_INTERETS` (`id_user`, `id_interet`, `priorite`)
SELECT u.`id_user`, i.`id_interet`, 1
FROM `USERS` u
JOIN `USER_INTERETS_REF` i ON i.`code` = CASE u.`login`
    WHEN 'camille.martin' THEN 'Education'
    WHEN 'nora.benali' THEN 'Ecologie'
    WHEN 'julien.moreau' THEN 'Budget'
    WHEN 'samir.durand' THEN 'Agriculture'
    ELSE 'Economie'
END
WHERE u.`login` IN ('camille.martin', 'nora.benali', 'julien.moreau', 'samir.durand', 'mod.pop')
  AND NOT EXISTS (
    SELECT 1
    FROM `USER_INTERETS` ui
    WHERE ui.`id_user` = u.`id_user`
      AND ui.`id_interet` = i.`id_interet`
  );

INSERT INTO `QUESTIONS` (`id_user`, `id_statut`, `code`, `libelle`, `description`, `image`, `forwards`, `date_expiration`)
SELECT u.`id_user`, s.`id_statut`, x.`code`, x.`libelle`, x.`description`, NULL, x.`forwards`, DATE_ADD(NOW(), INTERVAL x.`days_left` DAY)
FROM (
  SELECT 'camille.martin' AS `login`, 'ACTIF' AS `statut`, 'Q-LOCAL-004' AS `code`, 'Cantines scolaires durables' AS `libelle`, 'Faut-il augmenter la part de produits locaux et bio dans les cantines scolaires ?' AS `description`, 21 AS `forwards`, 28 AS `days_left`
  UNION ALL SELECT 'nora.benali', 'ACTIF', 'Q-LOCAL-005', 'Plan velo metropolitain', 'Souhaitez-vous prioriser les pistes cyclables continues entre les quartiers ?', 18, 32
  UNION ALL SELECT 'julien.moreau', 'ACTIF', 'Q-LOCAL-006', 'Budget participatif jeunesse', 'Une part du budget participatif doit-elle etre reservee aux 16-25 ans ?', 11, 26
  UNION ALL SELECT 'samir.durand', 'BROUILLON', 'Q-LOCAL-007', 'Marches de producteurs locaux', 'Faut-il ouvrir davantage de marches de producteurs en semaine ?', 7, 40
  UNION ALL SELECT 'mod.pop', 'ACTIF', 'Q-LOCAL-008', 'Maison de sante de quartier', 'Votre quartier a-t-il besoin dune maison de sante pluridisciplinaire ?', 15, 35
  UNION ALL SELECT 'g.andrieux', 'INACTIF', 'Q-LOCAL-009', 'Culture en soiree', 'Faut-il etendre les horaires des lieux culturels municipaux ?', 5, 18
) x
JOIN `USERS` u ON u.`login` = x.`login`
JOIN `STATUT_REF` s ON s.`code` = x.`statut`
WHERE NOT EXISTS (SELECT 1 FROM `QUESTIONS` q WHERE q.`code` = x.`code`);

INSERT INTO `QUESTION_CHOIX_GEO` (`id_question`, `id_ville`, `id_pays`, `id_dept`)
SELECT q.`id_question`, v.`id_ville`, p.`id_pays`, d.`id_dept`
FROM `QUESTIONS` q
JOIN `PAYS_REF` p ON p.`code` = 'FR'
JOIN `VILLE_REF` v ON v.`code` = CASE q.`code`
    WHEN 'Q-LOCAL-004' THEN '33063'
    WHEN 'Q-LOCAL-005' THEN '59350'
    WHEN 'Q-LOCAL-006' THEN '31555'
    WHEN 'Q-LOCAL-007' THEN '35238'
    WHEN 'Q-LOCAL-008' THEN '67482'
    ELSE '44109'
END
JOIN `DEPT_REF` d ON d.`id_dept` = v.`id_dept`
WHERE q.`code` IN ('Q-LOCAL-004', 'Q-LOCAL-005', 'Q-LOCAL-006', 'Q-LOCAL-007', 'Q-LOCAL-008', 'Q-LOCAL-009')
  AND NOT EXISTS (
    SELECT 1
    FROM `QUESTION_CHOIX_GEO` qcg
    WHERE qcg.`id_question` = q.`id_question`
  );

INSERT INTO `QUESTION_INTERETS` (`id_question`, `id_interet`, `priorite`)
SELECT q.`id_question`, i.`id_interet`, 1
FROM `QUESTIONS` q
JOIN `USER_INTERETS_REF` i ON i.`code` = CASE q.`code`
    WHEN 'Q-LOCAL-004' THEN 'Education'
    WHEN 'Q-LOCAL-005' THEN 'Ecologie'
    WHEN 'Q-LOCAL-006' THEN 'Budget'
    WHEN 'Q-LOCAL-007' THEN 'Agriculture'
    WHEN 'Q-LOCAL-008' THEN 'Economie'
    ELSE 'Culture'
END
WHERE q.`code` IN ('Q-LOCAL-004', 'Q-LOCAL-005', 'Q-LOCAL-006', 'Q-LOCAL-007', 'Q-LOCAL-008', 'Q-LOCAL-009')
  AND NOT EXISTS (
    SELECT 1
    FROM `QUESTION_INTERETS` qi
    WHERE qi.`id_question` = q.`id_question`
      AND qi.`id_interet` = i.`id_interet`
  );

INSERT INTO `QUESTIONS_STAT` (`id_question`, `id_answer`, `id_user`)
SELECT q.`id_question`, a.`id_answer`, u.`id_user`
FROM (
  SELECT 'Q-LOCAL-004' AS `question_code`, 'OUI' AS `answer_code`, 'admin' AS `login`
  UNION ALL SELECT 'Q-LOCAL-004', 'OUI', 'user'
  UNION ALL SELECT 'Q-LOCAL-004', 'NEUTRE', 'nora.benali'
  UNION ALL SELECT 'Q-LOCAL-005', 'OUI', 'camille.martin'
  UNION ALL SELECT 'Q-LOCAL-005', 'NON', 'julien.moreau'
  UNION ALL SELECT 'Q-LOCAL-005', 'OUI', 'samir.durand'
  UNION ALL SELECT 'Q-LOCAL-006', 'OUI', 'admin'
  UNION ALL SELECT 'Q-LOCAL-006', 'OUI', 'mod.pop'
  UNION ALL SELECT 'Q-LOCAL-006', 'NON', 'user'
  UNION ALL SELECT 'Q-LOCAL-007', 'NEUTRE', 'camille.martin'
  UNION ALL SELECT 'Q-LOCAL-008', 'OUI', 'nora.benali'
  UNION ALL SELECT 'Q-LOCAL-008', 'OUI', 'julien.moreau'
  UNION ALL SELECT 'Q-LOCAL-008', 'NON', 'samir.durand'
  UNION ALL SELECT 'Q-LOCAL-009', 'NON', 'admin'
  UNION ALL SELECT 'Q-LOCAL-009', 'NEUTRE', 'user'
) x
JOIN `QUESTIONS` q ON q.`code` = x.`question_code`
JOIN `ANSWER_REF` a ON a.`code` = x.`answer_code`
JOIN `USERS` u ON u.`login` = x.`login`
WHERE NOT EXISTS (
  SELECT 1
  FROM `QUESTIONS_STAT` qs
  WHERE qs.`id_question` = q.`id_question`
    AND qs.`id_user` = u.`id_user`
);

DELETE qs
FROM `QUESTIONS_STAT` qs
JOIN `QUESTIONS_STAT` keep_qs
  ON keep_qs.`id_question` = qs.`id_question`
 AND keep_qs.`id_user` = qs.`id_user`
 AND keep_qs.`id_questions_stat` < qs.`id_questions_stat`;
