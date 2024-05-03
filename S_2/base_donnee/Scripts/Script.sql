SELECT p.pk , COUNT(*) as eff , GROUP_CONCAT(genre), GROUP_CONCAT(annee_naissance)
FROM personne p 
GROUP BY p.pk
HAVING count(*) > 1;

SELECT p.pk
FROM personne p 
WHERE genre = 'trans woman';


-- création d'une vue qui compte les effectif par occupation

CREATE VIEW effectif_occupation
AS
SELECT lpo.fk_occupation, COUNT(*) AS eff,  lpo.occupation 
FROM liaison_pers_occup lpo 
GROUP by lpo.fk_occupation
HAVING count(*) > 1
ORDER BY lpo.occupation  ;

-- essais pour avoir les effectifs par occupations

SELECT COUNT (DISTINCT Fk_personne)
FROM liaison_pers_occup lpo ;

SELECT lpo.occupation, count(*)AS eff, lpo.occupation 
FROM liaison_pers_occup lpo 
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

SELECT iwn.column1, count(*) AS eff  --263 qui ont plusieurs nationalités
FROM import_wiki_nationalite iwn 
GROUP BY iwn.column1 
HAVING count(*) > 1; --263 qui ont plusieurs nationalités

SELECT iwn.column1, count(*) AS eff, GROUP_CONCAT(iwn.column5) AS nationalites -- les deux nationalités sortent !!!!!
FROM import_wiki_nationalite iwn 
GROUP BY iwn.column1 
HAVING count(*) > 1; --263 qui ont plusieurs nationalités

SELECT lpo.Fk_personne, count(*) AS eff  --2173 qui ont plusieurs occupations
FROM liaison_pers_occup lpo 
GROUP BY lpo.Fk_personne 
HAVING count(*) > 1; 

-- requête pour démontrer les combinaisons d'occupations

SELECT lpo.Fk_personne, count(*) AS eff, GROUP_CONCAT(lpo.occupation) as occupations --2173 qui ont plusieurs occupations
FROM liaison_pers_occup lpo 
GROUP BY lpo.Fk_personne 
HAVING count(*) > 1; 


SELECT occupation , eff -- occupation qui concernent 10 personnes ou plus / script intéressant !!!! 
FROM effectif_occupation eo 
WHERE (eo.eff > 9)
ORDER BY eff; 







