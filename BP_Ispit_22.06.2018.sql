create database [BP_Ispit_22.06.2018] on(
	name = 'BP_Ispit_22.06.2018',
	filename = 'D:\BP2\Data\BP_Ispit_22.06.2018.mdf',
	size = 10MB,
	maxsize =  unlimited,
	filegrowth = 5%
)
log on(
	name = 'BP_Ispit_22.06.2018ldf',
	filename = 'D:\BP2\Log\BP_Ispit_22.06.2018.ldf',
	size = 10MB,
	maxsize =  unlimited,
	filegrowth = 5%
)
use [BP_Ispit_22.06.2018]
create table Otkupljivaci(
	OtkupljivacID int primary key,
	Ime nvarchar(50) not null,
	Prezime nvarchar(50) not null,
	DatumRodjenja date not null default(sysdatetime()),
	JMBG nvarchar(13) not null,
	Spol nvarchar(1) not null,
	Grad nvarchar(50) not null,
	Adresa nvarchar(100) not null,
	Email nvarchar(100) not null unique,
	Aktivan bit not null default(1)
)
drop table Proizvodi
drop table OtkupProizvoda

create table Proizvodi(
	ProizvodID int primary key,
	Naziv nvarchar(50) not null,
	Sorta nvarchar(50) not null,
	OtkupnaCijena decimal not null,
	Opis text
)

create table OtkupProizvoda(
	Datum date not null default(getDate()),
	OtkupljivacID int not null constraint fk_OtkupljivacID references Otkupljivaci(OtkupljivacID),
	ProizvodID int not null constraint fk_ProizvodID references Proizvodi(ProizvodID),
	constraint fk_otkprID primary key(OtkupljivacID,ProizvodID,Datum),
	Kolicina decimal not null,
	BrojGajbica int not null
)

insert into Otkupljivaci
select top 5 e.EmployeeID,e.FirstName,e.LastName,e.BirthDate, convert(nvarchar(20),reverse(year(e.BirthDate))+convert(nvarchar(2),day(e.BirthDate))
+convert(nvarchar(2),month(e.BirthDate))+right(e.HomePhone,4)) as 'JMBG',CAST(case when e.TitleOfCourtesy = 'Ms.' then 'Z' else 'M' end as nvarchar) 
as 'Spol',e.City,replace(e.Address,' ','_') as 'Adress',e.FirstName+'_'+e.LastName+'@edu.fit.ba' as 'Email',1 as 'Aktivan'
from NORTHWND.dbo.Employees as e
order by 3 desc


insert into Proizvodi
select p.ProductID,p.ProductName,c.CategoryName,p.UnitPrice,c.Description
from NORTHWND.dbo.Products as p join NORTHWND.dbo.Categories as c on p.CategoryID=c.CategoryID


insert into OtkupProizvoda
select o.OrderDate,o.EmployeeID,od.ProductID,sum(od.Quantity*8) as 'Kolicina',sum(od.Quantity)
from NORTHWND.dbo.[Order Details] as od join NORTHWND.dbo.Orders as o on od.OrderID=o.OrderID
where o.EmployeeID in (select o.OtkupljivacID from Otkupljivaci as o)
group by o.OrderDate,o.EmployeeID,od.ProductID


alter table Otkupljivaci
alter column Adresa nvarchar(100) null

alter table Proizvodi
add TipProizvoda  nvarchar(50) 

update Proizvodi
set TipProizvoda='Voće'
where ProizvodID%2=0

update Otkupljivaci
set Aktivan=0
where Grad <> 'London'  and year(DatumRodjenja) >= 1960


update Proizvodi
set OtkupnaCijena = OtkupnaCijena+5.45
where CHARINDEX('/',Sorta)>0 or LEFT(Sorta,1)='/'

 
select o.Ime+' '+o.Prezime,p.Naziv,sum(op.Kolicina),sum(op.BrojGajbica)
from Otkupljivaci as o join OtkupProizvoda as op on o.OtkupljivacID=op.OtkupljivacID join Proizvodi as p on p.ProizvodID=op.ProizvodID
group by o.Ime+' '+o.Prezime,p.Naziv

select p.Naziv,convert(decimal(8,2),sum(op.Kolicina)) as 'Kolicina',convert(decimal(8,2),p.OtkupnaCijena*op.Kolicina) as 'Zarada'
from Otkupljivaci as o join OtkupProizvoda as op on o.OtkupljivacID=op.OtkupljivacID join Proizvodi as p on p.ProizvodID=op.ProizvodID
where op.Datum > convert(date,'24/12/1996',104) and op.Datum < convert(date,'16/08/1997',104)  
group by p.Naziv,p.OtkupnaCijena*op.Kolicina
having sum(op.Kolicina) >= 1000
order by p.OtkupnaCijena*op.Kolicina desc

