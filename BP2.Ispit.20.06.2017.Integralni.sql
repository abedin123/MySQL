create database [BP2.Ispit.20.06.2017.Integralni] on (
	name='[BP2.Ispit.20.06.2017.Integralni]mdf',
	filename='D:\BP2\Data\6.2017.Integral.mdf',
	size=20mb,
	maxsize=30mb,
	filegrowth=5%
)
log on(
	name='[BP2.Ispit.20.06.2017.Integralni]ldf',
	filename='D:\BP2\Log\6.2017.Integral.ldf',
	size=20mb,
	maxsize=30mb,
	filegrowth=5%
)

use [BP2.Ispit.20.06.2017.Integralni]

create table Proizvodi(
	ProizvodID int  primary key,
	Sifra nvarchar(25) unique not null,
	Naziv nvarchar(50) unique not null,
	Kategorija nvarchar(50) unique not null,
	Cijena decimal not null
)
alter table Proizvodi
drop constraint UQ__Proizvod__1785E0D74E5BD86B

create clustered index ind_siff on StavkeNarudzbe(Kolicina)
alter index ind_sif on Proizvodi disable
create table Narudzbe(
	NarudzbaID int  primary key,
	BrojNarudzbe nvarchar(25) unique not null,
	Datum date not null,
	Ukupno decimal not null
)

create table StavkeNarudzbe(
	ProizvodID int not null constraint fk_ProizvodID foreign key references Proizvodi(ProizvodID),
	NarudzbaID int not null constraint fk_NarudzbaID foreign key references Narudzbe(NarudzbaID),
	constraint pk_PrNarID primary key (ProizvodID,NarudzbaID),
	Kolicina int not null,
	Cijena decimal not null,
	Popust decimal not null,
	Iznos  decimal not null
)

insert into Proizvodi
select p.ProductID,p.ProductNumber,p.Name,pc.Name,p.ListPrice
from AdventureWorks2014.Production.Product as p join AdventureWorks2014.Production.ProductSubcategory as ps on p.ProductSubcategoryID=ps.ProductSubcategoryID
join AdventureWorks2014.Production.ProductCategory as pc on ps.ProductCategoryID=pc.ProductCategoryID 
where year(p.ModifiedDate)=2014


insert into Narudzbe
select s.SalesOrderID,s.SalesOrderNumber,s.OrderDate,s.TotalDue
from AdventureWorks2014.Sales.SalesOrderHeader as s
where year(s.ModifiedDate)=2014


insert into StavkeNarudzbe
select distinct p.ProductID,s.SalesOrderID,s.OrderQty,s.UnitPrice,s.UnitPriceDiscount,s.LineTotal
from AdventureWorks2014.Sales.SalesOrderDetail as s join AdventureWorks2014.Sales.SalesOrderHeader as sh on s.SalesOrderID=sh.SalesOrderID
join AdventureWorks2014.Sales.SpecialOfferProduct as sp on sp.ProductID=s.ProductID join AdventureWorks2014.Production.Product as p 
on sp.ProductID=p.ProductID
where year(s.ModifiedDate)=2014


create table Skladista(
	SkladisteID int identity(1,1) primary key,
	Naziv nvarchar(25) not null
)

create table SkladisteProizvod(
	SkladisteID int not null constraint fk_SkladisteID foreign key references Skladista(SkladisteID),
	ProizvodID int not null constraint fk_ProizvodsID foreign key references Proizvodi(ProizvodID),
	constraint pk_sklprid primary key (SkladisteID,ProizvodID),
	Kolicina int
)

insert into Skladista
values('Skladiste Mostar'),
('Skladiste Konjic'),
('Skladiste Sarajevo')

insert into SkladisteProizvod
select 3,p.ProizvodID,0
from Proizvodi as p


create procedure IzmjenaKolicine(
	@ProizvodID int,
	@SkladisteID int,
	@Kolicina int
)
as
begin
	update SkladisteProizvod
	set Kolicina=@Kolicina
	where ProizvodID=@ProizvodID and SkladisteID=@SkladisteID
end
	

select * from StavkeNarudzbe

exec IzmjenaKolicine 680,1,500

create nonclustered index ind_pro on Proizvodi(Sifra,Naziv)

create view pog
as
select p.Sifra,p.Naziv,p.Cijena,sum(sn.Kolicina) as 'Ukupna prodana kolicina',sum(sn.Iznos) as 'Ukupna zarada'
from Proizvodi as p join StavkeNarudzbe as sn on p.ProizvodID=sn.ProizvodID join Narudzbe as n on sn.NarudzbaID=n.NarudzbaID
group by p.Sifra,p.Naziv,p.Cijena

select * from pog


create procedure sifr(
	@Sifra nvarchar(25)= null
)
as
begin
	select p.[Ukupna prodana kolicina],p.[Ukupna zarada]
	from pog as p
	where p.Sifra=@Sifra or @Sifra is null
end

exec sifr 'LJ-0192-S'

backup database [BP2.Ispit.20.06.2017.Integralni]
to disk ='C:\Program Files\Microsoft SQL Server\MSSQL14.SQLA\MSSQL\Backup\fulo.bak'

backup database [BP2.Ispit.20.06.2017.Integralni]
to disk ='C:\Program Files\Microsoft SQL Server\MSSQL14.SQLA\MSSQL\Backup\fulodif.bak'
with differential


alter TRIGGER trig
    ON Proizvodi instead of delete
    AS
    BEGIN
		select d.Naziv 
		into #temp
		from deleted as d
    END

select * from Proizvodi
delete Proizvodi

select * from #temp