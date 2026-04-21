USE `poplitic_db`;

SET NAMES utf8mb4;

SET @admin_role_id = (SELECT `id_role` FROM `ROLES` WHERE `code` = 'ADMIN' LIMIT 1);
SET @user_role_id = (SELECT `id_role` FROM `ROLES` WHERE `code` = 'USER' LIMIT 1);

INSERT IGNORE INTO `USERS` (`id_role`, `login`, `nom`, `prenom`, `genre`, `email`, `numero_electeur`, `password`, `actif`)
VALUES (@admin_role_id, 'admin', 'Admin', 'Pop', 'N/A', 'admin@pop.local', 'POP-ADMIN-0001', 'admin', 1);

INSERT IGNORE INTO `USERS` (`id_role`, `login`, `nom`, `prenom`, `genre`, `email`, `numero_electeur`, `password`, `actif`)
VALUES (@user_role_id, 'user', 'User', 'Pop', 'N/A', 'user@pop.local', 'POP-USER-0001', 'user', 1);

UPDATE `USERS`
SET `password` = CASE `login`
    WHEN 'admin' THEN 'admin'
    WHEN 'user' THEN 'user'
    ELSE 'password'
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

INSERT INTO `LANGUES_REF` (`code`, `libelle`)
SELECT 'EN', 'Anglais'
WHERE NOT EXISTS (SELECT 1 FROM `LANGUES_REF` WHERE `code` = 'EN');

INSERT INTO `LANGUES_REF` (`code`, `libelle`)
SELECT 'ES', 'Espagnol'
WHERE NOT EXISTS (SELECT 1 FROM `LANGUES_REF` WHERE `code` = 'ES');

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
