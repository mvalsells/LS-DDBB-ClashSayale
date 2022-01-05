-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Model físic

-- DROP TABLES
-- Módul 1
DROP TABLE IF EXISTS Raresa CASCADE;
DROP TABLE IF EXISTS Carta CASCADE;
DROP TABLE IF EXISTS Edifici CASCADE;
DROP TABLE IF EXISTS Tropa CASCADE;
DROP TABLE IF EXISTS Encanteri CASCADE;
DROP TABLE IF EXISTS Pertany CASCADE;
DROP TABLE IF EXISTS Formen CASCADE;
DROP TABLE IF EXISTS Pila CASCADE;
DROP TABLE IF EXISTS Comparteixen CASCADE;
DROP TABLE IF EXISTS Modifiquen CASCADE;
-- Módul 2
DROP TABLE IF EXISTS Jugador CASCADE;
DROP TABLE IF EXISTS targeta_credit CASCADE;
DROP TABLE IF EXISTS article CASCADE;
DROP TABLE IF EXISTS Emoticones CASCADE;
DROP TABLE IF EXISTS Bundle CASCADE;
DROP TABLE IF EXISTS Cofre CASCADE;
DROP TABLE IF EXISTS cofre_carta CASCADE;
DROP TABLE IF EXISTS Art_Arena CASCADE;
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
DROP TABLE IF EXISTS Participen CASCADE;
DROP TABLE IF EXISTS Temporada CASCADE;

-- ----------------------------------------------------------------

-- Taules necessaries al principi

-- Taula Targeta de credit
CREATE TABLE targeta_credit(
	numero VARCHAR (255),
	caducitat DATE,
	CVV INTEGER,
	PRIMARY KEY (numero)
);

