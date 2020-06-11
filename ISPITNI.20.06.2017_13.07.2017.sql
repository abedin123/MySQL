CREATE DATABASE I20062017
ON
(NAME='Data',FILENAME='D:\BP2\I20062017\Data')
LOG ON
(NAME ='Log',FILENAME='D:\BP2\I20062017\LOG')
GO

USE I20062017
GO


CREATE TABLE Proizvodi
(
	 ProizvodID INT NOT NULL IDENTITY (1,1) CONSTRAINT PK_ProizvodID PRIMARY KEY,
	 Sifra NVARCHAR(25) NOT NULL CONSTRAINT UQ_Proizvodi_Sifra UNIQUE,
	 Naziv NVARCHAR(50) NOT NULL,
	 Kategorija NVARCHAR(50) NOT NULL,
	 Cijena DECIMAL (10,2) NOT NULL
);
GO

CREATE TABLE Narudzbe
(
	 NarudzbaID INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_NarudzbaID PRIMARY KEY,
	 BrojNarudzbe NVARCHAR(25) NOT NULL CONSTRAINT UQ_Narudzbe_BrojNarudzbe UNIQUE,
	 Datum DATE NOT NULL,
	 Ukupno DECIMAL(15,2) NOT NULL
);
GO

CREATE TABLE StavkeNarudzbe
(
	 ProizvodID INT NOT NULL  CONSTRAINT FK_StavkeNarudzbe_ProizvodID FOREIGN KEY REFERENCES Proizvodi(ProizvodID),
	 NarudzbaID INT NOT NULL  CONSTRAINT FK_StavkeNarudzbe_NarudzbaID FOREIGN KEY REFERENCES Narudzbe(NarudzbaID),
	 CONSTRAINT PK_StavkeNarudzbe_ProizvodID_NarudzbaID PRIMARY KEY(ProizvodID,NarudzbaID),
	 Kolicina INT NOT NULL,
	 Cijena DECIMAL(10,2) NOT NULL,
	 Popust DECIMAL(10,2) NOT NULL,
	 Iznos DECIMAL(15,2) NOT NULL
);
GO

--2

SET IDENTITY_INSERT Proizvodi ON
INSERT INTO Proizvodi (ProizvodID,Sifra,Naziv,Kategorija,Cijena)
SELECT DISTINCT P.ProductID,P.ProductNumber,P.Name,PC.Name,P.ListPrice
FROM AdventureWorks2014.Production.Product AS P
     INNER JOIN AdventureWorks2014.Production.ProductSubcategory AS PS ON P.ProductSubcategoryID=PS.ProductSubcategoryID
	 INNER JOIN AdventureWorks2014.Production.ProductCategory AS PC ON PS.ProductCategoryID=PC.ProductCategoryID
     INNER JOIN AdventureWorks2014.Sales.SalesOrderDetail AS SOD ON P.ProductID=SOD.ProductID
	  INNER JOIN AdventureWorks2014.Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID=SOH.SalesOrderID 
WHERE YEAR(SOH.OrderDate)=2014
SET IDENTITY_INSERT Proizvodi OFF	
GO

SET IDENTITY_INSERT Narudzbe ON	
INSERT INTO Narudzbe(NarudzbaID,BrojNarudzbe,Datum,Ukupno) 
SELECT DISTINCT SOH.SalesOrderID,SOH.SalesOrderNumber,SOH.OrderDate,SOH.TotalDue
FROM AdventureWorks2014.Sales.SalesOrderDetail AS SOD
     INNER JOIN AdventureWorks2014.Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID=SOH.SalesOrderID
WHERE YEAR(SOH.OrderDate)=2014
SET IDENTITY_INSERT Narudzbe OFF
GO


INSERT INTO StavkeNarudzbe
SELECT P.ProductID,SOH.SalesOrderID,SOD.OrderQty,SOD.UnitPrice,SOD.UnitPriceDiscount,SOD.LineTotal
FROM AdventureWorks2014.Sales.SalesOrderDetail AS SOD
     INNER JOIN AdventureWorks2014.Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID=SOH.SalesOrderID
     INNER JOIN AdventureWorks2014.Production.Product AS P ON SOD.ProductID=P.ProductID
WHERE YEAR(SOH.OrderDate)=2014
GO


--3


