-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema poplitic_db
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `poplitic_db` ;

-- -----------------------------------------------------
-- Schema poplitic_db
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `poplitic_db` DEFAULT CHARACTER SET latin1 ;
USE `poplitic_db` ;

-- -----------------------------------------------------
-- Table `poplitic_db`.`ANSWER_REF`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poplitic_db`.`ANSWER_REF` ;

CREATE TABLE IF NOT EXISTS `poplitic_db`.`ANSWER_REF` (
  `id_answer` INT(11) NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(45) NULL DEFAULT NULL,
  `libelle` VARCHAR(256) NULL DEFAULT NULL,
  PRIMARY KEY (`id_answer`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `poplitic_db`.`STATUT_REF`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poplitic_db`.`STATUT_REF` ;

CREATE TABLE IF NOT EXISTS `poplitic_db`.`STATUT_REF` (
  `id_statut` INT(11) NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(45) NULL DEFAULT NULL,
  `libelle` VARCHAR(256) NULL DEFAULT NULL,
  PRIMARY KEY (`id_statut`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `poplitic_db`.`ROLES`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poplitic_db`.`ROLES` ;

CREATE TABLE IF NOT EXISTS `poplitic_db`.`ROLES` (
  `id_role` INT NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(45) NULL DEFAULT NULL,
  `libelle` VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (`id_role`))
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = latin1;

CREATE UNIQUE INDEX `code_UNIQUE` ON `poplitic_db`.`ROLES` (`code` ASC) ;


-- -----------------------------------------------------
-- Table `poplitic_db`.`USER_PARAMETRES`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poplitic_db`.`USER_PARAMETRES` ;

CREATE TABLE IF NOT EXISTS `poplitic_db`.`USER_PARAMETRES` (
  `id_parametre` INT(11) NOT NULL AUTO_INCREMENT,
  `notifications` TINYINT(4) NOT NULL DEFAULT 0,
  `anonymat` TINYINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_parametre`))
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = latin1;

CREATE UNIQUE INDEX `id_parameter_UNIQUE` ON `poplitic_db`.`USER_PARAMETRES` (`id_parametre` ASC) ;


-- -----------------------------------------------------
-- Table `poplitic_db`.`USER_POSITION`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poplitic_db`.`USER_POSITION` ;

CREATE TABLE IF NOT EXISTS `poplitic_db`.`USER_POSITION` (
  `id_position` INT(11) NOT NULL AUTO_INCREMENT,
  `latitude` FLOAT NULL DEFAULT NULL,
  `longitude` FLOAT NULL DEFAULT NULL,
  PRIMARY KEY (`id_position`))
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = latin1;

CREATE UNIQUE INDEX `id_position_UNIQUE` ON `poplitic_db`.`USER_POSITION` (`id_position` ASC) ;


-- -----------------------------------------------------
-- Table `poplitic_db`.`USERS`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poplitic_db`.`USERS` ;

CREATE TABLE IF NOT EXISTS `poplitic_db`.`USERS` (
  `id_user` INT(11) NOT NULL AUTO_INCREMENT,
  `id_role` INT(11) NOT NULL,
  `id_parametre` INT(11) NOT NULL,
  `id_position` INT(11) NOT NULL,
  `login` VARCHAR(45) NOT NULL,
  `nom` VARCHAR(45) NULL DEFAULT NULL,
  `prenom` VARCHAR(45) NULL DEFAULT NULL,
  `genre` VARCHAR(45) NULL DEFAULT NULL,
  `email` VARCHAR(255) NOT NULL,
  `numero_electeur` VARCHAR(45) NULL,
  `password` VARCHAR(100) NOT NULL,
  `actif` TINYINT(4) NULL DEFAULT NULL,
  `date_creation` DATETIME NULL DEFAULT NULL,
  `date_modification` DATETIME NULL DEFAULT NULL,
  `date_suppression` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id_user`, `id_role`, `id_parametre`, `id_position`),
  CONSTRAINT `fk_USERS_ROLES1`
    FOREIGN KEY (`id_role`)
    REFERENCES `poplitic_db`.`ROLES` (`id_role`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_USERS_USER_PARAMETERS1`
    FOREIGN KEY (`id_parametre`)
    REFERENCES `poplitic_db`.`USER_PARAMETRES` (`id_parametre`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_USERS_USER_POSITION1`
    FOREIGN KEY (`id_position`)
    REFERENCES `poplitic_db`.`USER_POSITION` (`id_position`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = latin1;

CREATE UNIQUE INDEX `id_user_UNIQUE` ON `poplitic_db`.`USERS` (`id_user` ASC) ;

CREATE UNIQUE INDEX `login_UNIQUE` ON `poplitic_db`.`USERS` (`login` ASC) ;

CREATE INDEX `fk_USERS_USER_POSITION1_idx` ON `poplitic_db`.`USERS` (`id_position` ASC) ;

CREATE UNIQUE INDEX `email_UNIQUE` ON `poplitic_db`.`USERS` (`email` ASC) ;


-- -----------------------------------------------------
-- Table `poplitic_db`.`QUESTIONS`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poplitic_db`.`QUESTIONS` ;

CREATE TABLE IF NOT EXISTS `poplitic_db`.`QUESTIONS` (
  `id_question` INT(11) NOT NULL AUTO_INCREMENT,
  `id_user` INT(11) NOT NULL,
  `id_statut` INT(11) NOT NULL,
  `code` VARCHAR(45) NULL DEFAULT NULL,
  `libelle` VARCHAR(255) NULL DEFAULT NULL,
  `description` TEXT NULL DEFAULT NULL,
  `image` TEXT NULL DEFAULT NULL,
  `forwards` INT NULL,
  `date_creation` DATETIME NULL DEFAULT NULL,
  `date_modification` DATETIME NULL DEFAULT NULL,
  `date_expiration` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id_question`, `id_user`, `id_statut`),
  CONSTRAINT `fk_POP_QUESTIONS_POP_STATUT_REF1`
    FOREIGN KEY (`id_statut`)
    REFERENCES `poplitic_db`.`STATUT_REF` (`id_statut`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_POP_QUESTIONS_USERS1`
    FOREIGN KEY (`id_user`)
    REFERENCES `poplitic_db`.`USERS` (`id_user`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE UNIQUE INDEX `id_question_UNIQUE` ON `poplitic_db`.`QUESTIONS` (`id_question` ASC) ;

CREATE INDEX `fk_POP_QUESTIONS_POP_STATUT_REF1_idx` ON `poplitic_db`.`QUESTIONS` (`id_statut` ASC) ;

CREATE INDEX `fk_POP_QUESTIONS_USERS1_idx` ON `poplitic_db`.`QUESTIONS` (`id_user` ASC) ;


-- -----------------------------------------------------
-- Table `poplitic_db`.`QUESTIONS_STAT`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poplitic_db`.`QUESTIONS_STAT` ;

CREATE TABLE IF NOT EXISTS `poplitic_db`.`QUESTIONS_STAT` (
  `id_questions_stat` INT(11) NOT NULL AUTO_INCREMENT,
  `id_question` INT(11) NOT NULL,
  `id_answer` INT(11) NOT NULL,
  `id_user` INT(11) NOT NULL,
  `date_creation` DATETIME NULL,
  `date_modification` DATETIME NULL,
  PRIMARY KEY (`id_questions_stat`, `id_question`, `id_answer`, `id_user`),
  CONSTRAINT `fk_POP_QUESTIONS_STAT_POP_ANSWER_REF1`
    FOREIGN KEY (`id_answer`)
    REFERENCES `poplitic_db`.`ANSWER_REF` (`id_answer`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_POP_QUESTIONS_STAT_POP_QUESTIONS1`
    FOREIGN KEY (`id_question`)
    REFERENCES `poplitic_db`.`QUESTIONS` (`id_question`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_POP_QUESTIONS_STAT_USERS1`
    FOREIGN KEY (`id_user`)
    REFERENCES `poplitic_db`.`USERS` (`id_user`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `fk_POP_QUESTIONS_STAT_POP_QUESTIONS1_idx` ON `poplitic_db`.`QUESTIONS_STAT` (`id_question` ASC) ;

CREATE INDEX `fk_POP_QUESTIONS_STAT_POP_ANSWER_REF1_idx` ON `poplitic_db`.`QUESTIONS_STAT` (`id_answer` ASC) ;

CREATE INDEX `fk_POP_QUESTIONS_STAT_USERS1_idx` ON `poplitic_db`.`QUESTIONS_STAT` (`id_user` ASC) ;


-- -----------------------------------------------------
-- Table `poplitic_db`.`USER_INTERETS_REF`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poplitic_db`.`USER_INTERETS_REF` ;

CREATE TABLE IF NOT EXISTS `poplitic_db`.`USER_INTERETS_REF` (
  `id_interet` INT(11) NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(45) NOT NULL,
  `libelle` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id_interet`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE UNIQUE INDEX `code_UNIQUE` ON `poplitic_db`.`USER_INTERETS_REF` (`code` ASC) ;


-- -----------------------------------------------------
-- Table `poplitic_db`.`USER_INTERETS`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poplitic_db`.`USER_INTERETS` ;

CREATE TABLE IF NOT EXISTS `poplitic_db`.`USER_INTERETS` (
  `id_user` INT NOT NULL,
  `id_interet` INT NOT NULL,
  `priorite` INT NULL,
  PRIMARY KEY (`id_user`, `id_interet`),
  CONSTRAINT `fk_USERS_USER_INTERETS_REF_USERS1`
    FOREIGN KEY (`id_user`)
    REFERENCES `poplitic_db`.`USERS` (`id_user`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_USERS_has_USER_INTERETS_REF_USER_INTERETS_REF1`
    FOREIGN KEY (`id_interet`)
    REFERENCES `poplitic_db`.`USER_INTERETS_REF` (`id_interet`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `fk_POP_USERS_has_USER_INTERETS_REF_USER_INTERETS_REF1_idx` ON `poplitic_db`.`USER_INTERETS` (`id_interet` ASC) ;

CREATE INDEX `fk_POP_USERS_has_USER_INTERETS_REF_POP_USERS1_idx` ON `poplitic_db`.`USER_INTERETS` (`id_user` ASC) ;


-- -----------------------------------------------------
-- Table `poplitic_db`.`USER_ADRESSE`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poplitic_db`.`USER_ADRESSE` ;

CREATE TABLE IF NOT EXISTS `poplitic_db`.`USER_ADRESSE` (
  `id_adresse` INT NOT NULL AUTO_INCREMENT,
  `id_user` INT NOT NULL,
  `rue` VARCHAR(45) NULL DEFAULT NULL,
  `complement` VARCHAR(45) NULL DEFAULT NULL,
  `ville` VARCHAR(45) NULL DEFAULT NULL,
  `codepostal` VARCHAR(45) NULL DEFAULT NULL,
  `pays` VARCHAR(45) NULL DEFAULT NULL,
  `telephone` VARCHAR(45) NULL,
  PRIMARY KEY (`id_adresse`, `id_user`),
  CONSTRAINT `fk_USER_ADRESSE_USERS`
    FOREIGN KEY (`id_user`)
    REFERENCES `poplitic_db`.`USERS` (`id_user`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `poplitic_db`.`PAYS_REF`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poplitic_db`.`PAYS_REF` ;

CREATE TABLE IF NOT EXISTS `poplitic_db`.`PAYS_REF` (
  `id_pays` INT NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(45) NULL,
  `libelle` VARCHAR(255) NULL,
  PRIMARY KEY (`id_pays`))
ENGINE = InnoDB
AUTO_INCREMENT = 1;


-- -----------------------------------------------------
-- Table `poplitic_db`.`DEPT_REF`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poplitic_db`.`DEPT_REF` ;

CREATE TABLE IF NOT EXISTS `poplitic_db`.`DEPT_REF` (
  `id_dept` INT NOT NULL AUTO_INCREMENT,
  `id_pays` INT NOT NULL,
  `code` VARCHAR(45) NULL,
  `libelle` VARCHAR(255) NULL,
  PRIMARY KEY (`id_dept`, `id_pays`),
  CONSTRAINT `fk_DEPT_REF_PAYS_REF1`
    FOREIGN KEY (`id_pays`)
    REFERENCES `poplitic_db`.`PAYS_REF` (`id_pays`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 1;

CREATE INDEX `fk_DEPT_REF_PAYS_REF1_idx` ON `poplitic_db`.`DEPT_REF` (`id_pays` ASC) ;


-- -----------------------------------------------------
-- Table `poplitic_db`.`VILLE_REF`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poplitic_db`.`VILLE_REF` ;

CREATE TABLE IF NOT EXISTS `poplitic_db`.`VILLE_REF` (
  `id_ville` INT NOT NULL AUTO_INCREMENT,
  `id_dept` INT NOT NULL,
  `code` VARCHAR(45) NULL,
  `libelle` VARCHAR(255) NULL,
  PRIMARY KEY (`id_ville`, `id_dept`),
  CONSTRAINT `fk_VILLE_REF_DEPT_REF1`
    FOREIGN KEY (`id_dept`)
    REFERENCES `poplitic_db`.`DEPT_REF` (`id_dept`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 1;

CREATE INDEX `fk_VILLE_REF_DEPT_REF1_idx` ON `poplitic_db`.`VILLE_REF` (`id_dept` ASC) ;


-- -----------------------------------------------------
-- Table `poplitic_db`.`USER_CHOIX_GEO`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poplitic_db`.`USER_CHOIX_GEO` ;

CREATE TABLE IF NOT EXISTS `poplitic_db`.`USER_CHOIX_GEO` (
  `id_user` INT NOT NULL,
  `id_ville` INT NULL,
  `id_pays` INT NULL,
  `id_dept` INT NULL,
  `USER_CHOIX_GEOcol` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id_user`, `USER_CHOIX_GEOcol`),
  CONSTRAINT `fk_USERS_has_VILLE_REF_USERS1`
    FOREIGN KEY (`id_user`)
    REFERENCES `poplitic_db`.`USERS` (`id_user`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_USERS_CHOIX_GEO_VILLE_REF1`
    FOREIGN KEY (`id_ville`)
    REFERENCES `poplitic_db`.`VILLE_REF` (`id_ville`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_USERS_CHOIX_GEO_PAYS_REF1`
    FOREIGN KEY (`id_pays`)
    REFERENCES `poplitic_db`.`PAYS_REF` (`id_pays`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_USERS_CHOIX_GEO_DEPT_REF1`
    FOREIGN KEY (`id_dept`)
    REFERENCES `poplitic_db`.`DEPT_REF` (`id_dept`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `fk_USERS_has_VILLE_REF_USERS1_idx` ON `poplitic_db`.`USER_CHOIX_GEO` (`id_user` ASC) ;

CREATE INDEX `fk_USERS_CHOIX_GEO_VILLE_REF1_idx` ON `poplitic_db`.`USER_CHOIX_GEO` (`id_ville` ASC) ;

CREATE INDEX `fk_USERS_CHOIX_GEO_PAYS_REF1_idx` ON `poplitic_db`.`USER_CHOIX_GEO` (`id_pays` ASC) ;

CREATE INDEX `fk_USERS_CHOIX_GEO_DEPT_REF1_idx` ON `poplitic_db`.`USER_CHOIX_GEO` (`id_dept` ASC) ;


-- -----------------------------------------------------
-- Table `poplitic_db`.`LANGUES_REF`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poplitic_db`.`LANGUES_REF` ;

CREATE TABLE IF NOT EXISTS `poplitic_db`.`LANGUES_REF` (
  `id_langue` INT NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(45) NULL,
  `libelle` VARCHAR(255) NULL,
  PRIMARY KEY (`id_langue`))
ENGINE = InnoDB;

CREATE UNIQUE INDEX `code_UNIQUE` ON `poplitic_db`.`LANGUES_REF` (`code` ASC) ;


-- -----------------------------------------------------
-- Table `poplitic_db`.`USER_PARAMETRES_LANGUE`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poplitic_db`.`USER_PARAMETRES_LANGUE` ;

CREATE TABLE IF NOT EXISTS `poplitic_db`.`USER_PARAMETRES_LANGUE` (
  `id_parametre` INT NOT NULL,
  `id_langue` INT NOT NULL,
  `ordre` INT NULL,
  PRIMARY KEY (`id_parametre`, `id_langue`),
  CONSTRAINT `fk_USER_PARAMETRES_has_LANGUE_REF_USER_PARAMETRES1`
    FOREIGN KEY (`id_parametre`)
    REFERENCES `poplitic_db`.`USER_PARAMETRES` (`id_parametre`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_USER_PARAMETRES_LANGUE_LANGUES_REf1`
    FOREIGN KEY (`id_langue`)
    REFERENCES `poplitic_db`.`LANGUES_REF` (`id_langue`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `fk_USER_PARAMETRES_has_LANGUE_REF_USER_PARAMETRES1_idx` ON `poplitic_db`.`USER_PARAMETRES_LANGUE` (`id_parametre` ASC) ;

CREATE INDEX `fk_USER_PARAMETRES_LANGUE_LANGUES_REf1_idx` ON `poplitic_db`.`USER_PARAMETRES_LANGUE` (`id_langue` ASC) ;


-- -----------------------------------------------------
-- Table `poplitic_db`.`QUESTION_CHOIX_GEO`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poplitic_db`.`QUESTION_CHOIX_GEO` ;

CREATE TABLE IF NOT EXISTS `poplitic_db`.`QUESTION_CHOIX_GEO` (
  `id_question_choix_geo` INT NOT NULL AUTO_INCREMENT,
  `id_question` INT(11) NOT NULL,
  `id_ville` INT NULL,
  `id_pays` INT NULL,
  `id_dept` INT NULL,
  PRIMARY KEY (`id_question_choix_geo`),
  CONSTRAINT `fk_USERS_CHOIX_GEO_VILLE_REF10`
    FOREIGN KEY (`id_ville`)
    REFERENCES `poplitic_db`.`VILLE_REF` (`id_ville`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_USERS_CHOIX_GEO_PAYS_REF10`
    FOREIGN KEY (`id_pays`)
    REFERENCES `poplitic_db`.`PAYS_REF` (`id_pays`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_USERS_CHOIX_GEO_DEPT_REF10`
    FOREIGN KEY (`id_dept`)
    REFERENCES `poplitic_db`.`DEPT_REF` (`id_dept`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_QUESTION_CHOIX_GEO_POP_QUESTIONS1`
    FOREIGN KEY (`id_question`)
    REFERENCES `poplitic_db`.`QUESTIONS` (`id_question`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `fk_USERS_CHOIX_GEO_VILLE_REF1_idx` ON `poplitic_db`.`QUESTION_CHOIX_GEO` (`id_ville` ASC) ;

CREATE INDEX `fk_USERS_CHOIX_GEO_PAYS_REF1_idx` ON `poplitic_db`.`QUESTION_CHOIX_GEO` (`id_pays` ASC) ;

CREATE INDEX `fk_USERS_CHOIX_GEO_DEPT_REF1_idx` ON `poplitic_db`.`QUESTION_CHOIX_GEO` (`id_dept` ASC) ;

CREATE INDEX `fk_QUESTION_CHOIX_GEO_POP_QUESTIONS1_idx` ON `poplitic_db`.`QUESTION_CHOIX_GEO` (`id_question` ASC) ;


-- -----------------------------------------------------
-- Table `poplitic_db`.`QUESTION_INTERETS`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `poplitic_db`.`QUESTION_INTERETS` ;

CREATE TABLE IF NOT EXISTS `poplitic_db`.`QUESTION_INTERETS` (
  `id_question` INT(11) NOT NULL,
  `id_interet` INT NOT NULL,
  `priorite` INT NULL,
  PRIMARY KEY (`id_question`, `id_interet`),
  CONSTRAINT `fk_USERS_has_USER_INTERETS_REF_USER_INTERETS_REF10`
    FOREIGN KEY (`id_interet`)
    REFERENCES `poplitic_db`.`USER_INTERETS_REF` (`id_interet`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_USER_INTERETS_copy1_POP_QUESTIONS1`
    FOREIGN KEY (`id_question`)
    REFERENCES `poplitic_db`.`QUESTIONS` (`id_question`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `fk_POP_USERS_has_USER_INTERETS_REF_USER_INTERETS_REF1_idx` ON `poplitic_db`.`QUESTION_INTERETS` (`id_interet` ASC) ;

CREATE INDEX `fk_USER_INTERETS_copy1_POP_QUESTIONS1_idx` ON `poplitic_db`.`QUESTION_INTERETS` (`id_question` ASC) ;

USE `poplitic_db`;

DELIMITER $$

USE `poplitic_db`$$
DROP TRIGGER IF EXISTS `poplitic_db`.`USERS_BEFORE_INSERT` $$
USE `poplitic_db`$$
CREATE
DEFINER = CURRENT_USER
TRIGGER `poplitic_db`.`USERS_BEFORE_INSERT`
BEFORE INSERT ON `poplitic_db`.`USERS`
FOR EACH ROW
BEGIN
	INSERT INTO `poplitic_db`.`USER_PARAMETRES` () VALUES ();
    SET NEW.id_parametre = LAST_INSERT_id();
    
    INSERT INTO `poplitic_db`.`USER_PARAMETRES_LANGUE` (`id_parametre`, `id_langue`) VALUES (LAST_INSERT_id(), 1);
    
    INSERT INTO `poplitic_db`.`USER_POSITION` (`latitude`, `longitude`) VALUES (null,null);
    SET NEW.id_position = LAST_INSERT_id();
    
    SET NEW.date_creation = NOW();
END$$


USE `poplitic_db`$$
DROP TRIGGER IF EXISTS `poplitic_db`.`USERS_AFTER_INSERT` $$
USE `poplitic_db`$$
CREATE
DEFINER = CURRENT_USER
TRIGGER `poplitic_db`.`USERS_AFTER_INSERT`
AFTER INSERT ON `poplitic_db`.`USERS`
FOR EACH ROW
BEGIN
	INSERT INTO `poplitic_db`.`USER_ADRESSE` (id_user) VALUES (NEW.id_user);
END$$


USE `poplitic_db`$$
DROP TRIGGER IF EXISTS `poplitic_db`.`USERS_BEFORE_UPDATE` $$
USE `poplitic_db`$$
CREATE
DEFINER = CURRENT_USER
TRIGGER `poplitic_db`.`USERS_BEFORE_UPDATE`
BEFORE UPDATE ON `poplitic_db`.`USERS`
FOR EACH ROW
BEGIN
	SET NEW.date_modification = NOW();
END$$


USE `poplitic_db`$$
DROP TRIGGER IF EXISTS `poplitic_db`.`QUESTIONS_BEFORE_INSERT` $$
USE `poplitic_db`$$
CREATE
DEFINER = CURRENT_USER
TRIGGER `poplitic_db`.`QUESTIONS_BEFORE_INSERT`
BEFORE INSERT ON `poplitic_db`.`QUESTIONS`
FOR EACH ROW
BEGIN
	SET NEW.date_creation = NOW();
END$$


USE `poplitic_db`$$
DROP TRIGGER IF EXISTS `poplitic_db`.`QUESTIONS_BEFORE_UPDATE` $$
USE `poplitic_db`$$
CREATE
DEFINER = CURRENT_USER
TRIGGER `poplitic_db`.`QUESTIONS_BEFORE_UPDATE`
BEFORE UPDATE ON `poplitic_db`.`QUESTIONS`
FOR EACH ROW
BEGIN
	SET NEW.date_modification = NOW();
END$$


USE `poplitic_db`$$
DROP TRIGGER IF EXISTS `poplitic_db`.`QUESTIONS_STAT_BEFORE_INSERT` $$
USE `poplitic_db`$$
CREATE DEFINER = CURRENT_USER TRIGGER `poplitic_db`.`QUESTIONS_STAT_BEFORE_INSERT` BEFORE INSERT ON `QUESTIONS_STAT` FOR EACH ROW
BEGIN
	SET NEW.date_creation = NOW();
END$$


USE `poplitic_db`$$
DROP TRIGGER IF EXISTS `poplitic_db`.`QUESTIONS_STAT_BEFORE_UPDATE` $$
USE `poplitic_db`$$
CREATE DEFINER = CURRENT_USER TRIGGER `poplitic_db`.`QUESTIONS_STAT_BEFORE_UPDATE` BEFORE UPDATE ON `QUESTIONS_STAT` FOR EACH ROW
BEGIN
	SET NEW.date_modification = NOW();
END$$


DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
