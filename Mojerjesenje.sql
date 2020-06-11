
create database IB170058 ON (
	name='db_IB170058_data',
	filename='D:\BP2\Data\IB170058.mdf',
	size= 100MB,
	maxsize=500MB,
	filegrowth=20%
)
log on
(
	name='db_IB170058_log',
	filename='D:\BP2\Log\IB170058.ldf',
	size= 100MB,
	maxsize=500MB,
	filegrowth=20%
)


CREATE table Narudzba(
	NarudzbaID int primary key not null,
	Kupac nvarchar(40),
	PunaAdresa nvarchar(80),
	DatumNarudzbe date,
	Prevoz money,
	Uposlenik nvarchar(40),
	GradUposlenika nvarchar(30),
	DatumZaposlenja date,
	BrGodStaza int
)

--Verzija SQL-a
select @@version

--Sve baze koje postoje u SQL-u
SELECT * FROM sys.databases

--Lokacije gdje se nalaze fajlovi baze koju trenutno koristimo
SELECT * FROM sys.database_files

--Tabele baze koja je na use
SELECT *
FROM sys.tables


--Kolone baze koja je na use
SELECT *
FROM sys.columns
where object_id=1061578820




create table Proizvod(
	ProizvodID int primary key,
	NazivProizvoda nvarchar(40),
	NazivDobavljaca nvarchar(40),
	StanjeNaSklad int,
	NarucenaKol int
)

create table DetaljiNarudzbe(
	NarudzbaID int not null,
	ProizvodID int not null,
	CijenaProizvoda money,
	Kolicna int not null,
	Popust real,
	constraint fk_NarudzbaID foreign key (NarudzbaID) references Narudzba(NarudzbaID),
	constraint fk_ProizvodID foreign key (ProizvodID) references Proizvod(ProizvodID),
	constraint PK_Nar_PrID primary key (NarudzbaID,ProizvodID)
)

Insert into Narudzba
select o.OrderID, c.CompanyName, c.Address+'-'+c.PostalCode+'-'+c.City as 'Puna adresa',
o.OrderDate,o.Freight,e.FirstName+' '+e.LastName as Uposlenik,e.City,e.HireDate,
DATEDIFF(YEAR,e.HireDate,GETDATE()) AS 'Broj godina od zaposlenja'
from NORTHWND.dbo.Customers as c join NORTHWND.dbo.Orders as o on c.CustomerID=o.CustomerID 
join NORTHWND.dbo.Employees as e on o.EmployeeID=e.EmployeeID

Insert into Proizvod
select P.ProductID,p.ProductName,s.CompanyName,p.UnitsInStock,p.UnitsOnOrder
from NORTHWND.dbo.Suppliers as s join NORTHWND.dbo.Products as p on s.SupplierID=p.SupplierID


insert into DetaljiNarudzbe
select od.OrderID, od.ProductID,ROUND(od.UnitPrice,0,1) as CijenaProizvoda,od.Quantity,od.Discount
from NORTHWND.dbo.[Order Details] as od


alter table Narudzba
add SifraUposlenika nvarchar(20) CHECK (len (SifraUposlenika) =15 )

update Narudzba
set SifraUposlenika = left(reverse(GradUposlenika+' '+left(convert(nvarchar(10),DatumZaposlenja,104),10)),15)


update Narudzba
set SifraUposlenika = left((Select NEWID()),20)
where GradUposlenika like '%d'
select * from Narudzba


alter VIEW vwNarDetT
as
select n.Uposlenik,n.SifraUposlenika,count(p.NazivProizvoda) as 'Broj prozivoda'
from Narudzba as n join DetaljiNarudzbe as d on n.NarudzbaID=d.NarudzbaID join Proizvod as p on d.ProizvodID=p.ProizvodID
where len(n.SifraUposlenika)=20 
group by n.Uposlenik,n.SifraUposlenika
having count(p.NazivProizvoda) > 2

select * from vwNarDetT
order by 3 desc




alter procedure smanji_Sifru
as
begin
	update Narudzba
	set SifraUposlenika = left(newID(),4)
end

exec smanji_Sifru 
create view nekPog
as
select p.NazivProizvoda,round(sum(d.Kolicna*(d.CijenaProizvoda*(1-d.Popust))),2) as 'Cijena sa popustom'
from Narudzba as n join DetaljiNarudzbe as d on n.NarudzbaID=d.NarudzbaID join Proizvod as p on d.ProizvodID=p.ProizvodID
where p.NarucenaKol>0
group by p.NazivProizvoda
having sum(d.Kolicna*(d.CijenaProizvoda*(1-d.Popust))) > 10000

select * from nekPog
order by 2 desc



create view pog
as
select n.Kupac,p.NazivProizvoda,sum(d.CijenaProizvoda) as Cijena
from Proizvod as p join DetaljiNarudzbe as d on p.ProizvodID=d.ProizvodID join Narudzba as n on d.NarudzbaID=n.NarudzbaID
where d.CijenaProizvoda > (select avg(d.CijenaProizvoda)
							from Proizvod as p join DetaljiNarudzbe as d on p.ProizvodID=d.ProizvodID)
group by n.Kupac,p.NazivProizvoda

select * from pog
order by 3 

CREATE PROCEDURE sp_sr_vrij_cijene 
(
	@Kupac NVARCHAR (40) = NULL,
	@NazivProizvoda NVARCHAR (40) = NULL,
	@SumaPoCijeni MONEY = NULL
)
AS
BEGIN
	SELECT Kupac, NazivProizvoda, Cijena 
	FROM pog
	WHERE	Cijena > (SELECT AVG (Cijena) FROM pog) AND 
			Kupac = @Kupac OR
			NazivProizvoda = @NazivProizvoda OR
			Cijena = @SumaPoCijeni
	ORDER BY 3
END

exec sp_sr_vrij_cijene @SumaPoCijeni=123
exec sp_sr_vrij_cijene @Kupac='Hanari Carnes'
exec sp_sr_vrij_cijene @NazivProizvoda='Côte de Blaye'



create nonclustered index ind on Proizvod(NazivDobavljaca) include (StanjeNaSklad,NarucenaKol)


alter index ind
on Proizvod disable


backup database IB170058 
to disk='C:\Program Files\Microsoft SQL Server\MSSQL14.SQLA\MSSQL\Backup\ib170058.bak'


create procedure Brisanje
as
begin
	drop view vwNarDetT;
	drop procedure smanji_Sifru;
	drop view nekPog;
	drop view pog;
	drop procedure sp_sr_vrij_cijene
end

exec Brisanje





-1

--Check default location od DATA and LOG files on SQL Server instance
USE master
GO
SELECT
  SERVERPROPERTY('InstanceDefaultDataPath') AS 'Data Files',
  SERVERPROPERTY('InstanceDefaultLogPath') AS 'Log Files'

--Podaci o data i log fajlovima na nivou servera
USE master;
SELECT  *
FROM sys.master_files;

--2
-- SQL Server version
SELECT @@VERSION
GO

--Lokacija trenutne baze u use mdf i log fajlovi mjesto njihovo
USE Prodaja
GO
SELECT * FROM sys.database_files

--3
--Sve table iz baze koja je na use
SELECT *
FROM sys.tables

--Sve kolone vezane za tu bazu ili ako object_id stavimo onda samo za taj objekat kolone odnosno za tu tabelu
SELECT *
FROM sys.columns
WHERE object_id = 901578250



--Sve baze na tvom sql
SELECT * FROM sys.databases