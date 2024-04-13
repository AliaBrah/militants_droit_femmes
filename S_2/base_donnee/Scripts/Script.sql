SELECT p.pk , COUNT(*) as eff , GROUP_CONCAT(genre), GROUP_CONCAT(annee_naissance)
FROM personne p 
GROUP BY p.pk
HAVING count(*) > 1;

SELECT p.pk
FROM personne p 
WHERE genre = 'trans woman';
