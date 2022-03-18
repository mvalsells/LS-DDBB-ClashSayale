-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Set 5 - Preguntes creuades

-- 1. Mostrar el nombre de jugadors que té cada clan, però només considerant els jugadors
-- amb nom de rol que contingui el text "elder". Restringir la sortida per als 5 primers clans
-- amb més jugadors.

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
-- jugadors que tenen la carta Skeleton Army i han comprat articles abans del 01-01-2019.

SELECT j.nom, m.cos AS text, m.data_ AS data
FROM jugador AS j
    JOIN conversen AS c ON j.tag_jugador = c.tag_envia
    JOIN missatge AS m ON c.id_missatge = m.id_missatge
    JOIN compren AS buy ON j.tag_jugador = buy.tag_jugador
    JOIN pertany AS p ON j.tag_jugador = p.tag_jugador
WHERE buy.data_ < '2019-01-01' AND p.nom_carta LIKE 'Skeleton Army';


-- 3. Llistar els 10 primers jugadors amb experiència superior a 100.000 que han creat més
-- piles i han guanyat batalles a la temporada T7.

SELECT j.nom, j.experiencia, COUNT(DISTINCT p.id_pila) AS n_piles
FROM jugador AS j
    JOIN pila AS p ON j.tag_jugador = p.tag_jugador
    JOIN guanya AS g ON j.tag_jugador = g.tag_jugador
    JOIN batalla AS b ON g.id_batalla = b.id_batalla
WHERE j.experiencia > 100000 AND b.id_temporada LIKE 'T7'
GROUP BY j.tag_jugador
HAVING COUNT(DISTINCT p.id_pila) = (SELECT COUNT(id_pila) as a
                                    FROM pila
                                    GROUP BY tag_jugador
                                    ORDER BY a DESC
                                    LIMIT 1)
ORDER BY j.experiencia DESC
LIMIT 10;


-- 4. Enumera els articles que han estat comprats més vegades i el seu cost total.
SELECT a.nom ,COUNT(a.nom), (COUNT(a.nom)*a.preu) as cost_total
FROM article as a
JOIN compren c on a.id_article = c.id_article
GROUP BY a.nom, a.preu
HAVING COUNT(a.nom) >= (SELECT COUNT(a2.nom)
                        FROM article a2
                        JOIN compren c2 on a2.id_article = c2.id_article
                        GROUP BY a2.nom,a2.preu
                        ORDER BY COUNT(a2.nom) desc
                        LIMIT 1);

-- 5. Mostrar la identificació de les batalles, la durada, la data d'inici i la data de finalització
-- dels clans que la seva descripció no contingui el text "Chuck Norris". Considera només
-- les batalles amb una durada inferior a la durada mitjana de totes les batalles.
SELECT b.id_batalla, b.durada, l.data_inici, l.data_fi, c.descripcio
FROM batalla as b
JOIN lluiten l on b.id_batalla = l.id_batalla
JOIN clan c on l.tag_clan = c.tag_clan
WHERE c.descripcio NOT LIKE '%Chuck Norris%'
        AND b.durada < (SELECT AVG(b1.durada)
                        FROM batalla as b1);

-- 6. Enumerar el nom i l'experiència dels jugadors que pertanyen a un clan que té una
-- tecnologia el nom del qual conté la paraula "Militar" i aquests jugadors havien comprat
-- el 2021 més de 5 articles.
SELECT j.nom, j.experiencia
FROM millora as m
    JOIN tecnologia as t on t.id_tecnologia = m.nom_millora
    JOIN tenen_tecnologia as tt on t.id_tecnologia = tt.id_tecnologia
    JOIN clan as c on tt.tag_clan = c.tag_clan
    JOIN jugador as j on c.creador_clan = j.tag_jugador
WHERE m.nom_millora LIKE '%Militar%' AND 5 < (SELECT COUNT(a.nom)
                                        FROM article as a
                                        JOIN compren c3 on a.id_article = c3.id_article
                                        JOIN jugador j2 on c3.tag_jugador = j2.tag_jugador
                                        WHERE j.tag_jugador = j2.tag_jugador
                                        AND (c3.data_ >= '2021-01-01' AND c3.data_ <= '2021-12-31')) ;

-- 7. Indiqueu el nom dels jugadors que tenen totes les cartes amb el major valor de dany.

SELECT DISTINCT j.nom
FROM pertany AS p
JOIN jugador AS j on j.tag_jugador = p.tag_jugador
JOIN carta AS c on p.nom_carta = c.nom
WHERE c.dany = (
    SELECT max(c.dany)
    FROM carta AS c
);

