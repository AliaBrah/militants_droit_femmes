SELECT p.pk , COUNT(*) as eff , GROUP_CONCAT(genre), GROUP_CONCAT(annee_naissance)
FROM personne p 
GROUP BY p.pk
HAVING count(*) > 1;

SELECT p.pk
FROM personne p 
WHERE genre = 'trans woman';

CREATE VIEW effectif_occupation
AS
SELECT lpo.fk_occupation, COUNT(*) AS eff,  lpo.occupation 
FROM liaison_pers_occup lpo 
GROUP by lpo.fk_occupation
HAVING count(*) > 1
ORDER BY lpo.occupation  ;

SELECT COUNT (DISTINCT Fk_personne)
FROM liaison_pers_occup lpo ;

SELECT lpo.occupation, count(*)AS eff, lpo.occupation 
FROM liaison_pers_occup lpo 
GROUP BY lpo.occupation
ORDER BY lpo.occupation ;

SELECT
SUM(eff) AS enseignant
FROM effectif_occupation eo 
WHERE (eo.occupation  = 'teacher')OR (eo.occupation ='university teacher')
UNION
SELECT
SUM(eff) AS artistes
FROM effectif_occupation eo 
WHERE (eo.occupation  = 'painter')OR (eo.occupation ='artist') OR (eo.occupation ='actor');








