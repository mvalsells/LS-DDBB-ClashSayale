-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Model físic

-- DROP TABLES
-- Módul 1
DROP TABLE IF EXISTS Raresa CASCADE;
DROP TABLE IF EXISTS Carta CASCADE;
DROP TABLE IF EXISTS NivellCarta CASCADE;
DROP TABLE IF EXISTS Edifici CASCADE;
DROP TABLE IF EXISTS Tropa CASCADE;
DROP TABLE IF EXISTS Encanteri CASCADE;
DROP TABLE IF EXISTS Pertany CASCADE;
DROP TABLE IF EXISTS Formen CASCADE;
DROP TABLE IF EXISTS Pila CASCADE;
DROP TABLE IF EXISTS Comparteixen CASCADE;
DROP TABLE IF EXISTS Modifiquen CASCADE;
DROP TABLE IF EXISTS Warnings CASCADE;

-- Módul 2
DROP TABLE IF EXISTS Jugador CASCADE;
DROP TABLE IF EXISTS targeta_credit CASCADE;
DROP TABLE IF EXISTS article CASCADE;
DROP TABLE IF EXISTS Emoticones CASCADE;
DROP TABLE IF EXISTS Bundle CASCADE;
DROP TABLE IF EXISTS Cofre CASCADE;
DROP TABLE IF EXISTS Conte CASCADE;
DROP TABLE IF EXISTS Arena_pack CASCADE;
DROP TABLE IF EXISTS arena_pack_arena CASCADE;
DROP TABLE IF EXISTS Compren CASCADE;
DROP TABLE IF EXISTS Missatge CASCADE;
DROP TABLE IF EXISTS Conversen CASCADE;
-- Módul 3
DROP TABLE IF EXISTS Millora CASCADE;
DROP TABLE IF EXISTS Tecnologia CASCADE;
DROP TABLE IF EXISTS Estructura CASCADE;
DROP TABLE IF EXISTS Requereix_tecnologia CASCADE;
DROP TABLE IF EXISTS Requereix_estructura CASCADE;
DROP TABLE IF EXISTS Tenen_estructura CASCADE;
DROP TABLE IF EXISTS Tenen_tecnologia CASCADE;
DROP TABLE IF EXISTS Clan CASCADE;
DROP TABLE IF EXISTS Envia CASCADE;
DROP TABLE IF EXISTS Forma_part CASCADE;
DROP TABLE IF EXISTS Dona CASCADE;
DROP TABLE IF EXISTS Rol CASCADE;
DROP TABLE IF EXISTS Lluiten CASCADE;
-- Módul 4
DROP TABLE IF EXISTS Completen CASCADE;
DROP TABLE IF EXISTS Missio CASCADE;
DROP TABLE IF EXISTS Depen CASCADE;
DROP TABLE IF EXISTS Arena CASCADE;
DROP TABLE IF EXISTS Assoliment CASCADE;
DROP TABLE IF EXISTS Desbloquegen CASCADE;
DROP TABLE IF EXISTS Aconsegueix CASCADE;
DROP TABLE IF EXISTS Amics CASCADE;
DROP TABLE IF EXISTS Batallen CASCADE;
DROP TABLE IF EXISTS Batalla CASCADE;
DROP TABLE IF EXISTS Guanya CASCADE;
DROP TABLE IF EXISTS Perd CASCADE;
DROP TABLE IF EXISTS Insignia CASCADE;
DROP TABLE IF EXISTS Obte CASCADE;
DROP TABLE IF EXISTS Participen CASCADE;
DROP TABLE IF EXISTS Temporada CASCADE;

-- ----------------------------------------------------------------

-- Taules necessaries al principi

-- Taula Targeta de credit
CREATE TABLE targeta_credit(
	numero VARCHAR (255),
	caducitat DATE,
	PRIMARY KEY (numero)
);

