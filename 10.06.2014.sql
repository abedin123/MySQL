create database [10.06.2014]
use [10.06.2014]

create table Studenti(
	StudentID int identity(1,1) primary key,
	BrojDosijea nvarchar(10) not null unique,
	Ime nvarchar(35) not null,
	Prezime nvarchar(35) not null,
	[Godina studija] int not null,
	NacinStudiranja nvarchar(10) not null default('Redovan'),
	Email nvarchar(50) null
)

create table Nastava(
	NastavaID int identity(1,1) primary key,
	Datum datetime not null,
	Predmet nvarchar(20) not null,
	Nastavnik nvarchar(50) not null,
	Ucionica nvarchar(20) not null
)

create table Prisustvo(
	PrisustvoID int identity(1,1) primary key,
	StudentID int,
	NastavaID int
)

alter table Prisustvo
add constraint fk_StudentID  foreign key(StudentID) references Studenti(StudentiD)

alter table Prisustvo
add constraint fk_NastavaID foreign key (NastavaID) references Nastava(NastavaID)

create table Predmeti(
	PredmetID int identity(1,1) primary key not null,
	Naziv nvarchar(30) not null unique
)

alter table Nastava
drop column Predmet

alter table Nastava
add PredmetID int constraint fk_PredmetID foreign key references Predmeti(PredmetID)

insert into Predmeti
values('Programiranje'),
	('Baze podataka II'),
	('Matematika')

insert into Studenti
select top 10 left(ph.PhoneNumber,3) + left(e.EmailAddress,3) as 'Broj dosijea',p.FirstName,p.LastName,2 as 'Godina studija','Redovan' as 'Nacin studiranja',e.EmailAddress
from AdventureWorks2014.Sales.Customer as c join AdventureWorks2014.Person.Person as p on c.PersonID=p.BusinessEntityID join 
AdventureWorks2014.Person.PersonPhone as ph on p.BusinessEntityID=ph.BusinessEntityID join AdventureWorks2014.Person.EmailAddress 
as e on p.BusinessEntityID=e.BusinessEntityID


CREATE PROCEDURE  usp_Studenti_Update
    @StudentID int,
    @BrojDosijea nvarchar(10),
	@Ime nvarchar(35),
	@Prezime nvarchar(35),
	@GodinaStudija int,
	@NacinStudiranja nvarchar(10),
	@Email nvarchar(50)  
AS
    begin
		update Studenti
		set BrojDosijea=@BrojDosijea,
			Ime=@Ime,
			Prezime=@Prezime,
			[Godina studija]=@GodinaStudija,
			NacinStudiranja=@NacinStudiranja,
			Email=@Email
		where StudentID=@StudentID
	end

exec usp_Studenti_Update 4,'Ib1700','Abedin','Halilovic',3,'DL','abedinhalilovic12345@gmail.com'

alter PROCEDURE  usp_Nastava_Insert
    @NastavaID int = null,
	@StudentID int = null,
	@Datum datetime, 
	@PredmetID nvarchar(20), 
	@Nastavnik nvarchar(50),
	@Ucionica nvarchar(20) 
AS
    begin
		insert into Nastava
		values (GetDate(),@PredmetID,@Nastavnik,@Ucionica)
		
		insert into Prisustvo
		values (@NastavaID,@StudentID)
	end

select * from Nastava
select * from Studenti
select * from Prisustvo
insert into Nastava
exec usp_Nastava_Insert 5,2,'12/4/2019','Hikmet Trnka','Treca',2


create procedure usp_Prisustvo_Delete
	@NastavaID int,
	@StudentID int
as
	begin
		delete Prisustvo
		where @NastavaID=NastavaID and @StudentID=StudentID
	end

exec usp_Prisustvo_Delete 2,5

create view view_Studenti_Nastava
as
select s.BrojDosijea,s.Ime+s.Prezime as 'Ime i prezim studenta',n.Datum,n.Ucionica,n.Nastavnik,n.PredmetID
from Prisustvo as p join Nastava as n on p.NastavaID=n.NastavaID join Studenti as s on p.StudentID=s.StudentID

