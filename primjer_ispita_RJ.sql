--1
/*
a) Kreirati bazu Indeks.
*/
CREATE DATABASE Indeks
USE Indeks

/*
b) U bazi indeks kreirati sljedeće tabele:
1. Narudzba koja će se sastojati od polja:
2. Dobavljac
3. Proizvod
*/
CREATE TABLE Narudzba
(
	NarudzbaID INT NOT NULL,
	DatumNarudzbe DATE NULL,
	DatumPrijema DATE NULL,
	DatumIsporuke DATE NULL,
	TrosakPrevoza MONEY NULL,
	PunaAdresa NVARCHAR (70) NULL
	CONSTRAINT PK_Narudzba PRIMARY KEY (NarudzbaID)
)

CREATE TABLE Dobavljac 
(
	DobavljacID INT NOT NULL,
	NazivDobavljaca nvarchar(40) NOT NULL,
	PunaAdresa nvarchar(60) NULL,
	Drzava nvarchar(15) NULL,
	CONSTRAINT PK_Dobavljac PRIMARY KEY (DobavljacID)
)

CREATE TABLE Proizvod
(
	NarudzbaID INT NOT NULL,
	DobavljacID INT NOT NULL,
	ProizvodID INT NOT NULL,
	NazivProizvoda NVARCHAR (40) NOT NULL,
	Cijena INT NOT NULL,
	Kolicina INT NOT NULL,
	Popust DECIMAL (3,2) NOT NULL,
	Raspolozivost BIT NOT NULL,
	CONSTRAINT FK_Proizvod_Narudzba FOREIGN KEY (NarudzbaID) REFERENCES Narudzba (NarudzbaID),
	CONSTRAINT FK_Proizvod_Dobavljac FOREIGN KEY (DobavljacID) REFERENCES Dobavljac (DobavljacID),
	CONSTRAINT PK_Proizvod PRIMARY KEY (NarudzbaID, DobavljacID, ProizvodID)
)

--2
/*a) U tabelu Narudzba insertovati podatke iz tabele Orders baze Northwind pri čemu će puna adresa biti sačinjena od adrese, poštanskog broja i grada isporuke.
Između dijelova adrese umetnuti prazno mjesto. Ukoliko nije unijeta vrijednost poštanskog broja zamijeniti je sa 00000. 
Uslov je da se insertuju zapisi iz 1997. i većih godina (1998, 1999...), te da postoji datum isporuke. Zapise sortirati po vrijednosti troška prevoza.
*/
USE Indeks
INSERT INTO Narudzba 
SELECT	O.OrderID, O.OrderDate, O.RequiredDate, O.ShippedDate, O.Freight, O.ShipAddress + ' ' + ISNULL (O.ShipPostalCode, '00000') + ' ' + O.ShipCity
FROM	NORTHWND.dbo.Orders AS O
WHERE	YEAR (O.OrderDate) > 1996 AND O.ShippedDate IS NOT NULL
ORDER BY O.OrderID
--RJ: 657

/*
b) U tabelu Dobavljac insertovati zapise iz tabele Suppliers. Puna adresa će se sastojati od adrese, poštanskog broja i grada dobavljača.
*/

INSERT INTO Dobavljac
SELECT S.SupplierID, S.CompanyName, S.Address + ' ' + S.PostalCode + ' ' + S.City, S.Country
FROM NORTHWND.dbo.Suppliers AS S
--RJ: 29

/*
c) U tabelu Proizvod insertovati zapise iz odgovarajućih kolona tabela Order Details i Product uz uslov da vrijednost cijene bude veća od
10, te da je na proizvod odobren popust. S obzirom na zadatak 2a voditi računa o postavljanju odgovarajućeg uslova da ne bi došlo do
konflikta u odnosu na NarudzbaID - potrebno je postaviti uslov da se insertuju zapisi iz 1997. i većih godina (1998, 1999...), te da postoji datum isporuke.
*/
INSERT INTO Proizvod
SELECT	OD.OrderID,  P.SupplierID, P.ProductID, P.ProductName, OD.UnitPrice, OD.Quantity, OD.Discount, P.Discontinued
FROM	NORTHWND.dbo.[Order Details] AS OD INNER JOIN NORTHWND.dbo.Products AS P
ON		OD.ProductID = P.ProductID
			INNER JOIN NORTHWND.dbo.Orders AS O
			ON OD.OrderID = O.OrderID
