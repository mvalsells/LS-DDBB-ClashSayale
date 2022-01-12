-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Validació

-- Validació entorn a Jugadors
SELECT tag_jugador, nom, experiencia, trofeus, targeta_credit, numero, caducitat
FROM jugador as j
JOIN targeta_credit AS tc ON j.targeta_credit = tc.numero;

SELECT tag_jugador1, tag_jugador2
FROM amics as a;

-- Validació entorn a Cartes

-- Validació entorn a Clans

-- Validació entorn a Batalles

-- Validació entorn a Arenes

-- Validació entorn a Missions

-- Validació entorn a Assoliments

-- Validació entorn a Botiga