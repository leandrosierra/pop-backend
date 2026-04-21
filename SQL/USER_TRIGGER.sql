USE `poplitic_db`;

DELIMITER $$

DROP TRIGGER IF EXISTS `poplitic_db`.`USERS_BEFORE_INSERT` $$
CREATE DEFINER = CURRENT_USER TRIGGER `poplitic_db`.`USERS_BEFORE_INSERT`
BEFORE INSERT ON `poplitic_db`.`USERS`
FOR EACH ROW
BEGIN
    DECLARE default_language_id INT;

    INSERT INTO `poplitic_db`.`USER_PARAMETRES` () VALUES ();
    SET NEW.`id_parametre` = LAST_INSERT_ID();

    SELECT `id_langue`
    INTO default_language_id
    FROM `poplitic_db`.`LANGUES_REF`
    WHERE `code` = 'FR'
    LIMIT 1;

    INSERT INTO `poplitic_db`.`USER_PARAMETRES_LANGUE` (`id_parametre`, `id_langue`)
    VALUES (LAST_INSERT_ID(), default_language_id);

    INSERT INTO `poplitic_db`.`USER_POSITION` (`latitude`, `longitude`) VALUES (NULL, NULL);
    SET NEW.`id_position` = LAST_INSERT_ID();

    SET NEW.`date_creation` = NOW();
END$$

DROP TRIGGER IF EXISTS `poplitic_db`.`USERS_AFTER_INSERT` $$
CREATE DEFINER = CURRENT_USER TRIGGER `poplitic_db`.`USERS_AFTER_INSERT`
AFTER INSERT ON `poplitic_db`.`USERS`
FOR EACH ROW
BEGIN
    INSERT INTO `poplitic_db`.`USER_ADRESSE` (`id_user`) VALUES (NEW.`id_user`);
END$$

DROP TRIGGER IF EXISTS `poplitic_db`.`USERS_BEFORE_UPDATE` $$
CREATE DEFINER = CURRENT_USER TRIGGER `poplitic_db`.`USERS_BEFORE_UPDATE`
BEFORE UPDATE ON `poplitic_db`.`USERS`
FOR EACH ROW
BEGIN
    SET NEW.`date_modification` = NOW();
END$$

DELIMITER ;