WHERE	OD.Quantity > 10 AND OD.Discount > 0 AND YEAR (O.OrderDate) > 1996 AND O.ShippedDate IS NOT NULL
--RJ: 521

--3
/*
Iz tabele Proizvod dati pregled ukupnog broja ostvarenih narudzbi po dobavljaču i proizvodu.
*/
SELECT DobavljacID, NazivProizvoda, COUNT (NarudzbaID) AS UkupnoNarudzbi
FROM Proizvod
GROUP BY DobavljacID, NazivProizvoda
ORDER BY 1
--RJ: 76

--4
/*
Iz tabele Proizvod dati pregled ukupnog prometa ostvarenog po dobavljaču i narudžbi uz uslov da se prikažu samo oni zapisi kod kojih je vrijednost
prometa manja od 1000 i odobreni popust veći od 10%. Ukupni promet izračunati uz uzimanje u obzir i odobrenog popusta.
*/
SELECT DobavljacID, NarudzbaID, Popust, SUM (Cijena * Kolicina * (1 - Popust)) AS Promet
FROM Proizvod
WHERE Popust > 0.10
GROUP BY DobavljacID, NarudzbaID, Popust
HAVING SUM (Cijena * Kolicina * (1 - Popust)) < 1000
ORDER BY 1
--RJ: 242

--5
/*
Iz tabele Narudzba dati pregled svih narudzbi kod kojih je broj dana od datuma narudžbe do datuma isporuke manji od 10.
Pregled će se sastojati od ID narudžbe, broja dana razlike i kalendarske godine, pri čemu je razdvojiti pregled po godinama 
(1997 i 1998 - prvo sve 1997, zatim sve 1998). Sortirati po broju dana isporuke u opadajućem redoslijedu.
*/
SELECT NarudzbaID, DATEDIFF (DAY, DatumNarudzbe, DatumIsporuke) AS BrDanaIsporuke, YEAR (DatumIsporuke) AS Godina
FROM Narudzba
WHERE DATEDIFF (DAY, DatumNarudzbe, DatumIsporuke) < 10
ORDER BY 3, 2
--RJ: 495

SELECT NarudzbaID, DATEDIFF (DAY, DatumNarudzbe, DatumIsporuke) AS BrDanaIsporuke, '1997' AS Godina
FROM Narudzba
WHERE YEAR (DatumIsporuke) = 1997 AND DATEDIFF (DAY, DatumNarudzbe, DatumIsporuke) < 10
UNION
SELECT NarudzbaID, DATEDIFF (DAY, DatumNarudzbe, DatumIsporuke) AS BrDanaIsporuke, '1998' AS Godina
FROM Narudzba
WHERE YEAR (DatumIsporuke) = 1998 AND DATEDIFF (DAY, DatumNarudzbe, DatumIsporuke) < 10
ORDER BY 2 DESC

--6
/*
Iz tabele Narudzba dati pregled svih narudzbi kod kojih je isporuka izvršena u istom mjesecu.
Pregled će se sastojati od ID narudžbe, broja dana razlike, mjeseca narudžbe, mjeseca isporuke i kalendarske godine, pri čemu je potrebno razdvojiti pregled po godinama 
(1997 i 1998 - prvo sve 1997, zatim sve 1998). Sortirati po broju dana isporuke u opadajućem redoslijedu.
*/
SELECT NarudzbaID, DATEDIFF (DAY, DatumNarudzbe, DatumIsporuke) AS BrDanaIsporuke, MONTH (DatumIsporuke) AS MjesecNarudzbe, MONTH (DatumNarudzbe) AS MjesecIsporuke, YEAR (DatumIsporuke) AS Godina
FROM Narudzba
WHERE MONTH (DatumIsporuke) = MONTH (DatumNarudzbe)
ORDER BY 5, 2
--RJ: 464

--7
/*Iz tabele Narudzba dati pregled svih narudžbi koje su isporučene u Graz ili Köln.
Pregled će se sastojati od ID narudžbe i naziva grada. Sortirati po nazivu grada. 
*/
SELECT NarudzbaID, RIGHT (PunaAdresa, 4) AS NazivGrada
FROM Narudzba
WHERE PunaAdresa LIKE '%Graz%' OR PunaAdresa LIKE '%Köln%'
ORDER BY 2
--RJ: 31

