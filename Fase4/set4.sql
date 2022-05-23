-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynés i Albert Tomàs
-- Set 4 - M'agrada la competició. M'agraden els reptes...

/* 1) Cada vegada que un jugador completa una missió, necessitem actualitzar la informació a la base
   de dades. Per tant, cal preparar un trigger per cada vegada que s'afegeixi una entrada a la taula
   Jugadors-Quest (el nom pot variar depenent de la base de dades), perquè la informació de l'or i
   l'experiència del jugador es modifiqui en conseqüència.

   En primer lloc, hauràs de comprovar que el prerequisit de la missió s'ha completat, si n'hi ha,
   i en aquest cas procediràs a afegir l'or i l'experiència a la puntuació del jugador, depenent de
   l'Arena on es trobi actualment. Tot i això, si el jugador no ha completat el prerequisit, hauràs
   d'afegir una entrada a la taula de Warning, amb el nom d'usuari del jugador, la data en què es
   va completar la quest i la taula defectuosa en què s'ha realitzat l'entrada , juntament amb el
   següent missatge:

   "L'entrada de la quest per a " + <nom_de_la_quest> + " s'ha realitzat sense completar el "
   + <nom_de_la_quest> + " prerequisit"
*/


DROP FUNCTION IF EXISTS update_gold_experience CASCADE;

CREATE OR REPLACE FUNCTION update_gold_experience ()
RETURNS trigger AS $$
BEGIN
    IF ((SELECT id_missio2 FROM depen
        WHERE id_missio1 = NEW.id_missio) IN (SELECT id_missio FROM completen
                                             WHERE tag_jugador = NEW.tag_jugador))
    THEN
        UPDATE jugador SET
            or_ = or_ + NEW.or_,
            experiencia = experiencia + NEW.experiencia
        WHERE tag_jugador = NEW.tag_jugador;
    ELSE
        INSERT INTO warnings (affected_table, error_message, date, username)
        VALUES ('completen',
                'L''entrada de la quest per a "' || (SELECT titol FROM missio
                                                     WHERE id_missio = NEW.id_missio) ||
                '" s''ha realitzat sense completar el "' || (SELECT titol FROM missio AS m
                                                             JOIN depen AS d ON m.id_missio = d.id_missio2
                                                             WHERE d.id_missio1 = NEW.id_missio) ||
                '" prerequisit',
                CURRENT_DATE,
                NEW.tag_jugador);
    END IF;

    RETURN NULL;
END $$
LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS missionComplete ON completen CASCADE;

CREATE TRIGGER missionComplete AFTER INSERT ON completen
FOR EACH ROW
EXECUTE FUNCTION update_gold_experience();

/* Comprovacions del primer trigger

-- Fem un SELECT per veure l'or i l'experiència d'un jugador en concret
SELECT * FROM jugador
WHERE tag_jugador = '#J8QPJY8Q';
-- Mirem les missions que el jugador no hagi completat
SELECT DISTINCT * FROM missio
WHERE missio.id_missio NOT IN (SELECT id_missio FROM completen
                               WHERE tag_jugador = '#J8QPJY8Q');
-- Mirem les missions que el jugador hagi completat
SELECT DISTINCT * FROM missio
WHERE missio.id_missio IN (SELECT id_missio FROM completen
                               WHERE tag_jugador = '#J8QPJY8Q');
-- Mirem si alguna missió depen de les missions que ha completat el jugador
SELECT * FROM depen
WHERE id_missio2 = 103 OR id_missio2 = 190;
-- Fem l'insert per veure si es fa l'update
INSERT INTO completen (id_missio, id_arena, tag_jugador, or_, experiencia, desbloqueja)
VALUES (170, 54000057, '#J8QPJY8Q', 100, 2000, CURRENT_DATE);
-- Mirem les dades de la taula warnings
SELECT * FROM warnings;

DELETE FROM warnings
WHERE username = '#J8QPJY8Q';

SELECT id_missio2 FROM depen
        WHERE id_missio1 = 10
        AND id_missio2 IN (SELECT id_missio FROM completen
                                             WHERE tag_jugador = '#202C2CU0U');
 */


/* 2) Per descomptat, cada cop que batallem amb un jugador, necessitem actualitzar els valors
   i resultats d'una batalla. Cada vegada que inseriu una nova batalla a la base de dades,
   haureu de realitzar tots els canvis necessaris per mantenir la consistència de la informació.
   Això és:
   - Actualitzar els trofeus dels jugadors
   - Actualitzar l’arena on es troba el jugador, en cas que tinguis una taula que
     emmagatzemi aquesta informació
*/

DROP FUNCTION IF EXISTS updateTrophies CASCADE;

CREATE OR REPLACE FUNCTION updateTrophies()
RETURNS trigger AS $$
BEGIN
UPDATE jugador
SET
    trofeus = trofeus + NEW.num_trofeus
WHERE tag_jugador = NEW.tag_jugador;
RETURN NULL;
END $$
LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS battleWon ON guanya CASCADE;

