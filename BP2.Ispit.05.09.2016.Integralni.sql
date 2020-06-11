create database baza on(
	name='baza_data',
	filename='F:\Bp2\Data\baza_data.mdf',
	maxsize=500MB,
	filegrowth=20%,
	size=100MB
)
log on(
	name='baza_log',
	filename='F:\Bp2\Log\baza_log.ldf',
	maxsize=500MB,
	filegrowth=20%,
	size=100MB
)

create table Klijenti(
	KlijentID int identity(1,1) primary key not null,
	Ime nvarchar(30) not null,
	Prezime nvarchar(30) not null,
	Telefon nvarchar(20) not null,
	Email nvarchar(50) not null,
	BrojRacuna nvarchar(15) not null,
	KorisnickoIme nvarchar(20) not null,
	Lozinka nvarchar(20) not null
)

drop table Klijenti

delete from Klijenti
create table Transakcije(
	TransakcijaID int identity(1,1) primary key,
	Datum datetime not null,
	TipTranskacije nvarchar(30) not null,
	PosiljalacID int not null,
	PrimalacID int not null,
	Svrha nvarchar(50) not null,
	Iznos decimal not null,
	constraint fk_PosiljalacID foreign key (PosiljalacID) references Klijenti(KlijentID),
	constraint fk_PrimalacID foreign key (PrimalacID) references Klijenti(KlijentID)
)

drop table Transakcije

insert into Klijenti(Ime,Prezime,Telefon,Email,BrojRacuna,KorisnickoIme,Lozinka)
select p.FirstName,p.LastName, phn.Name,  e.EmailAddress,c.AccountNumber,left(p.FirstName+'.'+p.LastName,20) AS 'KorIme', right(pv.PasswordHash,8) as 'pass'
from AdventureWorks2014.Person.PhoneNumberType as phn join AdventureWorks2014.Person.PersonPhone as ph on phn.PhoneNumberTypeID=ph.PhoneNumberTypeID 
join AdventureWorks2014.Person.Person as p on ph.BusinessEntityID=p.BusinessEntityID join AdventureWorks2014.Person.EmailAddress as e on p.BusinessEntityID=e.BusinessEntityID
join AdventureWorks2014.Person.Password as pv on p.BusinessEntityID=pv.BusinessEntityID join AdventureWorks2014.Sales.Customer
 as c on p.BusinessEntityID=c.PersonID

 insert into Transakcije(Datum,TipTranskacije,PosiljalacID,PrimalacID,Svrha,Iznos)
 values('4/26/2019','Voznja autom',61220,61222,'Prodaja',24.3),
('4/26/2019','Voznja autom',61216,61217,'Prodaja',24.3),
('4/27/2019','Voznja autom',61157,61163,'Prodaja',24.3),
('4/28/2019','Voznja autom',61229,61232,'Prodaja',24.3),
('4/29/2019','Voznja autom',61235,61237,'Prodaja',24.3),
('4/30/2019','Voznja autom',61245,61248,'Prodaja',24.3),
('5/26/2019','Voznja autom',61249,61255,'Prodaja',24.3),
('6/26/2019','Voznja autom',61261,61264,'Prodaja',24.3),
('7/26/2019','Voznja autom',61269,61273,'Prodaja',24.3)

 create nonclustered index indee on Klijenti(Ime,Prezime) include (Email)
 

 alter index indee on  Klijenti
 disable

 create procedure unos_Klijenta(
	@Ime nvarchar(30),
	@Prezime nvarchar(30),
	@Telefon nvarchar(20),
	@Email nvarchar(50),
	@BrojRacuna nvarchar(15),
	@KorisnickoIme nvarchar(20),
	@Lozinka nvarchar(20)
 )
 as 
 begin
	insert into Klijenti
	values(@Ime,@Prezime,@Telefon,@Email,@BrojRacuna,@KorisnickoIme,@Lozinka)
 end

 exec unos_Klijenta 'Abedin','Halilovic','061-602-460','nekiemail','askdn123','asknda','askndak'

create view pog
as
select t.Datum,t.TipTranskacije,k.Ime+k.Prezime as 'Ime posiljaoca',k.BrojRacuna as 'Broj racuna pos',k1.Ime+k1.Prezime 
as 'Ime primaoca',k1.BrojRacuna as 'Broj racuna prim',t.Svrha,t.Iznos
from Transakcije as t join Klijenti as k on t.PosiljalacID=k.KlijentID join Klijenti as k1 on t.PrimalacID=k1.KlijentID


create procedure unesibroj(
	@BrojRacuna nvarchar(15)
)
as
begin
	select * from pog
	where pog.[Broj racuna pos]=@BrojRacuna
end

exec unesibroj 'AW00029484'

select year(Datum) as 'Kalendarska godina', sum(Iznos) as 'Ukupan iznos'
from Transakcije
group by year(Datum)
order by 1 desc

create procedure izbrisi(
	@KlijentID int
)
as
begin
	delete
	from Transakcije
	where PosiljalacID=@KlijentID or PrimalacID=@KlijentID

	delete
	from Klijenti
	where KlijentID=@KlijentID
end

select * from Klijenti
select * from Transakcije

exec izbrisi 61154

alter procedure pogg(
	@BrojRacuna nvarchar(15)= null,
	@Prezime nvarchar(30)= null
)
as
begin
	select *
	from pog
	where ((pog.[Broj racuna pos]=@BrojRacuna) or @BrojRacuna is null) and 
	((@Prezime=(select Prezime from Klijenti where (Ime+Prezime)=pog.[Ime posiljaoca])) or @Prezime is null)
end
exec pogg @BrojRacuna='AW00013265'

backup database baza
to disk='C:\Program Files\Microsoft SQL Server\MSSQL14.SQLA\MSSQL\Backup\bek.bak'

backup database baza
to disk='C:\Program Files\Microsoft SQL Server\MSSQL14.SQLA\MSSQL\Backup\bekdif.bak'
with DIFFERENTIAL;