-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Set 2 - No sóc un jugador, sóc un jugador de videojocs

-- Per borrar triggers --------- BORRAR -------------

CREATE OR REPLACE FUNCTION strip_all_triggers() RETURNS text AS $$ DECLARE
    triggNameRecord RECORD;
    triggTableRecord RECORD;
BEGIN
    FOR triggNameRecord IN select distinct(trigger_name) from information_schema.triggers where trigger_schema = 'public' LOOP
        FOR triggTableRecord IN SELECT distinct(event_object_table) from information_schema.triggers where trigger_name = triggNameRecord.trigger_name LOOP
            RAISE NOTICE 'Dropping trigger: % on table: %', triggNameRecord.trigger_name, triggTableRecord.event_object_table;
            EXECUTE 'DROP TRIGGER ' || triggNameRecord.trigger_name || ' ON ' || triggTableRecord.event_object_table || ';';
        END LOOP;
    END LOOP;

    RETURN 'done';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

select strip_all_triggers();


/*
 Comprar a la botiga és un procés senzill, simplement se selecciona l’article desitjat, es tria
una targeta de crèdit i es realitza la compra. No obstant això, quan es tracta de la
persistència a la base de dades d’aquesta informació, no és tan fàcil de manejar com podria
semblar. La consulta que realitza l'aplicació és un INSERT a la taula Compres/Comandes
(la denominació pot ser diferent en la seva implementació), però a partir d'aquí poden
passar moltes coses.

Un dels articles que els jugadors poden comprar són els Bundles. Aquests articles, com es
descriu als fitxers proporcionats de l'Etapa 2, inclouen un cert nombre de gemmes i or que
es compren, i posteriorment haurà de sumar aquestes quantitats als totals de cada jugador
que els compra. Un altre element que has de comprovar són els Packs d'Arena, que tenen
diferents quantitats d'or en funció de l'Arena on el jugador puntuï. Realitza els triggers
necessaris per actualitzar els atributs dels jugadors afectats en funció de les compres
 */

SELECT jugador.tag_jugador, jugador.or_,jugador.gemmes from jugador  WHERE tag_jugador  like '#QV2PYL';

-- algo + null = null, fem update perque no passi
UPDATE jugador
            SET or_ = 0
            WHERE  or_ IS NULL;

SELECT jugador.tag_jugador, jugador.or_,jugador.gemmes from jugador  WHERE tag_jugador  like '#QV2PYL';

DROP FUNCTION if exists suma_or_gemmes;

CREATE OR REPLACE FUNCTION suma_or_gemmes()
RETURNS trigger as $$
BEGIN
        UPDATE jugador
            SET or_  = jugador.or_ + (SELECT b.or_ from bundle as b
                            WHERE new.id_article = b.id_bundle)
            WHERE new.tag_jugador = jugador.tag_jugador;

        UPDATE jugador
            SET gemmes = jugador.gemmes + (SELECT b.gemmes from bundle as b where new.id_article = b.id_bundle)
            WHERE new.tag_jugador = jugador.tag_jugador;

        UPDATE jugador
            SET or_ = or_ + (SELECT apa.or_ from arena_pack_arena as apa join
                arena a on apa.id_arena = a.id_arena
                join arena_pack ap on apa.id_arena_pack = ap.id_arena_pack
                join article a2 on ap.id_arena_pack = a2.id_article
                join compren c on a2.id_article = c.id_article
                join jugador j2 on c.tag_jugador = j2.tag_jugador
                where new.id_article = ap.id_arena_pack and j2.tag_jugador = new.tag_jugador and
                    (SELECT(SUM(g.num_trofeus) + SUM(p.num_trofeus))
                    from jugador as j
                    join guanya g on j.tag_jugador = g.tag_jugador
                    join perd p on j.tag_jugador = p.tag_jugador
                    WHERE j.tag_jugador = new.tag_jugador
                    GROUP BY j.tag_jugador)  >= a.nombre_min and (SELECT(SUM(g.num_trofeus) + SUM(p.num_trofeus))
                        from jugador as j
                        join guanya g on j.tag_jugador = g.tag_jugador
                        join perd p on j.tag_jugador = p.tag_jugador
                        WHERE j.tag_jugador = new.tag_jugador
                        GROUP BY j.tag_jugador)  <= a.nombre_max
                        and (a.titol LIKE '%Arena_L10 - Ultimate Champion%'
                        OR a.nombre_max < 32767 ))
            WHERE tag_jugador = new.tag_jugador;

    RETURN NULL;

