CREATE DATABASE I05092016
GO

USE I05092016
GO


CREATE TABLE Klijenti
(
	KlijentID INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_KlijentID PRIMARY KEY,
	Ime NVARCHAR(30)NOT NULL,
	Prezime NVARCHAR(30)NOT NULL,
	Telefon NVARCHAR(20)NOT NULL,
	Mail NVARCHAR(50)NOT NULL CONSTRAINT UQ_Klijenti_Mail UNIQUE,
	BrojRacuna NVARCHAR(15)NOT NULL,
	KorisnickoIme NVARCHAR(20)NOT NULL,
	Lozinka NVARCHAR(20)NOT NULL
);
GO

CREATE TABLE Transakcije
(
   TransakcijaID INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_TransakcijaID PRIMARY KEY,
   Datum DATETIME NOT NULL,
   TipTransakcije NVARCHAR(30) NOT NULL,
   PosiljalacID INT NOT NULL CONSTRAINT FK_Transakcije_Klijent_PosiljalacID FOREIGN KEY REFERENCES Klijenti(KlijentID),
   PrimalacID INT NOT NULL CONSTRAINT FK_Transakcije_Klijent_PrimalacID FOREIGN KEY REFERENCES Klijenti(KlijentID),
   Svrha NVARCHAR(50) NOT NULL,
   Iznos DECIMAL (12,2) NOT NULL
)
GO


--2

INSERT INTO Klijenti
SELECT TOP 10 P.FirstName,P.LastName,PP.PhoneNumber,EA.EmailAddress,C.AccountNumber,P.FirstName+'.'+P.LastName,LEFT(PASS.PasswordHash,8)
FROM AdventureWorks2014.Person.Person AS P
     INNER JOIN AdventureWorks2014.Person.EmailAddress AS EA ON P.BusinessEntityID=EA.BusinessEntityID
	 INNER JOIN AdventureWorks2014.Person.PersonPhone AS PP ON P.BusinessEntityID=PP.BusinessEntityID
	 INNER JOIN AdventureWorks2014.Person.Password AS PASS ON P.BusinessEntityID=PASS.BusinessEntityID
	 INNER JOIN AdventureWorks2014.Sales.Customer AS C ON P.BusinessEntityID=C.PersonID
ORDER BY NEWID()
GO

SELECT *
FROM Klijenti
GO

INSERT INTO Transakcije
VALUES ('2016-01-01','TIP I',1,1,'Svrha 1',400),
       ('2016-02-02','TIP I',1,2,'Svrha 2',300),
	   ('2016-03-03','TIP II',2,1,'Svrha 3',200),
	   ('2015-04-04','TIP I',1,4,'Svrha 4',100),
	   ('2015-01-05','TIP II',2,3,'Svrha 5',500),
	   ('2015-05-06','TIP I',4,1,'Svrha 6',600),
	   ('2016-06-07','TIP I',5,2,'Svrha 7',700),
       ('2015-04-08','TIP II',3,1,'Svrha 8',800),
	   ('2017-03-09','TIP I',10,2,'Svrha 9',400),
	   ('2017-02-10','TIP II',9,4,'Svrha 10',300),
	   ('2017-01-11','TIP I',8,6,'Svrha 11',400),
	   ('2017-07-12','TIP II',7,1,'Svrha 12',800)
GO

--3

CREATE NONCLUSTERED INDEX IX_NON_Klijenti_Ime_Prezime_INC_BrojRacuna
ON Klijenti(Ime,Prezime)
INCLUDE (BrojRacuna)
GO

SELECT Ime,Prezime,BrojRacuna
FROM Klijenti
WHERE Prezime LIKE '[^A]%'
GO

ALTER INDEX IX_NON_Klijenti_Ime_Prezime_INC_BrojRacuna ON Klijenti
DISABLE
GO


--4


CREATE PROCEDURE usp_Klijent_INSERT
(
	@Ime NVARCHAR(30),
	@Prezime NVARCHAR(30),
	@Telefon NVARCHAR(20),
	@Mail NVARCHAR(50),
	@BrojRacuna NVARCHAR(15),
	@KorisnickoIme NVARCHAR(20),
	@Lozinka NVARCHAR(20)
)
AS
BEGIN
	INSERT INTO Klijenti
	VALUES (@Ime,@Prezime,@Telefon,@Mail,@BrojRacuna,@KorisnickoIme,@Lozinka)
