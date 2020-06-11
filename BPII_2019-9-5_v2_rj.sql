Napomena:

/*
1. Prilikom  bodovanja rješenja prioritet ima razultat koji treba upit da vrati (broj zapisa, vrijednosti agregatnih funkcija...).
U slučaju da rezultat upita nije tačan, a pogled, tabela... koji su rezultat tog upita se koriste u narednim zadacima, tada se rješenja narednih zadataka, bez obzira na tačnost koda, ne boduju punim brojem bodova, jer ni ta rješenja ne mogu vratiti tačan rezultat (broj zapisa, vrijednosti agregatnih funkcija...).

2. Tokom pisanja koda obratiti posebnu pažnju na tekst zadatka i ono što se traži zadatkom. Prilikom pregleda rada pokreće se kod koji se nalazi u sql skripti i sve ono što nije urađeno prema zahtjevima zadatka ili je pogrešno urađeno predstavlja grešku. Shodno navedenom na uvidu se ne prihvata prigovor da je neki dio koda posljedica previda ("nisam vidio", "slučajno sam to napisao"...) 
*/














/*
1.
a) Kreirati bazu pod vlastitim brojem indeksa.
*/
create database [Broj58] on(
	name='broj58mdf',
	filename='D:\BP2\Data\broj58mdf.mdf',
	size=10mb,
	maxsize=unlimited,
	filegrowth=5%
)
log on(
	name='broj58ldf',
	filename='D:\BP2\Log\broj58mdf.ldf',
	size=10mb,
	maxsize=unlimited,
	filegrowth=5%
)
use [Broj58]

/* 
b) Kreiranje tabela.
Prilikom kreiranja tabela voditi računa o odnosima između tabela.
I. Kreirati tabelu produkt sljedeće strukture:
	- produktID, cjelobrojna varijabla, primarni ključ
	- jed_cijena, novčana varijabla
	- kateg_naziv, 15 unicode karaktera
	- mj_jedinica, 20 unicode karaktera
	- dobavljac_naziv, 40 unicode karaktera
	- dobavljac_post_br, 10 unicode karaktera
*/
create table produkt(
	produktID int primary key,
	jed_cijena money,
	kateg_naziv nvarchar(15),
	mj_jedinica nvarchar(20),
	dobavljac_naziv nvarchar(40),
	dobavljac_post_br nvarchar(10)
)

/*
II. Kreirati tabelu narudzba sljedeće strukture:
	- narudzbaID, cjelobrojna varijabla, primarni ključ
	- dtm_narudzbe, datumska varijabla za unos samo datuma
	- dtm_isporuke, datumska varijabla za unos samo datuma
	- grad_isporuke, 15 unicode karaktera
	- klijentID, 5 unicode karaktera
	- klijent_naziv, 40 unicode karaktera
	- prevoznik_naziv, 40 unicode karaktera
*/
create table narudzba(
	narudzbaID int primary key,
	dtm_narudzbe date,
	dtm_isporuke date,
	grad_isporuke nvarchar(15),
	klijentID nvarchar(5),
	klijent_naziv nvarchar(40),
	prevoznik_naziv nvarchar(40)
)

/*
III. Kreirati tabelu narudzba_produkt sljedeće strukture:
	- narudzbaID, cjelobrojna varijabla, obavezan unos
	- produktID, cjelobrojna varijabla, obavezan unos
	- uk_cijena, novčana varijabla
*/
create table narudzba_produkt(
	narudzbaID int not null constraint fk_narudzbaid foreign key references narudzba(narudzbaID),
	produktID int not null constraint fk_produktID foreign key references produkt(produktID),
	constraint pk_prnarid primary key (narudzbaID,produktID),
	uk_cijena money
)
--10 bodova



