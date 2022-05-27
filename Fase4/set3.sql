-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Set 3 - Tingueu valor. Encara tenim el nostre clan. Sempre hi ha esperança.


-- Funció que donat un clan escolleix un nou leader aleatoriament dels
CREATE OR REPLACE FUNCTION f_selNewLeader(VARCHAR)
RETURNS void AS $$
DECLARE
    leaderID INTEGER = (SELECT id_rol FROM rol WHERE nom = 'leader');
    coLeaderID INTEGER = (SELECT id_rol FROM rol WHERE nom = 'coLeader');
    memberID INTEGER = (SELECT id_rol FROM rol WHERE nom = 'member');
    randColeader VARCHAR;
    randMember VARCHAR;
    countColeader INTEGER;

BEGIN

    SELECT count(id_forma_part) INTO countColeader
        FROM forma_part WHERE id_rol = coLeaderID AND tag_clan = $1;

    IF countColeader > 0
    THEN
        SELECT tag_jugador INTO randColeader
            FROM forma_part
            WHERE id_rol = coLeaderID AND tag_clan = $1
            OFFSET floor(random() * countColeader)
            LIMIT 1;
        UPDATE forma_part
            SET id_rol = leaderID, data = now()
            WHERE tag_clan = $1 AND tag_jugador = randColeader AND id_rol = coLeaderID;
    ELSE
        SELECT tag_jugador INTO randMember
            FROM forma_part
            WHERE id_rol = memberID AND tag_clan = $1
            OFFSET floor(random() * (SELECT count(id_forma_part) FROM forma_part WHERE id_rol = memberID AND tag_clan = $1))
            LIMIT 1;
        UPDATE forma_part
            SET id_rol = leaderID, data = now()
            WHERE tag_clan = $1 AND tag_jugador = randMember AND id_rol = memberID;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 3.1) "Cop d'efecte"
-- De vegades, la propietat d'un clan es transfereix de jugadors que ja no juguen tan sovint
-- com abans a altres més implicats, i com que els clans estan formats per molts jugadors de
-- tot el món que no es coneixen entre si, alguns trolls podrien voler destruir un clan des de
-- dins.
-- Per aquesta raó, necessitem crear un trigger que garanteixi que, una vegada que un jugador
-- és ascendit a líder de clan, no faci fora més de 5 jugadors alhora en les primeres 24 hores
-- després del seu ascens. Si aquest és el cas, els canvis s'han de desfer i la propietat del
-- clan, és a dir, el rol de líder, s'ha d'assignar a l'atzar a un dels colíders del clan, i si no n'hi
-- ha cap, a qualsevol membre de l'atzar que quedi. Es pot considerar els jugadors que han
-- estat expulsats d'un clan sempre que els seus rols a les taules de jugadors del clan s'hagin
-- establert com a nuls.
DROP TABLE IF EXISTS logDeletes;
CREATE TABLE logDeletes(
    id SERIAL PRIMARY KEY ,
    tag_removed VARCHAR,
    tag_clan VARCHAR,
    id_rol INTEGER,
    tag_leader VARCHAR,
    removed_date date
);

CREATE OR REPLACE FUNCTION f_CopdEfecte()
RETURNS trigger AS $$
DECLARE
    newestLeader INTEGER = (SELECT id_forma_part
                                FROM forma_part
                                WHERE tag_clan = OLD.tag_clan
                                AND id_rol = (SELECT id_rol FROM rol WHERE nom = 'leader')
                                ORDER BY data desc
                                LIMIT 1);
    item INTEGER;
BEGIN
    IF NEW.id_rol IS NULL
    THEN

        INSERT INTO logDeletes(tag_removed, tag_clan, id_rol, tag_leader, removed_date) VALUES (OLD.tag_jugador, OLD.tag_clan, OLD.id_rol, newestLeader, now());

        IF ((SELECT data + interval '1 day' FROM forma_part WHERE id_forma_part = newestLeader)  > now())
        THEN
            UPDATE forma_part
            SET jugadors_eliminats = jugadors_eliminats + 1
            WHERE id_forma_part = newestLeader;

            IF ((SELECT jugadors_eliminats FROM forma_part WHERE id_forma_part = newestLeader) > 5)
            THEN
            INSERT INTO dummylog VALUES ('more than 5',now());

                -- Desfer canvis

                -- Deleting logs older than 24h that aren't relevant and it is unnecessary storing them
                DELETE FROM logDeletes
                WHERE (removed_date - interval '24 hours') > now();

                FOR item IN (SELECT id FROM logDeletes WHERE tag_leader = (SELECT tag_leader FROM forma_part WHERE id_forma_part = newestLeader) AND tag_clan = OLD.tag_clan)
                LOOP
                    UPDATE forma_part
                    SET id_rol = (SELECT id_rol FROM logDeletes WHERE id = item)
                    WHERE tag_clan = OLD.tag_clan AND tag_jugador = (SELECT tag_removed FROM logDeletes WHERE id = item);
                END LOOP;

                -- Downgrade
               UPDATE forma_part
                    SET id_rol = NULL, jugadors_eliminats = 0
                    WHERE tag_clan = OLD.tag_clan AND id_forma_part = newestLeader;
                PERFORM f_selNewLeader(OLD.tag_clan);

            END IF;
        END IF;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS CopdEfecte ON forma_part;
