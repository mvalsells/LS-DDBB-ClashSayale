-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Model físic


-- IMPLEMENTACIÓ DEL MÒDUL 1:

-- Creació de la taula Raresa

DROP TABLE IF EXISTS Raresa CASCADE;
CREATE TABLE Raresa (
	grau VARCHAR (255),
	cost_pujar_nivell INTEGER,
	ID_raresa INTEGER,
	PRIMARY KEY (ID_raresa)
);

-- Creació de la taula Carta
DROP TABLE IF EXISTS Carta CASCADE;
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
DROP TABLE IF EXISTS Edifici CASCADE;
CREATE TABLE Edifici (
	vida INTEGER,
	ID_edifici INTEGER,
	PRIMARY KEY (ID_edifici),
	FOREIGN KEY (ID_edifici) REFERENCES Edifici (ID_edifici)
);

-- Creació de la taula Tropa
DROP TABLE IF EXISTS Tropa CASCADE;
CREATE TABLE Tropa (
	dany_aparicio INTEGER,
	ID_tropa INTEGER,
	PRIMARY KEY (ID_tropa),
	FOREIGN KEY (ID_tropa) REFERENCES Tropa (ID_tropa)
);

-- Creació de la taula Encanteri
DROP TABLE IF EXISTS Encanteri CASCADE;
CREATE TABLE Encanteri (
	radi INTEGER,
	ID_encanteri INTEGER,
	PRIMARY KEY (ID_encanteri),
	FOREIGN KEY (ID_encanteri) REFERENCES Encanteri (ID_encanteri)
);

-- Resta de taules (no formen part de la generalització de Carta)

-- Creació de la taula Pertany
DROP TABLE IF EXISTS Pertany CASCADE;
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

-- Creació de la taula Formen
DROP TABLE IF EXISTS Formen CASCADE;
CREATE TABLE Formen (
	ID_carta INTEGER,
	ID_pila INTEGER,
	PRIMARY KEY (ID_carta, ID_pila),
	FOREIGN KEY (ID_carta) REFERENCES Carta (ID_carta),
	FOREIGN KEY (ID_pila) REFERENCES Pila (ID_pila)
);

-- Creació de la taula Pila
DROP TABLE IF EXISTS Pila CASCADE;
CREATE TABLE Pila (
	nom VARCHAR (255),
	descripcio VARCHAR (255),
	data_creacio DATE,
	ID_pila INTEGER,
	ID_jugador INTEGER,
	PRIMARY KEY (ID_pila),
	FOREIGN KEY (ID_jugador) REFERENCES Jugador (ID_jugador)
);

-- Creació de la taula Comparteixen
DROP TABLE IF EXISTS Comparteixen CASCADE;
CREATE TABLE Comparteixen (
	ID_pila INTEGER,
	ID_jugador INTEGER,
	PRIMARY KEY (ID_pila, ID_jugador),
	FOREIGN KEY (ID_pila) REFERENCES Pila (ID_pila),
	FOREIGN KEY (ID_jugador) REFERENCES Jugador (ID_jugador)
);

-- Creació de la taula Modifiquen
DROP TABLE IF EXISTS Modifiquen CASCADE;
CREATE TABLE Modifiquen (
	ID_millores INTEGER,
	ID_carta INTEGER,
	PRIMARY KEY (ID_millores, ID_carta),
	FOREIGN KEY (ID_millores) REFERENCES Millora (ID_millores),
	FOREIGN KEY (ID_carta) REFERENCES Carta (ID_carta)
);



-- IMPLEMENTACIÓ DEL MÒDUL 2:


-- IMPLEMENTACIÓ DEL MÒDUL 3:

-- Creació de la taula millores
DROP TABLE IF EXISTS Millora CASCADE;
CREATE TABLE Millora (
	nom VARCHAR (255),
	descripcio VARCHAR (255),
	cost INTEGER,
	ID_millores INTEGER,
	PRIMARY KEY (ID_millores)
);
-- Generalització de l'entitat millores

-- Creació taula tecnologies
DROP TABLE IF EXISTS Tecnologia CASCADE;
CREATE TABLE Tecnologia (
	nivell_maxim INTEGER,
	ID_tecnologies INTEGER,
	PRIMARY KEY (ID_tecnologies),
	FOREIGN KEY (ID_tecnologies) REFERENCES Tecnologia (ID_tecnologies)
);

