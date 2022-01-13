-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Importació

-- Eliminar taules temporals si existeixen
DROP TABLE IF EXISTS technologies CASCADE;
DROP TABLE IF EXISTS buildings CASCADE;
DROP TABLE IF EXISTS clans_tech_strucutres CASCADE;
DROP TABLE IF EXISTS jugadors_clans CASCADE;
DROP TABLE IF EXISTS players CASCADE;
DROP TABLE  IF EXISTS cards CASCADE;
DROP TABLE IF EXISTS friend CASCADE;
DROP TABLE IF EXISTS battleTmp CASCADE;
DROP TABLE IF EXISTS clans_battle CASCADE;
DROP TABLE IF EXISTS playersdeck CASCADE;
DROP TABLE IF EXISTS quests_arenas CASCADE;
DROP TABLE IF EXISTS player_purchases CASCADE;
DROP TABLE IF EXISTS players_quests CASCADE;
DROP TABLE IF EXISTS msgPlayersTmp CASCADE;
DROP TABLE IF EXISTS msgClansTmp CASCADE;
DROP TABLE IF EXISTS playerCardsTmp CASCADE;
DROP TABLE IF EXISTS playerClans CASCADE;
DROP TABLE IF EXISTS msgPlayersTmp CASCADE;
DROP TABLE IF EXISTS msgClansTmp CASCADE;
DROP TABLE IF EXISTS playerCardsTmp CASCADE;
DROP TABLE IF EXISTS playersbadge CASCADE;
DROP TABLE IF EXISTS playersachievements CASCADE;
DROP TABLE IF EXISTS arena_packTmp CASCADE;


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
DELETE FROM arena_pack WHERE 1=1;
DELETE FROM nivellcarta WHERE 1 = 1;
DELETE FROM compren WHERE 1=1;
DELETE FROM article WHERE 1 = 1;
DELETE FROM cofre WHERE 1 = 1;
DELETE FROM emoticones WHERE 1 = 1;
DELETE FROM bundle WHERE 1 = 1;
DELETE FROM depen WHERE 1 = 1;
DELETE FROM assoliment WHERE 1 = 1;
DELETE FROM insignia WHERE 1 = 1;


-- Arena (arena.csv)
COPY arena(id_arena, titol, nombre_min, nombre_max)
FROM 'C:\Users\Public\Datasets\arenas.csv'
DELIMITER ','
CSV HEADER;

