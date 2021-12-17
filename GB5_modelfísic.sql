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



-- IMPLEMENTACIÓ DEL MÒDUL 4:



