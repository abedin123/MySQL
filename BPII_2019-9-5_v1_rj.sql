/*
Napomena:

1. Prilikom  bodovanja rješenja prioritet ima razultat koji treba upit da vrati (broj zapisa, vrijednosti agregatnih funkcija...).
U slučaju da rezultat upita nije tačan, a pogled, tabela... koji su rezultat tog upita se koriste u narednim zadacima, tada se 
rješenja narednih zadataka, bez obzira na tačnost koda, ne boduju punim brojem bodova, jer ni ta rješenja ne mogu vratiti tačan 
rezultat (broj zapisa, vrijednosti agregatnih funkcija...).

2. Tokom pisanja koda obratiti posebnu pažnju na tekst zadatka i ono što se traži zadatkom. Prilikom pregleda rada pokreće se 
kod koji se nalazi u sql skripti i sve ono što nije urađeno prema zahtjevima zadatka ili je pogrešno urađeno predstavlja grešku.
 Shodno navedenom na uvidu se ne prihvata prigovor da je neki dio koda posljedica previda ("nisam vidio", "slučajno sam to napisao"...) 
*/






















/*
1.
a) Kreirati bazu pod vlastitim brojem indeksa.
*/
create database [1700588]
use [1700588]

/* 
b) Kreiranje tabela.
Prilikom kreiranja tabela voditi računa o odnosima između tabela.
I. Kreirati tabelu narudzba sljedeće strukture:
	narudzbaID, cjelobrojna varijabla, primarni ključ
	dtm_narudzbe, datumska varijabla za unos samo datuma
	dtm_isporuke, datumska varijabla za unos samo datuma
	prevoz, novčana varijabla
	klijentID, 5 unicode karaktera
	klijent_naziv, 40 unicode karaktera
	prevoznik_naziv, 40 unicode karaktera
*/
create table narudzba(
	narudzbaID int primary key,
	dtm_narudzbe date,
	dtm_isporuke date,
	prevoz money,
	klijentID nvarchar(5),
	klijent_naziv nvarchar(40),
	prevoznik_naziv nvarchar(40)
)

CREATE TRIGGER trigo
    ON narudzba_proizvod
    after DELETE
    AS
    BEGIN
    select *
	into obrisano
	from deleted
    END

	delete narudzba
	where narudzbaID=10248
select * from narudzba

create nonclustered index ind_dtm on narudzba(dtm_narudzbe) include (dtm_isporuke)
alter index ind_dtm on narudzba disable
create table neka(
	nesto nvarchar(5)
)
alter table neka
add  nestoo tip
CREATE TYPE tip
    FROM varchar(11) NOT NULL

alter table neka 
add constraint unq_pr unique(nesto)
/* 
II. Kreirati tabelu proizvod sljedeće strukture:
	- proizvodID, cjelobrojna varijabla, primarni ključ
	- mj_jedinica, 20 unicode karaktera
	- jed_cijena, novčana varijabla
	- kateg_naziv, 15 unicode karaktera
	- dobavljac_naziv, 40 unicode karaktera
	- dobavljac_web, tekstualna varijabla
*/
create table proizvod(
	proizvodID int primary key,
	mj_jedinica nvarchar(20),
	jed_cijena money,
	kateg_naziv nvarchar(15),
	dobavljac_naziv nvarchar(40),
	dobavljac_web text
)

/*
III. Kreirati tabelu narudzba_proizvod sljedeće strukture:
	- narudzbaID, cjelobrojna varijabla, obavezan unos
	- proizvodID, cjelobrojna varijabla, obavezan unos
	- uk_cijena, novčana varijabla
*/
create table narudzba_proizvod(
	narudzbaID int not null constraint fk_narudzbaid foreign key references narudzba(narudzbaID),
	proizvodID int not null constraint fk_proizvodID foreign key references proizvod(proizvodID),
	constraint pk_narprid primary key (narudzbaID,proizvodID),
	uk_cijena money
)
--10 bodova



-------------------------------------------------------------------
/*
2. Import podataka
a) Iz tabela Customers, Orders i Shipers baze Northwind importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- OrderDate -> dtm_narudzbe
	- ShippedDate -> dtm_isporuke
	- Freight -> prevoz
	- CustomerID -> klijentID
	- CompanyName -> klijent_naziv
	- CompanyName -> prevoznik_naziv
*/
insert into narudzba
select o.OrderID,o.OrderDate,o.ShippedDate,o.Freight,c.CustomerID,c.CompanyName,s.CompanyName
from NORTHWND.dbo.Customers as c join NORTHWND.dbo.Orders as o on o.CustomerID=c.CustomerID join NORTHWND.dbo.Shippers as s on
s.ShipperID=o.ShipVia
--830

