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

DROP function IF EXISTS prerequisit;

CREATE OR REPLACE FUNCTION prerequisit()
RETURNS trigger AS $$
BEGIN

END;
$$ LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS update_gold_experience;

CREATE OR REPLACE FUNCTION update_gold_experience ()
RETURNS trigger AS $$
BEGIN
UPDATE jugador SET
    or_ = or_ + (SELECT or_ FROM completen, missio
                WHERE jugador.tag_jugador = completen.tag_jugador
                AND completen.id_missio = missio.id_missio),
    experiencia = experiencia + (SELECT experiencia FROM completen, missio
                WHERE jugador.tag_jugador = completen.tag_jugador
                AND completen.id_missio = missio.id_missio);
END;
$$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS missionComplete ON completen CASCADE;

CREATE TRIGGER missionComplete AFTER UPDATE ON completen
FOR EACH ROW
EXECUTE FUNCTION prerequisit();


/* 2) Per descomptat, cada cop que batallem amb un jugador, necessitem actualitzar els valors
   i resultats d'una batalla. Cada vegada que inseriu una nova batalla a la base de dades,
   haureu de realitzar tots els canvis necessaris per mantenir la consistència de la informació.
   Això és:
   - Actualitzar els trofeus dels jugadors
   - Actualitzar l’arena on es troba el jugador, en cas que tinguis una taula que
     emmagatzemi aquesta informació
*/

DROP FUNCTION IF EXISTS guanya_perd CASCADE;

CREATE OR REPLACE FUNCTION guanya_perd()
RETURNS trigger AS $$
BEGIN
UPDATE jugador SET
    trofeus = trofeus + (SELECT num_trofeus FROM guanya, perd
                        WHERE jugador.tag_jugador = guanya.tag_jugador
                        OR jugador.tag_jugador = perd.tag_jugador);
END;
$$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS battleCompleted ON batalla CASCADE;

CREATE TRIGGER battleCompleted AFTER UPDATE ON batalla
FOR EACH ROW
EXECUTE FUNCTION guanya_perd();


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
