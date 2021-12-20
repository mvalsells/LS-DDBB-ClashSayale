-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Model físic


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

-- Creació de la taula Formen
CREATE TABLE Formen (
	ID_carta INTEGER,
	ID_pila INTEGER,
	PRIMARY KEY (ID_carta, ID_pila),
	FOREIGN KEY (ID_carta) REFERENCES Carta (ID_carta),
	FOREIGN KEY (ID_pila) REFERENCES Pila (ID_pila)
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
	FOREIGN KEY (ID_millores) REFERENCES Millora (ID_millores),
	FOREIGN KEY (ID_carta) REFERENCES Carta (ID_carta)
);



-- IMPLEMENTACIÓ DEL MÒDUL 2:


-- IMPLEMENTACIÓ DEL MÒDUL 3:

-- Creació de la taula millores
CREATE TABLE Millora (
	nom VARCHAR (255),
	descripcio VARCHAR (255),
	cost INTEGER,
	ID_millores INTEGER,
	PRIMARY KEY (ID_millores)
);
-- Generalització de l'entitat millores

-- Creació taula tecnologies
CREATE TABLE Tecnologia (
	nivell_maxim INTEGER,
	ID_tecnologies INTEGER,
	PRIMARY KEY (ID_tecnologies),
	FOREIGN KEY (ID_tecnologies) REFERENCES Tecnologia (ID_tecnologies),
);

-- Creació de la taula estrcutura
CREATE TABLE Estructura (
	minim_trofeus INTEGER,
	ID_estructures INTEGER,
	PRIMARY KEY (ID_estructures),
	FOREIGN KEY (ID_estructures) REFERENCES Estructura (ID_estructures)
);

-- Creació de la taula requereixen
CREATE TABLE Requereixen (
	nivell INTEGER,
	ID_millora_nova INTEGER,
	ID_millora_requerida INTEGER,
	PRIMARY KEY (ID_millora_nova,ID_millora_requerida),
	FOREIGN KEY (ID_millora_nova) REFERENCES Millora (ID_millora_nova),
	FOREIGN KEY (ID_millora_requerida) REFERENCES Millora (ID_millora_requerida)
);

-- Creació de la taula tenen
CREATE TABLE Tenen (
	ID_millores INTEGER,
	ID_clan INTEGER,
	PRIMARY KEY (ID_millores, ID_clan),
	FOREIGN KEY (ID_millores) REFERENCES Millora (ID_millores),
	FOREIGN KEY (ID_clan) REFERENCES Clan (ID_clan)
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

-- Creació de la taula Pertany
CREATE TABLE Pertany (
	creador_del_clan VARCHAR (255)
	data DATE 
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
CREATE TABLE Donacio (
	or INTEGER, 
	data DATE,
	ID_donacio INTEGER,
	PRIMARY KEY (ID_donacio)
);

-- Creació taula rol
CREATE TABLE Rol (
	descripcio VARCHAR (255),
	ID_rol INTEGER,
	PRIMARY KEY (ID_rol)
);

-- Creació taula lluiten
CREATE TABLE Lluiten (
	ID_clan INTEGER,
	ID_batalla INTEGER,
	PRIMARY KEY (ID_clan,ID_batalla),
	FOREIGN KEY (ID_clan) REFERENCES Clan (ID_clan),
	FOREIGN KEY (ID_batalla) REFERENCES Batalla (ID_batalla)
);

-- IMPLEMENTACIÓ DEL MÒDUL 4:



