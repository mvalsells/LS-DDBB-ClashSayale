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
DROP TABLE IF EXISTS Tenen CASCADE;
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
DROP TABLE IF EXISTS Insignia CASCADE;
DROP TABLE IF EXISTS Participen CASCADE;
DROP TABLE IF EXISTS Temporada CASCADE;

-- ----------------------------------------------------------------

-- Taules necessaries al principi
-- Taula Jugador
CREATE TABLE Jugador(
	ID_jugador INTEGER,
	nom VARCHAR(255),
	experiencia INTEGER,
	trofeus INTEGER,
	targeta_credit INTEGER,
	PRIMARY KEY (ID_Jugador)
);

-- Creació de la taula millores
CREATE TABLE Millora (
	nom VARCHAR (255),
	descripcio VARCHAR (255),
	cost INTEGER,
	ID_millora INTEGER,
	PRIMARY KEY (ID_millora)
);

-- Creació de la taula Temporada
CREATE TABLE Temporada (
	ID_temporada INTEGER,
	data_inici DATE,
	data_fi DATE,
	PRIMARY KEY (ID_temporada)
);



-- Creació de la taula Arena
CREATE TABLE Arena (
	ID_arena INTEGER,
	titol VARCHAR(255),
	nombre_min INTEGER,
	recompenses VARCHAR(255),
	PRIMARY KEY (ID_arena)
);

-- Creació de la taula Batallen
CREATE TABLE Batalla (
	ID_batalla INTEGER,
	data_ DATE,
	durada TIME, --ns si es coorecte aqeust tipus de variable
	ID_temporada INTEGER,
	ID_arena INTEGER,
	PRIMARY KEY (ID_batalla),
	FOREIGN KEY (ID_temporada) REFERENCES Temporada (ID_temporada),
	FOREIGN KEY (ID_arena) REFERENCES Arena (ID_arena)
);

-- ----------------------------------------------------------------

-- IMPLEMENTACIÓ DEL MÒDUL 1:

-- Creació de la taula Raresa

CREATE TABLE Raresa (
	grau VARCHAR (255),
	cost_pujar_nivell INTEGER,
	ID_raresa INTEGER,
	PRIMARY KEY (ID_raresa)
);

-- Creació de la taula Carta
CREATE TABLE Carta (
	nom VARCHAR (255),
	dany INTEGER,
	velocitat_atac INTEGER,
	ID_carta INTEGER,
	ID_raresa INTEGER,
	PRIMARY KEY (ID_carta),
	FOREIGN KEY (ID_raresa) REFERENCES Raresa (ID_raresa)
);

-- Generalitzacions de l'entitat Carta
-- Creació de la taula Edifici
CREATE TABLE Edifici (
	vida INTEGER,
	ID_edifici INTEGER,
	PRIMARY KEY (ID_edifici),
	FOREIGN KEY (ID_edifici) REFERENCES Edifici (ID_edifici)
);

-- Creació de la taula Tropa
CREATE TABLE Tropa (
	dany_aparicio INTEGER,
	ID_tropa INTEGER,
	PRIMARY KEY (ID_tropa),
	FOREIGN KEY (ID_tropa) REFERENCES Tropa (ID_tropa)
);

-- Creació de la taula Encanteri
CREATE TABLE Encanteri (
	radi INTEGER,
	ID_encanteri INTEGER,
	PRIMARY KEY (ID_encanteri),
	FOREIGN KEY (ID_encanteri) REFERENCES Encanteri (ID_encanteri)
);

-- Resta de taules (no formen part de la generalització de Carta)

-- Creació de la taula Pertany
CREATE TABLE Pertany (
	quantitat INTEGER,
	data_desbolqueig DATE,
	ID_pertany INTEGER,
	ID_jugador INTEGER,
	ID_Carta INTEGER,
	PRIMARY KEY (ID_pertany),
	FOREIGN KEY (ID_jugador) REFERENCES Jugador (ID_jugador),
	FOREIGN KEY (ID_Carta) REFERENCES Carta (ID_carta)
);

-- Creació de la taula Pila
CREATE TABLE Pila (
	nom VARCHAR (255),
	descripcio VARCHAR (255),
	data_creacio DATE,
	ID_pila INTEGER,
	ID_jugador INTEGER,
	PRIMARY KEY (ID_pila),
	FOREIGN KEY (ID_jugador) REFERENCES Jugador (ID_jugador)
);

