-- BBDD GB5 - Marc Valsells, Marc Geremias, Irina Aynes i Albert Tomas
-- Validació

-- Validació entorn a Jugadors
SELECT tag_jugador, nom, experiencia, trofeus, targeta_credit, numero, caducitat
FROM jugador as j
JOIN targeta_credit AS tc ON j.targeta_credit = tc.numero;

SELECT tag_jugador1, tag_jugador2
FROM amics;

-- Validació entorn a Cartes
SELECT j.tag_jugador, j.nom, COUNT(ed.nom) AS num_c_edifici
FROM jugador AS j
JOIN pertany AS p on j.tag_jugador = p.tag_jugador
JOIN edifici AS ed ON ed.nom = p.nom_carta
GROUP BY j.tag_jugador;

SELECT j.tag_jugador, j.nom, COUNT(DISTINCT c.id_pila) AS num_piles_compartiedes
FROM jugador AS j
JOIN pila p on j.tag_jugador = p.tag_jugador
JOIN comparteixen c on p.id_pila = c.id_pila
GROUP BY j.tag_jugador;

SELECT p.tag_jugador, c.nom, COUNT(f.nom_carta) AS total
FROM carta AS c
JOIN formen AS f on c.nom = f.nom_carta
JOIN pila p on f.id_pila = p.id_pila
GROUP BY c.nom, p.tag_jugador
ORDER BY total DESC;

SELECT p.nom AS pila, COUNT(DISTINCT c.raresa) AS rareses_diferents
FROM pila AS p
JOIN formen f on p.id_pila = f.id_pila
JOIN carta c on c.nom = f.nom_carta
GROUP BY p.id_pila
ORDER BY rareses_diferents;


-- Validació entorn a Clans

SELECT clan.nom as nom_clan, jugador.tag_jugador, jugador.nom, sum(dona.quantitat) AS total_donat
FROM clan
JOIN forma_part ON forma_part.tag_clan = clan.tag_clan
JOIN jugador ON jugador.tag_jugador = forma_part.tag_jugador
JOIN dona ON dona.tag_jugador = jugador.tag_jugador
JOIN rol ON rol.id_rol = forma_part.id_rol
GROUP BY jugador.tag_jugador, clan.tag_clan
ORDER BY total_donat DESC
LIMIT 20;


SELECT clan.nom, estructura.id_estructura, estructura.minim_trofeus, millora.descripcio
FROM clan
JOIN tenen_estructura ON clan.tag_clan = tenen_estructura.tag_clan
JOIN estructura ON tenen_estructura.id_estructura = estructura.id_estructura
JOIN millora ON millora.nom_millora = estructura.id_estructura
ORDER BY clan.tag_clan;

SELECT requereix_tecnologia.id_tecnologia_nova AS nova_millora, millora.cost, requereix_tecnologia.nivell_prerequisit, requereix_tecnologia.id_tecnologia_requerida AS tecnologia_requerida
FROM tecnologia
JOIN requereix_tecnologia ON tecnologia.id_tecnologia = requereix_tecnologia.id_tecnologia_nova
JOIN millora ON millora.nom_millora = tecnologia.id_tecnologia
ORDER BY millora.cost DESC
LIMIT 20;

-- Validació entorn a Batalles
SELECT guanya.id_pila, perd.id_pila, guanya.num_trofeus, perd.num_trofeus, batalla.data, batalla.durada, batalla.clan_battle
FROM batalla
JOIN guanya ON batalla.id_batalla = guanya.id_batalla
JOIN perd ON batalla.id_batalla = perd.id_batalla;

SELECT tag_clan, id_batalla, data_inici, data_fi
FROM lluiten;

--Insignies i guanya
SELECT DISTINCT i.titol as Nom_Insignies,i.imatge as Imatge_Insiginia
FROM batalla as b JOIN guanya as g on b.id_batalla = g.id_batalla
JOIN jugador j on g.tag_jugador = j.tag_jugador
JOIN insignia i on b.data = i.data;


-- Validació entorn a Arenes

SELECT arena.titol AS nom_arena, SUM(arena_pack_arena.or_) AS or_arena_total
FROM arena
JOIN arena_pack_arena ON arena.id_arena = arena_pack_arena.id_arena
GROUP BY arena.id_arena
ORDER BY or_arena_total DESC
LIMIT 15;

SELECT arena.titol, arena.nombre_min , carta.nom, carta.dany, carta.velocitat_atac, raresa.cost_pujar_nivell
FROM arena
JOIN carta ON arena.id_arena = carta.arena
JOIN raresa ON carta.raresa = raresa.nom
WHERE arena.nombre_min > 2000
ORDER BY arena.nombre_min ASC
LIMIT 10;



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

--Assoliment i aconsegueix
SELECT ac.tag_jugador, a.titol, a.descripcio,ac.id_arena,ac.data,a.recompensa_gemmes
FROM assoliment as a JOIN aconsegueix ac on a.id_assoliment = ac.id_assoliment;

SELECT DISTINCT j.tag_jugador as ID_Jugador,j.nom as Nom_Jugador,a.id_arena as ID_Arena,
a2.recompensa_gemmes as Assoliment_Gemmes
FROM jugador as j JOIN aconsegueix a on j.tag_jugador = a.tag_jugador
JOIN assoliment a2 on a.id_assoliment = a2.id_assoliment;


-- Validació entorn a Botiga

--Compra article
SELECT j.tag_jugador as Id_Jugador, j.nom as Nom, COUNT(c.id_article) as Articles
FROM compren AS c JOIN targeta_credit tc on c.num_targeta = tc.numero
JOIN jugador j on c.tag_jugador = j.tag_jugador
JOIN article a on c.id_article = a.id_article
GROUP BY j.tag_jugador,j.nom
ORDER BY articles desc
LIMIT 10;

SELECT DISTINCT j.tag_jugador as ID_Jugador, j.nom as Nom, t.numero, a.nom as Nom_article,
a.preu as Preu_article, a.quantitat as Quants, c.descompte as Descompte,c.data_ as Data
FROM jugador as j JOIN targeta_credit as t on j.targeta_credit = t.numero
JOIN compren c on j.tag_jugador = c.tag_jugador and t.numero = c.num_targeta
JOIN article a on c.id_article = a.id_article;

--Paquet cofre
SELECT j.tag_jugador as ID_Jugador,j.nom as NOM, co.nom_cofre as Paquet_Cofre,a.preu as Preu_article,
co.raresa as Raresa, co.temps as Temps_Desbloqueig, co.quantitat_cartes as Num_Cartes
FROM article as a join cofre co on a.id_article = co.id_cofre
JOIN compren c on a.id_article = c.id_article
JOIN jugador j on c.tag_jugador = j.tag_jugador;

--Paquet bundle
SELECT j.tag_jugador as ID_Jugador,b.id_bundle as ID_Bundle,b.or_ as Bundle_Or, b.gemmes as Bundle_Gemmes
FROM  bundle AS b JOIN article as a on b.id_bundle = a.id_article
JOIN compren c on a.id_article = c.id_article
JOIN jugador j on c.tag_jugador = j.tag_jugador;

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