----------------------------------------------------------------------------------------------------------------------------
/*
2. Import podataka
a) Iz tabela Categories, Product i Suppliers baze Northwind u tabelu produkt importovati podatke prema pravilu:
	- ProductID -> produktID
	- QuantityPerUnit -> mj_jedinica
	- UnitPrice -> jed_cijena
	- CategoryName -> kateg_naziv
	- CompanyName -> dobavljac_naziv
	- PostalCode -> dobavljac_post_br
*/
insert into produkt
select p.ProductID,p.UnitPrice,c.CategoryName,p.QuantityPerUnit,s.CompanyName,s.PostalCode
from NORTHWND.dbo.Categories as c join NORTHWND.dbo.Products as p on c.CategoryID=p.CategoryID join NORTHWND.dbo.Suppliers as s
on p.SupplierID=s.SupplierID
--77

/*
a) Iz tabela Customers, Orders i Shipers baze Northwind u tabelu narudzba importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- OrderDate -> dtm_narudzbe
	- ShippedDate -> dtm_isporuke
	- ShipCity -> grad_isporuke
	- CustomerID -> klijentID
	- CompanyName -> klijent_naziv
	- CompanyName -> prevoznik_naziv
*/
insert into narudzba
select o.OrderID,o.OrderDate,o.ShippedDate,o.ShipCity,c.CustomerID,c.CompanyName,sh.CompanyName
from NORTHWND.dbo.Customers as c join NORTHWND.dbo.Orders as o on c.CustomerID=o.CustomerID join
NORTHWND.dbo.Shippers as sh on o.ShipVia=sh.ShipperID
--830

/*
c) Iz tabele Order Details baze Northwind u tabelu narudzba_produkt importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- ProductID -> produktID
	- uk_cijena <- produkt jedinične cijene i količine
uz uslov da je odobren popust 5% na produkt.
*/
insert into narudzba_produkt
select o.OrderID,o.ProductID,o.Quantity*o.UnitPrice as 'uk_cijena'
from NORTHWND.dbo.[Order Details] as o
where o.Discount=0.05
--185
--10 bodova


----------------------------------------------------------------------------------------------------------------------------
/*
3. 
a) Koristeći tabele narudzba i narudzba_produkt kreirati pogled view_uk_cijena koji će imati strukturu:
	- narudzbaID
	- klijentID
	- uk_cijena_cijeli_dio
	- uk_cijena_feninzi - prikazati kao cijeli broj  
Obavezno pregledati sadržaj pogleda.
b) Koristeći pogled view_uk_cijena kreirati tabelu nova_uk_cijena uz uslov da se preuzmu samo oni zapisi u kojima su feninzi veći od 49.
U tabeli trebaju biti sve kolone iz pogleda, te nakon njih kolona uk_cijena_nova u kojoj će ukupna cijena biti zaokružena na veću vrijednost.
 Npr. uk_cijena = 10, feninzi = 90 -> uk_cijena_nova = 11
*/
--a
create view view_uk_cijena
as
select n.narudzbaID,n.klijentID,convert(int,floor(np.uk_cijena)) as 'uk_cijena_cijeli_dio',convert(int,(np.uk_cijena-floor(np.uk_cijena))*100) as 'uk_cijena_feninzi'
from narudzba as n join narudzba_produkt as np on n.narudzbaID=np.narudzbaID

--ili
select * from view_uk_cijena

select v.narudzbaID,v.klijentID,v.uk_cijena_cijeli_dio+1 as 'uk_cijena_cijeli_dio',v.uk_cijena_feninzi
into nova_uk_cijena
from view_uk_cijena as v
where v.uk_cijena_feninzi>49
--185

--b

--32
--13 bodova




----------------------------------------------------------------------------------------------------------------------------
/*
4. 
Koristeći tabelu uk_cijena_nova kreiranu u 3. zadatku kreirati proceduru tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara 
(možemo ostaviti bilo koji parametar bez unijete vrijednosti). Proceduru pokrenuti za sljedeće vrijednosti varijabli:
1. narudzbaID - 10730
2. klijentID  - ERNSH
*/
create procedure proc_uk(
	@narudzbaID int = null,
	@klijentID nvarchar(5) = null,
	@uk_cijena_cijeli_dio int = null,
	@uk_cijena_feninzi int = null
)
as
begin
	select * from nova_uk_cijena as u
	where (u.narudzbaID=@narudzbaID or @narudzbaID is null) and (u.klijentID=@klijentID or @klijentID is null) and (u.uk_cijena_cijeli_dio=
	@uk_cijena_cijeli_dio or @uk_cijena_cijeli_dio is null) and (@uk_cijena_feninzi= u.uk_cijena_feninzi or @uk_cijena_feninzi is null)