-- Taula Jugador
CREATE TABLE Jugador(
	tag_jugador VARCHAR (255),
	nom VARCHAR(255),
	experiencia INTEGER,
	trofeus INTEGER,
	targeta_credit VARCHAR(255),
	PRIMARY KEY (tag_jugador),
	FOREIGN KEY (targeta_credit) REFERENCES targeta_credit(numero) ON DELETE CASCADE
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

-- Creació de la taula Arena
CREATE TABLE Arena (
	ID_arena INTEGER,
	titol VARCHAR(255),
	nombre_min INTEGER,
	nombre_max INTEGER,
	recompenses VARCHAR(255),
	PRIMARY KEY (ID_arena)
);

-- Creació de la taula Batallen
CREATE TABLE Batalla (
	ID_batalla INTEGER,
	data DATE,
	durada TIME,
	ID_temporada VARCHAR(255),
	ID_arena INTEGER,
	PRIMARY KEY (ID_batalla),
	FOREIGN KEY (ID_temporada) REFERENCES Temporada (ID_temporada) ON DELETE CASCADE,
	FOREIGN KEY (ID_arena) REFERENCES Arena (ID_arena) ON DELETE CASCADE
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
	ID_carta SERIAL,
	raresa VARCHAR(255),
	arena INTEGER,
	PRIMARY KEY (ID_carta),
	FOREIGN KEY (raresa) REFERENCES Raresa (nom) ON DELETE CASCADE,
	FOREIGN KEY (arena) REFERENCES Arena(ID_arena) ON DELETE CASCADE
);

-- Generalitzacions de l'entitat Carta
-- Creació de la taula Edifici
CREATE TABLE Edifici (
	vida INTEGER,
	ID_edifici SERIAL,
	PRIMARY KEY (ID_edifici),
	FOREIGN KEY (ID_edifici) REFERENCES Edifici (ID_edifici) ON DELETE CASCADE
);

-- Creació de la taula Tropa
CREATE TABLE Tropa (
	dany_aparicio INTEGER,
	ID_tropa SERIAL,
	PRIMARY KEY (ID_tropa),
	FOREIGN KEY (ID_tropa) REFERENCES Tropa (ID_tropa) ON DELETE CASCADE
);

-- Creació de la taula Encanteri
CREATE TABLE Encanteri (
	radi INTEGER,
	ID_encanteri SERIAL,
	PRIMARY KEY (ID_encanteri),
	FOREIGN KEY (ID_encanteri) REFERENCES Encanteri (ID_encanteri) ON DELETE CASCADE
);

-- Resta de taules (no formen part de la generalització de Carta)

-- Creació de la taula Pertany
CREATE TABLE Pertany (
	quantitat INTEGER,
	data_desbolqueig DATE,
	ID_pertany INTEGER,
	tag_jugador VARCHAR (255),
	ID_Carta INTEGER,
	PRIMARY KEY (ID_pertany),
	FOREIGN KEY (tag_jugador) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE,
	FOREIGN KEY (ID_Carta) REFERENCES Carta (ID_carta) ON DELETE CASCADE
);

-- Creació de la taula Pila
CREATE TABLE Pila (
    tag_jugador VARCHAR (255),
    ID_pila INTEGER,
	nom VARCHAR (255),
	descripcio TEXT,
	data_creacio DATE,
	PRIMARY KEY (ID_pila),
	FOREIGN KEY (tag_jugador) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE
);

-- Creació de la taula Formen
CREATE TABLE Formen (
	ID_carta INTEGER,
	ID_pila INTEGER,
	PRIMARY KEY (ID_carta, ID_pila),
	FOREIGN KEY (ID_carta) REFERENCES Carta (ID_carta) ON DELETE CASCADE,
	FOREIGN KEY (ID_pila) REFERENCES Pila (ID_pila) ON DELETE CASCADE
);



-- Creació de la taula Comparteixen
CREATE TABLE Comparteixen (
	ID_pila INTEGER,
	tag_jugador VARCHAR (255),
	PRIMARY KEY (ID_pila, tag_jugador),
	FOREIGN KEY (ID_pila) REFERENCES Pila (ID_pila) ON DELETE CASCADE,
	FOREIGN KEY (tag_jugador) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE
);

-- Creació de la taula Modifiquen
CREATE TABLE Modifiquen (
	nom_millora VARCHAR(255),
	ID_carta INTEGER,
	PRIMARY KEY (nom_millora, ID_carta),
	FOREIGN KEY (nom_millora) REFERENCES Millora (nom_millora) ON DELETE CASCADE,
	FOREIGN KEY (ID_carta) REFERENCES Carta (ID_carta) ON DELETE CASCADE
);

-- ----------------------------------------------------------------

-- IMPLEMENTACIÓ DEL MÒDUL 2:

-- Generalització article
CREATE TABLE Article (
	ID_article SERIAL,
	Nom VARCHAR(255),
	Preu FLOAT,
	PRIMARY KEY (ID_article)
);

-- Article: Emoticones
CREATE TABLE Emoticones (
	ID_emoticones SERIAL,
	nom_imatge VARCHAR(255),
	direccio_imatge VARCHAR(255),
	PRIMARY KEY(ID_emoticones),
	FOREIGN KEY (ID_emoticones) REFERENCES Article(ID_article) ON DELETE CASCADE
);

-- Article: Bundle
CREATE TABLE Bundle(
    ID_bundle SERIAL,
    Or_ INTEGER,
    gemmes INTEGER,
    PRIMARY KEY (ID_bundle),
    FOREIGN KEY (ID_bundle) REFERENCES Article(ID_article) ON DELETE CASCADE
);

-- Article: Arena
CREATE TABLE Art_Arena(
    ID_Art_Arena INTEGER,
    Nivell INTEGER,
    Or_ INTEGER,
    PRIMARY KEY (ID_Art_Arena),
    FOREIGN KEY (ID_Art_Arena) REFERENCES Article(ID_article) ON DELETE CASCADE
);

-- Article: Cofre
CREATE TABLE Cofre (
    ID_cofre SERIAL,
    nom_cofre VARCHAR(255),
    quantitat_cartes INTEGER,
    raresa VARCHAR(255),
    Temps INTEGER,
    Gemmes INTEGER,
    PRIMARY KEY (ID_cofre),
    FOREIGN KEY (ID_cofre) REFERENCES Article(ID_article) ON DELETE CASCADE,
    FOREIGN KEY (raresa) REFERENCES Raresa(nom) ON DELETE CASCADE
);

-- Relació Cofre - Carta
CREATE TABLE cofre_carta(
    ID_Art_Arena INTEGER,
    ID_Carta INTEGER,
    PRIMARY KEY (ID_Art_Arena,ID_Carta),
    FOREIGN KEY (ID_Art_Arena) REFERENCES Art_Arena(ID_Art_Arena) ON DELETE CASCADE,
    FOREIGN KEY (ID_Carta) REFERENCES Carta(ID_Carta) ON DELETE CASCADE
);

-- Compren (Relació tarja, article, jugador)
CREATE TABLE Compren (
    ID_Compren INTEGER,
    tag_jugador VARCHAR (255),
    num_targeta VARCHAR(255),
    ID_Article INTEGER,
    Data_ DATE,
    Quantitat INTEGER,
    Descompte FLOAT,
    PRIMARY KEY (ID_Compren),
    FOREIGN KEY (tag_jugador) REFERENCES Jugador(tag_jugador) ON DELETE CASCADE,
    FOREIGN KEY (num_targeta) REFERENCES targeta_credit(numero) ON DELETE CASCADE,
    FOREIGN KEY (ID_Article) REFERENCES Article(ID_article) ON DELETE CASCADE
);

-- Taula Missatge
CREATE TABLE Missatge (
  ID_Missatge INTEGER,
  Titol VARCHAR(255),
  Cos TEXT,
  data_ DATE,
  PRIMARY KEY (ID_Missatge)
);

-- Conversen (Relació missatge - jugador)
CREATE TABLE Conversen(
    tag_envia VARCHAR (255),
    tag_rep VARCHAR (255),
    ID_missatge INTEGER,
    PRIMARY KEY (tag_envia,tag_rep,ID_missatge),
    FOREIGN KEY (tag_envia) REFERENCES Jugador(tag_jugador) ON DELETE CASCADE,
    FOREIGN KEY (tag_rep) REFERENCES Jugador(tag_jugador) ON DELETE CASCADE,
    FOREIGN KEY (ID_missatge) REFERENCES Missatge(ID_Missatge) ON DELETE CASCADE
);

-- ----------------------------------------------------------------

-- IMPLEMENTACIÓ DEL MÒDUL 3:

-- Generalització de l'entitat millores

-- Creació taula tecnologies
CREATE TABLE Tecnologia (
	ID_tecnologia VARCHAR(255),
	nivell_maxim INTEGER,
	PRIMARY KEY (ID_tecnologia),
	FOREIGN KEY (ID_tecnologia) REFERENCES Tecnologia (ID_tecnologia) ON DELETE CASCADE
);

-- Creació de la taula estrcutura
CREATE TABLE Estructura (
    ID_estructura VARCHAR(255),
	minim_trofeus INTEGER,
	PRIMARY KEY (ID_estructura),
	FOREIGN KEY (ID_estructura) REFERENCES Estructura (ID_estructura) ON DELETE CASCADE
);

-- Creació de les taules requereix
CREATE TABLE Requereix_tecnologia (
	ID_tecnologia_nova VARCHAR(255),
	ID_tecnologia_requerida VARCHAR(255),
    nivell_prerequisit INTEGER,
	PRIMARY KEY (ID_tecnologia_nova),
	FOREIGN KEY (ID_tecnologia_nova) REFERENCES Tecnologia (ID_tecnologia) ON DELETE CASCADE,
	FOREIGN KEY (ID_tecnologia_requerida) REFERENCES Tecnologia (ID_tecnologia) ON DELETE CASCADE
);

CREATE TABLE Requereix_estructura (
	ID_estructura_nova VARCHAR(255),
	ID_estructura_requerida VARCHAR(255),
	PRIMARY KEY (ID_estructura_nova),
	FOREIGN KEY (ID_estructura_nova) REFERENCES Estructura (ID_estructura) ON DELETE CASCADE,
	FOREIGN KEY (ID_estructura_requerida) REFERENCES Estructura (ID_estructura) ON DELETE CASCADE
);

-- Creació de la taula Clan
CREATE TABLE Clan (
    tag_clan VARCHAR(255),
	nom VARCHAR(255),
	descripcio VARCHAR (255),
	nombre_trofeus INTEGER,
	trofeus_minims INTEGER,
	puntuacio INTEGER,
	PRIMARY KEY (tag_clan)
);

-- Creació de la taula tenen_tecnologia
CREATE TABLE Tenen_tecnologia (
	tag_clan VARCHAR(255),
	ID_tecnologia VARCHAR(255),
	data date,
	nivell INTEGER,
	PRIMARY KEY (ID_tecnologia, tag_clan),
	FOREIGN KEY (ID_tecnologia) REFERENCES Tecnologia (ID_tecnologia) ON DELETE CASCADE,
	FOREIGN KEY (tag_clan) REFERENCES Clan (tag_clan) ON DELETE CASCADE
);

-- Creació de la taula tenen_tecnologia
CREATE TABLE Tenen_estructura (
    tag_clan VARCHAR(255),
	ID_estructura VARCHAR(255),
	data date,
	nivell INTEGER,
	PRIMARY KEY (ID_estructura, tag_clan),
	FOREIGN KEY (ID_estructura) REFERENCES Estructura (ID_estructura) ON DELETE CASCADE,
	FOREIGN KEY (tag_clan) REFERENCES Clan (tag_clan) ON DELETE CASCADE
);


--Creació de la taula envia
CREATE TABLE Envia (
	ID_missatge INTEGER,
	tag_clan VARCHAR(255),
	tag_jugador VARCHAR (255),
	PRIMARY KEY (ID_missatge, tag_clan, tag_jugador),
	FOREIGN KEY (ID_missatge) REFERENCES Missatge (ID_missatge) ON DELETE CASCADE,
	FOREIGN KEY (tag_clan) REFERENCES Clan (tag_clan) ON DELETE CASCADE,
	FOREIGN KEY (tag_jugador) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE
);

-- Creació taula rol
CREATE TABLE Rol (
	descripcio VARCHAR (255),
	ID_rol INTEGER,
	PRIMARY KEY (ID_rol)
);

-- Creació taula donació
CREATE TABLE Dona (
	quantitat INTEGER,
	data DATE,
	ID_donacio INTEGER,
	tag_jugador VARCHAR (255),
	tag_clan VARCHAR(255),
	PRIMARY KEY (ID_donacio),
	FOREIGN KEY (tag_jugador) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE,
	FOREIGN KEY (tag_clan) REFERENCES Clan (tag_clan) ON DELETE CASCADE
);

-- Creació de la taula Forma_part
CREATE TABLE Forma_part (
	creador_del_clan VARCHAR (255),
	data DATE, 
	tag_clan VARCHAR(255),
	tag_jugador VARCHAR (255),
	ID_rol INTEGER,
	ID_Forma_part INTEGER,
	PRIMARY KEY (ID_Forma_part),
	FOREIGN KEY (tag_clan) REFERENCES Clan (tag_clan) ON DELETE CASCADE,
	FOREIGN KEY (tag_jugador) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE,
	FOREIGN KEY (ID_rol) REFERENCES Rol (ID_rol) ON DELETE CASCADE
);

-- Creació taula lluiten
CREATE TABLE Lluiten (
	tag_clan VARCHAR(255),
	ID_batalla INTEGER,
	PRIMARY KEY (tag_clan,ID_batalla),
	FOREIGN KEY (tag_clan) REFERENCES Clan (tag_clan) ON DELETE CASCADE,
	FOREIGN KEY (ID_batalla) REFERENCES Batalla (ID_batalla) ON DELETE CASCADE
);

-- ----------------------------------------------------------------

-- IMPLEMENTACIÓ DEL MÒDUL 4:

-- Creació de la taula Missio
CREATE TABLE Missio (
	ID_missio INTEGER,
	PRIMARY KEY (ID_missio)
);

-- Creació de la taula Completen
CREATE TABLE Completen (
	ID_missio INTEGER,
	ID_arena INTEGER,
	or_ INTEGER,
	experiencia INTEGER,
	PRIMARY KEY (ID_missio, ID_arena),
	FOREIGN KEY (ID_missio) REFERENCES Missio (ID_missio) ON DELETE CASCADE,
	FOREIGN KEY (ID_arena) REFERENCES Arena (ID_arena) ON DELETE CASCADE
);

-- Creació de la taula Depen
CREATE TABLE Depen (
	ID_missio1 INTEGER,
	ID_missio2 INTEGER,
	PRIMARY KEY (ID_missio1, ID_missio2),
	FOREIGN KEY (ID_missio1) REFERENCES Missio (ID_missio) ON DELETE CASCADE,
	FOREIGN KEY (ID_missio2) REFERENCES Missio (ID_missio) ON DELETE CASCADE
);

-- Creació de la taula Assoliment
CREATE TABLE Assoliment (
	ID_assoliment INTEGER,
	titol VARCHAR(255),
	recompensa_gemmes INTEGER,
	PRIMARY KEY (ID_assoliment),
	FOREIGN KEY (ID_assoliment) REFERENCES Assoliment (ID_assoliment) ON DELETE CASCADE
);

-- Creació de la taula Desbloquegen
CREATE TABLE Desbloquegen (
	tag_jugador VARCHAR (255),
	ID_arena INTEGER,
	PRIMARY KEY (tag_jugador, ID_arena),
	FOREIGN KEY (tag_jugador) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE,
	FOREIGN KEY (ID_arena) REFERENCES Art_Arena (ID_Art_Arena) ON DELETE CASCADE
);

-- Creació de la taula Aconsegueix
CREATE TABLE Aconsegueix (
	tag_jugador VARCHAR (255),
	ID_assoliment INTEGER,
	ID_arena INTEGER,
	PRIMARY KEY (tag_jugador, ID_assoliment, ID_arena),
	FOREIGN KEY (tag_jugador) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE,
	FOREIGN KEY (ID_assoliment) REFERENCES Assoliment (ID_assoliment) ON DELETE CASCADE,
	FOREIGN KEY (ID_arena) REFERENCES Art_Arena (ID_Art_Arena) ON DELETE CASCADE
);

-- Creació de la taula Amics
CREATE TABLE Amics (
	tag_jugador1 VARCHAR (255),
	tag_jugador2 VARCHAR (255),
	PRIMARY KEY (tag_jugador1, tag_jugador2),
	FOREIGN KEY (tag_jugador1) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE,
	FOREIGN KEY (tag_jugador2) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE
);

-- Creació de la taula Guanya
CREATE TABLE Guanya (
	tag_jugador VARCHAR (255),
	ID_batalla INTEGER,
	num_trofeus INTEGER,
	PRIMARY KEY (tag_jugador, ID_batalla),
	FOREIGN KEY (tag_jugador) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE,
	FOREIGN KEY (ID_batalla) REFERENCES Batalla (ID_batalla) ON DELETE CASCADE
);

-- Creació de la taula Perd
CREATE TABLE Perd (
    tag_jugador VARCHAR (255),
    ID_batalla INTEGER,
    num_trofeus INTEGER,
    PRIMARY KEY (tag_jugador, ID_batalla),
    FOREIGN KEY (tag_jugador) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE,
    FOREIGN KEY (ID_batalla) REFERENCES Batalla (ID_batalla) ON DELETE CASCADE
);

-- Creació de la taula Insignia
CREATE TABLE Insignia (
	ID_insignia INTEGER,
	imatge VARCHAR(255), --Es correcte que Imatge sigui VARCHAR?
	titol VARCHAR(255),
	PRIMARY KEY (ID_insignia),
	FOREIGN KEY (ID_insignia) REFERENCES Insignia (ID_insignia) ON DELETE CASCADE
);

-- Creació de la taula Participen
CREATE TABLE Participen (
	ID_temporada VARCHAR(255),
	tag_jugador VARCHAR (255),
	num_victories INTEGER,
	num_derrotes INTEGER,
	punts INTEGER,	
	PRIMARY KEY (tag_jugador, ID_temporada),
	FOREIGN KEY (tag_jugador) REFERENCES Jugador (tag_jugador) ON DELETE CASCADE,
	FOREIGN KEY (ID_temporada) REFERENCES Temporada (ID_temporada) ON DELETE CASCADE
);