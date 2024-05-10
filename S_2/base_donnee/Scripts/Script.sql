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

-- essais pour avoir les effectifs par occupations

SELECT COUNT (DISTINCT Fk_personne)
FROM liaison_personne_occupation   lpo ;

SELECT lpo.occupation, count(*)AS eff, lpo.occupation 
FROM liaison_personne_occupation   lpo 
GROUP BY lpo.occupation
ORDER BY lpo.occupation ;

-- regrouper tous les enseignants ensemble
SELECT
SUM(eff) AS enseignant
FROM effectif_occupation eo 
WHERE (eo.occupation  = 'teacher')OR (eo.occupation ='university teacher') OR (eo.occupation = 'professor') OR (eo.occupation = 'professeur des universités') ;

-- regrouper tous les écrivain.es ensemble
SELECT
SUM(eff) AS writers
FROM effectif_occupation eo 
WHERE (eo.occupation  = 'writer')OR (eo.occupation ='journalist') OR (eo.occupation = 'poet') OR (eo.occupation = 'novelist') OR (eo.occupation = 'essayist') OR (eo.occupation = 'author') ;


-- essai pour additionner les effectifs dans des classes d'occupation qui se ressemble, fonctionne pas, mais va dans le bon sens
SELECT
    CASE 
        WHEN occupation  LIKE 'teacher' THEN 'Teacher'
         WHEN occupation  LIKE 'university teacher' THEN 'Teacher'
        WHEN occupation LIKE 'painter' THEN 'Artist'
         WHEN occupation  LIKE 'actor' THEN 'Artist'
         WHEN occupation  LIKE 'artist' THEN 'Artist'
        -- Add more WHEN conditions for other classes as needed
        ELSE 'Other'
    END AS occupation_class,
    COUNT(*) AS total_occupations
FROM
   effectif_occupation eo 
GROUP BY
    CASE 
        WHEN occupation  LIKE 'teacher' THEN 'Teacher'
         WHEN occupation  LIKE 'university teacher' THEN 'Teacher'
        WHEN occupation LIKE 'painter' THEN 'Artist'
         WHEN occupation  LIKE 'actor' THEN 'Artist'
         WHEN occupation  LIKE 'artist' THEN 'Artist'
        -- Add more WHEN conditions for other classes as needed
        ELSE 'Other'
    END;
-- Autre essai ne fonctionne pas
SELECT
SUM(eff) AS enseignant
FROM effectif_occupation eo 
WHERE (eo.occupation  = 'teacher')OR (eo.occupation ='university teacher') -- les enseignants ensemble
UNION
SELECT
SUM(eff) AS artistes
FROM effectif_occupation eo 
WHERE (eo.occupation  = 'painter')OR (eo.occupation ='artist') OR (eo.occupation ='actor'); -- les artistes ensemble /problème création d'une ligne et non d'une colonne

SELECT win.column1, count(*) AS eff  --757 qui ont plusieurs nationalités
FROM wiki_import_nationalite win  
GROUP BY win.column1 
HAVING count(*) > 1; --757 qui ont plusieurs nationalités

SELECT win.column1, count(*) AS eff, GROUP_CONCAT(win.column5) AS nationalites -- les deux nationalités sortent !!!!!
FROM wiki_import_nationalite win  
GROUP BY win.column1 
HAVING count(*) > 1; --757 qui ont plusieurs nationalités

SELECT lpo.Fk_personne, count(*) AS eff  --2173 qui ont plusieurs occupations
FROM liaison_pers_occup lpo 
GROUP BY lpo.Fk_personne 
HAVING count(*) > 1; 

-- requête pour démontrer les combinaisons d'occupations

SELECT lpo.Fk_personne, count(*) AS eff, GROUP_CONCAT(lpo.occupation) as occupations --2173 qui ont plusieurs occupations
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

-- création d'une table à importer pou pouvoir faire une analyse qualitative multivariée --> table utilisée lors des statistique sur le genre, zone géo et période:
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

    
    -- marche pas 
   WITH tw1 as(
   SELECT p.pk, p.nom, max(zg.nom_zone) AS nom_zones, max(p.annee_naissance) AS Birthyear
    FROM personne p 
    JOIN wiki_import_nationalite win
ON win.fk_personne = p.pk 
JOIN pays p2 
ON p2.pk_pays = win.id_nationalite 
JOIN zone_geographique zg 
ON p2.fk_zone_geographique = zg.pk_zone 
GROUP BY p.pk , p.nom )
SELECT pk,nom
FROM tw1 
GROUP BY pk, nom
HAVING COUNT(*) > 1;

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






