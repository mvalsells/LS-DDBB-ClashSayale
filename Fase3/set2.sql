-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Set 2 - No sóc un jugador, sóc un jugador de videojocs

/* 1. Enumera els missatges (text i data) escrits pels jugadors que tenen més experiència que
la mitjana dels jugadors que tenen una "A" en nom seu i pertanyen al clan "NoA". Donar
la llista de ordenada dels missatges més antics als més nous.*/

SELECT m.cos as text, m.data_ as data, j.experiencia
FROM missatge AS m
JOIN conversen as c on c.id_missatge = m.id_missatge
JOIN jugador as j on j.tag_jugador = c.tag_envia
WHERE j.experiencia > (SELECT AVG(j1.experiencia)
                        FROM jugador as j1
                        JOIN clan c1 on j1.tag_jugador = c1.creador_clan
                        WHERE j1.nom LIKE '%a%' and c1.nom = 'NoA')
ORDER BY  m.data_ desc;

/*2. Enumera el número de la targeta de crèdit, la data i el descompte utilitzat pels jugadors
per comprar articles de Pack Arena amb un cost superior a 200 i per comprar articles
que el seu nom contingui una "B".*/

SELECT c.num_targeta, c.data_, c.descompte
FROM article as a
    JOIN compren c on a.id_article = c.id_article
    JOIN arena_pack ap on a.id_article = ap.id_arena_pack
WHERE a.nom LIKE '%b%' AND a.preu > 200;

/*3. Enumerar el nom i el nombre d’articles comprats, així com el cost total dels articles
comprats i l’experiència dels jugadors que els van demanar. Filtra la sortida amb els 5
articles en què els usuaris han gastat més diners.*/
SELECT a.nom , COUNT(a.nom) as Quantitat, (a.preu*COUNT(a.nom)) as Cost_total, SUM(j.experiencia) as Experiencia_Jugadors
FROM article as a
    JOIN compren c on a.id_article = c.id_article
    JOIN jugador j on c.tag_jugador = j.tag_jugador
GROUP BY a.nom,a.preu
ORDER BY Cost_total desc
LIMIT 5;

--4. Donar els números de les targetes de crèdit que s'han utilitzat més.
SELECT c.num_targeta
FROM compren as c
GROUP BY c.num_targeta
HAVING COUNT(c.num_targeta) >= (SELECT COUNT(c1.num_targeta)
                        FROM compren as c1
                        GROUP BY c1.num_targeta
                        ORDER BY COUNT(c1.num_targeta) desc
                        LIMIT 1);

--5. Donar els descomptes totals de les emoticones comprades durant l'any 2020
SELECT SUM(c.descompte) as Descompte_Total
FROM compren as c
    JOIN article a on c.id_article = a.id_article
    JOIN emoticones e on a.id_article = e.id_emoticones
WHERE c.data_ >= '2020-01-01' AND c.data_ <= '2020-12-31';


/*6. Enumerar el nom, experiència i número de targeta de crèdit dels jugadors amb
experiència superior a 150.000. Filtra les targetes de crèdit que no han estat utilitzades
per comprar cap article. Donar dues consultes diferents per obtenir el mateix resultat.*/

SELECT j.nom, j.experiencia, tc.numero
FROM jugador as j
        JOIN targeta_credit tc on j.targeta_credit = tc.numero
WHERE j.experiencia > 150000 AND tc.numero NOT IN (SELECT c2.num_targeta
                                                FROM compren as c2);;

SELECT j.nom, j.experiencia, tc.numero
FROM jugador as j
    left JOIN compren c on j.tag_jugador = c.tag_jugador
    left JOIN targeta_credit tc on j.targeta_credit = tc.numero
WHERE j.experiencia > 150000 AND tc.numero NOT IN (SELECT c2.num_targeta
                                                FROM compren as c2);

/*7. Retorna el nom dels articles comprats pels jugadors que tenen més de 105 cartes o pels
jugadors que han escrit més de 4 missatges. Ordeneu els resultats segons el nom de
l'article de més a menys valor.*/