CREATE TABLE Skladiste
(
	SkladisteID INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_SkladisteID PRIMARY KEY,
	Naziv NVARCHAR (30) NOT NULL
);
GO


CREATE TABLE ProizvodSkladiste
(
  SkladisteID INT NOT NULL CONSTRAINT FK_ProizvodSkladiste_SkladisteID FOREIGN KEY REFERENCES Skladiste(SkladisteID),
  ProizvodID INT NOT NULL CONSTRAINT FK_ProizvodSkladiste_ProizvodID FOREIGN KEY REFERENCES Proizvodi(ProizvodID),
  CONSTRAINT PK_ProizvodSkladiste_SkladisteID_ProizvodID PRIMARY KEY(SkladisteID,ProizvodID),
  Kolicina INT NOT NULL
);
GO

--4

INSERT INTO Skladiste
VALUES ('Mostarsko'),
       ('Sarajevosko'),
	   ('Zenicko')
GO

INSERT INTO ProizvodSkladiste
SELECT 1,ProizvodID,0 FROM Proizvodi
GO

INSERT INTO ProizvodSkladiste
SELECT 2,ProizvodID,0 FROM Proizvodi
GO

INSERT INTO ProizvodSkladiste
SELECT 3,ProizvodID,0 FROM Proizvodi
GO

SELECT *
FROM ProizvodSkladiste
GO


--5


CREATE PROCEDURE usp_ProizvodSkladiste_UPDATE
(
	@ProizvodID INT,
	@SkladisteID INT,
	@Kolicina INT
)
AS
BEGIN
	UPDATE ProizvodSkladiste
	SET Kolicina+=@Kolicina
	WHERE ProizvodID=@ProizvodID AND SkladisteID=@SkladisteID
END
GO

SELECT TOP 5 ProizvodID
FROM Proizvodi
GO

EXECUTE usp_ProizvodSkladiste_UPDATE 872,1,30
GO

SELECT *
FROM ProizvodSkladiste
WHERE ProizvodID=872 AND SkladisteID=1
GO


--6


CREATE NONCLUSTERED INDEX IX_NON_Proizvodi_Sifra_Naziv
ON Proizvodi(Sifra,Naziv)
GO

SELECT Sifra,Naziv
FROM Proizvodi
WHERE Naziv LIKE '[^M]%'
GO

--7

CREATE TRIGGER tr_Proizvodi_INSTEAD_DELETE
 ON Proizvodi
 INSTEAD OF DELETE
 AS
 BEGIN
	 print 'Nije moguce brisati podatke iz tabele Proizvodi'
	 ROLLBACK TRANSACTION
 END
 GO

 DELETE
 FROM Proizvodi
 WHERE Naziv LIKE '[M]%'
 GO
 --8

 CREATE VIEW vProizvodiStavkeNarudzbe
 AS
 SELECT P.Sifra,P.Naziv,P.Cijena,SUM(SN.Kolicina) AS Kolicina,SUM(N.Ukupno) AS Zarada
 FROM Proizvodi AS P
      INNER JOIN StavkeNarudzbe AS SN ON P.ProizvodID=SN.ProizvodID
	  INNER JOIN Narudzbe AS N ON SN.NarudzbaID=N.NarudzbaID
GROUP BY P.Sifra,P.Naziv,P.Cijena
GO

SELECT *
FROM vProizvodiStavkeNarudzbe
ORDER BY Kolicina DESC
GO

--9

CREATE PROCEDURE usp_ProizvodiStavke_SEARCH
(
  @Sifra NVARCHAR(25)=NULL
)
AS
BEGIN
	SELECT Kolicina,Zarada
	FROM vProizvodiStavkeNarudzbe
	WHERE Sifra=@Sifra OR @Sifra IS NULL
END
GO

EXECUTE usp_ProizvodiStavke_SEARCH
GO

EXECUTE usp_ProizvodiStavke_SEARCH 'HL-U509-R'
GO

--10

CREATE USER I20062017 FOR LOGIN Student
GO

GRANT EXECUTE ON [dbo].[usp_ProizvodiStavke_SEARCH] TO I20062017
GO
--11

BACKUP DATABASE I20062017
TO DISK ='D:\Backup\I20062017.bak'
GO

BACKUP DATABASE I20062017
TO DISK ='D:\Backup\I20062017DIFF.bak'
WITH DIFFERENTIAL
GO