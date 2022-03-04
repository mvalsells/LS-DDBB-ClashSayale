-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Set 5 - Preguntes creuades

-- 1. Mostrar el nombre de jugadors que té cada clan, però només considerant els jugadors
-- amb nom de rol que contingui el text "elder". Restringir la sortida per als 5 primers clans
-- amb més jugadors. (MarcG)

SELECT c.nom, COUNT(j.tag_jugador) AS num_jugadors
FROM clan AS c
    JOIN forma_part AS fp ON c.tag_clan = fp.tag_clan
    JOIN jugador AS j ON fp.tag_jugador = j.tag_jugador
    JOIN rol AS r ON fp.id_rol = r.id_rol
WHERE r.nom = 'elder'
GROUP BY c.tag_clan
ORDER BY num_jugadors DESC
LIMIT 5;

-- 2. Mostrar el nom dels jugadors, el text dels missatges i la data dels missatges enviats pels
-- jugadors que tenen la carta Skeleton Army i han comprat articles abans del 01-01-2019. (MarcG)

SELECT j.nom
FROM jugador AS j;


-- 3. Llistar els 10 primers jugadors amb experiència superior a 100.000 que han creat més
-- piles i han guanyat batalles a la temporada T7. (MarcG)

SELECT j.nom, j.experiencia
FROM jugador AS j
WHERE j.experiencia > 100000
ORDER BY j.experiencia DESC;

SELECT COUNT(p.id_pila) AS n_piles
FROM jugador AS j JOIN pila AS p ON j.tag_jugador = p.tag_jugador
GROUP BY j.tag_jugador
ORDER BY n_piles DESC;
--"Que han creat més piles han guanyat qualsevol batalla en la T7"


-- 4. Enumera els articles que han estat comprats més vegades i el seu cost total.


-- 5. Mostrar la identificació de les batalles, la durada, la data d'inici i la data de finalització
-- dels clans que la seva descripció no contingui el text "Chuck Norris". Considera només
-- les batalles amb una durada inferior a la durada mitjana de totes les batalles.


-- 6. Enumerar el nom i l'experiència dels jugadors que pertanyen a un clan que té una
-- tecnologia el nom del qual conté la paraula "Militar" i aquests jugadors havien comprat
-- el 2021 més de 5 articles.


-- 7. Indiqueu el nom dels jugadors que tenen totes les cartes amb el major valor de dany.

SELECT DISTINCT j.nom
FROM pertany AS p
JOIN jugador AS j on j.tag_jugador = p.tag_jugador
JOIN carta AS c on p.nom_carta = c.nom
WHERE c.dany = (
    SELECT max(c.dany)
    FROM carta AS c
);

SELECT tag_clan, count(tag_jugador) AS m
FROM forma_part
GROUP BY tag_clan
ORDER BY m DESC;

-- 8. Retorna el nom de les cartes i el dany que pertanyen a les piles el nom de les quals
-- conté la paraula "Madrid" i van ser creats per jugadors amb experiència superior a
-- 150.000. Considereu només les cartes amb dany superior a 200 i els jugadors que van
-- aconseguir un èxit en el 2021. Enumera el resultat des dels valors més alts del nom de
-- la carta fins als valors més baixos del nom de la carta.


SELECT DISTINCT c.nom, c.dany
FROM carta AS c
JOIN formen AS f on c.nom = f.nom_carta
JOIN pila AS p on p.id_pila = f.id_pila
JOIN jugador AS j on p.tag_jugador = j.tag_jugador
JOIN obte AS o on j.tag_jugador = o.tag_jugador
JOIN aconsegueix AS a on j.tag_jugador = a.tag_jugador
WHERE p.nom LIKE '%Madrid%'
    AND j.experiencia > 150000
    AND c.dany > 200
    AND EXTRACT(YEAR FROM a.data) = '2021'
ORDER BY c.nom DESC;

-- 9. Enumerar el nom, l’experiència i el nombre de trofeus dels jugadors que no han comprat
-- res. Així, el nom, l'experiència i el número de trofeus dels jugadors que no han enviat
-- cap missatge. Ordenar la sortida de menor a més valor en el nom del jugador.


-- 10.Llistar les cartes comunes que no estan incloses en cap pila i que pertanyen a jugadors
-- amb experiència superior a 200.000. Ordena la sortida amb el nom de la carta.


-- 11.Llistar el nom dels jugadors que han sol·licitat amics, però no han estat sol·licitats com
-- a amics.


-- 12.Enumerar el nom dels jugadors i el nombre d'articles comprats que tenen un cost
-- superior al cost mitjà de tots els articles. Ordenar el resultat de menor a major valor del
-- nombre de comandes.


-- 13.Poseu a zero els valors d'or i gemmes als jugadors que no han enviat cap missatge o
-- que han enviat el mateix nombre de missatges que el jugador que més missatges ha
-- enviat.