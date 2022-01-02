-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Importació

-- Eliminar taules temporals si existeixen
DROP TABLE IF EXISTS temporal1 CASCADE;
DROP TABLE IF EXISTS temporal2 CASCADE;

-- Eliminar importacions anteriors
DELETE FROM arena WHERE 1 = 1;
DELETE FROM millora WHERE 1 = 1;

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
    description VARCHAR(255));

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
    description VARCHAR(255));

COPY temporal2
FROM 'C:\Users\Public\Datasets\buildings.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO millora(nom_millora, descripcio, cost)
SELECT building, description, cost
FROM temporal2;

DROP TABLE temporal2;