-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Validació

-- Validació entorn a Jugadors
SELECT tag_jugador, nom, experiencia, trofeus, targeta_credit, numero, caducitat
FROM jugador as j
JOIN targeta_credit AS tc ON j.targeta_credit = tc.numero;

SELECT tag_jugador1, tag_jugador2
FROM amics;

-- Validació entorn a Cartes
SELECT id_pila, tag_jugador
FROM comparteixen;

-- Validació entorn a Clans

-- Validació entorn a Batalles
SELECT guanya.id_pila, perd.id_pila, guanya.num_trofeus, perd.num_trofeus, batalla.data, batalla.durada
FROM batalla
JOIN guanya ON batalla.id_batalla = guanya.id_batalla
JOIN perd ON batalla.id_batalla = perd.id_batalla;

SELECT tag_clan, id_batalla, data_inici, data_fi
FROM lluiten;

-- Validació entorn a Arenes

-- Validació entorn a Missions
SELECT j.tag_jugador AS tag_jugador, j.nom AS nom_jugador, count(c.id_missio) AS num_missions
FROM completen AS c
JOIN jugador AS j on c.tag_jugador = j.tag_jugador
GROUP BY j.tag_jugador
ORDER BY num_missions DESC;

SELECT j.tag_jugador AS tag_jugador, j.nom AS nom_jugador, SUM(c.or_) AS or_guanyat, SUM(c.experiencia) AS expereincia_guanyada
FROM completen AS c
JOIN jugador AS j on c.tag_jugador = j.tag_jugador
GROUP BY j.tag_jugador
ORDER BY or_guanyat DESC, expereincia_guanyada DESC;

SELECT m.id_missio, m.titol AS titol_missio, COUNT(c.id_arena) AS num_arenes
FROM missio AS m
JOIN completen AS c on m.id_missio = c.id_missio
GROUP BY m.id_missio;

SELECT m.titol AS Missio, (SELECT m2.titol FROM missio AS m2 WHERE m2.id_missio = d.id_missio2) AS depen
FROM missio AS m
JOIN depen AS d on m.id_missio = d.id_missio1;

SELECT j.tag_jugador, j.nom, a.titol AS titol_arena, SUM(c.experiencia) AS experiencia
FROM arena AS a
JOIN completen AS c on a.id_arena = c.id_arena
JOIN jugador AS j on c.tag_jugador = j.tag_jugador
GROUP BY a.id_arena, j.tag_jugador
ORDER BY experiencia DESC
LIMIT 10;

-- SELECT DISTINCT count(id_missio1)
-- FROM depen

-- Validació entorn a Assoliments



-- Validació entorn a Botiga