/*
b) Iz tabela Categories, Product i Suppliers baze Northwind importovati podatke prema pravilu:
	- ProductID -> proizvodID
	- QuantityPerUnit -> mj_jedinica
	- UnitPrice -> jed_cijena
	- CategoryName -> kateg_naziv
	- CompanyName -> dobavljac_naziv
	- HomePage -> dobavljac_web
*/
insert into proizvod
select p.ProductID,p.QuantityPerUnit,p.UnitPrice,c.CategoryName,s.CompanyName,s.HomePage
from NORTHWND.dbo.Categories as c join NORTHWND.dbo.Products AS p on c.CategoryID=p.CategoryID join
NORTHWND.dbo.Suppliers as s on p.SupplierID=s.SupplierID
--77

/*
c) Iz tabele Order Details baze Northwind importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- ProductID -> proizvodID
	- uk_cijena <- proizvod jedinične cijene i količine
uz uslov da nije odobren popust na proizvod.
*/
insert into narudzba_proizvod
select od.OrderID,od.ProductID,od.Quantity*od.UnitPrice as 'uk_cijena'
from NORTHWND.dbo.[Order Details] as od
where od.Discount=0
--1317
--10 bodova


-------------------------------------------------------------------
/*
3. 
Koristeći tabele proizvod i narudzba_proizvod kreirati pogled view_kolicina koji će imati strukturu:
	- proizvodID
	- kateg_naziv
	- jed_cijena
	- uk_cijena
	- kolicina - količnik ukupne i jedinične cijene
U pogledu trebaju biti samo oni zapisi kod kojih količina ima smisao (nije moguće da je na stanju 1,23 proizvoda).
Obavezno pregledati sadržaj pogleda.
*/
create view view_kolicina
as 
select p.proizvodID,p.kateg_naziv,p.jed_cijena,np.uk_cijena,np.uk_cijena/p.jed_cijena as 'Kolicina'
from proizvod as p join narudzba_proizvod as np on p.proizvodID=np.proizvodID
where FLOOR(np.uk_cijena/p.jed_cijena) = np.uk_cijena/p.jed_cijena

--1100
--7 bodova


-------------------------------------------------------------------
/*
4. 
Koristeći pogled kreiran u 3. zadatku kreirati proceduru tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara 
(možemo ostaviti bilo koji parametar bez unijete vrijednosti). Proceduru pokrenuti za sljedeće nazive kategorija:
1. Produce
2. Beverages
*/
alter procedure kat_proc(
	@proizvodID int = null,
	@kateg_naziv nvarchar(40) = null,
	@jed_cijena int = null,
	@uk_cijena int = null,
	@kolicina int = null
)
as
begin
	select * from view_kolicina as k
	where (k.proizvodID=@proizvodID or @proizvodID is null) and (k.kateg_naziv=@kateg_naziv or @kateg_naziv is null)
	and (k.jed_cijena=@jed_cijena or @jed_cijena is null) and (k.uk_cijena=@uk_cijena or @uk_cijena is null)
	and (k.Kolicina=@kolicina or @kolicina is null)
end

exec kat_proc @kateg_naziv= 'Produce'
exec kat_proc @kateg_naziv= 'Beverages'

--220
--8 bodova

------------------------------------------------
/*
5.
Koristeći pogled kreiran u 3. zadatku kreirati proceduru proc_br_kat_naziv koja će vršiti prebrojavanja po nazivu 
kategorije. Nakon kreiranja pokrenuti proceduru.
*/
alter procedure prebroj
as
begin
	select v.kateg_naziv,count(v.kateg_naziv) as 'Broj kategorija'
	from view_kolicina as v
	group by v.kateg_naziv
end
exec prebroj
--8
/*
kateg_naziv     broj_kateg_naziv
--------------- ----------------
Condiments      112
Beverages       220
Seafood         166
Dairy Products  189
Grains/Cereals  117
Confections     156
Produce         72
Meat/Poultry    68
*/
--5 bodova


