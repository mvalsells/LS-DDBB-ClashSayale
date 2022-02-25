-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Set1 - Les cartes són la guerra, disfressada d'esport

-- 1. Enumerar el nom i el valor de dany de les cartes de tipus de tropa amb un valor de
-- velocitat d’atac superior a 100 i el nom del qual contingui el caràcter "k"

SELECT c.nom, c.dany
    FROM carta AS c
    JOIN tropa t on c.nom = t.nom
    WHERE velocitat_atac > 100 AND c.nom LIKE '%k%';

-- 2. Enumerar el valor de dany mitjà, el valor de dany màxim i el valor de dany mínim de les
-- cartes èpiques.

SELECT avg(dany) AS dany_mitja, max(dany) AS dany_maxim, min(dany) AS dany_minim
FROM carta AS c
WHERE raresa = 'Epic';

-- 3. Enumera el nom i la descripció de les piles i el nom de les cartes que tenen un nivell de
-- carta més gran que el nivell mitjà de totes les cartes. Ordena els resultats segons el nom
-- de les piles i el nom de les cartes de més a menys valor.

SELECT p.nom AS pila, p.descripcio AS descripcio, c.nom AS carta
FROM formen AS f
JOIN carta AS c on c.nom = f.nom_carta
JOIN pila AS p on p.id_pila = f.id_pila
WHERE f.nivell > (
    SELECT avg(nivell)
    FROM formen
)
ORDER BY pila, carta


-- 4. Enumerar el nom i el dany de les cartes llegendàries de menor a major valor de dany
-- que pertanyin a una pila creada l'1 de novembre del 2021. Filtrar la sortida per tenir les
-- deu millors cartes.