CREATE TRIGGER battleWon AFTER INSERT ON guanya
FOR EACH ROW
EXECUTE FUNCTION updateTrophies();

DROP TRIGGER IF EXISTS battleLost ON perd CASCADE;

CREATE TRIGGER battleLost AFTER INSERT ON perd
FOR EACH ROW
EXECUTE FUNCTION updateTrophies();

/* Comprovacions del segon trigger

-- Inserim una nova batalla a la taula batalla
INSERT INTO batalla (data, durada, id_temporada)
VALUES (CURRENT_DATE, '02:45:00', 'T4');

SELECT * FROM batalla WHERE data = CURRENT_DATE;

-- Inserim un guanyador a la taula guanya
INSERT INTO guanya (tag_jugador, id_batalla, id_pila, num_trofeus)
VALUES ('#LRUQQPVU', 9923, 193, 30);
-- Inserim un perdedor a la taula perd
INSERT INTO perd (tag_jugador, id_batalla, id_pila, num_trofeus)
VALUES ('#VGR9CL0G', 9923, 1760, -30);

SELECT * FROM jugador WHERE tag_jugador = '#VGR9CL0G' OR tag_jugador = '#LRUQQPVU';
 */


/* 3) Recentment la comunitat de ClashSayale ha trobat una bretxa al tallafocs del servidor i la
   xarxa interna ha quedat exposada a informació alterada a algunes tècniques d'injecció que
   explotaven una mecànica en què els hackers han anat esborrant totes les seves derrotes
   de la nostra base de dades. La lògica de la base de dades interna permet als usuaris
   pertànyer a un sol clan alhora i a un de sol, que té un màxim de donacions per dia;
   tanmateix, d'alguna manera han trobat la manera de donar a clans a qui no pertanyen,
   saltant-se aquesta restricció.
   Comprova que la informació inserida és correcta abans de qualsevol inserció o actualització
   a les taules de donacions, i si es troba alguna inconsistència, bolca tota la informació
   rellevant sobre l'etiqueta del jugador, la taula de donacions i la data de la donació a la taula
   de warnings perquè els becaris puguin comprovar-la posteriorment de manera manual una
   per una.
   Algunes de les incoherències que es poden comprovar són les donacions amb valors nuls,
   les donacions a un clan on no s'està, o les donacions a un clan abans d'unir-s'hi o després
   d'abandonar-lo. Un exemple de missatge d’error és el següent:
   "S'ha realitzat una donació de <quantitat> d'or a " + <nom_del_clan> + " s'ha realitzat sense
   pertànyer al clan"
*/

DROP FUNCTION IF EXISTS comprova CASCADE;

CREATE OR REPLACE FUNCTION comprova()
RETURNS trigger AS $$
DECLARE totOK boolean:= true;
BEGIN
IF (NEW.quantitat IS NULL)
THEN
    totOK = false;
    INSERT INTO warnings (affected_table, error_message, date, username)
        VALUES ('dona',
                'S''ha intentat fer una donació nul·la',
                CURRENT_DATE,
                NEW.tag_jugador);
END IF;
IF (NEW.tag_clan <> (SELECT tag_clan FROM forma_part
                     WHERE tag_jugador = NEW.tag_jugador))
THEN
    totOK = false;
    INSERT INTO warnings (affected_table, error_message, date, username)
        VALUES ('dona',
                'S''ha realitzat una donació de ' || NEW.quantitat ||
                'd''or a ' || NEW.tag_clan ||
                'sense pertànyer al clan',
                CURRENT_DATE,
                NEW.tag_jugador);
END IF;
IF ((SELECT jugadors_eliminats FROM forma_part
    WHERE tag_jugador = NEW.tag_jugador) = 1)
THEN
    totOK = false;
    INSERT INTO warnings (affected_table, error_message, date, username)
        VALUES ('dona',
                'S''ha realitzat una donació de ' || NEW.quantitat ||
                'd''or a ' || NEW.tag_clan ||
                'i el jugador va ser expulsat d''aquest',
                CURRENT_DATE,
                NEW.tag_jugador);
END IF;
IF (totOK = false)
THEN
    DELETE FROM dona
    WHERE id_donacio = NEW.id_donacio;
END IF;
    RETURN NULL;
END $$
LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS comprovaDonacio ON dona CASCADE;

CREATE TRIGGER comprovaDonacio AFTER INSERT OR UPDATE ON dona
FOR EACH ROW
EXECUTE FUNCTION comprova();


/* Comprovació del tercer trigger

-- Posem una quantitat nul·la i veiem que s'afegeix a la taula warnings
INSERT INTO dona (tag_jugador, tag_clan, quantitat, data)
VALUES ('#QV2PYL', '#8LGRYC', 10, CURRENT_DATE);

-- Posem una quantitat nul·la i veiem que s'afegeix a la taula warnings
INSERT INTO dona (tag_jugador, tag_clan, quantitat, data)
VALUES ('#QV2PYL', '#2CQQVQCU', 10, CURRENT_DATE);

-- Fem un select de la taula warnings
SELECT * FROM warnings;
 */
