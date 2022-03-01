-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynés i Albert Tomàs

-- Set 4 - M'agrada la competició. M'agraden els reptes...


-- CONSULTES:

/* 1. Enumera el nom, els trofeus mínims, els trofeus màxims de les arenes que el seu títol
comença per "A" i tenen un paquet d’arena amb or superior a 8000. */
SELECT a.titol AS nom, a.nombre_min AS trofeus_minims, a.nombre_max AS trofeus_maxims, apa.or_ AS or_total FROM arena AS a
JOIN arena_pack_arena AS apa on a.id_arena = apa.id_arena
WHERE a.titol LIKE 'A%' AND apa.or_ > 8000
ORDER BY nom DESC;


/* 2. Llista de nom, data d'inici, data de finalització de les temporades i, de les batalles
d'aquestes temporades, el nom del jugador guanyador si el jugador té més victòries que
derrotes i la seva experiència és més gran de 200.000. */
SELECT t.id_temporada AS nom_temporada, t.data_inici, t.data_fi, j.nom FROM temporada AS t
JOIN batalla AS b ON t.id_temporada = b.id_temporada
JOIN guanya AS g ON b.id_batalla = g.id_batalla
JOIN perd AS p ON b.id_batalla = p.id_batalla
JOIN jugador AS j ON g.tag_jugador = j.tag_jugador
WHERE j.experiencia > 200000
GROUP BY t.id_temporada, j.nom, g.tag_jugador
HAVING COUNT(g.tag_jugador) > (
    SELECT COUNT(p2.tag_jugador) FROM perd AS p2
    );

SELECT COUNT(g.tag_jugador) FROM guanya AS g
GROUP BY g.tag_jugador;

-- NO SABEM EL NOMBRE DE VICTÒRIES I DERROTES I NO ESTÀ ALS DATASETS.
-- HE PROVAT FENT COUNTS DELS JUGADORS QUE GUANYEN I PERDEN (entre d'altres)


/* 3. Llistar la puntuació total dels jugadors guanyadors de batalles de cada temporada. Filtrar
la sortida per considerar només les temporades que han començat i acabat el 2019. */
SELECT j.nom, j.trofeus AS puntuacio FROM jugador AS j
JOIN guanya AS g ON j.tag_jugador = g.tag_jugador
JOIN batalla AS b ON g.id_batalla = b.id_batalla
JOIN temporada t ON b.id_temporada = t.id_temporada
WHERE t.data_inici >= '20190101' AND t.data_fi <= '20191231';

-- PUNTUACIÓ NO ESTÀ ALS DATASETS (HE SUPOSAT TROFEUS)

/* 4. Enumerar els noms de les arenes en què els jugadors veterans (experiència superior a
170.000) van obtenir insígnies després del "25-10-2021". Ordenar el resultat segons el
nom de l’arena en ordre ascendent. */
SELECT DISTINCT a.titol AS nom_arena FROM arena AS a
JOIN obte AS o ON a.id_arena = o.id_arena
JOIN jugador AS j ON o.tag_jugador = j.tag_jugador
JOIN insignia AS i ON o.id_insignia = i.id_insignia
WHERE j.experiencia > 170000 AND i.data > '20211025'
ORDER BY nom_arena ASC;


/* 5. Enumerar el nom de la insígnia, els noms de les cartes i el dany de les cartes dels
jugadors amb una experiència superior a 290.000 i obtingudes en arenes el nom de les
quals comença per "A" o quan la insígnia no té imatge. Així, considera només els
jugadors que tenen una carta el nom de la qual comença per "Lava". */
SELECT DISTINCT i.titol, c.nom, c.dany, j.experiencia FROM insignia AS i, carta AS c
JOIN pertany AS p on c.nom = p.nom_carta
JOIN jugador AS j on p.tag_jugador = j.tag_jugador
JOIN obte AS o on j.tag_jugador = o.tag_jugador
JOIN arena AS a on c.arena = a.id_arena
WHERE ((j.experiencia > 290000 AND a.titol LIKE 'A%') OR i.imatge IS NULL) AND c.nom LIKE 'Lava%';


/* 6. Donar el nom de les missions que donen recompenses a totes les arenes el títol de les
quals comença per "t" o acaba per "a". Ordena el resultat pel nom de la missió. */
SELECT DISTINCT m.titol AS nom_missio, a.titol FROM missio AS m
JOIN completen AS c on m.id_missio = c.id_missio
JOIN arena AS a on c.id_arena = a.id_arena
WHERE a.titol LIKE 'T%' OR a.titol LIKE '%a'
ORDER BY nom_missio;

/* 7. Donar el nom de les arenes amb jugadors que al novembre o desembre de 2021 van
obtenir insígnies si el nom de l’arena conté la paraula "Lliga", i les arenes tenen jugadors
que al 2021 van obtenir èxits el nom dels quals conté la paraula "Friend". */
SELECT


/* 8. Retorna el nom de les cartes que pertanyen a jugadors que van completar missions el
nom de les quals inclou la paraula "Armer" i l'or de la missió és més gran que l'or mitjà
recompensat en totes les missions de les arenes */
SELECT c.nom FROM carta AS c
JOIN pertany AS p ON c.nom = p.nom_carta
JOIN jugador AS j on p.tag_jugador = j.tag_jugador
JOIN completen AS c2 on j.tag_jugador = c2.tag_jugador

