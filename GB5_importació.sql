-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Importació

-- Eliminar taules temporals si existeixen
DROP TABLE IF EXISTS temporal1 CASCADE;
DROP TABLE IF EXISTS temporal2 CASCADE;
DROP TABLE IF EXISTS players CASCADE;
DROP TABLE  IF EXISTS cards CASCADE;

-- Eliminar importacions anteriors
DELETE FROM arena WHERE 1 = 1;
DELETE FROM millora WHERE 1 = 1;
DELETE FROM clan WHERE 1 = 1;
DELETE FROM temporada WHERE 1 = 1;
DELETE FROM amics WHERE 1 = 1;
DELETE FROM carta WHERE 1 = 1;
DELETE FROM carta WHERE 1 = 1;
DELETE FROM raresa WHERE 1 = 1;
DELETE FROM edifici WHERE 1 = 1;
DELETE FROM tropa WHERE 1 = 1;
DELETE FROM encanteri WHERE 1 = 1;
DELETE FROM jugador WHERE 1 = 1;


-- Arena (arena.csv)
COPY arena(id_arena, titol, nombre_min, nombre_max)
FROM 'C:\Users\Public\Datasets\arenas.csv'
DELIMITER ','
CSV HEADER;

-- Millora (technologies.csv buildings.csv)
CREATE TEMPORARY TABLE temporal1 (
    technology VARCHAR(255),
    cost INTEGER,
    max_level INTEGER,
    prerequisite VARCHAR(255),
    prereq_level INTEGER,
    mod_damage INTEGER,
    mod_hit_speed INTEGER,
    mod_radius INTEGER,
    mod_spawn_damage INTEGER,
    mod_lifetime INTEGER,
    description VARCHAR(255)
);

COPY temporal1
FROM 'C:\Users\Public\Datasets\technologies.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO millora(nom_millora, descripcio, cost)
SELECT technology, description, cost
FROM temporal1;

DROP TABLE temporal1;

CREATE TEMPORARY TABLE temporal2 (
    building VARCHAR(255),
    cost INTEGER,
    trophies INTEGER,
    prerequisite VARCHAR(255),
    mod_damage INTEGER,
    mod_hit_speed INTEGER,
    mod_radius INTEGER,
    mod_spawn_damage INTEGER,
    mod_lifetime INTEGER,
    description VARCHAR(255)
);

COPY temporal2
FROM 'C:\Users\Public\Datasets\buildings.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO millora(nom_millora, descripcio, cost)
SELECT building, description, cost
FROM temporal2;

DROP TABLE temporal2;

-- Temporades
COPY temporada(id_temporada,data_inici,data_fi)
    FROM 'C:\Users\Public\Datasets\seasons.csv'
    DELIMITER ','
    CSV HEADER;

-- Clans
COPY clan(tag_clan,nom,descripcio,trofeus_minims,nombre_trofeus,puntuacio)
    FROM 'C:\Users\Public\Datasets\clans.csv'
    DELIMITER ','
    CSV HEADER;

-- Jugadors
CREATE TEMPORARY TABLE players (
    tag VARCHAR(255),
    name VARCHAR(255),
    experience INTEGER,
    trophies INTEGER,
    cardnumber VARCHAR(255),
    cardexpiry DATE
);

COPY players
FROM 'C:\Users\Public\Datasets\players.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO Targeta_credit(numero,caducitat)
SELECT DISTINCT cardnumber, cardexpiry
FROM players;

INSERT INTO jugador(tag_jugador, nom, experiencia, trofeus, targeta_credit)
SELECT tag, name, experience, trophies, cardnumber
FROM players;

DROP TABLE players;

-- Amics
COPY amics(tag_jugador1, tag_jugador2)
    FROM 'C:\Users\Public\Datasets\friends.csv'
    DELIMITER ','
    CSV HEADER;

-- Cartes csv
CREATE TEMPORARY TABLE cards (
        name VARCHAR(255),
        rarity VARCHAR(255),
        arena INTEGER,
        damage INTEGER,
        hit_speed INTEGER,
        spawn_damage INTEGER,
        lifetime INTEGER,
        radious INTEGER
);

COPY cards
FROM 'C:\Users\Public\Datasets\cards.csv'
DELIMITER ','
CSV HEADER;

--Afegim a cartes
INSERT INTO Carta(nom ,dany ,velocitat_atac)
SELECT name,damage,hit_speed
FROM cards;

--Afegim a raresa
INSERT INTO raresa(nom)
SELECT DISTINCT rarity
FROM cards;

--Afegim a Edifici
INSERT INTO edifici(vida)
SELECT lifetime
FROM cards;

--Afegim a tropa
INSERT INTO tropa(dany_aparicio)
SELECT spawn_damage
FROM cards;

--Afegim a Encanteri
INSERT INTO encanteri(radi)
SELECT radious
FROM cards;

--Afegim a Arena
-- INSERT INTO arena(id_arena)
-- SELECT DISTINCT arena
-- FROM cards;

DROP TABLE cards;

