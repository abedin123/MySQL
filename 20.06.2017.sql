create database [170059] ON PRIMARY(
	NAME = N'[170059]',
	FILENAME = N'D:\BP2\Data\[170059].mdf',
	SIZE = 5MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 10%
)
LOG ON
(
	NAME = N'[170059]_log',
	FILENAME = N'D:\BP2\Data\[170059]_log.ldf',
	SIZE = 5MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 10%
)

create table Proizvodi(
	ProizvodID int primary key not null,
	Sifra nvarchar(25) unique not null,
	Naziv nvarchar(50) not null,
	Kategorija nvarchar(50) not null,
	Cijena decimal not null
)

create procedure proc_Unos(
	@ProizvodID int,
	@Sifra nvarchar(25),
	@Naziv nvarchar(50),
	@Kategorija nvarchar(50),
	@Cijena decimal
)
as
begin
	insert into Proizvodi(ProizvodID,Sifra,Naziv,Kategorija,Cijena)
	values(@ProizvodID,@Sifra,@Naziv,@Kategorija,@Cijena)
end

exec proc_Unos 123,'ksndns','zovese','u kateogirij',12.5

select *
from Proizvodi as p
where p.Sifra like '%ksndns%'
create table Narudzbe(
	NarudzbaID int primary key not null,
	BrojNarudzbe nvarchar(25) unique not null,
	Datum date not null,
	Ukupno decimal not null
)
ALTER table Proizvodi
add unique (Sifra)

create table StavkeNarudzbe(
	ProizvodID int,
	NarudzbaID int,
	Kolicina int not null,
	Cijena decimal not null,
	Popust decimal not null,
	Iznos decimal not null,
	constraint FK_ProizvodID foreign key (ProizvodID) references Proizvodi(ProizvodID),
	constraint FK_NaruzdzbaID foreign key (NarudzbaID) references Narudzbe(NarudzbaID),
	constraint Proizvod_NarudzbaID primary key (ProizvodID,NarudzbaID)
	)


insert into Narudzbe
select s.SalesOrderID,s.SalesOrderNumber,s.OrderDate,s.TotalDue
from AdventureWorks2014.Sales.SalesOrderHeader as s
where Year(s.OrderDate) = 2014


insert into Proizvodi
select pro.ProductID,pro.ProductNumber, pro.Name,  sab.Name, convert(decimal(10,2),pro.ListPrice)
from AdventureWorks2014.Production.Product as pro join AdventureWorks2014.Production.ProductSubcategory as sab 
on pro.ProductSubcategoryID =sab.ProductSubcategoryID
where Year(pro.ModifiedDate) = 2014

INSERT INTO StavkeNarudzbe
SELECT 
(SELECT TOP 1 P.ProizvodID
FROM Proizvodi AS P
WHERE SOD.ProductID = P.ProizvodID), 
(SELECT TOP 1 N.NarudzbaID
FROM Narudzbe AS N
WHERE SOH.SalesOrderID = N.NarudzbaID), 
SOD.OrderQty, SOD.UnitPrice, SOD.UnitPriceDiscount, SOD.LineTotal
FROM AdventureWorks2014.Sales.SalesOrderDetail AS SOD JOIN AdventureWorks2014.Sales.SalesOrderHeader AS SOH
	ON SOD.SalesOrderID = SOH.SalesOrderID
WHERE YEAR(SOH.OrderDate) = 2014

create table Skladista(
	SkladisteID int identity(1,1) primary key not null,
	Naziv nvarchar(30) not null
)


create table Skladista_Proizvod(
	SkladisteID int default null,
	ProizvodID int  default null,
	Kolicina int not null,
	constraint PK_Skladiste_Proizvod Primary key (SkladisteID,ProizvodID),
	constraint FK_SkladisteID foreign key (SkladisteID) references Skladista(SkladisteID),
	constraint FK_ProizvodID_ foreign key (ProizvodID) references Proizvodi(ProizvodID)
)

INSERT INTO Skladista
VALUES('SkladisteKonjic'),
('SkladisteSarajevo'),
('SkladisteMostar')

insert into Skladista_Proizvod
select (SELECT TOP 1 s.SkladisteID FROM Skladista as s TABLESAMPLE (295 ROWS)),p.ProizvodID, 0
from Proizvodi as p

delete from Skladista_Proizvod

SELECT column FROM table
ORDER BY RAND()
LIMIT 1

create NONCLUSTERED  index Index_P on Proizvodi(Sifra,Naziv)

SElect p.ProizvodID, p.Sifra, P.Naziv
from Proizvodi as p
where p.Naziv like 'P%'

create view Pregled
as
select  p.Sifra,p.Naziv,P.Cijena,sum(s.Kolicina) as 'Ukupna prodana kolicina',sum(s.Cijena*s.Kolicina*(1-s.Popust)) as 'Ukupna zarada'
from Proizvodi as p join StavkeNarudzbe as s on p.ProizvodID = s.ProizvodID join Narudzbe as n on s.NarudzbaID=n.NarudzbaID
group by p.Sifra,p.Naziv,p.Cijena

alter procedure upd_p(
	@ProizvodID int,
	@NarudzbaID int,
	@Kolicina int
)
as 
begin
	update StavkeNarudzbe
	set  Kolicina=@Kolicina
	WHERE ProizvodID=@ProizvodID and NarudzbaID=@NarudzbaID
end
select * from  Narudzbe
exec upd_p 680,63374,5