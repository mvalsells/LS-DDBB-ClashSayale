-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Validació

-- Validació entorn a Jugadors
SELECT tag_jugador, nom, experiencia, trofeus, targeta_credit, numero, caducitat
FROM jugador as j
JOIN targeta_credit AS tc ON j.targeta_credit = tc.numero;

SELECT tag_jugador1, tag_jugador2
FROM amics;

-- Validació entorn a Cartes
SELECT j.tag_jugador, j.nom, COUNT(ed.nom) AS num_c_edifici --, COUNT(en.nom) AS num_c_encanteri, COUNT(t.nom) AS num_c_trop
FROM jugador AS j
JOIN pertany AS p on j.tag_jugador = p.tag_jugador
JOIN edifici AS ed ON ed.nom = p.nom_carta
-- JOIN encanteri AS en on en.nom = p.nom_carta
-- JOIN tropa AS t ON t.nom = p.nom_carta
GROUP BY j.tag_jugador;


SELECT j.tag_jugador, j.nom, COUNT(DISTINCT c.id_pila) AS num_piles_compartiedes
FROM jugador AS j
JOIN pila p on j.tag_jugador = p.tag_jugador
JOIN comparteixen c on p.id_pila = c.id_pila
GROUP BY j.tag_jugador;

SELECT id_pila, tag_jugador
FROM comparteixen;

-- Validació entorn a Clans

-- Validació entorn a Batalles
SELECT guanya.id_pila, perd.id_pila, guanya.num_trofeus, perd.num_trofeus, batalla.data, batalla.durada, batalla.clan_battle
FROM batalla
JOIN guanya ON batalla.id_batalla = guanya.id_batalla
JOIN perd ON batalla.id_batalla = perd.id_batalla;

SELECT tag_clan, id_batalla, data_inici, data_fi
FROM lluiten;

-- Validació entorn a Arenes

-- Validació entorn a Missions
SELECT j.tag_jugador AS tag_jugador, j.nom AS nom_jugador, count(c.id_missio) AS num_missions
FROM completen AS c
JOIN jugador AS j on c.tag_jugador = j.tag_jugador
GROUP BY j.tag_jugador
ORDER BY num_missions DESC;

SELECT j.tag_jugador AS tag_jugador, j.nom AS nom_jugador, SUM(c.or_) AS or_guanyat, SUM(c.experiencia) AS expereincia_guanyada
FROM completen AS c
JOIN jugador AS j on c.tag_jugador = j.tag_jugador
GROUP BY j.tag_jugador
ORDER BY or_guanyat DESC, expereincia_guanyada DESC;

SELECT m.id_missio, m.titol AS titol_missio, COUNT(c.id_arena) AS num_arenes
FROM missio AS m
JOIN completen AS c on m.id_missio = c.id_missio
GROUP BY m.id_missio;

SELECT m.titol AS Missio, (SELECT m2.titol FROM missio AS m2 WHERE m2.id_missio = d.id_missio2) AS depen
FROM missio AS m
JOIN depen AS d on m.id_missio = d.id_missio1;

SELECT j.tag_jugador, j.nom, a.titol AS titol_arena, SUM(c.experiencia) AS experiencia
FROM arena AS a
JOIN completen AS c on a.id_arena = c.id_arena
JOIN jugador AS j on c.tag_jugador = j.tag_jugador
GROUP BY a.id_arena, j.tag_jugador
ORDER BY experiencia DESC
LIMIT 10;

-- SELECT DISTINCT count(id_missio1)
-- FROM depen

-- Validació entorn a Assoliments
SELECT tag_jugador,titol,descripcio,id_arena,data,recompensa_gemmes
FROM assoliment as a, aconsegueix as ac
WHERE a.id_assoliment = ac.id_assoliment;

--Jugador en una arena determinada quantes gemmes(assoliment) te
SELECT DISTINCT j.tag_jugador as ID_Jugador,j.nom as Nom_Jugador,a.id_arena as ID_Arena,
a2.recompensa_gemmes as Assoliment_Gemmes
FROM jugador as j JOIN aconsegueix a on j.tag_jugador = a.tag_jugador
JOIN assoliment a2 on a.id_assoliment = a2.id_assoliment;

--falta atribut arena que noe sta posat a cap taula
--SELECT tag_jugador, i.titol, id_arena,data,imatge
--FROM insignia as i, guanya as g, arena as a
--WHERE i.

-- Validació entorn a Botiga
--(Quants articles han comprat els 10 primers jugadors per ordre abc)
SELECT j.tag_jugador as Id_Jugador, j.nom as Nom, COUNT(c.id_article) as Articles
FROM compren AS c JOIN targeta_credit tc on c.num_targeta = tc.numero
JOIN jugador j on c.tag_jugador = j.tag_jugador
JOIN article a on c.id_article = a.id_article
GROUP BY j.tag_jugador,j.nom
ORDER BY j.nom asc
LIMIT 10;

--(Un jugador compra un article que es vegi la quantitat el preu i el seu nom, descompte)
SELECT DISTINCT j.tag_jugador as ID_Jugador, j.nom as Nom, t.numero, a.nom as Nom_article,
a.preu as Preu_article, a.quantitat as Quants, c.descompte as Descompte,c.data_ as Data
FROM jugador as j JOIN targeta_credit as t on j.targeta_credit = t.numero
JOIN compren c on j.tag_jugador = c.tag_jugador and t.numero = c.num_targeta
JOIN article a on c.id_article = a.id_article;

--(Jugador compra paquet que conte)
SELECT j.tag_jugador as ID_Jugador,j.nom as NOM, co.nom_cofre as Paquet_Cofre,a.preu as Preu_article,
co.raresa as Raresa, co.temps as Temps_Desbloqueig, co.quantitat_cartes as Num_Cartes
FROM article as a join cofre co on a.id_article = co.id_cofre
JOIN compren c on a.id_article = c.id_article
JOIN jugador j on c.tag_jugador = j.tag_jugador;

--Paquet bundle que conte
SELECT  b.or_ as Bundle_Or, b.gemmes as Bundle_Gemmes
FROM  bundle AS b;

--Paquet emoticones
SELECT j.tag_jugador as ID_Jugador,j.nom, a.nom as Nom_Article, e.nom_imatge
as nom_imatge, e.direccio_imatge as Direccio_imatge
FROM compren as c JOIN article a on c.id_article = a.id_article
JOIN jugador j on c.tag_jugador = j.tag_jugador
JOIN emoticones e on a.id_article = e.id_emoticones
LIMIT 20;

--Paquet arena
SELECT DISTINCT j.tag_jugador as ID_Jugador,j.nom as Nom_Jugador, a.preu as Preu_Article,
ap.id_pack AS Paquet_Arena_Id,apa.or_ as Paquet_Arena_Or
FROM jugador as j JOIN compren c on j.tag_jugador = c.tag_jugador
JOIN article as a  on a.id_article = c.id_article
JOIN arena_pack as ap on ap.id_pack = a.id_article
JOIN arena_pack_arena as apa on apa.id_arena_pack = ap.id_pack;