-------------------------------------------------------------------
/*
6.
a) Iz tabele narudzba_proizvod kreirati pogled view_suma sljedeće strukture:
	- narudzbaID
	- suma - sume ukupne cijene po ID narudžbe
Obavezno napisati naredbu za pregled sadržaja pogleda.
b) Napisati naredbu kojom će se prikazati srednja vrijednost sume zaokružena na dvije decimale.
c) Iz pogleda kreiranog pod a) dati pregled zapisa čija je suma veća od prosječne sume. Osim kolona iz pogleda, potrebno je prikazati 
razliku sume i srednje vrijednosti. Razliku zaokružiti na dvije decimale.
*/
create view view_suma
as 
select np.narudzbaID,sum(np.uk_cijena) as 'Ukupna cijena po kolicini'
from narudzba_proizvod as np
group by np.narudzbaID

select v.narudzbaID,round(v.[Ukupna cijena po kolicini],2)
from view_suma as v

select v.narudzbaID,v.[Ukupna cijena po kolicini],round(v.[Ukupna cijena po kolicini]-(select avg(v.[Ukupna cijena po kolicini]) as 'Prosjek'
from view_suma as v),2) as 'Razlika'
from view_suma as v
where v.[Ukupna cijena po kolicini] > (select avg(v.[Ukupna cijena po kolicini]) as 'Prosjek'
from view_suma as v)
group by v.narudzbaID,v.[Ukupna cijena po kolicini]



--191
--15 bodova


-------------------------------------------------------------------
/*
7.
a) U tabeli narudzba dodati kolonu evid_br, 30 unicode karaktera 
b) Kreirati proceduru kojom će se izvršiti punjenje kolone evid_br na sljedeći način:
	- ako u datumu isporuke nije unijeta vrijednost, evid_br se dobija generisanjem slučajnog niza znakova
	- ako je u datumu isporuke unijeta vrijednost, evid_br se dobija spajanjem datum narudžbe i datuma isprouke uz umetanje donje crte između datuma
Nakon kreiranja pokrenuti proceduru.
Obavezno provjeriti sadržaj tabele narudžba.
*/
--a
alter table narudzba
add evid_br nvarchar(30)
alter procedure punjenje
as
begin
	update narudzba 
	set evid_br = left(NEWID(),30)
	where dtm_isporuke is null

	update narudzba 
	set evid_br = CONVERT(nvarchar(15),dtm_narudzbe) + '_'+CONVERT(nvarchar(15),dtm_isporuke)
	where dtm_isporuke is not null
end

exec punjenje
--15 bodova
select * from narudzba

-------------------------------------------------------------------
/*
8. Kreirati proceduru kojom će se dobiti pregled sljedećih kolona:
	- narudzbaID,
	- klijent_naziv,
	- proizvodID,
	- kateg_naziv,
	- dobavljac_naziv
Uslov je da se dohvate samo oni zapisi u kojima naziv kategorije sadrži samo 1 riječ.
Pokrenuti proceduru.
*/
alter procedure pregled
as
begin
	select n.narudzbaID,n.klijent_naziv,p.proizvodID,p.kateg_naziv,p.dobavljac_naziv
	from proizvod as p join narudzba_proizvod as np on p.proizvodID=np.proizvodID join narudzba as n on np.narudzbaID=n.narudzbaID
	where CHARINDEX(' ',p.kateg_naziv) = 0 and CHARINDEX('/',p.kateg_naziv) = 0 
end

--863
--10 bodova


-------------------------------------------------------------------
/*
9.
U tabeli proizvod izvršiti update kolone dobavljac_web tako da se iz kolone dobavljac_naziv uzme prva riječ, 
a zatim se formira web adresa u formi www.prva_rijec.com. Update izvršiti pomoću dva upita, vodeći računa o broju riječi u nazivu. 
*/
--jedna riječ
update proizvod
set dobavljac_web= 'www.'+dobavljac_naziv+'.com'
where CHARINDEX(' ',dobavljac_naziv) = 0 and LEFT(dobavljac_naziv,1) <> ' '

update proizvod
set dobavljac_web= 'www.'+LEFT(dobavljac_naziv,CHARINDEX(' ',dobavljac_naziv)-1)+'.com'
where CHARINDEX(' ',dobavljac_naziv)-1 > 0
select * from proizvod

--72
--15 bodova




-------------------------------------------------------------------
/*
10.
a) Kreirati backup baze na default lokaciju.
b) Kreirati proceduru kojom će se u jednom izvršavanju obrisati svi pogledi i procedure u bazi. Pokrenuti proceduru.
*/
--a

backup database [1700588]
to disk = 'tajbroj.bak'