end
exec proc_uk @narudzbaID = 10730
exec proc_uk @klijentID = 'ERNSH'

--3
/*
narudzbaID  klijentID uk_cijena_cijeli_dio  uk_cijena_feninzi     uk_cijena_nova
----------- --------- --------------------- --------------------- ---------------------
10730       BONAP     261.00                75.00                 262.00
10730       BONAP     37.00                 50.00                 38.00
10730       BONAP     210.00                50.00                 211.00
*/


--2
/*
narudzbaID  klijentID uk_cijena_cijeli_dio  uk_cijena_feninzi     uk_cijena_nova
----------- --------- --------------------- --------------------- ---------------------
10351       ERNSH     1193.00               50.00                 1194.00
10776       ERNSH     256.00                50.00                 257.00
*/
--10 bodova




----------------------------------------------------------------------------------------------------------------------------
/*
5.
Koristeći tabelu produkt kreirati proceduru proc_post_br koja će prebrojati zapise u kojima poštanski broj dobavljača počinje cifrom.
 Potrebno je dati prikaz poštanskog broja i ukupnog broja zapisa po poštanskom broju. Nakon kreiranja pokrenuti proceduru.
*/

create procedure proc_post_br
as
begin
	select p.dobavljac_post_br,COUNT(p.dobavljac_post_br) as 'Broj zapisa'
	from produkt as p
	where ISNUMERIC(LEFT(p.dobavljac_post_br,1))=1
	group by p.dobavljac_post_br
end


--23
/*
dobavljac_post_br broj_po_post_br
----------------- ---------------
02134             2
0512              3
100               3
10785             3
1320              3
2042              3
27478             1
2800              2
3058              5
33007             2
48100             3
48104             3
53120             3
5442              1
545               3
60439             5
70117             4
71300             1
74000             2
75004             2
84100             2
97101             3
9999 ZZ           2
*/
--5 bodova


-------------------------------------------------------------------
/*
6.
a) Iz tabele narudzba kreirati pogled view_prebrojano sljedeće strukture:
	- klijent_naziv
	- prebrojano - ukupan broj narudžbi po nazivu klijent
Obavezno napisati naredbu za pregled sadržaja pogleda.
b) Napisati naredbu kojom će se prikazati maksimalna vrijednost kolone prebrojano.
c) Iz pogleda kreiranog pod a) dati pregled zapisa u kojem će osim kolona iz pogleda prikazati razlika maksimalne vrijednosti i kolone prebrojano 
uz uslov da se ne prikazuje zapis u kojem se nalazi maksimlana vrijednost.
*/

create view view_prebrojano
as
select n.klijent_naziv,COUNT(n.klijent_naziv) as 'Broj narudzbi po nazivu klijenta'
from narudzba as n
group by n.klijent_naziv


select max(v.[Broj narudzbi po nazivu klijenta]) as 'Najveca vrijednost kolone broj narudzbi'
from view_prebrojano as v

select v.klijent_naziv,v.[Broj narudzbi po nazivu klijenta],(select max(v.[Broj narudzbi po nazivu klijenta])from view_prebrojano as v) - 
v.[Broj narudzbi po nazivu klijenta]as 'Razlika'
from view_prebrojano as v
where v.[Broj narudzbi po nazivu klijenta] <> (select max(v.[Broj narudzbi po nazivu klijenta])from view_prebrojano as v)
--89

--max (prebrojano) = 31


--88
--12 bodova