--8
/*
Iz tabela Narudzba, Dobavljac i Proizvod kreirati pregled koji će se sastojati od polja NarudzbaID, GodNarudzbe kao godinu iz polja DatumNarudzbe, 
NazivProizvoda, NazivDobavljaca, Drzava, TrosakPrevoza, Ukupno kao ukupna vrijednost narudžbe koja će se računati uz uzimanje u obzir i popusta i postotak
koji će davati informaciju o vrijednosti postotka troška prevoza u odnosu na ukupnu vrijenost narudžbe.
Uslov je da postotak bude veći od 30% i da je ukupna vrijednost veća od troška prevoza. Sortirati po vrijednosti postotka u opadajućem redoslijedu.
*/
SELECT	N.NarudzbaID, YEAR (N.DatumNarudzbe) AS GodNarudzbe, P.NazivProizvoda, D.NazivDobavljaca, D.Drzava, 
		N.TrosakPrevoza, P.Cijena * P.Kolicina * (1 - P.Popust) AS Ukupno, LEFT (ROUND (N.TrosakPrevoza / (P.Cijena * P.Kolicina * (1 - P.Popust)) * 100, 2),5) AS Postotak
FROM	Narudzba AS N INNER JOIN Proizvod AS P
ON		N.NarudzbaID = P.NarudzbaID
		INNER JOIN Dobavljac AS D
		ON P.DobavljacID = D.DobavljacID
WHERE	N.TrosakPrevoza > 0.3 * (P.Cijena * P.Kolicina * (1 - P.Popust)) AND N.TrosakPrevoza < (P.Cijena * P.Kolicina * (1 - P.Popust))
ORDER BY 8 DESC
--RJ: 104

--9
/*
Iz tabela Narudzba, Dobavljac i Proizvod kreirati pogled koji će sadržavati ID narudžbe, dan iz datuma prijema, raspoloživost, naziv grada iz pune adrese naručitelja,
i državu dobavljača. Uslov je da je datum prijema u 2. ili 3. dekadi mjeseca i da grad naručitelja Bergamo.
*/
USE Indeks
GO
CREATE VIEW view1
AS
SELECT	TOP 100 PERCENT N.NarudzbaID, DAY (N.DatumPrijema) AS DanPrijema, P.Raspolozivost, RIGHT (N.PunaAdresa, 7) AS NazivGrada, D.Drzava
FROM	Narudzba AS N INNER JOIN Proizvod AS P
ON		N.NarudzbaID = P.NarudzbaID
		INNER JOIN Dobavljac AS D
		ON P.DobavljacID = D.DobavljacID
WHERE	DAY (N.DatumPrijema) BETWEEN 11 AND 31 AND RIGHT (N.PunaAdresa, 7) = 'Bergamo'
ORDER BY 2

SELECT * FROM view1
--RJ: 5

--10
/*
Iz tabela Proizvod i Dobavljac kreirati proceduru proc1 koja će sadržavati ID i naziv dobavljača i ukupan broj proizvoda
koji je realizirao dobavljač. Pokrenuti proceduru za vrijednost ukupno realiziranog broja proizvoda 22 i 14.
*/
USE Indeks
GO
CREATE PROCEDURE proc1
(
	@DobavljacID int = NULL,
	@NazivDobavljaca nvarchar(40) = NULL,
	@UkBroj int = NULL
)
AS
BEGIN
SELECT	P.DobavljacID, D.NazivDobavljaca, COUNT (P.ProizvodID) AS Broj
FROM	Proizvod AS P INNER JOIN Dobavljac AS D
ON		P.DobavljacID = D.DobavljacID
--WHERE	P.DobavljacID = @DobavljacID OR
--		NazivDobavljaca = @NazivDobavljaca OR
--		P.ProizvodID >= 0
GROUP BY P.DobavljacID, D.NazivDobavljaca
HAVING	COUNT (P.ProizvodID) = @UkBroj
END

exec proc1 @UkBroj = 14

exec proc1 @UkBroj = 22