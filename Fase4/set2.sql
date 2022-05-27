-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Set 2 - No sóc un jugador, sóc un jugador de videojocs
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
DROP FUNCTION if exists suma_or_gemmes CASCADE;

CREATE OR REPLACE FUNCTION suma_or_gemmes()
RETURNS trigger as $$
BEGIN
        IF (SELECT id_bundle from bundle where new.id_article = id_bundle) = new.id_article then
            UPDATE jugador
                SET or_  = (CASE WHEN jugador.or_ IS NULL THEN 0 ELSE jugador.or_ END)  + (SELECT (CASE WHEN b.or_ IS NULL
                            THEN 0 ELSE b.or_ END) from bundle as b
                            WHERE new.id_article = b.id_bundle)
            WHERE new.tag_jugador = jugador.tag_jugador;

            UPDATE jugador
                SET gemmes = (CASE WHEN jugador.gemmes IS NULL THEN 0 ELSE jugador.gemmes END) +
                             (SELECT (CASE WHEN b.gemmes IS NULL THEN 0 ELSE b.gemmes END) from bundle as b where new.id_article = b.id_bundle)
            WHERE new.tag_jugador = jugador.tag_jugador;
        end if;

        IF (SELECT id_arena_pack from arena_pack where id_arena_pack = new.id_article) = new.id_article then
        UPDATE jugador
            SET or_ = (CASE WHEN or_ IS NULL THEN 0 ELSE or_ END) + (SELECT (CASE WHEN apa.or_  IS NULL THEN 0 ELSE apa.or_ END) from arena_pack_arena as apa join
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
                        OR a.nombre_max < 32767 )
                    GROUP BY j2.tag_jugador, apa.or_)
            WHERE tag_jugador = new.tag_jugador;
        end if;

    RETURN NULL;

END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS suma_trig ON compren;
CREATE TRIGGER suma_trig AFTER INSERT ON compren
FOR EACH ROW
EXECUTE FUNCTION suma_or_gemmes();

-- Validació
-- BUNDLE
/*INSERT INTO compren (tag_jugador, num_targeta, id_article, data_, descompte)
VALUES ('#QV2PYL','0626997669324072',9, now(),0);
-- PACK_ARENA
INSERT INTO compren (tag_jugador, num_targeta, id_article, data_, descompte)
VALUES ('#QV2PYL','0626966543536722',60,now(),0);
--Comprovació
SELECT  tag_jugador, jugador.or_, jugador.gemmes from jugador  WHERE tag_jugador  like '#QV2PYL';
--Comprovació resultats
SELECT apa.or_ from arena_pack_arena as apa join
    arena a on apa.id_arena = a.id_arena join arena_pack ap on apa.id_arena_pack = ap.id_arena_pack
    join article a2 on ap.id_arena_pack = a2.id_article join compren c on a2.id_article = c.id_article
    join jugador j2 on c.tag_jugador = j2.tag_jugador
    where a2.id_article = 60 and j2.tag_jugador like '#QV2PYL' and (SELECT(SUM(g.num_trofeus) + SUM(p.num_trofeus) )
        as trofeus from jugador as j join guanya g on j.tag_jugador = g.tag_jugador
        join perd p on j.tag_jugador = p.tag_jugador
        WHERE j.tag_jugador like '#QV2PYL'
        GROUP BY j.tag_jugador)  >= a.nombre_min and (SELECT(SUM(g.num_trofeus) + SUM(p.num_trofeus))
            from jugador as j join guanya g on j.tag_jugador = g.tag_jugador
            join perd p on j.tag_jugador = p.tag_jugador
            WHERE j.tag_jugador like '#QV2PYL'
            GROUP BY j.tag_jugador)  <= a.nombre_max
            and (a.titol LIKE '%Arena_L10 - Ultimate Champion%'
            OR a.nombre_max < 32767 );*/

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

DROP TABLE IF EXISTS missatges_prohibits;
CREATE TABLE missatges_prohibits(
    id_paraula SERIAL,
    paraula varchar(255),
    PRIMARY KEY (id_paraula)
);