-------------------------------------------------------------------
/*
7.
a) U tabeli produkt dodati kolonu lozinka, 20 unicode karaktera 
b) Kreirati proceduru kojom će se izvršiti punjenje kolone lozinka na sljedeći način:
	- ako je u dobavljac_post_br podatak sačinjen samo od cifara, lozinka se kreira obrtanjem niza znakova koji se dobiju spajanjem zadnja 
	četiri znaka kolone mj_jedinica i kolone dobavljac_post_br
	- ako podatak u dobavljac_post_br podatak sadrži jedno ili više slova na bilo kojem mjestu, lozinka se kreira obrtanjem slučajno 
	generisanog niza znakova
Nakon kreiranja pokrenuti proceduru.
Obavezno provjeriti sadržaj tabele narudžba.
*/
--a
alter table produkt
add lozinka nvarchar(20)

create procedure punjloz
as begin
	update produkt
	set lozinka = reverse(RIGHT(convert(nvarchar(50),mj_jedinica),4)+RIGHT(convert(nvarchar(10),dobavljac_post_br),4))
	where isnumeric(dobavljac_post_br) = 1

	update produkt
	set lozinka = left(reverse(NEWID()),20)
	where isnumeric(dobavljac_post_br) = 0
end

--b

--59
--18


--10 bodova


-------------------------------------------------------------------
/*
8. 
a) Kreirati pogled kojim sljedeće strukture:
	- produktID,
	- dobavljac_naziv,
	- grad_isporuke
	- period_do_isporuke koji predstavlja vremenski period od datuma narudžbe do datuma isporuke
Uslov je da se dohvate samo oni zapisi u kojima je narudzba realizirana u okviru 4 sedmice.
Obavezno pregledati sadržaj pogleda.

b) Koristeći pogled view_isporuka kreirati tabelu isporuka u koju će biti smještene sve kolone iz pogleda. 
*/
create view pog
as
select p.produktID,p.dobavljac_naziv,n.grad_isporuke,(((year(n.dtm_narudzbe)*365)+(month(n.dtm_narudzbe)*30)+DAY(n.dtm_narudzbe))-
((year(n.dtm_isporuke)*365)+(month(n.dtm_isporuke)*30)+DAY(n.dtm_isporuke)))*-1 as 'Razlika',n.dtm_isporuke,n.dtm_narudzbe
from produkt as p join narudzba_produkt as np on p.produktID=np.produktID join
narudzba as n on np.narudzbaID=n.narudzbaID
where (((year(n.dtm_narudzbe)*365)+(month(n.dtm_narudzbe)*30)+DAY(n.dtm_narudzbe))-
((year(n.dtm_isporuke)*365)+(month(n.dtm_isporuke)*30)+DAY(n.dtm_isporuke)))*-1 <= 30

--170
select *
into novatab
from pog

--10 bodova




-------------------------------------------------------------------
/*
9.
a) U tabeli isporuka dodati kolonu red_br_sedmice, 10 unicode karaktera.
b) U tabeli isporuka izvršiti update kolone red_br_sedmice ( prva, druga, treca, cetvrta) u zavisnosti od vrijednosti u koloni period_do_isporuke. 
Pokrenuti proceduru
c) Kreirati pregled kojim će se prebrojati broj zapisa po rednom broju sedmice. Pregled treba da sadrži redni broj sedmice i ukupan broj 
zapisa po rednom broju.
*/
alter table novatab
add red_br_sedmice nvarchar(10)
--a

select * from novatab
--b
update novatab
set red_br_sedmice = 'prva'
where Razlika <= 7

update novatab
set red_br_sedmice = 'druga'
where Razlika <= 14 and Razlika > 7

update novatab
set red_br_sedmice = 'treca'
where Razlika <= 21 and Razlika > 14

update novatab
set red_br_sedmice = 'cetvrta'
where Razlika > 21
--108
--53
--1
--8

--c

--4
/*
red_br_sedmice 
-------------- -----------
cetvrta        8
druga          53
prva           108
treca          1
*/

--15 bodova

-------------------------------------------------------------------
/*
10.
a) Kreirati backup baze na default lokaciju.
b) Kreirati proceduru kojom će se u jednom izvršavanju obrisati svi pogledi i procedure u bazi. Pokrenuti proceduru.
*/
--a


--ili


--b

--5 BODOVA