END
$$ LANGUAGE plpgsql;

-- disparador
DROP TRIGGER IF EXISTS suma_trig ON compren;
CREATE TRIGGER suma_trig AFTER INSERT ON compren
FOR EACH ROW
EXECUTE FUNCTION suma_or_gemmes();

-- Validació

-- BUNDLE
INSERT INTO compren (tag_jugador, num_targeta, id_article, data_, descompte)
VALUES ('#V0QCQUCL','0626997669324072',9, now(),0);

-- PACK_ARENA
INSERT INTO compren (tag_jugador, num_targeta, id_article, data_, descompte)
VALUES ('#QV2PYL','0626966543536722',60,now(),0);

SELECT jugador.tag_jugador, jugador.or_,jugador.gemmes from jugador  WHERE tag_jugador  like '#QV2PYL';


---------------- AIXI FUNCIONA (No tocar)--------------------------------------------------
INSERT INTO compren (tag_jugador, num_targeta, id_article, data_, descompte)
VALUES ('#QV2PYL','0626966543536722',86,now(),0);

SELECT apa.or_ from arena_pack_arena as apa join
    arena a on apa.id_arena = a.id_arena join arena_pack ap on apa.id_arena_pack = ap.id_arena_pack
    join article a2 on ap.id_arena_pack = a2.id_article join compren c on a2.id_article = c.id_article
    join jugador j2 on c.tag_jugador = j2.tag_jugador
    where j2.tag_jugador like '#QV2PYL' and (SELECT(SUM(g.num_trofeus) + SUM(p.num_trofeus))
        from jugador as j join guanya g on j.tag_jugador = g.tag_jugador
        join perd p on j.tag_jugador = p.tag_jugador
        WHERE j.tag_jugador like '#QV2PYL'
        GROUP BY j.tag_jugador)  >= a.nombre_min and (SELECT(SUM(g.num_trofeus) + SUM(p.num_trofeus))
            from jugador as j join guanya g on j.tag_jugador = g.tag_jugador
            join perd p on j.tag_jugador = p.tag_jugador
            WHERE j.tag_jugador like '#QV2PYL'
            GROUP BY j.tag_jugador)  <= a.nombre_max
            and (a.titol LIKE '%Arena_L10 - Ultimate Champion%'
            OR a.nombre_max < 32767 );

SELECT *
    from arena;

SELECT *
    from arena_pack_arena
        where id_arena = 54000002;

SELECT *
    from arena_pack
        where id_arena_pack = 60;
-------------------------------------------------------------------------------------------


/*
 Des de fa poc, ClashSayale ha canviat els termes i les condicions, que molts jugadors no
han llegit, i s'ha aplicat una política de tolerància zero respecte al sexisme, el racisme, la
discriminació en general i la incitació a l'odi. Per això, cada vegada que s'insereixi un
missatge a la base de dades cal comprovar si hi ha paraules ofensives. Si això passa,
l'usuari serà immediatament banejat de la base de dades, però, podríem voler recuperar el
compte del jugador en cas que, després de la revisió manual, l'usuari pogués recuperar el
compte.
Per tant, caldrà crear una taula que contingui paraules prohibides i comparar-les amb cada
inserció a les taules de Missatges. Sempre que vulguis prohibir un jugador, hauràs de
canviar el seu nom per "_banned_" + <nom d'usuari> i afegir un informe a la taula de
Warnings amb la taula de Missatges a què correspon, la data del missatge enviat, l'etiqueta
del jugador que el va enviar i el format del missatge corresponent:

"Missatge d'odi enviat amb paraula/s " + <paraula_prohibida> + " a l'usuari " +
<etiqueta_del_jugador_receptor>
"Missatge d'odi enviat amb paraula/s " + <paraula_prohibida> + " al clan " +
<etiqueta_clan_receptor>
 */

