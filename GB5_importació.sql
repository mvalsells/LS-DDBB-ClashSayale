-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Importació

-- Eliminar taules temporals si existeixen
DROP TABLE IF EXISTS temporal1 CASCADE;
DROP TABLE IF EXISTS temporal2 CASCADE;
DROP TABLE IF EXISTS temporal3 CASCADE;
DROP TABLE IF EXISTS players CASCADE;
DROP TABLE  IF EXISTS cards CASCADE;
DROP TABLE IF EXISTS friend CASCADE;
DROP TABLE IF EXISTS battle CASCADE;
DROP TABLE IF EXISTS clan_battle CASCADE;
DROP TABLE IF EXISTS playersdeck CASCADE;
DROP TABLE IF EXISTS quests_arenas CASCADE;
DROP TABLE IF EXISTS player_purchases CASCADE;
DROP TABLE IF EXISTS players_quests CASCADE;
DROP TABLE IF EXISTS msgPlayersTmp CASCADE;
DROP TABLE IF EXISTS msgClansTmp CASCADE;
DROP TABLE IF EXISTS playerCardsTmp CASCADE;
DROP TABLE IF EXISTS playerClans CASCADE;
DROP TABLE IF EXISTS temporal4;
DROP TABLE IF EXISTS msgPlayersTmp CASCADE;
DROP TABLE IF EXISTS msgClansTmp CASCADE;
DROP TABLE IF EXISTS playerCardsTmp CASCADE;
DROP TABLE IF EXISTS playersbadge CASCADE;
DROP TABLE IF EXISTS playersachievements CASCADE;


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
DELETE FROM pertany WHERE 1 = 1;
DELETE FROM comparteixen WHERE 1 = 1;
DELETE FROM missatge WHERE 1 = 1;
DELETE FROM art_arena WHERE 1=1;
DELETE FROM nivellcarta WHERE 1 = 1;
DELETE FROM compren WHERE 1=1;
DELETE FROM article WHERE 1 = 1;
DELETE FROM cofre WHERE 1 = 1;
DELETE FROM emoticones WHERE 1 = 1;
DELETE FROM bundle WHERE 1 = 1;
DELETE FROM missio WHERE 1 = 1;
DELETE FROM depen WHERE 1 = 1;
DELETE FROM assoliment WHERE 1 = 1;
DELETE FROM insignia WHERE 1 = 1;


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

DROP TABLE IF EXISTS players;

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

INSERT INTO rol(nom, descripcio)
SELECT DISTINCT split_part(role,':', 1), split_part(role,':', 2)
FROM temporal4;

INSERT INTO forma_part(tag_jugador, tag_clan, id_rol, data)
SELECT player, clan, 1, date
FROM temporal4;

DROP TABLE IF EXISTS temporal4;

-- Amics
CREATE TEMPORARY TABLE friend (
    C1 VARCHAR (255),
    C2 VARCHAR (255)
);

COPY friend(C1, C2)
    FROM 'C:\Users\Public\Datasets\friends.csv'
    DELIMITER ','
    CSV HEADER;

INSERT INTO amics (tag_jugador1, tag_jugador2)
SELECT C1, C2
FROM friend;

DROP TABLE friend;

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
INSERT INTO edifici(nom,vida)
SELECT name,lifetime
FROM cards
WHERE lifetime IS NOT NULL;

--Afegim a tropa
INSERT INTO tropa(nom,dany_aparicio)
SELECT name,spawn_damage
FROM cards
WHERE spawn_damage IS NOT NULL;

--Afegim a Encanteri
INSERT INTO encanteri(nom,radi)
SELECT name,radious
FROM cards
WHERE radious IS NOT NULL;

-- Afegim a Arena
-- INSERT INTO arena(id_arena)
-- SELECT DISTINCT arena
-- FROM cards;

DROP TABLE cards;

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

INSERT INTO pila (tag_jugador, ID_pila, nom, descripcio, data_creacio)
SELECT DISTINCT player, deck, title, description, date
FROM playersdeck;

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

-- Afegim a batalla
INSERT INTO batalla(data, durada)
SELECT date, duration
FROM battle;

-- Afegim a guanyador
INSERT INTO guanya(tag_jugador, num_trofeus)
SELECT (SELECT tag_jugador FROM pila WHERE id_pila = battle.winner), battle.winner_score
FROM battle;

-- Afegim a perdedor
INSERT INTO perd(tag_jugador, num_trofeus)
SELECT (SELECT tag_jugador FROM pila WHERE id_pila = battle.loser), battle.loser_score
FROM battle;

-- Fem aquí el drop table de playersdeck ja que si no no existeix la taula per fer comparació
DROP TABLE playersdeck;
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

