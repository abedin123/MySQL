create database [BP2.Ispit.07.09.2017.Integralni] on(
	name='data[BP2.Ispit.07.09.2017',
	filename='D:\BP2\Data\dataproba.mdf',
	size= 5MB,
	maxsize=10MB,
	filegrowth=20%
)
log on(
	name='log[BP2.Ispit.07.09.2017',
	filename='D:\BP2\Log\logproba.ldf',
	size= 5MB,
	maxsize=10MB,
	filegrowth=20%
)
use [BP2.Ispit.07.09.2017.Integralni]
create table Klijenti(
	KlijentID int identity(1,1) primary key,
	Ime nvarchar(50) not null,
	Prezime nvarchar(50) not null,
	Grad nvarchar(50) not null,
	Telefon nvarchar(50) not null,
	Email nvarchar(50) not null
)

create table Racuni(
	RacunID int identity(1,1) primary key,
	DatumOtvaranja date not null,
	TipRacuna  nvarchar(50) not null,
	BrojRacuna  nvarchar(16) not null,
	Stanje decimal not null,
	KlijentID int not null constraint fk_KlijentID foreign key references Klijenti(KlijentID)
)
drop table Transakcije

create table Transakcije(
	TransakcijaID int identity(1,1) primary key,
	Datum date not null,
	Primatelj nvarchar(50) not null,
	BrojRacunaPrimatelja nvarchar(16) not null,
    MjestoPrimatelja nvarchar(50) not null,
	AdresaPrimatelja nvarchar(50) null,
	Svrha nvarchar(200)  null,
	Iznos decimal not null,
	RacunID int not null constraint fk_racunid foreign key references Racuni(RacunID)
)
drop table Transakcije
alter table Klijenti
add constraint unq_email unique(Email)

alter table Racuni 
add constraint unq_brojracuna unique(BrojRacuna)

create procedure unesi_racun(
	@DatumOtvaranja date,
	@TipRacuna  nvarchar(50),
	@BrojRacuna  nvarchar(16),
	@Stanje decimal,
	@KlijentID int
)
as
begin
	insert into Racuni
	values(@DatumOtvaranja,@TipRacuna,@BrojRacuna,@Stanje,@KlijentID)
end

select * from Klijenti
insert into Klijenti
values('Faris','Gogic','Konjic','061602460','anskdn@email.com')

exec unesi_racun '9/1/2019','Transferni','82818ASMBA',28.9,1

insert into Klijenti
select distinct left(c.ContactName,CHARINDEX(' ',c.ContactName)) as 'Ime',right(c.ContactName,len(c.ContactName)-CHARINDEX(' ',c.ContactName)) as 'Prezime',c.City,
replace(c.ContactName,' ','.')+'@northwind.ba' as 'Email',c.Phone
from NORTHWND.dbo.Customers as c join NORTHWND.dbo.Orders as o on c.CustomerID=o.CustomerID
where year(o.RequiredDate) =1996

exec unesi_racun '9/1/2019','Transferni','82818AuMBA',23.9,1
exec unesi_racun '9/1/2019','Transferni','8281AAMBA',22.9,1
exec unesi_racun '9/1/2019','Transferni','828SSoMBA',21.9,3
exec unesi_racun '9/1/2019','Transferni','8281SSASMBA',98.9,3
exec unesi_racun '9/1/2019','Transferni','8118ASMBA',88.9,4
exec unesi_racun '9/1/2019','Transferni','825818ASMBA',78.9,6
exec unesi_racun '9/1/2019','Transferni','810118ASMBA',68.9,6
exec unesi_racun '9/1/2019','Transferni','82998ASMBA',58.9,4
exec unesi_racun '9/1/2019','Transferni','82228ASMBA',48.9,7
exec unesi_racun '9/1/2019','Transferni','83338ASMBA',31.9,7

select * from Racuni
select * from Klijenti where Klijenti.Grad = 'Madrid'


insert into Transakcije
select top 10 o.OrderDate,o.ShipName,'00000'+convert(nvarchar(30),o.OrderID+ convert(int,'00000123456')) as 'Broj racuna',o.ShipCity,o.ShipAddress,null as 'Svrha',
od.UnitPrice,12 as 'RacunID'
from NORTHWND.dbo.Orders as o join NORTHWND.dbo.[Order Details] as od on o.OrderID=od.OrderID
order by newid()


update Racuni
set Stanje= Stanje+500
where Racuni.KlijentID IN (select k.KlijentID from Klijenti as k join Racuni as r on k.KlijentID=r.KlijentID where k.Grad='Madrid' and MONTH(r.DatumOtvaranja)=9 )


CREATE view pogled
as
select k.Ime+k.Prezime as 'Ime i prezime',k.Grad,k.Email,k.Telefon,r.TipRacuna,r.BrojRacuna,r.Stanje,t.BrojRacunaPrimatelja,t.Iznos
from Klijenti as k  left join Racuni as r on k.KlijentID=r.KlijentID left join Transakcije as t on r.RacunID=t.RacunID

select * from pogled

alter procedure procaa(
	@BrojRacuna  nvarchar(16) =  null
)
as
begin
	select isnull(p.[Ime i prezime],'N/A'),ISNULL(p.Grad,'N/A'),ISNULL(p.Telefon,'N/A'),ISNULL(p.BrojRacuna,'N/A'),
	ISNULL(CONVERT(nvarchar(6),p.Stanje),'N/A'),isnull(convert(nvarchar(6),sum(p.Iznos)),'N/A') as 'Ukupan iznos sa racuna'
	from pogled as p
	where @BrojRacuna = p.BrojRacuna or @BrojRacuna is null
	group by p.[Ime i prezime],p.Grad,p.Telefon,p.BrojRacuna,p.Stanje
end

exec procaa '82818ASMBA'

alter procedure brisi(
	@KlijentID int 
)
as
begin
	delete Transakcije
	where RacunID IN (select t.RacunID from Klijenti as k join Racuni as r on k.KlijentID=r.KlijentID join Transakcije as t on r.RacunID=t.RacunID
	where k.KlijentID=@KlijentID)
	delete Racuni
	where @KlijentID = KlijentID
	delete Klijenti
	where KlijentID=@KlijentID
end

select * from Transakcije

exec brisi 4

select * from Racuni

select * from Klijenti


create procedure uvecaj(
	@Grad nvarchar(20),
	@Mjesec int,
	@IznosUvecanja decimal
)
as
begin
	update Racuni
	set Stanje= Stanje+@IznosUvecanja
	where Racuni.KlijentID IN (select k.KlijentID from Klijenti as k join Racuni as r on k.KlijentID=r.KlijentID where k.Grad=@Grad and MONTH(r.DatumOtvaranja)=@Mjesec )
end

exec uvecaj 'Toulouse',9,25.9

backup database [BP2.Ispit.07.09.2017.Integralni]
to disk = 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLA\MSSQL\Backup\pit.07.09.2017.Integralni]full.bak'

backup database [BP2.Ispit.07.09.2017.Integralni]
to disk = 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLA\MSSQL\Backup\pit.07.09.2017.Integralni]dif.bak'
with differential