-- creem taula missatges prohibits
DROP TABLE IF EXISTS missatges_prohibits;
CREATE TABLE missatges_prohibits(
    id_paraula SERIAL,
    paraula varchar(255),
    PRIMARY KEY (id_paraula)
);
-- insertem paraules prohibides
INSERT INTO missatges_prohibits (paraula)
VALUES ('stupid'), ('silly'),('idiot');

DROP FUNCTION if exists missatges_ofensius;

CREATE OR REPLACE FUNCTION missatges_ofensius()
RETURNS trigger as $$
    DECLARE i INTEGER:= 1;
    DECLARE trobat boolean:= false;
BEGIN
       WHILE i <= (SELECT COUNT(paraula) from missatges_prohibits) AND trobat = FALSE LOOP
        IF (SELECT COUNT(m.cos) from missatge as m WHERE new.id_missatge = m.id_missatge
            and m.cos LIKE '%'||(SELECT paraula from missatges_prohibits WHERE id_paraula = i)||'%')
            >= 1 then
            trobat = true;
        end if;
            i = i +1;
        END LOOP;

        IF trobat then
            INSERT INTO Warnings (affected_table, error_message, date, username)
            VALUES ('missatge','Missatge d''odi enviat amb paraula/s ' || (Select paraula from missatges_prohibits where id_paraula = i-1)
            ||' a l`usuari '|| new.tag_rep, (SELECT m.data_ from missatge as m where m.id_missatge = new.id_missatge) ,(SELECT j.nom FROM jugador as j where j.tag_jugador = new.tag_envia));

        UPDATE jugador
                SET nom = '_banned_ ' || nom
                WHERE new.tag_envia = tag_jugador;

        end if;
        return null;
END
    $$ LANGUAGE plpgsql;

-- disparador
DROP TRIGGER IF EXISTS ofen_trig ON conversen;
CREATE TRIGGER ofen_trig AFTER INSERT ON conversen
FOR EACH ROW
EXECUTE FUNCTION missatges_ofensius();

--Validació
INSERT INTO missatge(id_missatge,cos, data_)
VALUES (3024,'You ara very stupid',CURRENT_DATE);
INSERT INTO conversen (tag_envia, tag_rep,id_missatge)
VALUES ('#P8CJYJ02','#2V20QJVR',3024);

SELECT *
from warnings;

SELECT nom
from jugador
where tag_jugador like '%#P8CJYJ02%';

DROP FUNCTION if exists missatges_clans;

CREATE OR REPLACE FUNCTION missatges_clans()
RETURNS trigger as $$
    DECLARE i INTEGER:= 1;
    DECLARE trobat boolean:= false;
BEGIN
       WHILE i <= (SELECT COUNT(paraula) from missatges_prohibits) AND trobat = FALSE LOOP
        IF (SELECT COUNT(m.cos) from missatge as m WHERE new.id_missatge = m.id_missatge
            and m.cos LIKE '%'||(SELECT paraula from missatges_prohibits WHERE id_paraula = i)||'%')
            >= 1 then
            trobat = true;
        end if;
            i = i +1;
        END LOOP;

        IF trobat then
            INSERT INTO Warnings (affected_table, error_message, date, username)
            VALUES ('missatge','Missatge d''odi enviat amb paraula/s ' || (Select paraula from missatges_prohibits where id_paraula = i-1)
            ||' al clan '|| new.tag_clan, (SELECT m.data_ from missatge as m where m.id_missatge = new.id_missatge) ,(SELECT c.nom FROM clan as c where c.tag_clan = new.tag_clan));

        UPDATE clan
                SET nom = '_banned_ ' || nom
                WHERE new.tag_clan = tag_clan;
        end if;

        return null;