END
GO

EXECUTE usp_Klijent_INSERT 'Elnad','Vranic','065 302 666','elnadv@mail.com','123456918399311','Elnad.Vranic','p@ssw0rt'
GO

SELECT *
FROM Klijenti
WHERE Mail ='elnadv@mail.com'
GO


--5

CREATE VIEW vTransakcijeKlijenti
AS
SELECT Datum,TipTransakcije,
       (SELECT Ime+' '+Prezime FROM Klijenti AS K WHERE K.KlijentID=PosiljalacID) AS Posiljaoc,
	   (SELECT BrojRacuna FROM Klijenti AS K WHERE K.KlijentID=PosiljalacID) AS [Racun posiljaoca],
	   (SELECT Ime+' '+Prezime FROM Klijenti AS K WHERE K.KlijentID=PrimalacID) AS Primalac,
	    (SELECT BrojRacuna FROM Klijenti AS K WHERE K.KlijentID=PrimalacID) AS [Racun primaoca],
	   Svrha,Iznos
FROM Transakcije
GO

--6

CREATE PROCEDURE usp_TransakcijePosiljaoca
(
@BrojRacuna NVARCHAR(15)
)
AS
BEGIN
	SELECT *
	FROM vTransakcijeKlijenti
	WHERE [Racun posiljaoca]=@BrojRacuna OR [Racun primaoca]=@BrojRacuna
END
GO

SELECT PosiljalacID
FROM Transakcije
GO

SELECT BrojRacuna
FROM Klijenti
WHERE KlijentID=2
GO


EXECUTE usp_TransakcijePosiljaoca 'AW00022634'
GO

--7


SELECT YEAR(Datum) AS Godina,CONVERT(NVARCHAR,SUM(Iznos))+' KM' AS [Ukupan iznos transakcija]
FROM Transakcije
GROUP BY YEAR(Datum)
GO

--8


CREATE PROCEDURE usp_Klijent_DELETE
(
@BrojRacuna NVARCHAR(15)
)
AS
BEGIN
   DELETE
   FROM Transakcije
   WHERE (PosiljalacID IN (SELECT KlijentID FROM Klijenti WHERE BrojRacuna=@BrojRacuna)) OR
         (PrimalacID IN (SELECT KlijentID FROM Klijenti WHERE BrojRacuna=@BrojRacuna))

	DELETE
	FROM Klijenti
	WHERE BrojRacuna=@BrojRacuna
END
GO


SELECT BrojRacuna
FROM Klijenti
WHERE KlijentID=2
GO

EXECUTE usp_Klijent_DELETE 'AW00022634'
GO

SELECT *
FROM Transakcije
WHERE (PosiljalacID IN (SELECT KlijentID FROM Klijenti WHERE BrojRacuna='AW00022634')) OR
      (PrimalacID IN (SELECT KlijentID FROM Klijenti WHERE BrojRacuna='AW00022634'))
GO

--9

CREATE PROCEDURE usp_KlijentTransakcije_SEARCH
(
	@BrojRacuna NVARCHAR(15)=NULL,
	@Prezime NVARCHAR(30)=NULL
)
AS
BEGIN
	SELECT *
	FROM vTransakcijeKlijenti
	WHERE ([Racun posiljaoca] =@BrojRacuna OR @BrojRacuna IS NULL)AND
		  (RIGHT(Posiljaoc,LEN(Posiljaoc)-CHARINDEX(' ',Posiljaoc)) LIKE @Prezime+'%' OR @Prezime IS NULL)
END
GO

SELECT Posiljaoc
FROM vTransakcijeKlijenti
GO


EXECUTE usp_KlijentTransakcije_SEARCH
GO

EXECUTE usp_KlijentTransakcije_SEARCH @BrojRacuna='AW00028302'
GO

EXECUTE usp_KlijentTransakcije_SEARCH @Prezime='Hughes'
GO

EXECUTE usp_KlijentTransakcije_SEARCH @BrojRacuna='AW00028302', @Prezime='Hughes'
GO


--10


BACKUP DATABASE I05092016
TO DISK = 'D:\Backup\I05092016.bak'
GO

BACKUP DATABASE I05092016
TO DISK='D:\Backup\I05092016DIFF.bak'
WITH DIFFERENTIAL
GO