-- Creació de la taula Formen
CREATE TABLE Formen (
	ID_carta INTEGER,
	ID_pila INTEGER,
	PRIMARY KEY (ID_carta, ID_pila),
	FOREIGN KEY (ID_carta) REFERENCES Carta (ID_carta),
	FOREIGN KEY (ID_pila) REFERENCES Pila (ID_pila)
);



-- Creació de la taula Comparteixen
CREATE TABLE Comparteixen (
	ID_pila INTEGER,
	ID_jugador INTEGER,
	PRIMARY KEY (ID_pila, ID_jugador),
	FOREIGN KEY (ID_pila) REFERENCES Pila (ID_pila),
	FOREIGN KEY (ID_jugador) REFERENCES Jugador (ID_jugador)
);

-- Creació de la taula Modifiquen
CREATE TABLE Modifiquen (
	ID_millores INTEGER,
	ID_carta INTEGER,
	PRIMARY KEY (ID_millores, ID_carta),
	FOREIGN KEY (ID_millores) REFERENCES Millora (ID_millora),
	FOREIGN KEY (ID_carta) REFERENCES Carta (ID_carta)
);

-- ----------------------------------------------------------------

-- IMPLEMENTACIÓ DEL MÒDUL 2:

-- Taula Targeta de credit
CREATE TABLE targeta_credit(
	ID_targeta INTEGER,
	numero INTEGER,
	caducitat DATE,
	CVV INTEGER,
	ID_jugador INTEGER,
	PRIMARY KEY (ID_targeta),
	FOREIGN KEY (ID_Jugador) REFERENCES Jugador(ID_Jugador)
);

-- Generalització article
CREATE TABLE Article (
	ID_article INTEGER,
	Nom VARCHAR(255),
	Preu INTEGER,
	PRIMARY KEY (ID_article)
);

-- Article: Emoticones
CREATE TABLE Emoticones (
	ID_emoticones INTEGER,
	imatge_animada VARCHAR(255),
	PRIMARY KEY(ID_emoticones),
	FOREIGN KEY (ID_emoticones) REFERENCES Article(ID_article)
);

-- Article: Bundle
CREATE TABLE Bundle(
    ID_bundle INTEGER,
    Or_ INTEGER,
    gemmes INTEGER,
    PRIMARY KEY (ID_bundle),
    FOREIGN KEY (ID_bundle) REFERENCES Article(ID_article)
);

-- Article: Arena
CREATE TABLE Art_Arena(
    ID_Art_Arena INTEGER,
    Nivell INTEGER,
    Or_ INTEGER,
    PRIMARY KEY (ID_Art_Arena),
    FOREIGN KEY (ID_Art_Arena) REFERENCES Article(ID_article)
);

-- Article: Cofre
CREATE TABLE Cofre (
    ID_cofre INTEGER,
    ID_Raresa INTEGER, -- Possiblement s'haurà de canviar el integer per varchar
    Temps INTEGER,
    Gemmes INTEGER,
    PRIMARY KEY (ID_cofre),
    FOREIGN KEY (ID_cofre) REFERENCES Article(ID_article),
    FOREIGN KEY (ID_Raresa) REFERENCES Raresa(ID_Raresa)
);

-- Relació Cofre - Carta
CREATE TABLE cofre_carta(
    ID_Art_Arena INTEGER,
    ID_Carta INTEGER,
    PRIMARY KEY (ID_Art_Arena,ID_Carta),
    FOREIGN KEY (ID_Art_Arena) REFERENCES Art_Arena(ID_Art_Arena),
    FOREIGN KEY (ID_Carta) REFERENCES Carta(ID_Carta)
);

-- Compren (Relació tarja, article, jugador)
CREATE TABLE Compren (
    ID_Compren INTEGER,
    ID_Jugador INTEGER,
    ID_Targeta INTEGER,
    ID_Article INTEGER,
    Data_ DATE,
    Quantitat INTEGER,
    Descompte INTEGER,
    PRIMARY KEY (ID_Compren),
    FOREIGN KEY (ID_Jugador) REFERENCES Jugador(ID_jugador),
    FOREIGN KEY (ID_Targeta) REFERENCES targeta_credit(ID_targeta),
    FOREIGN KEY (ID_Article) REFERENCES Article(ID_article)
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
    ID_envia INTEGER,
    ID_rep INTEGER,
    ID_missatge INTEGER,
    PRIMARY KEY (ID_envia,ID_rep,ID_missatge),
    FOREIGN KEY (ID_envia) REFERENCES Jugador(ID_jugador),
    FOREIGN KEY (ID_rep) REFERENCES Jugador(ID_jugador),
    FOREIGN KEY (ID_missatge) REFERENCES Missatge(ID_Missatge)
);