END
    $$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS ofen_trig2 ON envia;
CREATE TRIGGER ofen_trig2 AFTER INSERT ON envia
FOR EACH ROW
EXECUTE FUNCTION missatges_clans();

--Validació
INSERT INTO missatge(id_missatge,cos, data_)
VALUES (3061,'Hi idiot I hate you',CURRENT_DATE);
INSERT INTO envia (id_missatge, tag_clan, tag_jugador)
VALUES (3061,'#8LGRYC','#2V20QJVR');

SELECT *
from warnings;

SELECT nom
from clan
where tag_clan like '%#8LGRYC%';

/*
 Els anys de ClashSayale es divideixen en dues temporades: una temporada de tornada a
l'escola de setembre a desembre, que se sol utilitzar per a fins competitius, i una temporada
d'any complet de gener a agost.
No obstant això, al final de la temporada, cal emmagatzemar tots els resultats i mantenir la
coherència entre les taules. És necessari crear un trigger per al final de la temporada, on
els jugadors hauran de ser col·locats en una taula anomenada "Rànquing" per a aquesta
temporada amb la seva Etiqueta de Jugador, l'Arena en què es van classificar, i el nombre
de trofeus obtinguts a aquesta temporada.
Considerarem que el final d'una temporada tindrà lloc sempre que una nova temporada que
comenci després de la darrera i, per tant, sempre que s'afegeixi a la base de dades.
Si ja teniu una taula equivalent a la "Classificació", podeu utilitzar-la, només us heu
d'assegurar que el nom de la taula s'indiqui al vostre informe
 */

 --Creeem taula ranquing
DROP TABLE IF EXISTS ranquing;
CREATE TABLE ranquing(
    id_ranquing SERIAL,
    tag_jugador VARCHAR(255),
    arena VARCHAR(255),
    num_trofeus INTEGER,
    id_temp VARCHAR(255),
    PRIMARY KEY (id_ranquing)
);

DROP FUNCTION if exists actualitza_ranquing;

CREATE OR REPLACE FUNCTION actualitza_ranquing()
RETURNS trigger as $$
BEGIN
        INSERT INTO ranquing (tag_jugador, arena, num_trofeus, id_temp)
        SELECT j2.tag_jugador,a.id_arena, (SELECT(SELECT (CASE WHEN SUM(g.num_trofeus) IS NULL THEN 0 ELSE SUM(g.num_trofeus) END)
                 from jugador as j join guanya g on j.tag_jugador = g.tag_jugador
                 join batalla on g.id_batalla = batalla.id_batalla
                 WHERE batalla.data >= new.data_inici and batalla.data <= new.data_fi
                 and j.tag_jugador = j2.tag_jugador) + (SELECT (CASE WHEN SUM(p.num_trofeus) IS NULL THEN 0 ELSE SUM(p.num_trofeus) END)
                 from jugador as j join perd p on j.tag_jugador = p.tag_jugador
                 join batalla as b2 on p.id_batalla = b2.id_batalla
                 WHERE b2.data >= new.data_inici and b2.data <= new.data_fi
                 and j.tag_jugador = j2.tag_jugador)
                 from jugador as j3
                 where j3.tag_jugador = j2.tag_jugador
                 GROUP BY j3.tag_jugador),new.id_temporada
        from jugador as j2
        join arena as a on
            (SELECT(SELECT (CASE WHEN SUM(g.num_trofeus) IS NULL THEN 0 ELSE SUM(g.num_trofeus) END)
             from jugador as j join guanya g on j.tag_jugador = g.tag_jugador
             join batalla on g.id_batalla = batalla.id_batalla
             WHERE batalla.data >= new.data_inici and batalla.data <= new.data_fi
             and j.tag_jugador = j2.tag_jugador) + (SELECT (CASE WHEN SUM(p.num_trofeus) IS NULL THEN 0 ELSE SUM(p.num_trofeus) END)
             from jugador as j join perd p on j.tag_jugador = p.tag_jugador
             join batalla as b2 on p.id_batalla = b2.id_batalla
             WHERE b2.data >= new.data_inici and b2.data <= new.data_fi
             and j.tag_jugador = j2.tag_jugador)
             from jugador as j3
             where j3.tag_jugador = j2.tag_jugador
             GROUP BY j3.tag_jugador) >= a.nombre_min and (SELECT((SELECT (CASE WHEN SUM(g.num_trofeus) IS NULL THEN 0 ELSE SUM(g.num_trofeus) END)
                             from jugador as j join guanya g on j.tag_jugador = g.tag_jugador
                             join batalla on g.id_batalla = batalla.id_batalla
                             WHERE batalla.data >= new.data_inici and batalla.data <= new.data_fi
                             and j.tag_jugador = j2.tag_jugador) + (SELECT (CASE WHEN SUM(p.num_trofeus) IS NULL THEN 0 ELSE SUM(p.num_trofeus) END)
                             from jugador as j join perd p on j.tag_jugador = p.tag_jugador
                             join batalla as b2 on p.id_batalla = b2.id_batalla
                             WHERE b2.data >= new.data_inici and b2.data <= new.data_fi
                             and j.tag_jugador = j2.tag_jugador))
                             from jugador as j3
                             where j3.tag_jugador = j2.tag_jugador
                             GROUP BY j3.tag_jugador)  <= a.nombre_max
                        and (a.titol LIKE '%Arena_L10 - Ultimate Champion%'
                        OR a.nombre_max < 32767 )
        --join temporada as t on t.data_inici >= new.data_inici and t.data_fi <= new.data_fi
        GROUP BY j2.tag_jugador,a.id_arena;

        RETURN NULL;
