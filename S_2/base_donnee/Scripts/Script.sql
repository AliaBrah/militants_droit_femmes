SELECT p.pk , COUNT(*) as eff , GROUP_CONCAT(genre), GROUP_CONCAT(annee_naissance)
FROM personne p 
GROUP BY p.pk
HAVING count(*) > 1;

SELECT p.pk
FROM personne p 
WHERE genre = 'non-binary'  ;

-- nettoyer les tables : vérifier qu'il n'y ait pas de doublon
-- table personne
SELECT p.pk , count(*) AS eff, p.nom 
FROM personne p 
GROUP BY p.pk 
ORDER BY eff DESC;

-- nettoyer occupation

SELECT o.pk , count(*) AS eff, o.nom  
FROM occupation o 
GROUP BY o.pk 
ORDER BY eff DESC;


-- création d'une vue qui compte les effectif par occupation

--CREATE VIEW effectif_occupation
--AS
SELECT lpo.fk_occupation, COUNT(*) AS eff,  lpo.occupation 
FROM liaison_personne_occupation lpo 
GROUP by lpo.fk_occupation
ORDER BY eff DESC ;


SELECT win.column1, count(*) AS eff  --757 qui ont plusieurs nationalités
FROM wiki_import_nationalite win  
GROUP BY win.column1 
HAVING count(*) > 1; --757 qui ont plusieurs nationalités

SELECT win.column1, count(*) AS eff, GROUP_CONCAT(win.column5) AS nationalites -- les deux nationalités sortent !!!!!
FROM wiki_import_nationalite win  
GROUP BY win.column1 
HAVING count(*) > 1; --757 qui ont plusieurs nationalités

SELECT lpo.Fk_personne, count(*) AS eff, lpo.personne  --2173 qui ont plusieurs occupations
FROM liaison_personne_occupation lpo 
GROUP BY lpo.Fk_personne 
HAVING count(*) > 1; 

-- requête pour démontrer les combinaisons d'occupations

SELECT lpo.Fk_personne, count(*) AS eff, lpo.personne , GROUP_CONCAT(lpo.occupation) as occupations --2173 qui ont plusieurs occupations
FROM liaison_personne_occupation   lpo 
GROUP BY lpo.Fk_personne 
HAVING count(*) > 1; 


SELECT occupation , eff -- occupation qui concernent 10 personnes ou plus / script intéressant !!!! 
FROM effectif_occupation eo 
WHERE (eo.eff > 9)
ORDER BY eff; 

-- compter le nombre de personne qui ont une activités et combien d'occurence ça concerne (passé en CSV et utilisé sur python)
WITH tw1 AS (
SELECT LOWER(TRIM(occupation)) occupation, COUNT(*) as occurence
FROM liaison_personne_occupation 
GROUP BY TRIM(occupation), LOWER(TRIM(occupation)) )
SELECT occurence, count(*) as nombre_occ, group_concat(occupation, '; ') AS labels_occ
FROM tw1
GROUP BY occurence
ORDER BY nombre_occ DESC, occurence ASC;


-- Nationalite
SELECT win.id_nationalite  ,count(*) AS eff, win.nationalite 
FROM wiki_import_nationalite win 
GROUP BY win.id_nationalite  
ORDER BY eff DESC ;

-- insertion des pays de la table nationalité dans la table pays.
-- INSERT INTO pays (pk_pays,nom_pays)
SELECT DISTINCT TRIM(id_nationalite), TRIM(nationalite)
FROM wiki_import_nationalite;

SELECT DISTINCT win.id_nationalite, win.nationalite 
FROM wiki_import_nationalite win ;

-- association des domaines NATIONALITE et effectif !!!
WITH TW1 AS (
SELECT win.id_nationalite, COUNT(*) AS eff 
FROM wiki_import_nationalite win 
GROUP BY win.id_nationalite)
SELECT p.pk_pays , nom_pays , eff, p.fk_zone_geographique
FROM TW1 JOIN pays p 
ON p.pk_pays = TW1.id_nationalite
ORDER BY eff DESC;

-- compter les effectif de personne par pays. 
SELECT zg.nom_zone , COUNT(*) AS eff 
FROM wiki_import_nationalite win 
JOIN pays p 
ON p.pk_pays = win.id_nationalite 
JOIN zone_geographique zg 
ON zg.pk_zone = p.fk_zone_geographique
GROUP BY zg.nom_zone
ORDER BY eff DESC ;

