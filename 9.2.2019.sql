create database [9.2.2019]
use [9.2.2019]

create table Zaposlenici(
	ZaposlenikID int primary key,
	Ime nvarchar(30) not null,
	Prezime nvarchar(30) not null,
	Spol nvarchar(10) not null,
	JMBG nvarchar(13) not null,
	DatumRodjenja date not null default(getDate()),
	Adresa nvarchar(100) not null,
	Email nvarchar(100) not null unique,
	KorisnickoIme nvarchar(60),
	Lozinka nvarchar(30) not null
)

create table Artikli(
	ArtikalID int primary key,
	Naziv nvarchar(50) not null,
	Cijena decimal not null,
	StanjeNaSkladistu int not null
)

create table Prodaja(
	ArtikalID int not null constraint fk_ArtikalID foreign key references Artikli(ArtikalID),
	ZaposlenikID int not null constraint fk_ZaposlenikID foreign key references Zaposlenici(ZaposlenikID),
	Datum date not null default(getDate()),
	Kolicina decimal not null
)

alter table Prodaja
add constraint pk_ar_zapID primary key (ArtikalID,ZaposlenikID,Datum)

insert into Zaposlenici
select e.EmployeeID,e.FirstName,e.LastName,e.TitleOfCourtesy,convert(nvarchar(4),day(e.BirthDate))+convert(nvarchar(4),MONTH(e.BirthDate))+convert(nvarchar(4),year(e.BirthDate)) as 'JMBG',
e.BirthDate,e.Country+','+e.City+','+e.Address as'Adresa',e.FirstName+'['+right(year(e.BirthDate),2)+']@poslovna.ba' as 'Email',
upper(e.FirstName)+'.'+UPPER(e.LastName) as 'Korisnicko ime',reverse(replace(left(right(CONVERT(nvarchar(1000),e.Notes),LEN(CONVERT(nvarchar(1000),e.Notes))-15),6)+
left(e.Extension,2)+' '+convert(nvarchar(10),DATEDIFF(day,e.BirthDate,e.HireDate)),' ','#')) as 'Lozinka'
from NORTHWND.dbo.Employees as e
where DATEDIFF(year,e.BirthDate,GetDate()) > 60

insert into Artikli
select distinct p.ProductID,p.ProductName,p.UnitPrice,p.UnitsInStock
from NORTHWND.dbo.Products as p join NORTHWND.dbo.[Order Details] as od on p.ProductID=od.ProductID join
NORTHWND.dbo.Orders as o on od.OrderID=o.OrderID
where year(o.OrderDate) = 1997 and (MONTH(o.OrderDate)=8 or MONTH(o.OrderDate)=9)
order by 2 asc


insert into Prodaja
select distinct od.ProductID,o.EmployeeID,o.OrderDate,od.Quantity
from NORTHWND.dbo.Employees as e join NORTHWND.dbo.Orders as o on e.EmployeeID=o.EmployeeID join NORTHWND.dbo.[Order Details] as od on
o.OrderID=od.OrderID join NORTHWND.dbo.Products as p on od.ProductID=p.ProductID
where (year(o.OrderDate) = 1997 and (MONTH(o.OrderDate)=8 or MONTH(o.OrderDate)=9)) and DATEDIFF(year,e.BirthDate,GetDate()) > 60

alter table Zaposlenici
alter column Adresa nvarchar(100) null

alter table Artikli
add Kategorija nvarchar(50)


update Artikli
set Kategorija = 'Hrana'
where ArtikalID%3=0

update Zaposlenici
set DatumRodjenja=DATEADD(year,-2,DatumRodjenja)
where Spol='Ms.'

update Zaposlenici
set KorisnickoIme=LOWER(Ime)+'_'+'['+substring(CONVERT(nvarchar(4),year(DatumRodjenja)),2,2)+']'+'_'+LOWER(Prezime)

select * from Zaposlenici


select a.Naziv,a.StanjeNaSkladistu,sum(p.Kolicina) as 'Naruceno',sum(p.Kolicina)-a.StanjeNaSkladistu as 'Potrebno naruciti'
from Zaposlenici as z join Prodaja as p on z.ZaposlenikID=p.ZaposlenikID join Artikli as a on p.ArtikalID=a.ArtikalID
group by a.Naziv,a.StanjeNaSkladistu
having sum(p.Kolicina)>a.StanjeNaSkladistu

select z.Ime+z.Prezime as 'Ime i prezime',a.Naziv,isnull(a.Kategorija,'N/A'),round(sum(p.Kolicina),1,2) as 'Ukupna prodana kolicina',round(sum(a.Cijena*p.Kolicina),1,2) as 'Ukupna zarada'
from Zaposlenici as z join Prodaja as p on z.ZaposlenikID=p.ZaposlenikID join Artikli as a on p.ArtikalID=a.ArtikalID
group by z.Ime+z.Prezime,a.Naziv,a.Kategorija


select z.Ime+z.Prezime as 'Ime i prezime',a.Naziv,isnull(a.Kategorija,'N/A'),round(sum(p.Kolicina),1,2) as 'Ukupna prodana kolicina',round(sum(a.Cijena*p.Kolicina),1,2) as 'Ukupna zarada',
p.Datum
from Zaposlenici as z join Prodaja as p on z.ZaposlenikID=p.ZaposlenikID join Artikli as a on p.ArtikalID=a.ArtikalID
where z.Spol='Ms.' and (a.Naziv like 'C%' or a.Naziv like 'G%') and (CONVERT(nvarchar(20),p.Datum) = '1997-08-22' or CONVERT(nvarchar(20),p.Datum) = '1997-09-22')
and a.Kategorija is not null
group by z.Ime+z.Prezime,a.Naziv,a.Kategorija,p.Datum


delete Zaposlenici
where 