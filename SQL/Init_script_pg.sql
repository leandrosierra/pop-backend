
INSERT INTO LANGUES_REF (code,libelle) VALUES
('FR','Français'),
('EN','Anglais'),
('DE','Allemand'),
('ES','Espagnol'),
('IT','Italien'),
('PT','Portugais'),
('NL','Néerlandais'),
('SV','Suédois'),
('DA','Danois'),
('FI','Finnois'),
('NO','Norvégien'),
('IS','Islandais'),
('GA','Irlandais'),
('PL','Polonais'),
('CS','Tchèque'),
('SK','Slovaque'),
('HU','Hongrois'),
('RO','Roumain'),
('BG','Bulgare'),
('EL','Grec'),
('HR','Croate'),
('SL','Slovène'),
('LT','Lituanien'),
('LV','Letton'),
('ET','Estonien'),
('MT','Maltais'),
('SQ','Albanais'),
('SR','Serbe'),
('BS','Bosnien'),
('MK','Macédonien'),
('UK','Ukrainien'),
('RU','Russe'),
('TR','Turc'),
('LB','Luxembourgeois'),
('BE','Biélorusse'),
('CA','Catalan')
ON CONFLICT DO NOTHING;

INSERT INTO ROLES (code,libelle) VALUES ('ADMIN','Administrateur');
INSERT INTO ROLES (code,libelle) VALUES ('USER','Utilisateur');

INSERT INTO USERS (id_role,login,nom,prenom,email,password,actif) VALUES (1,'l.sierra','sierra','leandro','leandrosierra1@gmail.com','$2b$12$/2o5Qsmf36ANfGDSpVboqObPrWdGMamAs27M82/7uzqoMAAg0kcY6',1);
INSERT INTO USERS (id_role,login,nom,prenom,email,password,actif) VALUES (1,'g.andrieux','andrieux','guillaume','andrieux.guillaume@gmail.com','$2b$12$9PDtZunhJcTwyiRL5/DL2Og5E3PzdhRyLvS.eo7uC2U/4guykgsb2',1);

INSERT INTO USER_INTERETS_REF (code,libelle) VALUES ('Ecologie','Ecologie');
INSERT INTO USER_INTERETS_REF (code,libelle) VALUES ('Education','Education');
INSERT INTO USER_INTERETS_REF (code,libelle) VALUES ('Santé','Santé');
INSERT INTO USER_INTERETS_REF (code,libelle) VALUES ('Agriculture','Agriculture');
INSERT INTO USER_INTERETS_REF (code,libelle) VALUES ('Economie','Economie');
INSERT INTO USER_INTERETS_REF (code,libelle) VALUES ('Fiscalité','Fiscalité');
INSERT INTO USER_INTERETS_REF (code,libelle) VALUES ('Droit travail','Droit travail');
INSERT INTO USER_INTERETS_REF (code,libelle) VALUES ('Budget','Budget');
INSERT INTO USER_INTERETS_REF (code,libelle) VALUES ('Culture','Culture');
INSERT INTO USER_INTERETS_REF (code,libelle) VALUES ('Vie politique','Vie politique');

INSERT INTO STATUT_REF (code,libelle) VALUES ('BROUILLON','Brouillon');
INSERT INTO STATUT_REF (code,libelle) VALUES ('ACTIF','Actif');
INSERT INTO STATUT_REF (code,libelle) VALUES ('INACTIF','Inactif');

INSERT INTO ANSWER_REF (code,libelle) VALUES ('OUI','Oui');
INSERT INTO ANSWER_REF (code,libelle) VALUES ('NON','Non');
INSERT INTO ANSWER_REF (code,libelle) VALUES ('NEUTRE','Neutre');

INSERT INTO PAYS_REF (code,libelle) VALUES ('FR','France');

INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'1','Ain');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'2','Aisne');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'3','Allier');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'4','Alpes-de-Haute-Provence');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'5','Hautes-Alpes');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'6','Alpes-Maritimes');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'7','Ardèche');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'8','Ardennes');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'9','Ariège');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'10','Aube');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'11','Aude');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'12','Aveyron');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'13','Bouches-du-Rhône');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'14','Calvados');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'15','Cantal');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'16','Charente');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'17','Charente-Maritime');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'18','Cher');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'19','Corrèze');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'2A','Corse-du-Sud');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'2B','Haute-Corse');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'21','Côte-d''Or');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'22','Côtes-d''Armor');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'23','Creuse');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'24','Dordogne');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'25','Doubs');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'26','Drôme');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'27','Eure');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'28','Eure-et-Loir');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'29','Finistère');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'30','Gard');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'31','Haute-Garonne');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'32','Gers');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'33','Gironde');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'34','Hérault');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'35','Ille-et-Vilaine');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'36','Indre');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'37','Indre-et-Loire');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'38','Isère');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'39','Jura');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'40','Landes');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'41','Loir-et-Cher');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'42','Loire');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'43','Haute-Loire');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'44','Loire-Atlantique');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'45','Loiret');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'46','Lot');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'47','Lot-et-Garonne');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'48','Lozère');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'49','Maine-et-Loire');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'50','Manche');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'51','Marne');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'52','Haute-Marne');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'53','Mayenne');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'54','Meurthe-et-Moselle');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'55','Meuse');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'56','Morbihan');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'57','Moselle');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'58','Nièvre');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'59','Nord');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'60','Oise');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'61','Orne');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'62','Pas-de-Calais');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'63','Puy-de-Dôme');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'64','Pyrénées-Atlantiques');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'65','Hautes-Pyrénées');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'66','Pyrénées-Orientales');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'67','Bas-Rhin10');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'68','Haut-Rhin10');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'69','RhôneNote 6');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'70','Haute-Saône');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'71','Saône-et-Loire');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'72','Sarthe');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'73','Savoie');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'74','Haute-Savoie');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'75','Paris');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'76','Seine-Maritime');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'77','Seine-et-Marne');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'78','Yvelines');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'79','Deux-Sèvres');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'80','Somme');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'81','Tarn');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'82','Tarn-et-Garonne');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'83','Var');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'84','Vaucluse');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'85','Vendée');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'86','Vienne');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'87','Haute-Vienne');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'88','Vosges');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'89','Yonne');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'90','Territoire de Belfort');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'91','Essonne');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'92','Hauts-de-Seine');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'93','Seine-Saint-Denis');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'94','Val-de-Marne');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'95','Val-d''Oise');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'971','Guadeloupe');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'972','Martinique');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'973','Guyane');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'974','La Réunion');
INSERT INTO DEPT_REF (id_pays,code,libelle) VALUES (1,'976','Mayotte');
