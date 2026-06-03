-- PostgreSQL schema for poplitic (migrated from MySQL Workbench export).
-- The application runs with Hibernate ddl-auto=update, which creates/updates the
-- tables from the JPA entities at boot. This script is the source of truth for the
-- schema and the triggers (Hibernate does NOT manage triggers). Table/column names
-- are unquoted -> PostgreSQL folds them to lower case, matching what Hibernate emits.

-- -----------------------------------------------------
-- Reference tables (no FK)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS ANSWER_REF (
  id_answer SERIAL PRIMARY KEY,
  code VARCHAR(45) DEFAULT NULL,
  libelle VARCHAR(256) DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS STATUT_REF (
  id_statut SERIAL PRIMARY KEY,
  code VARCHAR(45) DEFAULT NULL,
  libelle VARCHAR(256) DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS ROLES (
  id_role SERIAL PRIMARY KEY,
  code VARCHAR(45) DEFAULT NULL,
  libelle VARCHAR(255) DEFAULT NULL
);
CREATE UNIQUE INDEX IF NOT EXISTS code_UNIQUE_ROLES ON ROLES (code);

CREATE TABLE IF NOT EXISTS USER_PARAMETRES (
  id_parametre SERIAL PRIMARY KEY,
  notifications SMALLINT NOT NULL DEFAULT 0,
  anonymat SMALLINT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS USER_POSITION (
  id_position SERIAL PRIMARY KEY,
  latitude REAL DEFAULT NULL,
  longitude REAL DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS PAYS_REF (
  id_pays SERIAL PRIMARY KEY,
  code VARCHAR(45),
  libelle VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS DEPT_REF (
  id_dept SERIAL PRIMARY KEY,
  id_pays INT NOT NULL,
  code VARCHAR(45),
  libelle VARCHAR(255),
  CONSTRAINT fk_DEPT_REF_PAYS_REF1 FOREIGN KEY (id_pays) REFERENCES PAYS_REF (id_pays)
);
CREATE INDEX IF NOT EXISTS fk_DEPT_REF_PAYS_REF1_idx ON DEPT_REF (id_pays);

CREATE TABLE IF NOT EXISTS VILLE_REF (
  id_ville SERIAL PRIMARY KEY,
  id_dept INT NOT NULL,
  code VARCHAR(45),
  libelle VARCHAR(255),
  CONSTRAINT fk_VILLE_REF_DEPT_REF1 FOREIGN KEY (id_dept) REFERENCES DEPT_REF (id_dept)
);
CREATE INDEX IF NOT EXISTS fk_VILLE_REF_DEPT_REF1_idx ON VILLE_REF (id_dept);

CREATE TABLE IF NOT EXISTS LANGUES_REF (
  id_langue SERIAL PRIMARY KEY,
  code VARCHAR(45),
  libelle VARCHAR(255)
);
CREATE UNIQUE INDEX IF NOT EXISTS code_UNIQUE_LANGUES ON LANGUES_REF (code);

CREATE TABLE IF NOT EXISTS USER_INTERETS_REF (
  id_interet SERIAL PRIMARY KEY,
  code VARCHAR(45) NOT NULL,
  libelle VARCHAR(255) NOT NULL
);
CREATE UNIQUE INDEX IF NOT EXISTS code_UNIQUE_USER_INTERETS_REF ON USER_INTERETS_REF (code);

-- -----------------------------------------------------
-- USERS and dependents
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS USERS (
  id_user SERIAL,
  id_role INT NOT NULL,
  id_parametre INT NOT NULL,
  id_position INT NOT NULL,
  login VARCHAR(45) NOT NULL,
  nom VARCHAR(45) DEFAULT NULL,
  prenom VARCHAR(45) DEFAULT NULL,
  genre VARCHAR(45) DEFAULT NULL,
  email VARCHAR(255) NOT NULL,
  numero_electeur VARCHAR(45),
  password VARCHAR(100) NOT NULL,
  actif SMALLINT DEFAULT NULL,
  date_creation TIMESTAMP DEFAULT NULL,
  date_modification TIMESTAMP DEFAULT NULL,
  date_suppression TIMESTAMP DEFAULT NULL,
  PRIMARY KEY (id_user, id_role, id_parametre, id_position),
  CONSTRAINT fk_USERS_ROLES1 FOREIGN KEY (id_role) REFERENCES ROLES (id_role),
  CONSTRAINT fk_USERS_USER_PARAMETERS1 FOREIGN KEY (id_parametre) REFERENCES USER_PARAMETRES (id_parametre),
  CONSTRAINT fk_USERS_USER_POSITION1 FOREIGN KEY (id_position) REFERENCES USER_POSITION (id_position)
);
CREATE UNIQUE INDEX IF NOT EXISTS id_user_UNIQUE ON USERS (id_user);
CREATE UNIQUE INDEX IF NOT EXISTS login_UNIQUE ON USERS (login);
CREATE UNIQUE INDEX IF NOT EXISTS email_UNIQUE ON USERS (email);
CREATE INDEX IF NOT EXISTS fk_USERS_USER_POSITION1_idx ON USERS (id_position);

CREATE TABLE IF NOT EXISTS USER_ADRESSE (
  id_adresse SERIAL,
  id_user INT NOT NULL,
  rue VARCHAR(45) DEFAULT NULL,
  complement VARCHAR(45) DEFAULT NULL,
  ville VARCHAR(45) DEFAULT NULL,
  codepostal VARCHAR(45) DEFAULT NULL,
  pays VARCHAR(45) DEFAULT NULL,
  telephone VARCHAR(45),
  PRIMARY KEY (id_adresse, id_user),
  CONSTRAINT fk_USER_ADRESSE_USERS FOREIGN KEY (id_user) REFERENCES USERS (id_user)
);

CREATE TABLE IF NOT EXISTS USER_INTERETS (
  id_user INT NOT NULL,
  id_interet INT NOT NULL,
  priorite INT,
  PRIMARY KEY (id_user, id_interet),
  CONSTRAINT fk_USERS_USER_INTERETS_REF_USERS1 FOREIGN KEY (id_user) REFERENCES USERS (id_user),
  CONSTRAINT fk_USERS_has_USER_INTERETS_REF_USER_INTERETS_REF1 FOREIGN KEY (id_interet) REFERENCES USER_INTERETS_REF (id_interet)
);
CREATE INDEX IF NOT EXISTS fk_USER_INTERETS_interet_idx ON USER_INTERETS (id_interet);
CREATE INDEX IF NOT EXISTS fk_USER_INTERETS_user_idx ON USER_INTERETS (id_user);

CREATE TABLE IF NOT EXISTS USER_CHOIX_GEO (
  id_user INT NOT NULL,
  id_ville INT,
  id_pays INT,
  id_dept INT,
  USER_CHOIX_GEOcol VARCHAR(45) NOT NULL,
  PRIMARY KEY (id_user, USER_CHOIX_GEOcol),
  CONSTRAINT fk_USERS_has_VILLE_REF_USERS1 FOREIGN KEY (id_user) REFERENCES USERS (id_user),
  CONSTRAINT fk_USERS_CHOIX_GEO_VILLE_REF1 FOREIGN KEY (id_ville) REFERENCES VILLE_REF (id_ville),
  CONSTRAINT fk_USERS_CHOIX_GEO_PAYS_REF1 FOREIGN KEY (id_pays) REFERENCES PAYS_REF (id_pays),
  CONSTRAINT fk_USERS_CHOIX_GEO_DEPT_REF1 FOREIGN KEY (id_dept) REFERENCES DEPT_REF (id_dept)
);
CREATE INDEX IF NOT EXISTS fk_UCG_user_idx ON USER_CHOIX_GEO (id_user);
CREATE INDEX IF NOT EXISTS fk_UCG_ville_idx ON USER_CHOIX_GEO (id_ville);
CREATE INDEX IF NOT EXISTS fk_UCG_pays_idx ON USER_CHOIX_GEO (id_pays);
CREATE INDEX IF NOT EXISTS fk_UCG_dept_idx ON USER_CHOIX_GEO (id_dept);

CREATE TABLE IF NOT EXISTS USER_PARAMETRES_LANGUE (
  id_parametre INT NOT NULL,
  id_langue INT NOT NULL,
  ordre INT,
  PRIMARY KEY (id_parametre, id_langue),
  CONSTRAINT fk_UPL_PARAMETRES1 FOREIGN KEY (id_parametre) REFERENCES USER_PARAMETRES (id_parametre),
  CONSTRAINT fk_UPL_LANGUES1 FOREIGN KEY (id_langue) REFERENCES LANGUES_REF (id_langue)
);
CREATE INDEX IF NOT EXISTS fk_UPL_parametre_idx ON USER_PARAMETRES_LANGUE (id_parametre);
CREATE INDEX IF NOT EXISTS fk_UPL_langue_idx ON USER_PARAMETRES_LANGUE (id_langue);

-- -----------------------------------------------------
-- QUESTIONS and dependents
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS QUESTIONS (
  id_question SERIAL,
  id_user INT NOT NULL,
  id_statut INT NOT NULL,
  code VARCHAR(45) DEFAULT NULL,
  libelle VARCHAR(255) DEFAULT NULL,
  description TEXT DEFAULT NULL,
  image TEXT DEFAULT NULL,
  forwards INT,
  date_creation TIMESTAMP DEFAULT NULL,
  date_modification TIMESTAMP DEFAULT NULL,
  date_expiration TIMESTAMP DEFAULT NULL,
  PRIMARY KEY (id_question, id_user, id_statut),
  CONSTRAINT fk_QUESTIONS_STATUT_REF1 FOREIGN KEY (id_statut) REFERENCES STATUT_REF (id_statut),
  CONSTRAINT fk_QUESTIONS_USERS1 FOREIGN KEY (id_user) REFERENCES USERS (id_user)
);
CREATE UNIQUE INDEX IF NOT EXISTS id_question_UNIQUE ON QUESTIONS (id_question);
CREATE INDEX IF NOT EXISTS fk_QUESTIONS_statut_idx ON QUESTIONS (id_statut);
CREATE INDEX IF NOT EXISTS fk_QUESTIONS_user_idx ON QUESTIONS (id_user);

CREATE TABLE IF NOT EXISTS QUESTIONS_STAT (
  id_questions_stat SERIAL,
  id_question INT NOT NULL,
  id_answer INT NOT NULL,
  id_user INT NOT NULL,
  date_creation TIMESTAMP,
  date_modification TIMESTAMP,
  PRIMARY KEY (id_questions_stat, id_question, id_answer, id_user),
  CONSTRAINT fk_QS_ANSWER_REF1 FOREIGN KEY (id_answer) REFERENCES ANSWER_REF (id_answer),
  CONSTRAINT fk_QS_QUESTIONS1 FOREIGN KEY (id_question) REFERENCES QUESTIONS (id_question),
  CONSTRAINT fk_QS_USERS1 FOREIGN KEY (id_user) REFERENCES USERS (id_user)
);
CREATE INDEX IF NOT EXISTS fk_QS_question_idx ON QUESTIONS_STAT (id_question);
CREATE INDEX IF NOT EXISTS fk_QS_answer_idx ON QUESTIONS_STAT (id_answer);
CREATE INDEX IF NOT EXISTS fk_QS_user_idx ON QUESTIONS_STAT (id_user);

CREATE TABLE IF NOT EXISTS QUESTION_CHOIX_GEO (
  id_question_choix_geo SERIAL PRIMARY KEY,
  id_question INT NOT NULL,
  id_ville INT,
  id_pays INT,
  id_dept INT,
  CONSTRAINT fk_QCG_VILLE_REF FOREIGN KEY (id_ville) REFERENCES VILLE_REF (id_ville),
  CONSTRAINT fk_QCG_PAYS_REF FOREIGN KEY (id_pays) REFERENCES PAYS_REF (id_pays),
  CONSTRAINT fk_QCG_DEPT_REF FOREIGN KEY (id_dept) REFERENCES DEPT_REF (id_dept),
  CONSTRAINT fk_QCG_QUESTIONS FOREIGN KEY (id_question) REFERENCES QUESTIONS (id_question)
);
CREATE INDEX IF NOT EXISTS fk_QCG_ville_idx ON QUESTION_CHOIX_GEO (id_ville);
CREATE INDEX IF NOT EXISTS fk_QCG_pays_idx ON QUESTION_CHOIX_GEO (id_pays);
CREATE INDEX IF NOT EXISTS fk_QCG_dept_idx ON QUESTION_CHOIX_GEO (id_dept);
CREATE INDEX IF NOT EXISTS fk_QCG_question_idx ON QUESTION_CHOIX_GEO (id_question);

CREATE TABLE IF NOT EXISTS QUESTION_INTERETS (
  id_question INT NOT NULL,
  id_interet INT NOT NULL,
  priorite INT,
  PRIMARY KEY (id_question, id_interet),
  CONSTRAINT fk_QI_INTERETS_REF FOREIGN KEY (id_interet) REFERENCES USER_INTERETS_REF (id_interet),
  CONSTRAINT fk_QI_QUESTIONS FOREIGN KEY (id_question) REFERENCES QUESTIONS (id_question)
);
CREATE INDEX IF NOT EXISTS fk_QI_interet_idx ON QUESTION_INTERETS (id_interet);
CREATE INDEX IF NOT EXISTS fk_QI_question_idx ON QUESTION_INTERETS (id_question);

CREATE TABLE IF NOT EXISTS QUESTION_COMMENTS (
  id_comment SERIAL PRIMARY KEY,
  id_question INT NOT NULL,
  id_user INT NOT NULL,
  id_parent_comment INT,
  contenu TEXT NOT NULL,
  date_creation TIMESTAMP,
  date_modification TIMESTAMP,
  CONSTRAINT fk_QC_QUESTIONS FOREIGN KEY (id_question) REFERENCES QUESTIONS (id_question),
  CONSTRAINT fk_QC_USERS FOREIGN KEY (id_user) REFERENCES USERS (id_user),
  CONSTRAINT fk_QC_PARENT FOREIGN KEY (id_parent_comment) REFERENCES QUESTION_COMMENTS (id_comment) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS fk_QC_question_idx ON QUESTION_COMMENTS (id_question);
CREATE INDEX IF NOT EXISTS fk_QC_user_idx ON QUESTION_COMMENTS (id_user);
CREATE INDEX IF NOT EXISTS fk_QC_parent_idx ON QUESTION_COMMENTS (id_parent_comment);

CREATE TABLE IF NOT EXISTS QUESTION_MEETINGS (
  id_meeting SERIAL PRIMARY KEY,
  id_question INT NOT NULL,
  id_user INT NOT NULL,
  type_meeting VARCHAR(20) NOT NULL,
  titre VARCHAR(255),
  description TEXT,
  lieu VARCHAR(255),
  url TEXT,
  date_debut TIMESTAMP,
  date_fin TIMESTAMP,
  date_creation TIMESTAMP,
  date_modification TIMESTAMP,
  CONSTRAINT fk_QM_QUESTIONS FOREIGN KEY (id_question) REFERENCES QUESTIONS (id_question),
  CONSTRAINT fk_QM_USERS FOREIGN KEY (id_user) REFERENCES USERS (id_user)
);
CREATE INDEX IF NOT EXISTS fk_QM_question_idx ON QUESTION_MEETINGS (id_question);
CREATE INDEX IF NOT EXISTS fk_QM_user_idx ON QUESTION_MEETINGS (id_user);

-- -----------------------------------------------------
-- BUDGETS
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS BUDGETS (
  id_budget SERIAL PRIMARY KEY,
  niveau VARCHAR(20) NOT NULL,
  code_territoire VARCHAR(45) NOT NULL,
  libelle_territoire VARCHAR(255),
  annee INT,
  montant_total NUMERIC(15,2),
  date_creation TIMESTAMP,
  date_modification TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_BUDGETS_TERRITOIRE ON BUDGETS (niveau, code_territoire, annee);

CREATE TABLE IF NOT EXISTS BUDGET_POSTES (
  id_budget_poste SERIAL PRIMARY KEY,
  id_budget INT NOT NULL,
  code VARCHAR(45),
  libelle VARCHAR(255),
  description TEXT,
  montant_actuel NUMERIC(15,2),
  CONSTRAINT fk_BP_BUDGETS FOREIGN KEY (id_budget) REFERENCES BUDGETS (id_budget)
);
CREATE INDEX IF NOT EXISTS fk_BP_budget_idx ON BUDGET_POSTES (id_budget);

CREATE TABLE IF NOT EXISTS BUDGET_IMPACTS (
  id_budget_impact SERIAL PRIMARY KEY,
  id_budget_poste INT NOT NULL,
  sens VARCHAR(20) NOT NULL,
  libelle VARCHAR(255),
  description TEXT,
  seuil_pourcentage NUMERIC(7,2),
  CONSTRAINT fk_BI_BUDGET_POSTES FOREIGN KEY (id_budget_poste) REFERENCES BUDGET_POSTES (id_budget_poste)
);
CREATE INDEX IF NOT EXISTS fk_BI_poste_idx ON BUDGET_IMPACTS (id_budget_poste);

CREATE TABLE IF NOT EXISTS BUDGET_CHOIX (
  id_budget_choix SERIAL PRIMARY KEY,
  id_budget INT NOT NULL,
  id_user INT NOT NULL,
  date_creation TIMESTAMP,
  date_modification TIMESTAMP,
  CONSTRAINT fk_BC_BUDGETS FOREIGN KEY (id_budget) REFERENCES BUDGETS (id_budget),
  CONSTRAINT fk_BC_USERS FOREIGN KEY (id_user) REFERENCES USERS (id_user)
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_BUDGET_CHOIX_USER ON BUDGET_CHOIX (id_budget, id_user);
CREATE INDEX IF NOT EXISTS fk_BC_user_idx ON BUDGET_CHOIX (id_user);

CREATE TABLE IF NOT EXISTS BUDGET_CHOIX_POSTES (
  id_budget_choix_poste SERIAL PRIMARY KEY,
  id_budget_choix INT NOT NULL,
  id_budget_poste INT NOT NULL,
  montant NUMERIC(15,2),
  CONSTRAINT fk_BCP_BUDGET_CHOIX FOREIGN KEY (id_budget_choix) REFERENCES BUDGET_CHOIX (id_budget_choix),
  CONSTRAINT fk_BCP_BUDGET_POSTES FOREIGN KEY (id_budget_poste) REFERENCES BUDGET_POSTES (id_budget_poste)
);
CREATE INDEX IF NOT EXISTS fk_BCP_choix_idx ON BUDGET_CHOIX_POSTES (id_budget_choix);
CREATE INDEX IF NOT EXISTS fk_BCP_poste_idx ON BUDGET_CHOIX_POSTES (id_budget_poste);

-- -----------------------------------------------------
-- ACTUALITES / LOIS / PROPOSITIONS
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS ACTUALITES (
  id_actualite SERIAL PRIMARY KEY,
  source VARCHAR(255),
  titre VARCHAR(255) NOT NULL,
  resume TEXT,
  url TEXT,
  date_publication TIMESTAMP,
  date_creation TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_ACTUALITES_DATE_PUBLICATION ON ACTUALITES (date_publication);

CREATE TABLE IF NOT EXISTS QUESTION_SUGGESTIONS (
  id_question_suggestion SERIAL PRIMARY KEY,
  id_actualite INT NOT NULL,
  id_question INT,
  statut VARCHAR(45),
  titre VARCHAR(255),
  description TEXT,
  date_creation TIMESTAMP,
  date_modification TIMESTAMP,
  CONSTRAINT fk_QSUG_ACTUALITES FOREIGN KEY (id_actualite) REFERENCES ACTUALITES (id_actualite),
  CONSTRAINT fk_QSUG_QUESTIONS FOREIGN KEY (id_question) REFERENCES QUESTIONS (id_question)
);
CREATE INDEX IF NOT EXISTS fk_QSUG_actualite_idx ON QUESTION_SUGGESTIONS (id_actualite);
CREATE INDEX IF NOT EXISTS fk_QSUG_question_idx ON QUESTION_SUGGESTIONS (id_question);

CREATE TABLE IF NOT EXISTS LOIS (
  id_loi SERIAL PRIMARY KEY,
  code VARCHAR(45),
  titre VARCHAR(255),
  contenu TEXT,
  source VARCHAR(255),
  date_publication TIMESTAMP,
  date_creation TIMESTAMP,
  date_modification TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_LOIS_CODE ON LOIS (code);

CREATE TABLE IF NOT EXISTS LOI_INCOHERENCES (
  id_loi_incoherence SERIAL PRIMARY KEY,
  id_loi INT NOT NULL,
  id_loi_reference INT NOT NULL,
  description TEXT,
  correction_proposee TEXT,
  statut VARCHAR(45),
  date_creation TIMESTAMP,
  date_modification TIMESTAMP,
  CONSTRAINT fk_LI_LOIS FOREIGN KEY (id_loi) REFERENCES LOIS (id_loi),
  CONSTRAINT fk_LI_LOIS_REF FOREIGN KEY (id_loi_reference) REFERENCES LOIS (id_loi)
);
CREATE INDEX IF NOT EXISTS fk_LI_loi_idx ON LOI_INCOHERENCES (id_loi);
CREATE INDEX IF NOT EXISTS fk_LI_loiref_idx ON LOI_INCOHERENCES (id_loi_reference);

CREATE TABLE IF NOT EXISTS PROPOSITIONS_LOI (
  id_proposition_loi SERIAL PRIMARY KEY,
  id_question INT NOT NULL,
  id_user INT NOT NULL,
  titre VARCHAR(255),
  expose_motifs TEXT,
  dispositif TEXT,
  analyse_conformite TEXT,
  statut VARCHAR(45),
  date_creation TIMESTAMP,
  date_modification TIMESTAMP,
  CONSTRAINT fk_PL_QUESTIONS FOREIGN KEY (id_question) REFERENCES QUESTIONS (id_question),
  CONSTRAINT fk_PL_USERS FOREIGN KEY (id_user) REFERENCES USERS (id_user)
);
CREATE INDEX IF NOT EXISTS fk_PL_question_idx ON PROPOSITIONS_LOI (id_question);
CREATE INDEX IF NOT EXISTS fk_PL_user_idx ON PROPOSITIONS_LOI (id_user);

-- -----------------------------------------------------
-- Triggers (ported from MySQL to PL/pgSQL).
-- Hibernate does NOT manage these; run this section after the schema exists.
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION users_before_insert() RETURNS trigger AS $BODY$
DECLARE
  default_language_id INT;
  new_parametre_id INT;
  new_position_id INT;
BEGIN
  INSERT INTO USER_PARAMETRES DEFAULT VALUES RETURNING id_parametre INTO new_parametre_id;
  NEW.id_parametre := new_parametre_id;

  SELECT id_langue INTO default_language_id FROM LANGUES_REF WHERE code = 'FR' LIMIT 1;
  IF default_language_id IS NOT NULL THEN
    INSERT INTO USER_PARAMETRES_LANGUE (id_parametre, id_langue) VALUES (new_parametre_id, default_language_id);
  END IF;

  INSERT INTO USER_POSITION (latitude, longitude) VALUES (NULL, NULL) RETURNING id_position INTO new_position_id;
  NEW.id_position := new_position_id;

  NEW.date_creation := NOW();
  RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS USERS_BEFORE_INSERT ON USERS;
CREATE TRIGGER USERS_BEFORE_INSERT BEFORE INSERT ON USERS FOR EACH ROW EXECUTE FUNCTION users_before_insert();

CREATE OR REPLACE FUNCTION users_after_insert() RETURNS trigger AS $BODY$
BEGIN
  INSERT INTO USER_ADRESSE (id_user) VALUES (NEW.id_user);
  RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS USERS_AFTER_INSERT ON USERS;
CREATE TRIGGER USERS_AFTER_INSERT AFTER INSERT ON USERS FOR EACH ROW EXECUTE FUNCTION users_after_insert();

CREATE OR REPLACE FUNCTION set_date_modification() RETURNS trigger AS $BODY$
BEGIN
  NEW.date_modification := NOW();
  RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS USERS_BEFORE_UPDATE ON USERS;
CREATE TRIGGER USERS_BEFORE_UPDATE BEFORE UPDATE ON USERS FOR EACH ROW EXECUTE FUNCTION set_date_modification();

CREATE OR REPLACE FUNCTION set_date_creation() RETURNS trigger AS $BODY$
BEGIN
  NEW.date_creation := NOW();
  RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS QUESTIONS_BEFORE_INSERT ON QUESTIONS;
CREATE TRIGGER QUESTIONS_BEFORE_INSERT BEFORE INSERT ON QUESTIONS FOR EACH ROW EXECUTE FUNCTION set_date_creation();

DROP TRIGGER IF EXISTS QUESTIONS_BEFORE_UPDATE ON QUESTIONS;
CREATE TRIGGER QUESTIONS_BEFORE_UPDATE BEFORE UPDATE ON QUESTIONS FOR EACH ROW EXECUTE FUNCTION set_date_modification();

DROP TRIGGER IF EXISTS QUESTIONS_STAT_BEFORE_INSERT ON QUESTIONS_STAT;
CREATE TRIGGER QUESTIONS_STAT_BEFORE_INSERT BEFORE INSERT ON QUESTIONS_STAT FOR EACH ROW EXECUTE FUNCTION set_date_creation();

DROP TRIGGER IF EXISTS QUESTIONS_STAT_BEFORE_UPDATE ON QUESTIONS_STAT;
CREATE TRIGGER QUESTIONS_STAT_BEFORE_UPDATE BEFORE UPDATE ON QUESTIONS_STAT FOR EACH ROW EXECUTE FUNCTION set_date_modification();