-- 8. Retorna el nom de les cartes i el dany que pertanyen a les piles el nom de les quals
-- conté la paraula "Madrid" i van ser creats per jugadors amb experiència superior a
-- 150.000. Considereu només les cartes amb dany superior a 200 i els jugadors que van
-- aconseguir un èxit en el 2021. Enumera el resultat des dels valors més alts del nom de
-- la carta fins als valors més baixos del nom de la carta.

SELECT DISTINCT c.nom, c.dany
FROM carta AS c
JOIN formen AS f on c.nom = f.nom_carta
JOIN pila AS p on p.id_pila = f.id_pila AND  p.nom LIKE '%Madrid%'
JOIN jugador AS j on p.tag_jugador = j.tag_jugador AND j.experiencia > 150000
JOIN obte AS o on j.tag_jugador = o.tag_jugador
JOIN aconsegueix AS a on j.tag_jugador = a.tag_jugador AND EXTRACT(YEAR FROM a.data) = '2021'
WHERE c.dany > 200
ORDER BY c.nom DESC;

-- 9. Enumerar el nom, l’experiència i el nombre de trofeus dels jugadors que no han comprat
-- res. Així, el nom, l'experiència i el número de trofeus dels jugadors que no han enviat
-- cap missatge. Ordenar la sortida de menor a més valor en el nom del jugador.

SELECT j.nom, j.experiencia, j.trofeus
FROM jugador AS j
LEFT JOIN compren AS c on j.tag_jugador = c.tag_jugador
WHERE c.tag_jugador IS NULL
UNION
SELECT j.nom, j.experiencia, j.trofeus
FROM jugador AS j
LEFT JOIN conversen c on j.tag_jugador = c.tag_envia
LEFT JOIN envia e on j.tag_jugador = e.tag_jugador
WHERE e.tag_jugador IS NULL AND c.tag_envia IS NULL
ORDER BY nom;

-- 10.Llistar les cartes comunes que no estan incloses en cap pila i que pertanyen a jugadors
-- amb experiència superior a 200.000. Ordena la sortida amb el nom de la carta.
SELECT DISTINCT c.nom
FROM carta AS c
JOIN pertany AS p ON c.nom = p.nom_carta
JOIN jugador AS j ON p.tag_jugador = j.tag_jugador AND j.experiencia > 200000
LEFT JOIN formen AS f ON c.nom = f.nom_carta
WHERE f.nom_carta IS NULL;

-- 11.Llistar el nom dels jugadors que han sol·licitat amics, però no han estat sol·licitats com
-- a amics.
/*SELECT j.nom FROM jugador AS j
JOIN amics AS a on j.tag_jugador = a.tag_jugador1*/

-- 12.Enumerar el nom dels jugadors i el nombre d'articles comprats que tenen un cost
-- superior al cost mitjà de tots els articles. Ordenar el resultat de menor a major valor del
-- nombre de comandes.
SELECT j.nom, COUNT(a.id_article) AS nombre_articles, a.preu FROM jugador AS j
JOIN compren AS c on j.tag_jugador = c.tag_jugador
JOIN article AS a on c.id_article = a.id_article
WHERE a.preu > (
    SELECT AVG(a2.preu) FROM article AS a2)
GROUP BY j.nom, a.preu
ORDER BY nombre_articles DESC;

-- Validació
SELECT AVG(a.preu) AS mitjana FROM article AS a;

-- 13.Poseu a zero els valors d'or i gemmes als jugadors que no han enviat cap missatge o
-- que han enviat el mateix nombre de missatges que el jugador que més missatges ha
-- enviat.

UPDATE jugador
SET
    or_ = 0,
    gemmes = 0
WHERE
    tag_jugador IN (
        SELECT j.tag_jugador FROM jugador AS j
        LEFT JOIN conversen c on j.tag_jugador = c.tag_envia
        LEFT JOIN envia e on j.tag_jugador = e.tag_jugador
        WHERE e.tag_jugador IS NULL AND c.tag_envia IS NULL)
OR
    tag_jugador IN (
        SELECT j.tag_jugador AS num FROM jugador AS j
            LEFT JOIN conversen AS c on j.tag_jugador = c.tag_envia
            LEFT JOIN envia AS e on j.tag_jugador = e.tag_jugador
        GROUP BY j.tag_jugador
        HAVING COUNT(j.tag_jugador) = (
            SELECT COUNT(j.tag_jugador) AS num FROM jugador AS j
                LEFT JOIN conversen AS c on j.tag_jugador = c.tag_envia
            LEFT JOIN envia AS e on j.tag_jugador = e.tag_jugador
            GROUP BY j.tag_jugador
            ORDER BY num DESC
            LIMIT 1)
        );
