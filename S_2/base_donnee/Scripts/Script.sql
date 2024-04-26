SELECT p.pk , COUNT(*) as eff , GROUP_CONCAT(genre), GROUP_CONCAT(annee_naissance)
FROM personne p 
GROUP BY p.pk
HAVING count(*) > 1;

SELECT p.pk
FROM personne p 
WHERE genre = 'trans woman';


-- création d'une vue

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

-- essai pour additionner les effectifs dans des classes d'occupation qui se ressemble

SELECT
SUM(eff) AS enseignant
FROM effectif_occupation eo 
WHERE (eo.occupation  = 'teacher')OR (eo.occupation ='university teacher') -- les enseignants ensemble
UNION
SELECT
SUM(eff) AS artistes
FROM effectif_occupation eo 
WHERE (eo.occupation  = 'painter')OR (eo.occupation ='artist') OR (eo.occupation ='actor'); -- les artistes ensemble