-- Millora (technologies.csv buildings.csv)
CREATE TEMPORARY TABLE technologies (
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

COPY technologies
FROM 'C:\Users\Public\Datasets\technologies.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO millora(nom_millora, descripcio, cost, mod_damage, mod_hit_speed, mod_radius, mod_spawn_damage, mod_lifetime)
SELECT technology, description, cost, mod_damage, mod_hit_speed, mod_radius, mod_spawn_damage, mod_lifetime
FROM technologies;

INSERT INTO tecnologia(id_tecnologia, nivell_maxim)
SELECT technology,max_level
FROM technologies;

INSERT INTO requereix_tecnologia(id_tecnologia_nova, id_tecnologia_requerida, nivell_prerequisit)
SELECT technology,prerequisite, prereq_level
FROM technologies
WHERE prerequisite IS NOT NULL ;

DROP TABLE technologies;


CREATE TEMPORARY TABLE buildings (
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

COPY buildings
FROM 'C:\Users\Public\Datasets\buildings.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO millora(nom_millora, descripcio, cost, mod_damage, mod_hit_speed, mod_radius, mod_spawn_damage, mod_lifetime)
SELECT building, description, cost, mod_damage, mod_hit_speed, mod_radius, mod_spawn_damage, mod_lifetime
FROM buildings;

INSERT INTO estructura(id_estructura, minim_trofeus)
SELECT building, trophies
FROM buildings;

INSERT INTO requereix_estructura(id_estructura_nova, id_estructura_requerida)
SELECT building, prerequisite
FROM buildings
WHERE prerequisite IS NOT NULL ;

DROP TABLE buildings;

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

CREATE TEMPORARY TABLE clans_tech_strucutres (
    clan VARCHAR(255),
    tech VARCHAR(255),
    structure VARCHAR(255),
    date DATE,
    level INTEGER
);

COPY clans_tech_strucutres
FROM 'C:\Users\Public\Datasets\clan_tech_structures.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO tenen_tecnologia(tag_clan, id_tecnologia, data, nivell)
SELECT clan, tech, date, level
FROM clans_tech_strucutres
WHERE tech IS NOT NULL;

INSERT INTO tenen_estructura(tag_clan, id_estructura, data, nivell)
SELECT clan, structure, date, level
FROM clans_tech_strucutres
WHERE structure IS NOT NULL;

DROP TABLE clans_tech_strucutres;

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

CREATE TEMPORARY TABLE jugadors_clans (
    player VARCHAR(255),
    clan VARCHAR(255),
    role TEXT,
    date DATE
);

COPY jugadors_clans(player, clan, role, date)
FROM 'C:\Users\Public\Datasets\playersClans.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO rol(nom, descripcio)
SELECT DISTINCT split_part(role,': ', 1), split_part(role,': ', 2)
FROM jugadors_clans;

INSERT INTO forma_part(tag_jugador, tag_clan, id_rol, data)
SELECT player, clan, rol.id_rol, date
FROM rol JOIN jugadors_clans ON jugadors_clans.role = concat(rol.nom, ': ', rol.descripcio);

UPDATE clan
SET creador_clan = jc.player
FROM jugadors_clans AS jc
WHERE jc.role LIKE 'leader%' AND clan.tag_clan = jc.clan;



DROP TABLE IF EXISTS jugadors_clans;

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

--Afegim a raresa
INSERT INTO raresa(nom)
SELECT DISTINCT rarity
FROM cards;

--Afegim a cartes
INSERT INTO Carta(nom ,dany ,velocitat_atac,arena,raresa)
SELECT name,damage,hit_speed,arena,rarity
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
CREATE TEMPORARY TABLE battleTmp (
    winner INTEGER,
    loser INTEGER,
    winner_score INTEGER,
    loser_score INTEGER,
    date DATE,
    duration TIME,
    clan_battle INTEGER
);

COPY battleTmp
FROM 'C:\Users\Public\Datasets\battles.csv'
DELIMITER ','
CSV HEADER;

-- Afegim a batalla
INSERT INTO batalla(data, durada,clan_battle)
SELECT date, duration,clan_battle
FROM battleTmp;

-- Afegim a guanyador
INSERT INTO guanya(tag_jugador, ID_pila, num_trofeus)
SELECT (SELECT tag_jugador FROM pila WHERE id_pila = battleTmp.winner), (SELECT ID_pila FROM pila WHERE id_pila = battleTmp.winner), battleTmp.winner_score
FROM battleTmp;

-- Afegim a perdedor
INSERT INTO perd(tag_jugador, ID_pila, num_trofeus)
SELECT (SELECT tag_jugador FROM pila WHERE id_pila = battleTmp.loser), (SELECT ID_pila FROM pila WHERE id_pila = battleTmp.loser), battleTmp.loser_score
FROM battleTmp;

-- Fem aquí el drop table de playersdeck ja que si no no existeix la taula per fer comparació
DROP TABLE playersdeck;

-- Afegim a batalla de clans
CREATE TEMPORARY TABLE clans_battle (
    battle INTEGER,
    clan VARCHAR (255),
    start_date DATE,
    end_date DATE
);

COPY clans_battle
FROM 'C:\Users\Public\Datasets\clan_battles.csv'
DELIMITER ','
CSV HEADER;

-- Afegim a lluiten
INSERT INTO lluiten(tag_clan, ID_batalla, data_inici, data_fi)
SELECT cb.clan,b.id_batalla , cb.start_date, cb.end_date
FROM clans_battle AS cb
JOIN batalla AS b ON cb.battle = b.clan_battle;

DROP TABLE clans_battle;
DROP TABLE battleTmp;

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
INSERT INTO missio(id_missio,titol, descripcio, requeriment)
SELECT DISTINCT quest_id,quest_title,quest_description,quest_requirement
FROM players_quests;

--Afegim depen
INSERT INTO depen(id_missio1, id_missio2)
SELECT DISTINCT quest_id,quest_depends
FROM players_quests
WHERE quest_id IS NOT NULL AND quest_depends IS NOT NULL;

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

INSERT INTO completen(id_missio, id_arena, tag_jugador,or_, experiencia,desbloqueja)
SELECT qa.quest_id, qa.arena_id,pq.player_tag,qa.gold, qa.experience,pq.unlock
FROM quests_arenas AS qa, players_quests AS pq
WHERE qa.quest_id = pq.quest_id;


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

--Afegim a articles
INSERT INTO article(id_article,nom,preu,quantitat)
SELECT DISTINCT buy_id,buy_name, buy_cost, buy_stock
FROM player_purchases;

--Afegim a arena paquet
INSERT INTO arena_pack(id_arena_pack,id_pack)
SELECT DISTINCT buy_id,arenapack_id
FROM player_purchases
WHERE arenapack_id IS NOT NULL;

--Afegim a cofre
INSERT INTO cofre(nom_cofre, temps, raresa, quantitat_cartes)
SELECT DISTINCT chest_name, chest_unlock_time, chest_rarity, chest_num_cards
FROM player_purchases;

--Afegim a bundle
INSERT INTO bundle(or_, gemmes)
SELECT DISTINCT bundle_gold, bundle_gems
FROM player_purchases;

--Afegim a emoticones
INSERT INTO emoticones(nom_imatge, direccio_imatge)
SELECT DISTINCT emote_name,emote_path
FROM player_purchases;

--Id_compren es duplica
INSERT INTO compren(tag_jugador, num_targeta,data_,descompte)
SELECT DISTINCT player,credit_card,date,discount
FROM player_purchases;


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
INSERT INTO assoliment(titol, recompensa_gemmes, descripcio)
SELECT name,gems,description
FROM playersachievements;

--Afegim a aconsegueixen
INSERT INTO aconsegueix(tag_jugador,id_arena, data)
SELECT player, arena, date
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
    answer INTEGER
);

COPY msgPlayersTmp(id, sender, reciver, text, date, answer)
FROM 'C:\Users\Public\Datasets\messages_between_players.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO missatge(id_missatge, cos, data_, id_resposta)
SELECT id, text, date, answer
FROM msgPlayersTmp
WHERE id IS NOT NULL AND text IS NOT NULL AND date IS NOT NULL;

INSERT INTO conversen(tag_envia, tag_rep, id_missatge)
SELECT sender, reciver, id
FROM msgPlayersTmp
WHERE id IS NOT NULL AND sender IS NOT NULL AND reciver IS NOT NULL;


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

INSERT INTO msgPlayersTmp(id,answer)
SELECT '-2147483648',COUNT(id_missatge)
FROM missatge;

INSERT INTO missatge(id_missatge, cos, data_, id_resposta)
SELECT (mct.id + mpt.answer), mct.text, mct.date, (mct.answer + mpt.answer)
FROM msgClansTmp AS mct
JOIN msgPlayersTmp AS mpt ON mpt.id = -2147483648;

INSERT INTO Envia(ID_MISSATGE, TAG_CLAN, TAG_JUGADOR)
SELECT (mct.id + mpt.answer), clan, player
FROM msgClansTmp AS mct
JOIN msgPlayersTmp AS mpt ON mpt.id = -2147483648;

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
FROM playerCardsTmp AS pct
JOIN carta AS c ON pct.name = c.nom;

-- Decks compartits (shared_decks.csv)
COPY comparteixen(id_pila, tag_jugador)
FROM 'C:\Users\Public\Datasets\shared_decks.csv'
DELIMITER ','
CSV HEADER;


-- Arena pack
CREATE TEMPORARY TABLE arena_packTmp(
    id INTEGER,
    arena INTEGER,
    gold INTEGER
);

COPY arena_packTmp(id,arena,gold)
FROM 'C:\Users\Public\Datasets\arena_pack.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO arena_pack_arena(id_arena, id_arena_pack, or_)
SELECT arena,id,gold
FROM arena_packTmp AS apt
JOIN arena_pack AS ap ON ap.id_arena_pack = apt.id;


