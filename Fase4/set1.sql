-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Set1 - Les cartes són la guerra, disfressada d'esport

/*1.1) Proporcions de rareses
Les rareses de les cartes hi són no només per tenir diferents probabilitats de caure en els
cofres i les recompenses, sinó també per assegurar-se que n'hi ha una proporció total en
termes del nombre total de cartes. Les proporcions assignades a les cartes són les
representades al gràfic adjunt.

Heu de crear un trigger que s'asseguri que aquestes proporcions es mantenen sempre en
ordre. Per tant, heu de comprovar després de canviar la taula de Cartes que aquests
percentatges de raresa es respecten o no. Si no es respecten els percentatges, els heu
d'incloure per raresa a la taula de Warnings, al costat de l'hora en què es van capturar
aquestes proporcions, l'usuari actual connectat a la base de dades que canvia les cartes, i
la taula de Cartes afectada a la vostra camp corresponent, al costat del següent missatge:
"Proporcions de raresa no respectades: " + <raritat> + " la proporció actual és " +
<proporció_actual> + " quan hauria de ser " + <proporció_esperada>
Al contrari, si es respecten les proporcions, no cal fer res.
*/

-- despres de canviar la taula? un trigger per cada tipus? -> INSERT, DELATE O ALTER


CREATE OR REPLACE FUNCTION f_proporcionsRares()
RETURNS trigger AS $$
DECLARE
    n_total INT;
    n_common INT;
    n_rare INT;
    n_epic INT;
    n_legendary INT;
    n_champion INT;
BEGIN
        SELECT COUNT(c.nom) INTO n_total
        FROM carta AS c;

        SELECT COUNT(c.nom)*100 INTO n_common
        FROM carta AS c
        WHERE c.raresa LIKE 'Common';
        SELECT COUNT(c.nom)*100 INTO n_rare
        FROM carta AS c
        WHERE c.raresa LIKE 'Rare';
        SELECT COUNT(c.nom)*100 INTO n_epic
        FROM carta AS c
        WHERE c.raresa LIKE 'Epic';
        SELECT COUNT(c.nom)*100 INTO n_legendary
        FROM carta AS c
        WHERE c.raresa LIKE 'Legendary';
        SELECT COUNT(c.nom)*100 INTO n_champion
        FROM carta AS c
        WHERE c.raresa LIKE 'Champion';

         IF (n_common / n_total) != 31 THEN
            INSERT INTO warnings(affected_table, error_message, date, username)
            VALUES('Cartes',
                   'Proporcions de raresa no respectades:' ||
                   ' Common ' ||
                   'la proporció actual és ' ||
                   (n_common / n_total) ||
                   ' quan hauria de ser ' ||
                   '31',
                   CURRENT_DATE,
                   CURRENT_USER);
         END IF;

         IF (n_rare / n_total) != 26 THEN
            INSERT INTO warnings(affected_table, error_message, date, username)
            VALUES('Cartes',
                   'Proporcions de raresa no respectades:' ||
                   ' Rare ' ||
                   'la proporció actual és ' ||
                   (n_rare / n_total) ||
                   ' quan hauria de ser ' ||
                   '26',
                   CURRENT_DATE,
                   CURRENT_USER);
         END IF;

        IF (n_epic / n_total) != 23 THEN
            INSERT INTO warnings(affected_table, error_message, date, username)
            VALUES('Cartes',
                   'Proporcions de raresa no respectades:' ||
                   ' Epic ' ||
                   'la proporció actual és ' ||
                   (n_epic / n_total) ||
                   ' quan hauria de ser ' ||
                   '23',
                   CURRENT_DATE,
                   CURRENT_USER);
        END IF;

        IF (n_legendary / n_total) != 17 THEN
            INSERT INTO warnings(affected_table, error_message, date, username)
            VALUES('Cartes',
                   'Proporcions de raresa no respectades:' ||
                   ' Legendary ' ||
                   'la proporció actual és ' ||
                   (n_legendary / n_total) ||
                   ' quan hauria de ser ' ||
                   '17',
                   CURRENT_DATE,
                   CURRENT_USER);
        END IF;

        IF (n_champion / n_total) != 3 THEN
            INSERT INTO warnings(affected_table, error_message, date, username)
            VALUES('Cartes',
                   'Proporcions de raresa no respectades:' ||
                   ' Champion ' ||
                   'la proporció actual és ' ||
                   (n_champion / n_total) ||
                   ' quan hauria de ser ' ||
                   '3',
                   CURRENT_DATE,
                   CURRENT_USER);
        END IF;

RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS proporcionsRares ON carta;
CREATE TRIGGER proporcionsRares
    AFTER INSERT OR  DELETE OR UPDATE ON carta
    EXECUTE FUNCTION f_proporcionsRares();

/*
TESTING:
INSERT INTO carta(nom, dany, velocitat_atac, raresa, arena)
VALUES ('UESAS', 12, 12, 'Champion', 54000000);
*/


/*1.2) Regal d'actualització de cartes

L'equip de ClashSayale ha iniciat una campanya de màrqueting per premiar els jugadors
que es comprometen amb el joc i obtenen noves cartes.

Per això, cada cop que aconsegueixin una nova carta, aquesta s'actualitzarà gratuïtament fins al nivell màxim.
Per tant, per consolidar que els canvis es realitzin, cal implementar aquest trigger i totes les
actualitzacions d'informació necessàries a la base de dades per persistir els canvis.
*/

CREATE OR REPLACE FUNCTION f_setMaxlevel()
RETURNS trigger AS $$
BEGIN

    UPDATE pertany
    SET  nivell =       (SELECT nc.nivell
                        FROM nivellcarta AS nc
                        ORDER BY nc.nivell DESC
                        LIMIT 1)
    WHERE pertany.id_pertany = NEW.id_pertany;

RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS triggerMaxlevel ON pertany;
CREATE TRIGGER triggeMaxlevel AFTER INSERT ON pertany
FOR EACH ROW
EXECUTE FUNCTION f_setMaxlevel();

/*
 TESTING:
INSERT INTO pertany(quantitat, data_desbolqueig, id_pertany, tag_jugador, nom_carta, nivell)
VALUES (637,'2021-04-04',91943,'#QV2PYL','Battle Ram',11);
*/









/*
1.3) Targetes OP que necessiten revisió

Al llarg dels anys que funciona l'aplicació ClashSayale, els mods han hagut d'ajustar la força
de múltiples cartes per equilibrar el joc. Aquest és un procés que sol durar setmanes per
assegurar-se que en reduir la potència d'una carta no se'n potenciï excessivament cap altra,
però com que la majoria dels desenvolupadors de l'empresa s'han vist afectats per la variant
més recent de COVID-19 Deltacron, se'ls ha demanat que automatitzin aquesta
comprovació.

Per tant, haureu de crear un trigger que comprovi les cartes que han estat guanyant masses
batalles (més del 90% de totes les batalles en què s'estan utilitzant) i afegir-les a la taula
OPCardBlackList (si us plau, creeu-la). No obstant això, si la carta ja ha estat col·locada a
la llista negra la setmana anterior, reduïu tots els seus valors en un 1%.
*/


DROP TABLE IF EXISTS OPCardBlackList CASCADE;

CREATE TABLE OPCardBlackList (
	nom VARCHAR(255),
	--TODO S'HA DE GUARDAR EL DATE TMB
	FOREIGN KEY (nom) REFERENCES Carta(nom)
);


CREATE OR REPLACE FUNCTION f_targetesOp()
RETURNS trigger AS $$
BEGIN

    INSERT INTO OPCardBlackList
    SELECT c.nom, COUNT(id_batalla)*100 / (COUNT(id_batalla) + (SELECT COUNT(id_batalla)
                                        FROM carta AS c2
                                        JOIN formen AS f ON c2.nom = f.nom_carta
                                        JOIN pila AS p ON f.id_pila = p.id_pila
                                        JOIN perd ON p.id_pila = perd.id_pila
                                        WHERE c.nom = c2.nom
                                        GROUP BY c2.nom))

    FROM carta AS c
    JOIN formen AS f ON c.nom = f.nom_carta
    JOIN pila AS p ON f.id_pila = p.id_pila
    JOIN guanya AS g ON p.id_pila = g.id_pila

    GROUP BY c.nom
    HAVING COUNT(id_batalla)*100 / (COUNT(id_batalla) + (SELECT COUNT(id_batalla)
                                        FROM carta AS c2
                                        JOIN formen AS f ON c2.nom = f.nom_carta
                                        JOIN pila AS p ON f.id_pila = p.id_pila
                                        JOIN perd ON p.id_pila = perd.id_pila
                                        WHERE c.nom = c2.nom
                                        GROUP BY c2.nom)) > 90;

    UPDATE carta
    SET dany = dany * 0.99
    /*TODO WHERE comprovar si existeix dins la taula OPCardBlackList*/;


RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS targetesOp ON batalla;
CREATE TRIGGER targetesOp AFTER INSERT ON batalla
FOR EACH ROW
EXECUTE FUNCTION f_targetesOp();