CREATE TRIGGER CopdEfecte
AFTER UPDATE ON forma_part
FOR EACH ROW
WHEN (pg_trigger_depth() = 0) -- Per evitar que el trigger salti al fer updates de forma part dins del mateix trigger
EXECUTE FUNCTION f_CopdEfecte();


-- 3.2) Hipocresia de trofeus minims
-- La majoria dels clans tenen un mínim de trofeus per poder-s'hi unir, alguns fins i tot són
-- "massa exclusius" i requereixen una invitació o sol·licitud d'acceptació per unir-s'hi. No
-- obstant això, una vegada que entres al clan, si perds trofeus i acabes per sota del llindar
-- mínim de trofeus, actualment no passa res.
-- Per compensar això i garantir que tots els membres del clan estiguin al nivell mínim, hauràs
-- de comprovar després de cada actualització dels trofeus dels jugadors que segueixen
-- estant per sobre del llindar. Si no és així, hauràs d'expulsar aquest jugador del clan i fer els
-- canvis necessaris a la base de dades.
-- A més, si l'usuari que ha estat expulsat del clan és el líder, hauràs de comprovar quants
-- coliders queden, i si no n'hi ha, triar un membre a l'atzar que pertanyi al clan perquè sigui
-- el líder.

DROP function IF EXISTS f_minTrofeus;
CREATE OR REPLACE FUNCTION f_minTrofeus()
RETURNS trigger AS $$
DECLARE
    currentClan VARCHAR;
    idFormaPart INTEGER;
BEGIN
    SELECT tag_clan INTO currentClan
        FROM forma_part
        WHERE tag_jugador = NEW.tag_jugador
        ORDER BY data desc
        LIMIT 1;

    SELECT id_forma_part INTO idFormaPart
        FROM forma_part
        WHERE tag_jugador = NEW.tag_jugador
        ORDER BY data desc
        LIMIT 1;


    IF (SELECT trofeus_minims FROM clan WHERE tag_clan = currentClan) < NEW.trofeus
    THEN
        IF (SELECT id_rol FROM forma_part WHERE id_forma_part = idFormaPart) = (SELECT id_rol FROM rol WHERE nom = 'leader')
        THEN
            SELECT f_selNewLeader(currentClan);
        end if;
        UPDATE forma_part
        SET id_rol = NULL
        WHERE id_forma_part = idFormaPart;
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS minTrofeus ON jugador;
CREATE TRIGGER minTrofeus
    AFTER UPDATE OF trofeus ON jugador
    FOR EACH ROW
    EXECUTE FUNCTION f_minTrofeus();

-- 3.3) Mals perdedors
-- Després d'un atac de pisin al domini de correu electrònic de ClashSayale, molts dels
-- comptes del gestor de la base de dades s'han vist compromesos, i els hackers els han
-- utilitzat per esborrar de la nostra base de dades les batalles en què han perdut. Mentre
-- l'equip de suport tècnic intenta recuperar els comptes dels treballadors, la junta ha decidit
-- implementar un trigger perquè tots els esborrats realitzats a la base de dades siguin filtrats
-- i que l'únic compte que els pugui fer sigui el de "admin".
-- Per tant, caldrà configurar una funció trigger que, en comptes d'esborrar la informació,
-- comproveu l'usuari de la base de dades que l'està realitzant, i si no és admin, haurà d'afegir
-- una entrada a Avisos amb:
-- - L'usuari actual de la base de dades connectat que està fent l'esborrat
-- - La taula de batalles que està sent afectada
-- - La data en què s'ha produït l'esborrat
-- - Un missatge amb el següent format:
-- "S'ha intentat esborrar la batalla " + <id_batalla> + " on l 'usuari " +
-- <etiqueta_jugador_perdedor> + " va perdre " + <puntuació_perdedor> + " trofeus"


CREATE OR REPLACE FUNCTION f_malsPerdedors()
RETURNS trigger AS $$
DECLARE
    warningMsg VARCHAR;
BEGIN
    IF NOT current_user = 'admin'
    THEN
        SELECT CONCAT('S''ha intentat esborrar la batalla ', OLD.id_batalla, ' on l''usuari ', (SELECT tag_jugador FROM perd WHERE id_batalla = OLD.id_batalla), ' va perdre ', (SELECT num_trofeus FROM perd WHERE id_batalla = OLD.id_batalla), ' trofeus') INTO warningMsg;
        INSERT INTO warnings (affected_table, error_message, date, username)  VALUES ('batalla', warningMsg, now(),current_user);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS malsPerdedors ON jugador;
CREATE TRIGGER malsPerdedors
    BEFORE DELETE ON batalla
    FOR EACH ROW
    EXECUTE FUNCTION f_malsPerdedors();