-- Afegim a lluiten
INSERT INTO lluiten(tag_clan, ID_batalla, data_inici, data_fi)
SELECT clan, battle, start_date, end_date
FROM clan_battle;

DROP TABLE clan_battle;

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
--SELECT DISTINCT buy_id,buy_stock,date,discount
--FROM player_purchases;


--Afegim a articles
INSERT INTO article(nom,preu)
SELECT buy_name, buy_cost
FROM player_purchases;

--Afegim a arena paquet
INSERT INTO art_arena(id_art_arena)
SELECT DISTINCT arenapack_id
FROM player_purchases
WHERE arenapack_id IS NOT NULL;

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

--Afegim a missions
--id repetida
--INSERT INTO missio(id_missio, titol, descripcio, requeriment, desbloqueja)
--SELECT DISTINCT quest_id,quest_title,quest_description,quest_requirement,unlock
--FROM players_quests;

--Afegim depen
INSERT INTO depen(id_missio1, id_missio2)
SELECT DISTINCT quest_id,quest_depends
FROM players_quests
WHERE quest_id IS NOT NULL AND quest_depends IS NOT NULL;

-- Playersachievement
CREATE TEMPORARY TABLE playersachievements(
    player VARCHAR(255),
    name VARCHAR(255),
    description VARCHAR(255),
    arena INTEGER,
    date DATE,
    gems INTEGER
);

COPY playersachievements
FROM 'C:\Users\Public\Datasets\playersachievements.csv'
DELIMITER ','
CSV HEADER;

--Afegim a assoliments
INSERT INTO assoliment(titol, recompensa_gemmes, descripcio, data)
SELECT name,gems,description,date
FROM playersachievements;

--Players badge csv
CREATE TEMPORARY TABLE playersbadge(
    player VARCHAR(255),
    name VARCHAR(255),
    arena INTEGER,
    date DATE,
    img VARCHAR(255)
);

COPY playersbadge
FROM 'C:\Users\Public\Datasets\playersbadge.csv'
DELIMITER ','
CSV HEADER;

--afegim a insignia
INSERT INTO insignia(imatge, titol, data)
SELECT img,name,date
FROM playersbadge;

-- -------------- MISSATGES --------------

-- msg_between_players.csv
CREATE TEMPORARY TABLE msgPlayersTmp(
    id INTEGER,
    sender VARCHAR(255),
    reciver VARCHAR(255),
    text TEXT,
    date DATE,
    answer INTEGER,
    total INTEGER
);

COPY msgPlayersTmp(id, sender, reciver, text, date, answer)
FROM 'C:\Users\Public\Datasets\messages_between_players.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO msgPlayersTmp(id,total)
SELECT '-2147483648',COUNT(id)
FROM msgPlayersTmp;

INSERT INTO missatge(id_missatge, cos, data_, id_resposta)
SELECT id, text, date, answer
FROM msgPlayersTmp
WHERE id IS NOT NULL AND text IS NOT NULL AND date IS NOT NULL AND answer IS NOT NULL;

-- msg_to_clans.csv
CREATE TEMPORARY TABLE msgClansTmp(
    id INTEGER,
    player VARCHAR(255),
    clan VARCHAR(255),
    text TEXT,
    date DATE,
    answer INTEGER
);

COPY msgClansTmp
FROM 'C:\Users\Public\Datasets\messages_to_clans.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO missatge(id_missatge, cos, data_, id_resposta)
SELECT (id + (SELECT total FROM msgPlayersTmp WHERE id = -2147483648)), text, date, (answer + (SELECT total FROM msgPlayersTmp WHERE id = -2147483648))
FROM msgClansTmp;

-- ------------------------------------------
-- -------------- Cartes --------------
CREATE TEMPORARY TABLE playerCardsTmp(
    player VARCHAR(255),
    id INTEGER,
    name VARCHAR(255),
    level INTEGER,
    amount INTEGER,
    date DATE
);

COPY playerCardsTmp
FROM 'C:\Users\Public\Datasets\playerscards.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO nivellcarta(nivell)
SELECT DISTINCT level
FROM playerCardsTmp;

INSERT INTO pertany(nom_carta,tag_jugador,quantitat,data_desbolqueig, nivell)
SELECT pct.name,pct.player,pct.amount,pct.date,pct.level
FROM playerCardsTmp AS pct, carta AS c
WHERE pct.name = c.nom;

-- Decks compartits (shared_decks.csv)
COPY comparteixen(id_pila, tag_jugador)
FROM 'C:\Users\Public\Datasets\shared_decks.csv'
CSV HEADER;