-- Taula Jugador
CREATE TABLE Jugador(
	tag_jugador VARCHAR (255),
	nom VARCHAR(255),
	experiencia INTEGER,
	trofeus INTEGER,
	targeta_credit VARCHAR(255),
	or_ INTEGER,
	gemmes INTEGER,
	PRIMARY KEY (tag_jugador),
	FOREIGN KEY (targeta_credit) REFERENCES targeta_credit(numero) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creació de la taula millores
CREATE TABLE Millora (
	nom_millora VARCHAR (255),
	descripcio VARCHAR (255),
	cost INTEGER,
	mod_damage INTEGER,
    mod_hit_speed INTEGER,
    mod_radius INTEGER,
    mod_spawn_damage INTEGER,
    mod_lifetime INTEGER,
	PRIMARY KEY (nom_millora)
);

-- Creació de la taula Temporada
CREATE TABLE Temporada (
	ID_temporada VARCHAR(255),
	data_inici DATE,
	data_fi DATE,
	PRIMARY KEY (ID_temporada)
);

-- Creació de la taula participen
CREATE TABLE Participen (
    tag_jugador VARCHAR (255),
    punts INTEGER,
    ID_temporada VARCHAR (255),
    PRIMARY KEY (tag_jugador, ID_temporada),
    FOREIGN KEY (tag_jugador) REFERENCES Jugador (tag_jugador),
    FOREIGN KEY (ID_temporada) REFERENCES Temporada (ID_temporada)
);

-- Creació de la taula Arena
CREATE TABLE Arena (
	ID_arena INTEGER,
	titol VARCHAR(255),
	nombre_min INTEGER,
	nombre_max INTEGER,
	PRIMARY KEY (ID_arena)
);

-- Creació de la taula Batallen
CREATE TABLE Batalla (
	ID_batalla SERIAL,
	data DATE,
	durada TIME,
	ID_temporada VARCHAR(255),
	ID_arena INTEGER,
	clan_battle INTEGER,
	PRIMARY KEY (ID_batalla),
	FOREIGN KEY (ID_temporada) REFERENCES Temporada (ID_temporada) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (ID_arena) REFERENCES Arena (ID_arena) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------------------------------------------

-- IMPLEMENTACIÓ DEL MÒDUL 1:

-- Creació de la taula Raresa
CREATE TABLE Raresa (
	nom VARCHAR (255),
	cost_pujar_nivell INTEGER,
	PRIMARY KEY (nom)
);

-- Creació de la taula Carta
CREATE TABLE Carta (
	nom VARCHAR (255),
	dany INTEGER,
	velocitat_atac INTEGER,
	raresa VARCHAR(255),
	arena INTEGER,
	PRIMARY KEY (nom),
	FOREIGN KEY (raresa) REFERENCES Raresa (nom) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (arena) REFERENCES Arena(ID_arena) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Generalitzacions de l'entitat Carta
-- Creació de la taula Edifici
CREATE TABLE Edifici (
	vida INTEGER,
	nom VARCHAR(255),
	PRIMARY KEY (nom),
	FOREIGN KEY (nom) REFERENCES Carta(nom) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creació de la taula Tropa
CREATE TABLE Tropa (
	dany_aparicio INTEGER,
	nom VARCHAR(255),
	PRIMARY KEY (nom),
	FOREIGN KEY (nom) REFERENCES Carta(nom) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creació de la taula Encanteri
CREATE TABLE Encanteri (
	radi INTEGER,
	nom VARCHAR(255),
	PRIMARY KEY (nom),
	FOREIGN KEY (nom) REFERENCES Carta(nom) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Resta de taules (no formen part de la generalització de Carta)

CREATE TABLE NivellCarta(
    nivell INTEGER,
    multiplicador INTEGER,
    PRIMARY KEY (nivell)
);

-- Creació de la taula Pertany
CREATE TABLE Pertany (
	quantitat INTEGER,
	data_desbolqueig DATE,
	ID_pertany SERIAL,
	tag_jugador VARCHAR (255),
	nom_carta VARCHAR(255),
	nivell INTEGER,
	PRIMARY KEY (ID_pertany),
	FOREIGN KEY (tag_jugador) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (nom_carta) REFERENCES Carta (nom) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (nivell) REFERENCES NivellCarta(nivell) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creació de la taula Pila
CREATE TABLE Pila (
    tag_jugador VARCHAR (255),
    ID_pila INTEGER,
    nom VARCHAR(255),
	descripcio TEXT,
	data_creacio DATE,
	PRIMARY KEY (ID_pila),
	FOREIGN KEY (tag_jugador) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creació de la taula Formen
CREATE TABLE Formen (
    ID_formen SERIAL,
	nom_carta VARCHAR(255),
	ID_pila INTEGER,
	nivell INTEGER,
	PRIMARY KEY (ID_formen),
	FOREIGN KEY (nom_carta) REFERENCES Carta (nom) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (ID_pila) REFERENCES Pila (ID_pila) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (nivell) REFERENCES NivellCarta(nivell) ON DELETE CASCADE ON UPDATE CASCADE
);



-- Creació de la taula Comparteixen
CREATE TABLE Comparteixen (
	ID_pila INTEGER,
	tag_jugador VARCHAR (255),
	PRIMARY KEY (ID_pila, tag_jugador),
	FOREIGN KEY (ID_pila) REFERENCES Pila (ID_pila) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (tag_jugador) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creació de la taula Modifiquen
CREATE TABLE Modifiquen (
	nom_millora VARCHAR(255),
	nom_carta VARCHAR(255),
	PRIMARY KEY (nom_millora, nom_carta),
	FOREIGN KEY (nom_millora) REFERENCES Millora (nom_millora) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (nom_carta) REFERENCES Carta (nom) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------------------------------------------

-- IMPLEMENTACIÓ DEL MÒDUL 2:

-- Generalització article
CREATE TABLE Article (
	ID_article INTEGER,
	Nom VARCHAR(255),
	Preu FLOAT,
	Quantitat INTEGER,
	PRIMARY KEY (ID_article)
);

-- Article: Emoticones
CREATE TABLE Emoticones (
	ID_emoticones INTEGER,
	nom_imatge VARCHAR(255),
	direccio_imatge VARCHAR(255),
	PRIMARY KEY(ID_emoticones),
	FOREIGN KEY (ID_emoticones) REFERENCES Article(ID_article) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Article: Bundle
CREATE TABLE Bundle(
    ID_bundle INTEGER,
    Or_ INTEGER,
    gemmes INTEGER,
    PRIMARY KEY (ID_bundle),
    FOREIGN KEY (ID_bundle) REFERENCES Article(ID_article) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Article: Arena
CREATE TABLE Arena_pack(
    ID_arena_pack INTEGER,
    ID_pack INTEGER,
    PRIMARY KEY (ID_arena_pack),
    FOREIGN KEY (ID_arena_pack) REFERENCES Article(ID_article) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE arena_pack_arena(
    ID_arena INTEGER,
    ID_arena_pack INTEGER,
    or_ INTEGER,
    PRIMARY KEY (ID_arena,ID_arena_pack),
    FOREIGN KEY (ID_arena) REFERENCES Arena(ID_arena) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ID_arena_pack) REFERENCES Arena_pack(id_arena_pack) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Article: Cofre
CREATE TABLE Cofre (
    ID_cofre INTEGER,
    nom_cofre VARCHAR(255),
    quantitat_cartes INTEGER,
    raresa VARCHAR(255),
    Temps INTEGER,
    PRIMARY KEY (ID_cofre),
    FOREIGN KEY (ID_cofre) REFERENCES Article(ID_article) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (raresa) REFERENCES Raresa(nom) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Relació Cofre - Carta
CREATE TABLE Conte(
    ID_cofre INTEGER,
    nom_carta VARCHAR(255),
    PRIMARY KEY (ID_cofre,nom_carta),
    FOREIGN KEY (ID_cofre) REFERENCES Cofre(id_cofre) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (nom_carta) REFERENCES Carta(nom) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Compren (Relació tarja, article, jugador)
CREATE TABLE Compren (
    ID_Compren SERIAL,
    tag_jugador VARCHAR (255),
    num_targeta VARCHAR(255),
    ID_Article INTEGER,
    Data_ DATE,
    Descompte FLOAT,
    PRIMARY KEY (ID_Compren),
    FOREIGN KEY (tag_jugador) REFERENCES Jugador(tag_jugador) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (num_targeta) REFERENCES targeta_credit(numero) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ID_Article) REFERENCES Article(ID_article) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Taula Missatge
CREATE TABLE Missatge (
  ID_Missatge INTEGER,
  Cos TEXT,
  data_ DATE,
  ID_resposta INTEGER,
  PRIMARY KEY (ID_Missatge)
);

-- Conversen (Relació missatge - jugador)
CREATE TABLE Conversen(
    tag_envia VARCHAR (255),
    tag_rep VARCHAR (255),
    ID_missatge INTEGER,
    PRIMARY KEY (tag_envia,tag_rep,ID_missatge),
    FOREIGN KEY (tag_envia) REFERENCES Jugador(tag_jugador) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (tag_rep) REFERENCES Jugador(tag_jugador) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ID_missatge) REFERENCES Missatge(ID_Missatge) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------------------------------------------

-- IMPLEMENTACIÓ DEL MÒDUL 3:

-- Generalització de l'entitat millores

-- Creació taula tecnologies
CREATE TABLE Tecnologia (
	ID_tecnologia VARCHAR(255),
	nivell_maxim INTEGER,
	PRIMARY KEY (ID_tecnologia),
	FOREIGN KEY (ID_tecnologia) REFERENCES Tecnologia (ID_tecnologia) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creació de la taula estrcutura
CREATE TABLE Estructura (
    ID_estructura VARCHAR(255),
	minim_trofeus INTEGER,
	PRIMARY KEY (ID_estructura),
	FOREIGN KEY (ID_estructura) REFERENCES Estructura (ID_estructura) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creació de les taules requereix
CREATE TABLE Requereix_tecnologia (
	ID_tecnologia_nova VARCHAR(255),
	ID_tecnologia_requerida VARCHAR(255),
    nivell_prerequisit INTEGER,
	PRIMARY KEY (ID_tecnologia_nova),
	FOREIGN KEY (ID_tecnologia_nova) REFERENCES Tecnologia (ID_tecnologia) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (ID_tecnologia_requerida) REFERENCES Tecnologia (ID_tecnologia) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Requereix_estructura (
	ID_estructura_nova VARCHAR(255),
	ID_estructura_requerida VARCHAR(255),
	PRIMARY KEY (ID_estructura_nova),
	FOREIGN KEY (ID_estructura_nova) REFERENCES Estructura (ID_estructura) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (ID_estructura_requerida) REFERENCES Estructura (ID_estructura) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creació de la taula Clan
CREATE TABLE Clan (
    tag_clan VARCHAR(255),
	nom VARCHAR(255),
	descripcio VARCHAR (255),
	nombre_trofeus INTEGER,
	trofeus_minims INTEGER,
	puntuacio INTEGER,
	creador_clan VARCHAR(255),
	PRIMARY KEY (tag_clan),
    FOREIGN KEY (creador_clan) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE ON UPDATE CASCADE

);

-- Creació de la taula tenen_tecnologia
CREATE TABLE Tenen_tecnologia (
	tag_clan VARCHAR(255),
	ID_tecnologia VARCHAR(255),
	data date,
	nivell INTEGER,
	PRIMARY KEY (ID_tecnologia, tag_clan),
	FOREIGN KEY (ID_tecnologia) REFERENCES Tecnologia (ID_tecnologia) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (tag_clan) REFERENCES Clan (tag_clan) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creació de la taula tenen_tecnologia
CREATE TABLE Tenen_estructura (
    tag_clan VARCHAR(255),
	ID_estructura VARCHAR(255),
	data date,
	nivell INTEGER,
	PRIMARY KEY (ID_estructura, tag_clan),
	FOREIGN KEY (ID_estructura) REFERENCES Estructura (ID_estructura) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (tag_clan) REFERENCES Clan (tag_clan) ON DELETE CASCADE ON UPDATE CASCADE
);


--Creació de la taula envia
CREATE TABLE Envia (
	ID_missatge INTEGER,
	tag_clan VARCHAR(255),
	tag_jugador VARCHAR (255),
	PRIMARY KEY (ID_missatge, tag_clan, tag_jugador),
	FOREIGN KEY (ID_missatge) REFERENCES Missatge (ID_missatge) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (tag_clan) REFERENCES Clan (tag_clan) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (tag_jugador) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creació taula rol
CREATE TABLE Rol (
    ID_rol SERIAL,
    nom VARCHAR(255),
	descripcio TEXT,
	PRIMARY KEY (ID_rol)
);

-- Creació taula donació
CREATE TABLE Dona (
    ID_donacio SERIAL,
	tag_jugador VARCHAR (255),
	tag_clan VARCHAR(255),
	quantitat INTEGER,
	data DATE,
	PRIMARY KEY (ID_donacio),
	FOREIGN KEY (tag_jugador) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (tag_clan) REFERENCES Clan (tag_clan) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creació de la taula Forma_part
CREATE TABLE Forma_part (
    ID_Forma_part SERIAL,
	tag_clan VARCHAR(255),
	tag_jugador VARCHAR (255),
	ID_rol INTEGER,
	data DATE,
	jugadors_eliminats INTEGER,
	PRIMARY KEY (ID_Forma_part),
	FOREIGN KEY (tag_clan) REFERENCES Clan (tag_clan) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (tag_jugador) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (ID_rol) REFERENCES Rol (ID_rol) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creació taula lluiten
CREATE TABLE Lluiten (
	tag_clan VARCHAR(255),
	ID_batalla SERIAL,
	data_inici DATE,
	data_fi DATE,
	PRIMARY KEY (tag_clan,ID_batalla),
	FOREIGN KEY (tag_clan) REFERENCES Clan (tag_clan) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (ID_batalla) REFERENCES Batalla (ID_batalla) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------------------------------------------

-- IMPLEMENTACIÓ DEL MÒDUL 4:

-- Creació de la taula Missio
CREATE TABLE Missio (
	ID_missio INTEGER,
	titol VARCHAR(255),
    descripcio VARCHAR(255),
    requeriment VARCHAR(255),
	PRIMARY KEY (ID_missio)
);

-- Creació de la taula Completen
CREATE TABLE Completen (
    ID_completen SERIAL,
	ID_missio INTEGER,
	ID_arena INTEGER,
	tag_jugador VARCHAR(255),
	or_ INTEGER,
	experiencia INTEGER,
	desbloqueja DATE,
	PRIMARY KEY (ID_completen),
	FOREIGN KEY (ID_missio) REFERENCES Missio (ID_missio) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (ID_arena) REFERENCES Arena (ID_arena) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (tag_jugador) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creació de la taula Depen
CREATE TABLE Depen (
	ID_missio1 INTEGER,
	ID_missio2 INTEGER,
	PRIMARY KEY (ID_missio1, ID_missio2),
	FOREIGN KEY (ID_missio1) REFERENCES Missio (ID_missio) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (ID_missio2) REFERENCES Missio (ID_missio) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creació de la taula Assoliment
CREATE TABLE Assoliment (
	ID_assoliment SERIAL,
	titol VARCHAR(255),
	recompensa_gemmes INTEGER,
	descripcio VARCHAR(255),
	PRIMARY KEY (ID_assoliment),
	FOREIGN KEY (ID_assoliment) REFERENCES Assoliment (ID_assoliment) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creació de la taula Aconsegueix
CREATE TABLE Aconsegueix (
	tag_jugador VARCHAR (255),
	ID_assoliment SERIAL,
	ID_arena INTEGER,
	data DATE,
	PRIMARY KEY (tag_jugador, ID_assoliment, ID_arena),
	FOREIGN KEY (tag_jugador) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (ID_assoliment) REFERENCES Assoliment (ID_assoliment) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (ID_arena) REFERENCES Arena (ID_arena) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creació de la taula Amics
CREATE TABLE Amics (
	tag_requester VARCHAR (255),
	tag_requested VARCHAR (255),
	PRIMARY KEY (tag_requester, tag_requested),
	FOREIGN KEY (tag_requester) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (tag_requested) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creació de la taula Guanya
CREATE TABLE Guanya (
	tag_jugador VARCHAR (255),
	ID_batalla SERIAL,
	ID_pila INTEGER,
	num_trofeus INTEGER,
	PRIMARY KEY (tag_jugador, ID_batalla, ID_pila),
	FOREIGN KEY (tag_jugador) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (ID_batalla) REFERENCES Batalla (ID_batalla) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (ID_pila) REFERENCES Pila (ID_pila) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creació de la taula Perd
CREATE TABLE Perd (
    tag_jugador VARCHAR (255),
    ID_batalla SERIAL,
    ID_pila INTEGER,
    num_trofeus INTEGER,
    PRIMARY KEY (tag_jugador, ID_batalla, ID_pila),
    FOREIGN KEY (tag_jugador) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ID_batalla) REFERENCES Batalla (ID_batalla) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ID_pila) REFERENCES Pila (ID_pila) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creació de la taula Insignia
CREATE TABLE Insignia (
	ID_insignia SERIAL,
	imatge VARCHAR(255), --Es correcte que Imatge sigui VARCHAR?
	titol VARCHAR(255),
	data DATE,
	PRIMARY KEY (ID_insignia),
	FOREIGN KEY (ID_insignia) REFERENCES Insignia (ID_insignia) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creació de la taula Obté
CREATE TABLE Obte (
    ID_insignia SERIAL,
    tag_jugador VARCHAR (255),
    ID_arena INTEGER,
    PRIMARY KEY (ID_insignia, tag_jugador, ID_arena),
    FOREIGN KEY (ID_insignia) REFERENCES Insignia (ID_insignia) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (tag_jugador) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ID_arena) REFERENCES Arena (ID_arena) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Creació taula Warning per a la fase 4
CREATE TABLE Warnings (
    affected_table VARCHAR(255),
    error_message VARCHAR(255),
    date DATE,
    username VARCHAR(255)
);


