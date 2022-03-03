-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Set 3 - Tingueu valor. Encara tenim el nostre clan. Sempre hi ha esperança.
/*
1. Llistar els clans (nom i descripció) i el nombre de jugadors que tenen una experiència
superior a 200.000. Filtra la sortida per tenir els clans amb més trofeus requerits.
*/

SELECT c.nom AS nom, c.descripcio AS descripcio, COUNT(j.tag_jugador) AS num_jugadors
FROM clan AS c
    JOIN forma_part AS fp ON c.tag_clan = fp.tag_clan
    JOIN jugador AS j ON fp.tag_jugador = j.tag_jugador
WHERE j.experiencia > 200000
GROUP BY c.tag_clan, trofeus_minims
ORDER BY c.trofeus_minims DESC;

/*
2. Llistar els 15 jugadors amb més experiència, la seva experiència i el nom del clan que
pertany si el clan que ha investigat una tecnologia amb un cost superior a 1000.
*/

SELECT DISTINCT j.nom, j.experiencia, c.nom
FROM jugador AS j
         JOIN forma_part AS fp ON j.tag_jugador = fp.tag_jugador
         JOIN clan AS c ON fp.tag_clan = c.tag_clan
         JOIN tenen_tecnologia AS tt ON c.tag_clan = tt.tag_clan
         JOIN tecnologia AS t ON tt.id_tecnologia = t.id_tecnologia
         JOIN millora AS m ON t.id_tecnologia = m.nom_millora
WHERE m.cost > 1000
ORDER BY j.experiencia DESC
LIMIT 15;


/*
3. Enumera l’identificador, la data d'inici i la durada de les batalles que van començar
després del "01-01-2021" i en què van participar clans amb trofeus mínims superiors a
6900. Donar només 5 batalles amb la major durada.
*/

SELECT b.id_batalla, l.data_inici, b.durada, b.data
FROM batalla AS b
    JOIN lluiten AS l ON b.id_batalla = l.id_batalla
    JOIN clan AS c ON l.tag_clan = c.tag_clan
WHERE c.trofeus_minims > 6900 AND b.data > '2021-01-01'
ORDER BY b.durada DESC
LIMIT 5;

/*
4. Enumera per a cada clan el nombre d'estructures i el cost total d'or. Considera les
estructures creades a l'any 2020 i amb trofeus mínims superiors a 1200. Donar només
la informació dels clans que tinguin més de 2 estructures.
*/

SELECT c.nom, COUNT(te.id_estructura) AS num_estructures, SUM(m.cost)
FROM clan AS c
    JOIN tenen_estructura AS te ON c.tag_clan = te.tag_clan
    JOIN estructura AS e ON te.id_estructura = e.id_estructura
    JOIN millora AS m ON e.id_estructura = m.nom_millora
WHERE EXTRACT(YEAR FROM te.data) = 2020 AND e.minim_trofeus > 1200
GROUP BY c.tag_clan, c.trofeus_minims
HAVING COUNT(te.id_estructura) > 2;

/*
5. Enumera el nom dels clans, la descripció i els trofeus mínims ordenat de menor a major
nivell de trofeus mínims per als clans amb jugadors que tinguin més de 200.000
d’experiència i el rol co-líder.
*/

SELECT c.nom, c.descripcio, c.trofeus_minims
FROM clan AS c
    JOIN forma_part AS fp ON fp.tag_clan = c.tag_clan
    JOIN jugador AS j ON j.tag_jugador = fp.tag_jugador
    JOIN rol AS r ON fp.id_rol = r.id_rol
--Subquerie? WHERE r.nom = 'coLeader' AND j.experiencia > 200000
ORDER BY c.trofeus_minims ASC;

/*
6. Necessitem canviar algunes dades a la base de dades. Hem d'incrementar un 25% el
cost de les tecnologies que utilitzen els clans amb trofeus mínims superiors a la mitjana
de trofeus mínims de tots els clans.
*/

UPDATE millora AS m
SET cost = m.cost*0.25 + m.cost
FROM clan AS c
    JOIN tenen_tecnologia tt ON c.tag_clan = tt.tag_clan
    JOIN tecnologia AS t ON tt.id_tecnologia = t.id_tecnologia
    JOIN millora AS mm ON t.id_tecnologia = mm.nom_millora
WHERE c.trofeus_minims > (SELECT AVG(c.trofeus_minims)
                            FROM clan AS c);
-- ESTIC INCREMENTANT NOMES EL DE LES TECNOLOGIES O TMB EL DE LES ESTRUCTURES?


--Subquerie s'ha de treure l'AVG

/*
7. Enumerar el nom i la descripció de la tecnologia utilitzada pels clans que tenen una
estructura "Monument" construïda després del "01-01-2021". Ordena les dades segons
el nom i la descripció de les tecnologies.
*/

SELECT DISTINCT t.id_tecnologia AS nom_tecnologia, m.descripcio
FROM clan AS c
    JOIN tenen_tecnologia AS tt ON c.tag_clan = tt.tag_clan
    JOIN tenen_estructura AS te ON c.tag_clan = te.tag_clan
    JOIN tecnologia AS t ON tt.id_tecnologia = t.id_tecnologia
    JOIN millora AS m ON m.nom_millora = t.id_tecnologia
WHERE te.id_estructura LIKE 'Monument' AND te.data > '2021-01-01'
ORDER BY t.id_tecnologia, m.descripcio;

/*
8. Enumera els clans amb un mínim de trofeus superior a 6900 i que hagin participat a
totes les batalles de clans.
*/
SELECT c.nom, COUNT(DISTINCT ll.id_batalla) AS n_batalles
FROM clan AS c
    JOIN lluiten AS ll ON c.tag_clan = ll.tag_clan
WHERE c.trofeus_minims > 6900 AND (SELECT COUNT(ll.tag_clan)
                                    FROM lluiten AS ll
                                    /*WHERE ll.tag_clan = */)
GROUP BY c.tag_clan;