END
    $$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS rank_trig ON temporada;
CREATE TRIGGER rank_trig AFTER INSERT ON temporada
FOR EACH ROW
EXECUTE FUNCTION actualitza_ranquing();

--Validació
INSERT INTO batalla (data, durada)
VALUES ('2028-01-02','03:52:00');
SELECT *
from batalla ORDER BY data DESC;
INSERT INTO guanya (tag_jugador, id_batalla,num_trofeus,id_pila)
VALUES ('#QV2PYL',9925,80,102);
INSERT INTO perd (tag_jugador, id_batalla, id_pila, num_trofeus)
VALUES ('#8GLQ9G0RG',9925,1113,-67);
INSERT INTO temporada (id_temporada, data_inici, data_fi)
VALUES ('T16','2028-01-01','2028-08-20');

SELECT * from guanya where tag_jugador = '#QV2PYL' ;

select * FROM PERD where tag_jugador = '#8GLQ9G0RG';
SELECT *
from jugador;

SELECT *
from ranquing;

-------------------------- FUNCIONA AQUI (no tocar)------------------------
(SELECT((SELECT (CASE WHEN SUM(g.num_trofeus) IS NULL THEN 0 ELSE SUM(g.num_trofeus) END)
    from jugador as j join guanya g on j.tag_jugador = g.tag_jugador
     join batalla on g.id_batalla = batalla.id_batalla
    WHERE batalla.data >= '2026-01-01' and batalla.data <= '2026-08-20'
    and j.tag_jugador = '#8GLQ9G0RG') +  (SELECT (CASE WHEN SUM(p.num_trofeus) IS NULL THEN 0 ELSE SUM(p.num_trofeus) END)
           from jugador as j join perd p on j.tag_jugador = p.tag_jugador
        join batalla as b2 on p.id_batalla = b2.id_batalla
        WHERE b2.data >= '2026-01-01' and b2.data <= '2026-08-20'
        and j.tag_jugador = '#8GLQ9G0RG'))
                    from jugador as j
                    where j.tag_jugador = '#8GLQ9G0RG'
                    GROUP BY j.tag_jugador);



SELECT * FROM batalla
                    WHERE batalla.data >= '2029-01-01' and batalla.data <= '2030-08-20'




