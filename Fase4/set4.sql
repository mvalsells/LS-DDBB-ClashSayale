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

/*CREATE OR REPLACE FUNCTION prerequisit()
RETURNS trigger AS $$

$$ LANGUAGE plpgsql;*/


DROP function IF EXISTS update_gold_experience;

CREATE OR REPLACE FUNCTION update_gold_experience ()
RETURNS trigger AS $$
BEGIN
UPDATE jugador SET
    or_ = or_ + (SELECT or_ FROM completen, missio
                WHERE jugador.tag_jugador = completen.tag_jugador
                AND completen.id_missio = missio.id_missio),
    experiencia = experiencia + (SELECT or_ FROM completen, missio
                WHERE jugador.tag_jugador = completen.tag_jugador
                AND completen.id_missio = missio.id_missio);
END;
$$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS missionComplete ON completen CASCADE;

CREATE TRIGGER missionComplete AFTER UPDATE ON completen
FOR EACH ROW
EXECUTE FUNCTION prerequisit();