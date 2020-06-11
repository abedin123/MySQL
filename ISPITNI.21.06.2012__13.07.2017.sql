CREATE DATABASE I21062012
GO

USE I21062012
GO


CREATE TABLE Kupci
(
  KupacID INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_KupacID PRIMARY KEY,
  Ime NVARCHAR(35)NOT NULL,
  Prezime NVARCHAR(35)NOT NULL,
  JMBG NVARCHAR(13)NOT NULL,
  DatumRegistracije DATE NULL
);
GO

CREATE TABLE Proizvodi
(
	 ProizvodID INT NOT NULL IDENTITY (1,1) CONSTRAINT PK_ProizvodID PRIMARY KEY,
	 Naziv NVARCHAR(35)NOT NULL
);
GO


CREATE TABLE Narudzbe
(
	 NarudzbaID INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_NarudbeID PRIMARY KEY,
	 KupacID INT NOT NULL  CONSTRAINT FK_Narudzbe_KupacID FOREIGN KEY REFERENCES Kupci(KupacID),
	 ProizvodID INT NOT NULL CONSTRAINT PK_Narudzbe_ProizvodID FOREIGN KEY REFERENCES Proizvodi(ProizvodID),
     DatumNarudzbe DATETIME NULL,
	 Kolicina INT NOT NULL,
	 Cijena INT NOT NULL
);
GO

--2


INSERT INTO Kupci
VALUES ('Edin','Smajlagic','2509996170953','2015-07-02')
GO

INSERT INTO Proizvodi
VALUES ('ISO Sport')
GO

--3

SELECT FirstName,LastName,LEFT(rowguid,13)AS JMBG,GETDATE() DatumRegistracije
INTO #TempBrojDosijea
FROM AdventureWorks2014.Person.Person
WHERE MiddleName IS NOT NULL AND Title IS NOT NULL
GO

--4

INSERT INTO Kupci
SELECT *
FROM #TempBrojDosijea
GO

INSERT INTO Narudzbe
SELECT KupacID,1,SYSDATETIME(),2,1200 FROM Kupci
GO

SELECT *
FROM Narudzbe
GO

--5

CREATE VIEW view_kupciNarudzbe
AS
SELECT K.Ime,K.Prezime,P.Naziv,N.DatumNarudzbe,CONVERT(NVARCHAR,(N.Kolicina*N.Cijena))+' KM' AS Ukupno
FROM Narudzbe AS N
     INNER JOIN Kupci AS K ON N.KupacID=K.KupacID
	 INNER JOIN Proizvodi AS P ON N.ProizvodID=P.ProizvodID
GO

--6

CREATE PROCEDURE usp_KupciUpdate
(
  @KupacID INT ,
  @Ime NVARCHAR(35),
  @Prezime NVARCHAR(35),
  @JMBG NVARCHAR(13),
  @DatumRegistracije DATE 
)
AS
BEGIN
	UPDATE Kupci
	SET Ime=@Ime,Prezime=@Prezime,JMBG=@JMBG,DatumRegistracije=@DatumRegistracije
	WHERE KupacID=@KupacID
END
GO


--7

EXECUTE usp_KupciUpdate 1,'Edin','Smajlagiæ','2509996170953','2017-07-13'
GO

SELECT *
FROM Kupci
WHERE KupacID=1
GO


--8


CREATE PROCEDURE usp_KupciDelete
(
 @KupacID INT 
)
AS
BEGIN
    DELETE
	FROM Narudzbe
	WHERE KupacID=@KupacID

	DELETE
	FROM Kupci
	WHERE KupacID=@KupacID
END
GO

--9

EXECUTE usp_KupciDelete 1
