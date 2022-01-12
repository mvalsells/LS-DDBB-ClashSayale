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
-- Validació entorn a Arenes

-- Validació entorn a Missions

-- Validació entorn a Assoliments

-- Validació entorn a Botiga