-- création d'une table à importer pou pouvoir faire une analyse qualitative bivariée --> table utilisée lors des statistique sur le genre, zone géo et période:
CREATE VIEW analyse_personne_geo
AS
SELECT p.pk, p.nom,
CASE 
	WHEN p.genre = 'male'
	THEN 'M'
	WHEN p.genre='female'
	THEN 'F'
	ELSE 'LGBTQ'
	END AS gender,
MAX(zg.nom_zone) AS zone_geo, MAX(p.annee_naissance) AS annee_naissance 
FROM personne p
    JOIN wiki_import_nationalite win 
    ON win.fk_personne =p.pk 
    JOIN pays p2 
    ON p2.pk_pays = win.id_nationalite 
    JOIN zone_geographique zg 
    ON zg.pk_zone = p2.fk_zone_geographique 
    GROUP BY p.pk , p.nom ;
   
   -- OCCUPATION Création de la table pour l'analyse multivariée des occupations. 
   -- essaie de démontrer les différent domaine de l'occupation pour chaque personne
 CREATE VIEW analyse_personne_occupation
 AS
   SELECT DISTINCT  lpo.Fk_personne, lpo.personne , apg.gender , apg.zone_geo, apg.annee_naissance, GROUP_CONCAT(domaine) as domaines, COUNT(*) as eff--2173 qui ont plusieurs occupations
FROM liaison_personne_occupation lpo
   JOIN occupation o ON o.pk= lpo.fk_occupation
   JOIN analyse_personne_geo apg ON apg.pk =lpo.fk_personne
   JOIN domaine_occupation do ON do.pk_domaine = o.fk_domaine_occupation
GROUP BY lpo.Fk_personne
ORDER BY eff DESC ;

-- effectif des domaines :
SELECT DISTINCT do.domaine, COUNT(*) as eff
FROM domaine_occupation do 
JOIN occupation o 
 	ON o.fk_domaine_occupation = do.pk_domaine 
JOIN liaison_personne_occupation lpo 
	ON lpo.fk_occupation = o.pk 
GROUP BY do.domaine 
ORDER BY eff DESC ;


-- vérification si quelqu'un pas de zone associée --> y en a 0
SELECT COUNT(*) 
FROM personne p 
JOIN wiki_import_nationalite win 
ON win.fk_personne = p.pk 
JOIN pays p2 
ON p2.pk_pays = win.id_nationalite 
LEFT JOIN zone_geographique zg 
ON zg.pk_zone = p2.fk_zone_geographique 
WHERE zg.nom_zone IS NULL ;

-- NATIONALITE: 
SELECT win.nationalite , COUNT(*) as eff
FROM wiki_import_nationalite win 
GROUP BY win.nationalite 
ORDER BY eff DESC;




-- UNIVERSITE : ANALYSE DE RESEAUX
-- effectif par universités
SELECT wpu.fk_uni  , COUNT(*) as eff, wpu.universite 
FROM wiki_personne_universite wpu 
GROUP BY wpu.fk_uni  
ORDER BY eff DESC; -- 2294 université différentes

-- code pour voir si des personnes ont étudiés dans diverse universités. 
SELECT wpu.column1 , count(*) AS eff, GROUP_CONCAT(wpu.column5) as universites, wpu.column2 
FROM wiki_personne_universite wpu  
GROUP BY wpu.column1  
HAVING count(*) > 1
ORDER BY eff DESC ; -- 1233 personne sont allées dans des universités différentes !!!!!! potentiel de réseaux




-- LIEU DE NAISSANCE ANALYSE SPATIALE CREATION DE LA TABLE POUR FAIRE L'ANALYSE.
CREATE VIEW analyse_spatiale_1
AS 
SELECT fk_lieu , lieu_naissance , COUNT(*) eff, MAX(coordinates) geo_coord
FROM wiki_import_lieu_naissance wiln 
WHERE coordinates  LIKE 'Point(%'
GROUP BY fk_lieu , lieu_naissance 
-- exlu valeurs vides
HAVING LENGTH(MAX(coordinates)) > 7
ORDER BY eff DESC;

CREATE VIEW analyse_spatiale_2
AS
SELECT annee_naissance ,fk_lieu , lieu_naissance , coordinates  AS geo_coord
FROM wiki_import_lieu_naissance wiln  
-- il y a des erreurs dans Wikidata
WHERE wiln.coordinates LIKE 'Point(%';

CREATE VIEW analyse_spatiale_3
AS
SELECT generations, lieu_naissance , geo_coord, COUNT(*) as effectif
FROM wdt_generations_birth_place wgbp
GROUP BY generations, fk_lieu , lieu_naissance , geo_coord;




