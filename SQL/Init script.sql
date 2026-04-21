
INSERT INTO `poplitic_db`.`LANGUES_REF` (`code`,`libelle`) VALUES
("FR","Français"),
("EN","Anglais"),
("DE","Allemand"),
("ES","Espagnol"),
("IT","Italien"),
("PT","Portugais"),
("NL","Néerlandais"),
("SV","Suédois"),
("DA","Danois"),
("FI","Finnois"),
("NO","Norvégien"),
("IS","Islandais"),
("GA","Irlandais"),
("PL","Polonais"),
("CS","Tchèque"),
("SK","Slovaque"),
("HU","Hongrois"),
("RO","Roumain"),
("BG","Bulgare"),
("EL","Grec"),
("HR","Croate"),
("SL","Slovène"),
("LT","Lituanien"),
("LV","Letton"),
("ET","Estonien"),
("MT","Maltais"),
("SQ","Albanais"),
("SR","Serbe"),
("BS","Bosnien"),
("MK","Macédonien"),
("UK","Ukrainien"),
("RU","Russe"),
("TR","Turc"),
("LB","Luxembourgeois"),
("BE","Biélorusse"),
("CA","Catalan")
ON DUPLICATE KEY UPDATE `libelle` = VALUES(`libelle`);

INSERT INTO `poplitic_db`.`ROLES` (`code`,`libelle`) VALUES ("ADMIN","Administrateur");
INSERT INTO `poplitic_db`.`ROLES` (`code`,`libelle`) VALUES ("USER","Utilisateur");

INSERT INTO `poplitic_db`.`USERS` (`id_role`,`login`,`nom`,`prenom`,`email`,`password`,`actif`) VALUES (1,"l.sierra","sierra","leandro","leandrosierra1@gmail.com","$2a$12$zFYMf2HGDbuXDp8dq6tplesCg9xq2DVTEEDqVS9yT8yf36Ctq.uIO",1);
INSERT INTO `poplitic_db`.`USERS` (`id_role`,`login`,`nom`,`prenom`,`email`,`password`,`actif`) VALUES (1,"g.andrieux","andrieux","guillaume","andrieux.guillaume@gmail.com","$2a$12$zFYMf2HGDbuXDp8dq6tplesCg9xq2DVTEEDqVS9yT8yf36Ctq.uIO",1);

INSERT INTO `poplitic_db`.`USER_INTERETS_REF` (`code`,`libelle`) VALUES ("Ecologie","Ecologie");
INSERT INTO `poplitic_db`.`USER_INTERETS_REF` (`code`,`libelle`) VALUES ("Education","Education");
INSERT INTO `poplitic_db`.`USER_INTERETS_REF` (`code`,`libelle`) VALUES ("Santé","Santé");
INSERT INTO `poplitic_db`.`USER_INTERETS_REF` (`code`,`libelle`) VALUES ("Agriculture","Agriculture");
INSERT INTO `poplitic_db`.`USER_INTERETS_REF` (`code`,`libelle`) VALUES ("Economie","Economie");
INSERT INTO `poplitic_db`.`USER_INTERETS_REF` (`code`,`libelle`) VALUES ("Fiscalité","Fiscalité");
INSERT INTO `poplitic_db`.`USER_INTERETS_REF` (`code`,`libelle`) VALUES ("Droit travail","Droit travail");
INSERT INTO `poplitic_db`.`USER_INTERETS_REF` (`code`,`libelle`) VALUES ("Budget","Budget");
INSERT INTO `poplitic_db`.`USER_INTERETS_REF` (`code`,`libelle`) VALUES ("Culture","Culture");
INSERT INTO `poplitic_db`.`USER_INTERETS_REF` (`code`,`libelle`) VALUES ("Vie politique","Vie politique");

INSERT INTO `poplitic_db`.`STATUT_REF` (`code`,`libelle`) VALUES ("BROUILLON","Brouillon");
INSERT INTO `poplitic_db`.`STATUT_REF` (`code`,`libelle`) VALUES ("ACTIF","Actif");
INSERT INTO `poplitic_db`.`STATUT_REF` (`code`,`libelle`) VALUES ("INACTIF","Inactif");

INSERT INTO `poplitic_db`.`ANSWER_REF` (`code`,`libelle`) VALUES ("OUI","Oui");
INSERT INTO `poplitic_db`.`ANSWER_REF` (`code`,`libelle`) VALUES ("NON","Non");
INSERT INTO `poplitic_db`.`ANSWER_REF` (`code`,`libelle`) VALUES ("NEUTRE","Neutre");

INSERT INTO `poplitic_db`.`PAYS_REF` (`code`,`libelle`) VALUES ("FR","France");

INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"1","Ain");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"2","Aisne");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"3","Allier");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"4","Alpes-de-Haute-Provence");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"5","Hautes-Alpes");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"6","Alpes-Maritimes");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"7","Ardèche");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"8","Ardennes");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"9","Ariège");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"10","Aube");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"11","Aude");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"12","Aveyron");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"13","Bouches-du-Rhône");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"14","Calvados");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"15","Cantal");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"16","Charente");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"17","Charente-Maritime");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"18","Cher");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"19","Corrèze");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"2A","Corse-du-Sud");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"2B","Haute-Corse");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"21","Côte-d'Or");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"22","Côtes-d'Armor");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"23","Creuse");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"24","Dordogne");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"25","Doubs");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"26","Drôme");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"27","Eure");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"28","Eure-et-Loir");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"29","Finistère");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"30","Gard");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"31","Haute-Garonne");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"32","Gers");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"33","Gironde");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"34","Hérault");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"35","Ille-et-Vilaine");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"36","Indre");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"37","Indre-et-Loire");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"38","Isère");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"39","Jura");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"40","Landes");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"41","Loir-et-Cher");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"42","Loire");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"43","Haute-Loire");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"44","Loire-Atlantique");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"45","Loiret");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"46","Lot");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"47","Lot-et-Garonne");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"48","Lozère");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"49","Maine-et-Loire");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"50","Manche");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"51","Marne");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"52","Haute-Marne");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"53","Mayenne");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"54","Meurthe-et-Moselle");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"55","Meuse");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"56","Morbihan");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"57","Moselle");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"58","Nièvre");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"59","Nord");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"60","Oise");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"61","Orne");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"62","Pas-de-Calais");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"63","Puy-de-Dôme");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"64","Pyrénées-Atlantiques");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"65","Hautes-Pyrénées");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"66","Pyrénées-Orientales");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"67","Bas-Rhin10");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"68","Haut-Rhin10");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"69","RhôneNote 6");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"70","Haute-Saône");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"71","Saône-et-Loire");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"72","Sarthe");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"73","Savoie");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"74","Haute-Savoie");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"75","Paris");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"76","Seine-Maritime");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"77","Seine-et-Marne");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"78","Yvelines");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"79","Deux-Sèvres");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"80","Somme");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"81","Tarn");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"82","Tarn-et-Garonne");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"83","Var");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"84","Vaucluse");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"85","Vendée");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"86","Vienne");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"87","Haute-Vienne");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"88","Vosges");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"89","Yonne");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"90","Territoire de Belfort");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"91","Essonne");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"92","Hauts-de-Seine");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"93","Seine-Saint-Denis");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"94","Val-de-Marne");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"95","Val-d'Oise");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"971","Guadeloupe");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"972","Martinique");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"973","Guyane");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"974","La Réunion");
INSERT INTO `poplitic_db`.`DEPT_REF` (`id_pays`,`code`,`libelle`) VALUES (1,"976","Mayotte");