-- ----------------------------------------------------------------

-- IMPLEMENTACIÓ DEL MÒDUL 3:

-- Generalització de l'entitat millores

-- Creació taula tecnologies
CREATE TABLE Tecnologia (
	nivell_maxim INTEGER,
	ID_tecnologies INTEGER,
	PRIMARY KEY (ID_tecnologies),
	FOREIGN KEY (ID_tecnologies) REFERENCES Tecnologia (ID_tecnologies)
);

-- Creació de la taula estrcutura
CREATE TABLE Estructura (
	minim_trofeus INTEGER,
	ID_estructures INTEGER,
	PRIMARY KEY (ID_estructures),
	FOREIGN KEY (ID_estructures) REFERENCES Estructura (ID_estructures)
);

-- Creació de les taules requereix
CREATE TABLE Requereix_tecnologia (
	ID_tecnologia_nova INTEGER,
	ID_tecnologia_requerida INTEGER,
	PRIMARY KEY (ID_tecnologia_nova,ID_tecnologia_requerida),
	FOREIGN KEY (ID_tecnologia_nova) REFERENCES Tecnologia (ID_tecnologies),
	FOREIGN KEY (ID_tecnologia_requerida) REFERENCES Tecnologia (ID_tecnologies)
);

CREATE TABLE Requereix_estructura (
	ID_estructura_nova INTEGER,
	ID_estructura_requerida INTEGER,
	PRIMARY KEY (ID_estructura_nova,ID_estructura_requerida),
	FOREIGN KEY (ID_estructura_nova) REFERENCES Estructura (ID_estructures),
	FOREIGN KEY (ID_estructura_requerida) REFERENCES Estructura (ID_estructures)
);

-- Creació de la taula Clan
CREATE TABLE Clan (
	descripcio VARCHAR (255),
	nombre_trofeus INTEGER,
	trofeus_minims INTEGER,
	puntuacio INTEGER,
	ID_clan INTEGER,
	PRIMARY KEY (ID_clan)
);

-- Creació de la taula tenen
CREATE TABLE Tenen (
	data date,
	nivell INTEGER,
	ID_millores INTEGER,
	ID_clan INTEGER,
	PRIMARY KEY (ID_millores, ID_clan),
	FOREIGN KEY (ID_millores) REFERENCES Millora (ID_millora),
	FOREIGN KEY (ID_clan) REFERENCES Clan (ID_clan)
);

--Creació de la taula envia
CREATE TABLE Envia (
	ID_missatge INTEGER,
	ID_clan INTEGER,
	ID_jugador INTEGER,
	PRIMARY KEY (ID_missatge, ID_clan, ID_jugador),
	FOREIGN KEY (ID_missatge) REFERENCES Missatge (ID_missatge),
	FOREIGN KEY (ID_clan) REFERENCES Clan (ID_clan),
	FOREIGN KEY (ID_jugador) REFERENCES Jugador (ID_jugador)
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
	ID_jugador INTEGER,
	ID_clan INTEGER,
	PRIMARY KEY (ID_donacio),
	FOREIGN KEY (ID_jugador) REFERENCES Jugador (ID_jugador),
	FOREIGN KEY (ID_clan) REFERENCES Clan (ID_clan)
);

-- Creació de la taula Forma_part
CREATE TABLE Forma_part (
	creador_del_clan VARCHAR (255),
	data DATE, 
	ID_clan INTEGER,
	ID_jugador INTEGER,
	ID_rol INTEGER,
	ID_Forma_part INTEGER,
	PRIMARY KEY (ID_Forma_part),
	FOREIGN KEY (ID_clan) REFERENCES Clan (ID_clan),
	FOREIGN KEY (ID_jugador) REFERENCES Jugador (ID_jugador),
	FOREIGN KEY (ID_rol) REFERENCES Rol (ID_rol)
);

-- Creació taula lluiten
CREATE TABLE Lluiten (
	ID_clan INTEGER,
	ID_batalla INTEGER,
	PRIMARY KEY (ID_clan,ID_batalla),
	FOREIGN KEY (ID_clan) REFERENCES Clan (ID_clan),
	FOREIGN KEY (ID_batalla) REFERENCES Batalla (ID_batalla)
);

