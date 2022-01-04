-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Importació

-- Eliminar taules temporals si existeixen
DROP TABLE IF EXISTS temporal1 CASCADE;
DROP TABLE IF EXISTS temporal2 CASCADE;
DROP TABLE IF EXISTS players CASCADE;
DROP TABLE  IF EXISTS cards CASCADE;
DROP TABLE IF EXISTS battle CASCADE;
DROP TABLE IF EXISTS clan_battle CASCADE;
DROP TABLE IF EXISTS playersdeck CASCADE;
DROP TABLE IF EXISTS quests_arenas CASCADE;

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
DELETE FROM targeta_credit WHERE 1 = 1;
DELETE FROM batalla WHERE 1 = 1;
DELETE FROM lluiten WHERE 1 = 1;
DELETE FROM pila WHERE 1 = 1;
DELETE FROM missio WHERE 1 = 1;
DELETE FROM completen WHERE 1 = 1;


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

INSERT INTO targeta_credit(numero, caducitat)
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

-- Afegim a Batalla
CREATE TEMPORARY TABLE battle (
        winner INTEGER,
        loser INTEGER,
        winner_score INTEGER,
        loser_score INTEGER,
        date DATE,
        duration TIME,
        clan_battle INTEGER
);

COPY battle
FROM 'C:\Users\Public\Datasets\battles.csv'
DELIMITER ','
CSV HEADER;

--Afegim a batalla (com afegim un id si en el .csv no en tenim???)
-- INSERT INTO batalla(ID_batalla, data ,durada)
-- SELECT ???, date, duration
-- FROM battle;

-- (AQUÍ PASSA EL MATEIX AMB  "tag_jugador", EN EL .csv NO ENS HO POSA)
-- Afegim a guanyador
-- INSERT INTO guanya(num_trofeus)
-- SELECT winner_score
-- FROM battle;

-- Afegim a perdedor
-- INSERT INTO perd(num_trofeus)
-- SELECT loser_score
-- FROM battle;

DROP TABLE battle;

-- Afegim a batalla de clans
CREATE TEMPORARY TABLE clan_battle (
        battle INTEGER,
        clan VARCHAR (255),
        start_date DATE,
        end_date DATE
);

COPY clan_battle
FROM 'C:\Users\Public\Datasets\clan_battles.csv'
DELIMITER ','
CSV HEADER;

-- MATEIX ERROR AMB LES CLAUS PRIMÀRIES I FORÀNIES
-- Afegim a lluiten
-- INSERT INTO lluiten(tag_clan, ID_batalla)
-- SELECT clan, battle
-- FROM clan_battle;

DROP TABLE clan_battle;

-- Afegim a pila
CREATE TEMPORARY TABLE playersdeck (
        player VARCHAR (255),
        deck INTEGER,
        title VARCHAR (255),
        description TEXT,
        date DATE,
        card INTEGER,
        level INTEGER
);

COPY playersdeck
FROM 'C:\Users\Public\Datasets\playersdeck.csv'
DELIMITER ','
CSV HEADER;

-- HI HA UN ERROR DE LLARGÀRIA DE VARCHAR tot i qu he canviat a TEXT (en teoria deixa més caràcters)
-- INSERT INTO pila (tag_jugador, ID_pila, nom, descripcio, data_creacio)
-- SELECT player, deck, title, description, date
-- FROM playersdeck;

DROP TABLE playersdeck;

-- Afegim a Missió
CREATE TEMPORARY TABLE quests_arenas (
        quest_id INTEGER,
        arena_id INTEGER,
        gold INTEGER,
        experience INTEGER
);

COPY quests_arenas
FROM 'C:\Users\Public\Datasets\quests_arenas.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO missio (id_missio)
SELECT DISTINCT quest_id
FROM quests_arenas;

INSERT INTO completen (id_missio, id_arena, or_, experiencia)
SELECT quest_id, arena_id, gold, experience
FROM quests_arenas;

DROP TABLE quests_arenas;