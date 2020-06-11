create database [index] on(
	name='db_index_data',
	filename='D:\BP2\Data\db_index_data.mdf',
	size=100MB,
	maxsize=500MB,
	filegrowth=20%
)
log on(
	name='db_index_log',
	filename='D:\BP2\Data\db_index_data.ldf',
	size=100MB,
	maxsize=500MB,
	filegrowth=20%
)

use [index]

create table Autori(
	AutorID nvarchar(11) primary key,
	Prezime nvarchar(25) not null,
	Ime nvarchar(25) not null,
	Telefon nvarchar(20) default(null),
	DatumKeiranjaZapisa date not null default(getDate()),
	DatumModifikovanjaZapisa date default(null)
)

create table Izdavaci(
	IzdavacID nvarchar(4) primary key,
	Naziv nvarchar(100) not null unique,
	Biljeske ntext default('Lorem ipsum'),
	DatumKreiranjaZapisa date not null default(getDate()),
	DatumModifikovanjaZapisa date default(null)
)

create table Naslovi(
	NaslovID nvarchar(6) primary key,
	IzdavacID nvarchar(4),
	Naslov nvarchar(100) not null,
	Cijena money,
	DatumIzdavanja date not null default(getDate()),
	DatumKreiranjaZapisa date not null default(getDate()),
	DatumModifikovanjaZapisa date default(null),
	constraint FK_IzdavacID foreign key (IzdavacID) references Izdavaci(IzdavacID)
)

create table NasloviAutori(
	AutorID nvarchar(11) not null,
	NaslovID nvarchar(6) not null,
	DatumKreiranjaZapisa date not null default(getDate()),
	DatumModifikovanjaZapisa date default(null)
)

alter table NasloviAutori
add constraint fk_AutorID foreign key (AutorID) references Autori(AutorID),
constraint fk_NaslovID foreign key (NaslovID) references Naslovi(NaslovID),
constraint pk_NaslAutID primary key (NaslovID,AutorID) 

insert into Autori
select a.au_id,a.au_fname,a.au_lname,a.phone,getDate() as 'Datum unosa',null
from pubs.dbo.authors as a
order by newId()

insert into Izdavaci
select p.pub_id,p.pub_name,cast(i.pr_info as nvarchar(100)) as 'Biljeske',GETDATE(),null
from pubs.dbo.publishers as p join pubs.dbo.pub_info as i on p.pub_id=i.pub_id
order by newId()

insert into Naslovi
select t.title_id,t.pub_id,t.title,t.price,SYSDATETIME() as 'Datum izdavanja',SYSDATETIME() as 'Datum unosa',null
from pubs.dbo.titles as t
order by newId()

insert into NasloviAutori
select t.au_id,t.title_id,SYSDATETIME() as 'Unos zapisa',null
from pubs.dbo.titleauthor as t
order by newId()

create table Gradovi(
	GradID int identity(5,5) primary key,
	Naziv nvarchar(100) not null,
	DatumKreiranjaZapisa date not null default(getDate()),
	DatumModifikovanjaZapisa date default(null)
)

alter table Autori
add GradID int constraint fk_GradID foreign key (GradID) references Gradovi(GradID)

insert into Gradovi
select distinct a.city,SYSDATETIME() as 'Datum unosa',null
from pubs.dbo.authors as a


alter procedure Izmjeni_Grad
as
begin
	update Autori
	set GradID = (select GradID from Gradovi where Naziv = 'San Francisco')
	where AutorID in (select top 10 AutorID from Autori)
end

create procedure Izmjeni_Grad_2
as
begin
	update Autori
	set GradID = (select GradID from Gradovi where Naziv = 'Berkeley')
	where GradID is null
end
select * from Izdavaci where Naziv like '%&%'
select * from Naslovi where Naziv like '%&%'



exec Izmjeni_Grad
exec Izmjeni_Grad_2

create view pog
as
select Prezime+Ime as 'Prezime i ime',g.Naziv as 'Naziv grada',n.Naslov,n.Cijena,i.Naziv,i.Biljeske
from  Gradovi as g join Autori AS A on a.GradID=g.GradID join NasloviAutori na on a.AutorID=na.AutorID 
join Naslovi as n on na.NaslovID=n.NaslovID join Izdavaci as i on n.IzdavacID=i.IzdavacID
where (n.Cijena is not null and n.Cijena > 10) and i.Naziv like '%&%' and g.Naziv='San Francisco'


select * from pog


alter table Autori
add Email nvarchar(100) default(null)


create procedure Izmeniasn
as
begin
	update Autori
	set Email = Ime+'.'+Prezime+'@fit.ba'
	where GradID in (select g.GradID from Gradovi as g where g.Naziv = 'San Francisco')
end

select * from Autori
exec Izmenibr

create procedure Izmenibr
as
begin
	update Autori
	set Email = Prezime+'.'+Ime+'@fit.ba'
	where GradID in (select g.GradID from Gradovi as g where g.Naziv = 'Berkeley')
end


select isnull(p.Title,'N/A') as 'Title',p.LastName,p.FirstName,e.EmailAddress,phn.Name,cr.CardNumber,p.LastName+'.'+p.FirstName as 'Username',
lower(replace(left(newid(),16),'-','7')) as 'Password'
into #temp
from AdventureWorks2014.Sales.CreditCard as cr join AdventureWorks2014.Sales.PersonCreditCard  as pcr on cr.CreditCardID=pcr.CreditCardID
right join AdventureWorks2014.Person.Person as p on pcr.BusinessEntityID=p.BusinessEntityID join AdventureWorks2014.Person.PersonPhone as ph on
p.BusinessEntityID=ph.BusinessEntityID join AdventureWorks2014.Person.PhoneNumberType as phn on ph.PhoneNumberTypeID=phn.PhoneNumberTypeID
join AdventureWorks2014.Person.EmailAddress e on p.BusinessEntityID=e.BusinessEntityID
order by p.LastName,p.FirstName
drop table #temp
select * from #temp
delete from #temp
create nonclustered index ind_Pret on #temp(Username) include (LastName,FirstName)


create procedure brisi
as
begin
	delete 
	from #temp
	where CardNumber is null
end


exec brisi

backup database [index]
to disk='C:\Program Files\Microsoft SQL Server\MSSQL14.SQLA\MSSQL\Backup\index.bak'

create procedure brisisve
as
begin
	delete from NasloviAutori;
	delete from Naslovi;
	delete from Autori;
	delete from Izdavaci;
	delete from Gradovi;
end


exec brisisve

select * from NasloviAutori
select * from Naslovi
select * from Autori
select * from Izdavaci
select * from Gradovi