-- ----------------------------------------------------------------

-- IMPLEMENTACIÓ DEL MÒDUL 4:

-- Creació de la taula Missio
CREATE TABLE Missio (
	ID_missio INTEGER,
	tasques VARCHAR(255),
	recompenses INTEGER,
	titol VARCHAR(255),
	PRIMARY KEY (ID_missio)
);

-- Creació de la taula Completen
CREATE TABLE Completen (
	ID_jugador INTEGER,
	ID_missio INTEGER,
	ID_arena INTEGER,
	data_ DATE,	 			--no puc ficar "date" pq es una keyword
	or_ INTEGER, 			--no puc ficar "or" pq es una keyword
	experiencia INTEGER,
	PRIMARY KEY (ID_jugador, ID_missio, ID_arena),
	FOREIGN KEY (ID_jugador) REFERENCES Jugador (ID_jugador),
	FOREIGN KEY (ID_missio) REFERENCES Missio (ID_missio),
	FOREIGN KEY (ID_arena) REFERENCES Art_Arena (ID_Art_Arena)
);

-- Creació de la taula Depen
CREATE TABLE Depen (
	ID_missio1 INTEGER,
	ID_missio2 INTEGER,
	PRIMARY KEY (ID_missio1, ID_missio2),
	FOREIGN KEY (ID_missio1) REFERENCES Missio (ID_missio),
	FOREIGN KEY (ID_missio2) REFERENCES Missio (ID_missio)
);

-- Creació de la taula Assoliment
CREATE TABLE Assoliment (
	ID_assoliment INTEGER,
	titol VARCHAR(255),
	recompensa_gemmes INTEGER,
	PRIMARY KEY (ID_assoliment),
	FOREIGN KEY (ID_assoliment) REFERENCES Assoliment (ID_assoliment)
);

-- Creació de la taula Desbloquegen
CREATE TABLE Desbloquegen (
	ID_Jugador INTEGER,
	ID_arena INTEGER,
	PRIMARY KEY (ID_Jugador, ID_arena),
	FOREIGN KEY (ID_Jugador) REFERENCES Jugador (ID_jugador),
	FOREIGN KEY (ID_arena) REFERENCES Art_Arena (ID_Art_Arena)
);

-- Creació de la taula Aconsegueix
CREATE TABLE Aconsegueix (
	ID_jugador INTEGER,
	ID_assoliment INTEGER,
	ID_arena INTEGER,
	PRIMARY KEY (ID_jugador, ID_assoliment, ID_arena),
	FOREIGN KEY (ID_jugador) REFERENCES Jugador (ID_jugador),
	FOREIGN KEY (ID_assoliment) REFERENCES Assoliment (ID_assoliment),
	FOREIGN KEY (ID_arena) REFERENCES Art_Arena (ID_Art_Arena)
);

-- Creació de la taula Amics
CREATE TABLE Amics (
	ID_jugador1 INTEGER,
	ID_jugador2 INTEGER,
	PRIMARY KEY (ID_jugador1, ID_jugador2),
	FOREIGN KEY (ID_jugador1) REFERENCES Jugador (ID_jugador),
	FOREIGN KEY (ID_jugador2) REFERENCES Jugador (ID_jugador)
);

-- Creació de la taula Batallen
CREATE TABLE Batallen (
	ID_jugador INTEGER,
	ID_batalla INTEGER,
	PRIMARY KEY (ID_jugador, ID_batalla),
	FOREIGN KEY (ID_jugador) REFERENCES Jugador (ID_jugador),
	FOREIGN KEY (ID_batalla) REFERENCES Batalla (ID_batalla)
);


-- Creació de la taula Insignia
CREATE TABLE Insignia (
	ID_insignia INTEGER,
	imatge VARCHAR(255), --Es correcte que Imatge sigui VARCHAR?
	titol VARCHAR(255),
	PRIMARY KEY (ID_insignia),
	FOREIGN KEY (ID_insignia) REFERENCES Insignia (ID_insignia)
);

-- Creació de la taula Participen
CREATE TABLE Participen (
	ID_temporada INTEGER,
	ID_jugador INTEGER,
	num_victories INTEGER,
	num_derrotes INTEGER,
	punts INTEGER,	
	PRIMARY KEY (ID_jugador, ID_temporada),
	FOREIGN KEY (ID_jugador) REFERENCES Jugador (ID_jugador),
	FOREIGN KEY (ID_temporada) REFERENCES Temporada (ID_temporada)
);