-- Creació de la taula estrcutura
DROP TABLE IF EXISTS Estructura CASCADE;
CREATE TABLE Estructura (
	minim_trofeus INTEGER,
	ID_estructures INTEGER,
	PRIMARY KEY (ID_estructures),
	FOREIGN KEY (ID_estructures) REFERENCES Estructura (ID_estructures)
);

-- Creació de la taula requereixen
DROP TABLE IF EXISTS Requereixen CASCADE;
CREATE TABLE Requereixen (
	nivell INTEGER,
	ID_millora_nova INTEGER,
	ID_millora_requerida INTEGER,
	PRIMARY KEY (ID_millora_nova,ID_millora_requerida),
	FOREIGN KEY (ID_millora_nova) REFERENCES Millora (ID_millora_nova),
	FOREIGN KEY (ID_millora_requerida) REFERENCES Millora (ID_millora_requerida)
);

-- Creació de la taula tenen
DROP TABLE IF EXISTS Tenen CASCADE;
CREATE TABLE Tenen (
	ID_millores INTEGER,
	ID_clan INTEGER,
	PRIMARY KEY (ID_millores, ID_clan),
	FOREIGN KEY (ID_millores) REFERENCES Millora (ID_millores),
	FOREIGN KEY (ID_clan) REFERENCES Clan (ID_clan)
);

-- Creació de la taula Clan
DROP TABLE IF EXISTS Caln CASCADE;
CREATE TABLE Clan (
	descripcio VARCHAR (255),
	nombre_trofeus INTEGER,
	trofeus_minims INTEGER,
	puntuacio INTEGER,
	ID_clan INTEGER,
	PRIMARY KEY (ID_clan)
);

--Creació de la taula envia
DROP TABLE IF EXISTS Envia CASCADE;
CREATE TABLE Envia (
	ID_missatge INTEGER,
	ID_clan INTEGER,
	ID_jugador INTEGER,
	PRIMARY KEY (ID_missatge, ID_clan, ID_jugador),
	FOREIGN KEY (ID_missatge) REFERENCES Missatge (ID_missatge),
	FOREIGN KEY (ID_clan) REFERENCES Clan (ID_clan),
	FOREIGN KEY (ID_jugador) REFERENCES Jugador (ID_jugador)
);

-- Creació de la taula Pertany
DROP TABLE IF EXISTS Pertany CASCADE;
CREATE TABLE Pertany (
	creador_del_clan VARCHAR (255),
	data DATE, 
	ID_clan INTEGER,
	ID_jugador INTEGER,
	ID_rol INTEGER,
	ID_donacio INTEGER,
	ID_Pertany INTEGER,
	PRIMARY KEY (ID_Pertany),
	FOREIGN KEY (ID_clan) REFERENCES Clan (ID_clan),
	FOREIGN KEY (ID_jugador) REFERENCES Jugador (ID_jugador),
	FOREIGN KEY (ID_rol) REFERENCES Rol (ID_rol),
	FOREIGN KEY (ID_donacio) REFERENCES Donacio (ID_donacio)
);

-- Creació taula donació
DROP TABLE IF EXISTS Donacio CASCADE;
CREATE TABLE Donacio (
	quantitat INTEGER, 
	data DATE,
	ID_donacio INTEGER,
	PRIMARY KEY (ID_donacio)
);

-- Creació taula rol
DROP TABLE IF EXISTS Rol CASCADE;
CREATE TABLE Rol (
	descripcio VARCHAR (255),
	ID_rol INTEGER,
	PRIMARY KEY (ID_rol)
);

-- Creació taula lluiten
DROP TABLE IF EXISTS Lluiten CASCADE;
CREATE TABLE Lluiten (
	ID_clan INTEGER,
	ID_batalla INTEGER,
	PRIMARY KEY (ID_clan,ID_batalla),
	FOREIGN KEY (ID_clan) REFERENCES Clan (ID_clan),
	FOREIGN KEY (ID_batalla) REFERENCES Batalla (ID_batalla)
);

-- IMPLEMENTACIÓ DEL MÒDUL 4:

-- Creació de la taula Completen
DROP TABLE IF EXISTS Completen CASCADE;
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
	FOREIGN KEY (ID_arena) REFERENCES Arena (ID_arena)
);

-- Creació de la taula Missio
DROP TABLE IF EXISTS Missio CASCADE;
CREATE TABLE Missio (
	ID_missio INTEGER,
	tasques VARCHER(255),
	recompenses INTEGER,
	titol VARCHER(255),
	PRIMARY KEY (ID_missio)
);

