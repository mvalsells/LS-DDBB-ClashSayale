-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Set 3 - Tingueu valor. Encara tenim el nostre clan. Sempre hi ha esperança.
/*
1. Llistar els clans (nom i descripció) i el nombre de jugadors que tenen una experiència
superior a 200.000. Filtra la sortida per tenir els clans amb més trofeus requerits.
*/

SELECT c.nom AS nom, c.descripcio AS descripcio
FROM clan AS c
    JOIN forma_part AS fp ON c.tag_clan = fp.tag_clan
    JOIN jugador AS j ON fp.tag_jugador = j.tag_jugador
ORDER BY c.trofeus_minims DESC;
--TODO "i el nombre de jugadors que tenen una experiència superior a 200.000."

/*
2. Llistar els 15 jugadors amb més experiència, la seva experiència i el nom del clan que
pertany si el clan que ha investigat una tecnologia amb un cost superior a 1000.
*/

SELECT *
FROM jugador AS j
ORDER BY j.experiencia DESC
LIMIT 15;

/*
3. Enumera l’identificador, la data d'inici i la durada de les batalles que van començar
després del "01-01-2021" i en què van participar clans amb trofeus mínims superiors a
6900. Donar només 5 batalles amb la major durada.
*/

/*
4. Enumera per a cada clan el nombre d'estructures i el cost total d'or. Considera les
estructures creades a l'any 2020 i amb trofeus mínims superiors a 1200. Donar només
la informació dels clans que tinguin més de 2 estructures.
*/

/*
5. Enumera el nom dels clans, la descripció i els trofeus mínims ordenat de menor a major
nivell de trofeus mínims per als clans amb jugadors que tinguin més de 200.000
d’experiència i el rol co-líder.
*/

/*
6. Necessitem canviar algunes dades a la base de dades. Hem d'incrementar un 25% el
cost de les tecnologies que utilitzen els clans amb trofeus mínims superiors a la mitjana
de trofeus mínims de tots els clans.
*/

/*
7. Enumerar el nom i la descripció de la tecnologia utilitzada pels clans que tenen una
estructura "Monument" construïda després del "01-01-2021". Ordena les dades segons
el nom i la descripció de les tecnologies.
*/

/*
8. Enumera els clans amb un mínim de trofeus superior a 6900 i que hagin participat a
totes les batalles de clans.
*/