SELECT DISTINCT j3.tag_jugador, a.nom
FROM article as a
    JOIN compren as c on a.id_article = c.id_article
    JOIN jugador j3 on c.tag_jugador = j3.tag_jugador
WHERE 105 < (SELECT COUNT(f.nom_carta)
    FROM pila as p
    JOIN formen as f on p.id_pila = f.id_pila
    JOIN jugador j2 on p.tag_jugador = j2.tag_jugador
    WHERE j2.tag_jugador = j3.tag_jugador) OR 4 < (SELECT COUNT(c2.id_missatge)
                                    FROM jugador as j
                                    JOIN conversen as c2 on j.tag_jugador = c2.tag_envia
                                    WHERE j.tag_jugador = j3.tag_jugador)
ORDER BY a.nom desc;

--Validacions

--Quins jugadors tenen més de 105 cartes:
SELECT  COUNT(f.nom_carta), j.tag_jugador
    FROM carta as c1
    JOIN  formen as f on c1.nom = f.nom_carta
    JOIN nivellcarta as nv on f.nivell = nv.nivell
    JOIN pila as p on f.id_pila = p.id_pila
    JOIN jugador j on p.tag_jugador = j.tag_jugador
GROUP BY j.tag_jugador;

--Mirem taula cartes de nivell
SELECT *
FROM carta
join formen as f on carta.nom = f.nom_carta
join nivellcarta as nv on f.nivell = nv.nivell ;

--Mirem quina id_pila te cada jugador
SELECT  j.tag_jugador, COUNT(f.id_pila)
FROM pila p
JOIN formen as f on p.id_pila = f.id_pila
JOIN jugador as j on p.tag_jugador = j.tag_jugador
WHERE j.tag_jugador like '#PJUJCVUR'
GROUP BY j.tag_jugador
ORDER BY j.tag_jugador;

SELECT  j.tag_jugador, p.id_pila
FROM pila p
JOIN formen as f on p.id_pila = f.id_pila
JOIN jugador as j on p.tag_jugador = j.tag_jugador
WHERE j.tag_jugador like '#PJUJCVUR'
--GROUP BY j.tag_jugador
ORDER BY j.tag_jugador;

--Provem la consulta
SELECT  j.tag_jugador
FROM pila p
JOIN formen as f on p.id_pila = f.id_pila
JOIN jugador as j on p.tag_jugador = j.tag_jugador
where (SELECT COUNT(f1.nom_carta)
    FROM pila p1
    JOIN formen as f1 on p1.id_pila = f1.id_pila
    JOIN jugador as j1 on p1.tag_jugador = j1.tag_jugador
    WHERE j.tag_jugador = j1.tag_jugador) > 105
GROUP BY j.tag_jugador
ORDER BY j.tag_jugador;

SELECT COUNT(f1.nom_carta), j1.tag_jugador
  FROM pila p1
    JOIN formen as f1 on p1.id_pila = f1.id_pila
    JOIN jugador as j1 on p1.tag_jugador = j1.tag_jugador
GROUP BY j1.tag_jugador;


--Quins jugadors han enviat mes de 4 missatges
SELECT  j.tag_jugador, COUNT(c2.id_missatge)
FROM jugador as j
    JOIN conversen as c2 on j.tag_jugador = c2.tag_envia
GROUP BY j.tag_jugador
HAVING COUNT(c2.id_missatge) > 4
ORDER BY COUNT(c2.id_missatge) desc;



/*8. Retorna els missatges (text i data) enviats a l'any 2020 entre jugadors i que hagin estat
respostos, o els missatges sense respostes enviats a un clan. Ordena els resultats
segons la data del missatge i el text del missatge de més a menys valor.*/
SELECT m.cos as text, m.data_ as data
FROM missatge AS m
    join envia e on m.id_missatge = e.id_missatge
    join clan c on e.tag_clan = c.tag_clan
WHERE m.data_ >= '2020-01-01' AND m.data_ <= '2020-12-31'
ORDER BY m.data_ desc, text desc;