-- Creació de la taula Depen
DROP TABLE IF EXISTS Depen CASCADE;
CREATE TABLE Depen (
	ID_missio1 INTEGER,
	ID_missio2 INTEGER,
	PRIMARY KEY (ID_missio1, ID_missio2),
	FOREIGN KEY (ID_missio1) REFERENCES Missio (ID_missio),
	FOREIGN KEY (ID_missio2) REFERENCES Missio (ID_missio)
);

-- Creació de la taula Arena
DROP TABLE IF EXISTS Arena CASCADE;
CREATE TABLE Arena (
	ID_arena INTEGER,
	titol VARCHER(255),
	nombre_min INTEGER,
	recompenses VARCHAR(255),
	PRIMARY KEY (ID_arena)
);

-- Creació de la taula Assoliment
DROP TABLE IF EXISTS Assoliment CASCADE;
CREATE TABLE Assoliment (
	ID_assoliment INTEGER,
	titol VARCHER(255),
	recompensa_gemmes INTEGER,
	PRIMARY KEY (ID_assoliment),
	FOREIGN KEY (ID_assoliment) REFERENCES Assoliment (ID_assoliment)
);

-- Creació de la taula Desbloquegen
DROP TABLE IF EXISTS Desbloquegen CASCADE;
CREATE TABLE Desbloquegen (
	ID_desbloquegen INTEGER,
	ID_arena INTEGER,
	PRIMARY KEY (ID_desbloquegen, ID_arena),
	FOREIGN KEY (ID_desbloquegen) REFERENCES Desbloquegen (ID_desbloquegen),
	FOREIGN KEY (ID_arena) REFERENCES Arena (ID_arena)
);

-- Creació de la taula Aconsegueix
DROP TABLE IF EXISTS Aconsegueix CASCADE;
CREATE TABLE Aconsegueix (
	ID_jugador INTEGER,
	ID_assoliment INTEGER,
	ID_arena INTEGER,
	PRIMARY KEY (ID_jugador, ID_assoliment, ID_arena),
	FOREIGN KEY (ID_jugador) REFERENCES Jugador (ID_jugador),
	FOREIGN KEY (ID_assoliment) REFERENCES Assoliment (ID_assoliment),
	FOREIGN KEY (ID_arena) REFERENCES Arena (ID_arena)
);

-- Creació de la taula Amics
DROP TABLE IF EXISTS Amics CASCADE;
CREATE TABLE Amics (
	ID_jugador1 INTEGER,
	ID_jugador2 INTEGER,
	PRIMARY KEY (ID_jugador1, ID_jugador2),
	FOREIGN KEY (ID_jugador1) REFERENCES Jugador (ID_jugador),
	FOREIGN KEY (ID_jugador2) REFERENCES Jugador (ID_jugador)
);

-- Creació de la taula Batallen
DROP TABLE IF EXISTS Batallen CASCADE;
CREATE TABLE Batallen (
	ID_jugador INTEGER,
	ID_batalla INTEGER,
	PRIMARY KEY (ID_jugador, ID_batalla),
	FOREIGN KEY (ID_jugador) REFERENCES Jugador (ID_jugador),
	FOREIGN KEY (ID_batalla) REFERENCES Batalla (ID_batalla)
);

-- Creació de la taula Batallen
DROP TABLE IF EXISTS Batalla CASCADE;
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


-- Creació de la taula Insignia
DROP TABLE IF EXISTS Insignia CASCADE;
CREATE TABLE Insignia (
	ID_insignia INTEGER,
	imatge VARCHER(255), --Es correcte que Imatge sigui VARCHAR?
	titol VARCHAR(255),
	PRIMARY KEY (ID_insignia),
	FOREIGN KEY (ID_insignia) REFERENCES Insignia (ID_insignia)
);

-- Creació de la taula Participen
DROP TABLE IF EXISTS Participen CASCADE;
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

-- Creació de la taula Temporada
DROP TABLE IF EXISTS Temporada CASCADE;
CREATE TABLE Temporada (
	ID_temporada INTEGER,
	data_inici DATE,
	data_fi DATE,
	PRIMARY KEY (ID_temporada),
	FOREIGN KEY (data_inici) REFERENCES Temporada (data_inici),
	FOREIGN KEY (data_fi) REFERENCES Temporada (data_fi)
);