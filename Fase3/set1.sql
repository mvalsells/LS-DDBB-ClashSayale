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
ORDER BY pila, carta DESC;


-- 4. Enumerar el nom i el dany de les cartes llegendàries de menor a major valor de dany
-- que pertanyin a una pila creada l'1 de novembre del 2021. Filtrar la sortida per tenir les
-- deu millors cartes.


-- TODO: Preguntar order by
SELECT c.nom, c.dany
FROM formen AS f
JOIN carta AS c on c.nom = f.nom_carta AND c.raresa = 'Legendary'
JOIN pila AS p on p.id_pila = f.id_pila AND date(p.data_creacio) = '2021-11-01'
ORDER BY c.dany DESC
LIMIT 10;

-- 5.Llistar les tres primeres cartes de tipus edifici (nom i dany) en funció del dany dels
-- jugadors amb experiència superior a 250.000

-- TODO: funció del dany x + o x -?
SELECT DISTINCT c.nom, c.dany
FROM pertany AS p
JOIN carta AS c on p.nom_carta = c.nom
JOIN edifici AS e on c.nom = e.nom
JOIN jugador AS j on p.tag_jugador = j.tag_jugador AND j.experiencia > 250000
ORDER BY c.dany
LIMIT 3;



-- 6. Els dissenyadors del joc volen canviar algunes coses a les dades. El nom d'una carta
-- "Rascals" serà "Hal Roach's Rascals", la Raresa "Common" es dirà "Proletari".
-- Proporcioneu les ordres SQL per fer les modificacions sense eliminar les dades i
-- reimportar-les.


-- 7. Enumerar els noms de les cartes que no estan en cap pila i els noms de les cartes que
-- només estan en una pila. Per validar els resultats de la consulta, proporcioneu dues
-- consultes diferents per obtenir el mateix resultat
SELECT c.nom
FROM carta AS c
LEFT JOIN formen AS f on c.nom = f.nom_carta
WHERE f.nom_carta IS NULL
UNION
-- TODO: Aquesta query diria que està bé però no retorna cap resultat
SELECT nom_carta--, count(nom_carta)
FROM formen
GROUP BY nom_carta
HAVING count(nom_carta) = 1;

-- 8. Enumera el nom i el dany de les cartes èpiques que tenen un dany superior al dany mitjà
-- de les cartes llegendàries. Ordena els resultats segons el dany de les cartes de menys
-- a més valor.

SELECT c.nom, c.dany
FROM carta AS c
WHERE c.raresa = 'Epic' AND c.dany > (
    SELECT avg(c2.dany)
    FROM carta AS c2
    WHERE c2.raresa = 'Legendary'
)
ORDER BY c.dany;