create database [BP2.Ispit.25.09.2017] on (
	name='BP2.Ispit.25.09.2017data',
	filename='D:\BP2\Data\BP2.Ispit.25.09.2017data.mdf',
	size=10mb,
	maxsize=20mb,
	filegrowth=5%
)
log on(
	name='BP2.Ispit.25.09.2017log',
	filename='D:\BP2\Log\BP2.Ispit.25.09.2017log.ldf',
	size=10mb,
	maxsize=20mb,
	filegrowth=5%
)

use [BP2.Ispit.25.09.2017]

create table Klijenti(
	KlijentID int identity(1,1) primary key,
	Ime nvarchar(50) not null,
	Prezime nvarchar(50) not null,
	Drzava nvarchar(50) not null,
	Grad nvarchar(50) not null,
	Email nvarchar(50) not null,
    Telefon nvarchar(50) not null
)

create table Izleti(
	IzletID int identity(1,1) primary key,
	Sifra nvarchar(10) not null,
	Naziv nvarchar(100) not null,
	DatumPolaska date not null,
	DatumPovratka date not null,
	Cijena decimal not null,
	Opis text null
)


create table Prijave(
	KlijentID int not null constraint fk_KlijentID foreign key references Klijenti(KlijentID),
	IzletID int not null constraint fk_IzletID foreign key references Izleti(IzletID),
	constraint pk_klizID primary key (KlijentID,IzletID),
	Datum datetime not null,
	BrojOdraslih int not null,
	BrojDjece int not null
)
delete Klijenti
delete Prijave
insert into Klijenti
select distinct p.FirstName,p.LastName,cr.Name,a.City,e.EmailAddress,ph.PhoneNumber
from AdventureWorks2014.Sales.Customer as c join AdventureWorks2014.Person.Person as p on c.PersonID=p.BusinessEntityID join
AdventureWorks2014.Person.BusinessEntity as be on p.BusinessEntityID=be.BusinessEntityID join AdventureWorks2014.Person.BusinessEntityAddress as ba
on be.BusinessEntityID=ba.BusinessEntityID join AdventureWorks2014.Person.Address as a on ba.AddressID=a.AddressID join
AdventureWorks2014.Person.StateProvince as st on a.StateProvinceID=st.StateProvinceID join AdventureWorks2014.Person.CountryRegion as cr
on st.CountryRegionCode=cr.CountryRegionCode join AdventureWorks2014.Person.EmailAddress as e on p.BusinessEntityID=e.BusinessEntityID
join AdventureWorks2014.Person.PersonPhone as ph on p.BusinessEntityID=ph.BusinessEntityID


insert into Izleti
values('Prva sifra','Mostar-Sarajevo','9/4/2019','12/4/2019',215.40,'Dobar izlet'),
('Drug sifra','Mostar-Konjic','4/15/2019','4/20/2019',300.40,'Dobar izlet'),
('Trec sifra','Konjic-Sarajevo','4/20/2019','4/24/2019',345.40,'Dobar izlet')

create procedure insert_Prijave(
	@KlijentID int,
	@IzletID int,
	@BrojOdraslih int,
	@BrojDjece int
)
as
begin
	insert into Prijave
	values(@KlijentID,@IzletID,getDate(),@BrojOdraslih,@BrojDjece)
end
select * from Klijenti
exec insert_Prijave 1,20,1,2
exec insert_Prijave 1,21,2,1
exec insert_Prijave 18,21,4,0
exec insert_Prijave 2,21,1,10
exec insert_Prijave 2,20,1,3
exec insert_Prijave 7,21,8,8
exec insert_Prijave 3,21,8,3
exec insert_Prijave 3,20,5,3
exec insert_Prijave 4,21,7,2
exec insert_Prijave 5,21,6,2

alter table Klijenti
add constraint unq_Em unique(Email)

select * from Klijenti order by Email

delete Klijenti
where KlijentID=28093

create type TabelinID
from int not null
create table Tabela(
	TabelaID TabelinID primary key constraint pk_tabID foreign key references Klijenti(KlijentID)
)


create table #temp(
	KlijentID int,
	Ime nvarchar(50) not null,
	Prezime nvarchar(50) not null,
	Drzava nvarchar(50) not null,
	Grad nvarchar(50) not null,
	Email nvarchar(50) not null,
    Telefon nvarchar(50) not null
)
alter TRIGGER bris
    ON Klijenti
    after DELETE
    AS
    BEGIN
	insert into #temp
	select *
	from deleted as d
    END

select * from Klijenti

delete Klijenti
where KlijentID=18510

select * from #t