INSERT INTO missatges_prohibits (paraula)
VALUES ('stupid'), ('silly'),('idiot');

DROP FUNCTION if exists missatges_ofensius CASCADE;

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


DROP TRIGGER IF EXISTS ofen_trig ON conversen;
CREATE TRIGGER ofen_trig AFTER INSERT ON conversen
FOR EACH ROW
EXECUTE FUNCTION missatges_ofensius();

--Validació
/*INSERT INTO missatge(id_missatge,cos, data_)
VALUES (3024,'You ara very stupid',CURRENT_DATE);
INSERT INTO conversen (tag_envia, tag_rep,id_missatge)
VALUES ('#P8CJYJ02','#2V20QJVR',3024);
--Comprovació
SELECT *
from warnings;
--Comprovació nom banejat
SELECT nom
from jugador
where tag_jugador like '%#P8CJYJ02%';*/

DROP FUNCTION if exists missatges_clans CASCADE;

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

        UPDATE jugador
                SET nom = '_banned_ ' || nom
                WHERE new.tag_jugador = tag_jugador;
        end if;

        return null;
END
    $$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS ofen_trig2 ON envia;
CREATE TRIGGER ofen_trig2 AFTER INSERT ON envia
FOR EACH ROW
EXECUTE FUNCTION missatges_clans();

--Validació
/*INSERT INTO missatge(id_missatge,cos, data_)
VALUES (3062,'Hi idiot I hate you',CURRENT_DATE);
INSERT INTO envia (id_missatge, tag_clan, tag_jugador)
VALUES (3062,'#8LGRYC','#2V20QJVR');
--Comprovació
SELECT *
from warnings;
--Comprovació nom banejat
SELECT nom
from jugador
where jugador.tag_jugador like '#2V20QJVR';
 */

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

DROP TABLE IF EXISTS ranquing;
CREATE TABLE ranquing(
    id_ranquing SERIAL,
    tag_jugador VARCHAR(255),
    arena VARCHAR(255),
    num_trofeus INTEGER,
    id_temp VARCHAR(255),
    PRIMARY KEY (id_ranquing)
);

DROP FUNCTION if exists actualitza_ranquing CASCADE;

CREATE OR REPLACE FUNCTION actualitza_ranquing()
RETURNS trigger as $$
    DECLARE temp_anterior VARCHAR (255) := (SELECT id_temporada from temporada where temporada.data_fi <> new.data_fi ORDER BY temporada.data_fi desc LIMIT 1);
    BEGIN
        INSERT INTO ranquing (tag_jugador, arena, num_trofeus, id_temp)
        SELECT j2.tag_jugador,a.id_arena,(SELECT(SELECT (CASE WHEN SUM(g.num_trofeus) IS NULL THEN 0 ELSE SUM(g.num_trofeus) END)
                 from jugador as j join guanya g on j.tag_jugador = g.tag_jugador
                 join batalla on g.id_batalla = batalla.id_batalla
                 WHERE batalla.id_temporada = temp_anterior
                 and j.tag_jugador = j2.tag_jugador) + (SELECT (CASE WHEN SUM(p.num_trofeus) IS NULL THEN 0 ELSE SUM(p.num_trofeus) END)
                 from jugador as j join perd p on j.tag_jugador = p.tag_jugador
                 join batalla as b2 on p.id_batalla = b2.id_batalla
                 WHERE b2.id_temporada = temp_anterior
                 and j.tag_jugador = j2.tag_jugador)
                 from jugador as j3
                 where j3.tag_jugador = j2.tag_jugador
                 GROUP BY j3.tag_jugador),temp_anterior
        from jugador as j2
        join arena as a on
            (SELECT(SELECT (CASE WHEN SUM(g.num_trofeus) IS NULL THEN 0 ELSE SUM(g.num_trofeus) END)
                 from jugador as j join guanya g on j.tag_jugador = g.tag_jugador
                 join batalla on g.id_batalla = batalla.id_batalla
                 WHERE batalla.id_temporada = temp_anterior
                 and j.tag_jugador = j2.tag_jugador) + (SELECT (CASE WHEN SUM(p.num_trofeus) IS NULL THEN 0 ELSE SUM(p.num_trofeus) END)
                 from jugador as j join perd p on j.tag_jugador = p.tag_jugador
                 join batalla as b2 on p.id_batalla = b2.id_batalla
                 WHERE b2.id_temporada = temp_anterior
                 and j.tag_jugador = j2.tag_jugador)
                 from jugador as j3
                 where j3.tag_jugador = j2.tag_jugador
                 GROUP BY j3.tag_jugador) >= a.nombre_min and (SELECT((SELECT (CASE WHEN SUM(g.num_trofeus) IS NULL THEN 0 ELSE SUM(g.num_trofeus) END)
                             from jugador as j join guanya g on j.tag_jugador = g.tag_jugador
                             join batalla on g.id_batalla = batalla.id_batalla
                             WHERE batalla.id_temporada = temp_anterior
                             and j.tag_jugador = j2.tag_jugador) + (SELECT (CASE WHEN SUM(p.num_trofeus) IS NULL THEN 0 ELSE SUM(p.num_trofeus) END)
                             from jugador as j join perd p on j.tag_jugador = p.tag_jugador
                             join batalla as b2 on p.id_batalla = b2.id_batalla
                             WHERE  b2.id_temporada = temp_anterior
                             and j.tag_jugador = j2.tag_jugador))
                             from jugador as j3
                             where j3.tag_jugador = j2.tag_jugador
                             GROUP BY j3.tag_jugador)  <= a.nombre_max
                        and (a.titol LIKE '%Arena_L10 - Ultimate Champion%'
                        OR a.nombre_max < 32767)
        WHERE j2.tag_jugador IN  (SELECT tag_jugador from participen where id_temporada = temp_anterior)
        GROUP BY j2.tag_jugador,a.id_arena,temp_anterior;

        RETURN NULL;
