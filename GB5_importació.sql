-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Importació

-- Eliminar taules temporals si existeixen
DROP TABLE IF EXISTS temporal1 CASCADE;
DROP TABLE IF EXISTS temporal2 CASCADE;
DROP TABLE IF EXISTS temporal3 CASCADE;
DROP TABLE IF EXISTS players CASCADE;
DROP TABLE  IF EXISTS cards CASCADE;
DROP TABLE IF EXISTS battle CASCADE;
DROP TABLE IF EXISTS clan_battle CASCADE;
DROP TABLE IF EXISTS playersdeck CASCADE;
DROP TABLE IF EXISTS quests_arenas CASCADE;
DROP TABLE IF EXISTS player_purchases CASCADE;
DROP TABLE IF EXISTS players_quests CASCADE;
DROP TABLE IF EXISTS msgPlayersTmp CASCADE;
DROP TABLE IF EXISTS msgClansTmp CASCADE;
DROP TABLE IF EXISTS playerCardsTmp CASCADE;
DROP TABLE  IF EXISTS playerClans CASCADE;
DROP TABLE IF EXISTS temporal4;


-- Eliminar importacions anteriors
DELETE FROM arena WHERE 1 = 1;
DELETE FROM millora WHERE 1 = 1;
DELETE FROM tecnologia WHERE 1 = 1;
DELETE FROM requereix_tecnologia WHERE 1 = 1;
DELETE FROM estructura WHERE 1 = 1;
DELETE FROM requereix_estructura WHERE 1 = 1;
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
--DELETE FROM player_purchases WHERE 1 = 1;
--DELETE FROM players_quests WHERE 1 = 1;


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

INSERT INTO millora(nom_millora, descripcio, cost, mod_damage, mod_hit_speed, mod_radius, mod_spawn_damage, mod_lifetime)
SELECT technology, description, cost, mod_damage, mod_hit_speed, mod_radius, mod_spawn_damage, mod_lifetime
FROM temporal1;

INSERT INTO tecnologia(id_tecnologia, nivell_maxim)
SELECT technology,max_level
FROM temporal1;

INSERT INTO requereix_tecnologia(id_tecnologia_nova, id_tecnologia_requerida, nivell_prerequisit)
SELECT technology,prerequisite, prereq_level
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

INSERT INTO millora(nom_millora, descripcio, cost, mod_damage, mod_hit_speed, mod_radius, mod_spawn_damage, mod_lifetime)
SELECT building, description, cost, mod_damage, mod_hit_speed, mod_radius, mod_spawn_damage, mod_lifetime
FROM temporal2;

INSERT INTO estructura(id_estructura, minim_trofeus)
SELECT building, trophies
FROM temporal2;

INSERT INTO requereix_estructura(id_estructura_nova, id_estructura_requerida)
SELECT building, prerequisite
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

CREATE TEMPORARY TABLE temporal3 (
    clan VARCHAR(255),
    tech VARCHAR(255),
    structure VARCHAR(255),
    date DATE,
    level INTEGER
);

COPY temporal3
FROM 'C:\Users\Public\Datasets\clan_tech_structures.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO tenen_tecnologia(tag_clan, id_tecnologia, data, nivell)
SELECT clan, tech, date, level
FROM temporal3
WHERE tech IS NOT NULL;

INSERT INTO tenen_estructura(tag_clan, id_estructura, data, nivell)
SELECT clan, structure, date, level
FROM temporal3
WHERE structure IS NOT NULL;


DROP TABLE temporal3;




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


--Donacio

COPY dona(tag_jugador, tag_clan, quantitat, data)
FROM 'C:\Users\Public\Datasets\playersClansdonations.csv'
DELIMITER ','
CSV HEADER;


--Forma part

CREATE TEMPORARY TABLE temporal4 (
    player VARCHAR(255),
    clan VARCHAR(255),
    role TEXT,
    date DATE
);

COPY temporal4(player, clan, role, date)
FROM 'C:\Users\Public\Datasets\playersClans.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO forma_part(tag_jugador, tag_clan, data)
SELECT player, clan, date
FROM temporal4;



DROP TABLE IF EXISTS temporal4;

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

--player_purchase csv
CREATE TEMPORARY TABLE player_purchases(
    player VARCHAR(255),
    credit_card VARCHAR(255),
    buy_id INTEGER,
    buy_name VARCHAR(255),
    buy_cost FLOAT,
    buy_stock INTEGER,
    date DATE,
    discount FLOAT,
    arenapack_id  INTEGER,
    chest_name VARCHAR(255),
    chest_rarity VARCHAR(255),
    chest_unlock_time INTEGER,
    chest_num_cards INTEGER,
    bundle_gold INTEGER,
    bundle_gems INTEGER,
    emote_name VARCHAR(255),
    emote_path VARCHAR(255)
);

COPY player_purchases
FROM 'C:\Users\Public\Datasets\player_purchases.csv'
DELIMITER ','
CSV HEADER;

--Player no cal ja s'ha afegit
--Credit card ja afegida no cal
--Id_compren es duplica al csv, es duplica pel nom
--INSERT INTO compren(id_compren,quantitat,data_,descompte)
--SELECT buy_id,buy_stock,date,discount
--FROM player_purchases;


--Afegim a articles
INSERT INTO article(nom,preu)
SELECT buy_name, buy_cost
FROM player_purchases;

--Afegim a arena paquet
--Hi han valors nulls a la id
--INSERT INTO art_arena(id_art_arena)
--SELECT arenapack_id
--FROM player_purchases;

--Afegim a cofre
INSERT INTO cofre(nom_cofre, temps, raresa, quantitat_cartes)
SELECT chest_name, chest_unlock_time, chest_rarity, chest_num_cards
FROM player_purchases;

--Afegim a bundle
INSERT INTO bundle(or_, gemmes)
SELECT bundle_gold, bundle_gems
FROM player_purchases;

--Afegim a emoticones
INSERT INTO emoticones(nom_imatge, direccio_imatge)
SELECT emote_name,emote_path
FROM player_purchases;

--Player_quest csv
CREATE TEMPORARY TABLE players_quests(
  player_tag VARCHAR(255),
  quest_id INTEGER,
  quest_title VARCHAR(255),
  quest_description VARCHAR(255),
  quest_requirement VARCHAR(255),
  quest_depends INTEGER,
  unlock DATE
);

COPY players_quests
FROM 'C:\Users\Public\Datasets\players_quests.csv'
DELIMITER ','
CSV HEADER;