END
    $$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS rank_trig ON temporada;
CREATE TRIGGER rank_trig AFTER INSERT ON temporada
FOR EACH ROW
EXECUTE FUNCTION actualitza_ranquing();

--Validació
/*--Insert abans del trigger
INSERT INTO temporada (id_temporada, data_inici, data_fi)
VALUES ('T11','2022-01-01','2022-08-20');
INSERT INTO participen (tag_jugador, id_temporada)
VALUES ('#QV2PYL','T11');
INSERT INTO batalla (data, durada,id_temporada)
VALUES ('2022-01-02','03:52:00','T11');
INSERT INTO guanya (tag_jugador, id_batalla,num_trofeus,id_pila)
VALUES ('#QV2PYL',9920,80,102);
INSERT INTO perd (tag_jugador, id_batalla, id_pila, num_trofeus)
VALUES ('#QV2PYL',9920,1113,-67);
-- Insert despres del trigger
INSERT INTO temporada (id_temporada, data_inici, data_fi)
VALUES ('T12','2023-01-01','2023-08-20');

-- Comprovació taula ranquing
SELECT *
from ranquing;

-- Comprovació del ranquing
(SELECT((SELECT (CASE WHEN SUM(g.num_trofeus) IS NULL THEN 0 ELSE SUM(g.num_trofeus) END)
    from jugador as j join guanya g on j.tag_jugador = g.tag_jugador
     join batalla on g.id_batalla = batalla.id_batalla
    WHERE batalla.data >= '2022-01-02' and batalla.data <= '2022-08-20'
    and j.tag_jugador = '#QV2PYL') + (SELECT (CASE WHEN SUM(p.num_trofeus) IS NULL THEN 0 ELSE SUM(p.num_trofeus) END)
           from jugador as j join perd p on j.tag_jugador = p.tag_jugador
        join batalla as b2 on p.id_batalla = b2.id_batalla
        WHERE b2.data >= '2022-01-01' and b2.data <= '2022-08-20'
        and j.tag_jugador = '#QV2PYL')) as suma
                    from jugador as j
                    where j.tag_jugador = '#QV2PYL'
                    GROUP BY j.tag_jugador);

SELECT *
from arena;*/







