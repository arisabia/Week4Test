create database NegozioDischi

create table Band(
	ID int identity(1,1) not null,
	Nome varchar(25) not null,
	NumeroComponenti int not null,

	primary key(ID)
)

insert into Band values
('Band a',2),
('Band b',5),
('Maneskin',3),
('Band c',1),
('Band d',2)

insert into Band values ('The Giornalisti', 5)

create table Brano(
	ID int identity(1,1) not null,
	Titolo varchar(50) not null,
	Durata decimal(9,2) not null,

	primary key(ID)
)

insert into Brano values
('Brano a',3.20),
('Brano b',4.10),
('brano c',3.60),
('Imagine',3),
('brano d',2.90),
('brano x',4.10)

create table Album(
	ID int identity(1,1) not null,
	Titolo varchar(50) not null,
	AnnoUscita int not null,
	CasaDiscografica varchar(25) not null,
	Genere varchar(10) not null,
	SupportoDistribuzione varchar(12) not null,
	BandID int not null,

	primary key(ID),
	foreign key(BandID) references Band(ID),
	Unique(Titolo, AnnoUscita, CasaDiscografica, Genere, SupportoDistribuzione),
	check(Genere in ('Classico', 'jazz', 'pop', 'rock', 'metal')),
	check(SupportoDistribuzione in ('CD', 'Vinile', 'Streaming'))
)

insert into Album values
('album x',1983 ,'casa w','Classico','CD',1),
('album y', 2020,'casa m','jazz','Vinile',3),
('album z',1983,'casa f','pop','CD',6),
('abum a',2018 ,'casa d','Classico','Vinile',3),
('album x',1999 ,'casa s','rock','Streaming',3),
('album z',1998 ,'casa o','metal','Streaming',6)



create table AlbumBrano(
	AlbumID int not null,
	BranoID int not null,
	foreign key(AlbumID) references Album(ID),
	foreign key(BranoID) references Brano(ID)
)

insert into AlbumBrano values
(1,4),
(2,4),
(4,1),
(5,2),
(3,3),
(6,5),
(6,1)




--1)Scrivere una query che restituisca i titoli degli album degli “83”;

Select a.Titolo as TitoloAlbum
from Album a
where a.AnnoUscita = 1983


--2)Selezionare tutti gli album editi dalla casa editrice 
-- nell’anno specificato;

select *
from Album a
where a.ID = all(
			select a.ID
			from album a
			where a.CasaDiscografica = 'casa o' and a.AnnoUscita = 1998)

--3)Scrivere una query che restituisca tutti i titoli delle canzoni 
-- dei “Maneskin” appartenenti ad album pubblicati prima del 2019;

select b.Titolo, a.AnnoUscita
from Brano b
join AlbumBrano ab
on ab.BranoID = b.Id
join Album a
on ab.AlbumID = a.ID
join Band bd
on bd.ID = a.BandID
where bd.Nome = 'Maneskin' and a.AnnoUscita < 2019

--4)Individuare tutti gli album in cui è contenuta la canzone “Imagine”;

select a.Titolo, a.Genere, a.CasaDiscografica, b.Titolo
from Album a
join AlbumBrano ab
on ab.AlbumID  = a.ID
join Brano b
on ab.BranoID = b.Id
 where b.Titolo = 'Imagine'

--5)Restituire il numero totale di canzoni eseguite dalla
--band “The Giornalisti”;
select bd.Nome, count(*) as 'Numero Totale Canzoni'
from Brano b
join AlbumBrano ab
on ab.BranoID = b.Id
join Album a
on ab.AlbumID = a.ID
join Band bd
on bd.ID = a.BandID
group by bd.Nome
having bd.Nome = 'The Giornalisti'
--having Count(*) = 'The Giornalisti'


--6)Contare per ogni album, la somma dei minuti dei brani contenuti.
select a.Titolo, sum(b.Durata) as  'Lungheza Album'
from Album a
join AlbumBrano ab
on ab.AlbumID  = a.ID
join Brano b
on ab.BranoID = b.Id
group by  a.Titolo, b.Durata

--Creare una view che mostri i dati completi dell’album, 
--dell’artista e dei brani contenuti in essa

create view[Dati Album] as(
select a.Titolo, a.AnnoUscita,a.CasaDiscografica,a.Genere,
		bd.Nome,bd.NumeroComponenti,b.Titolo as NomeBand,b.Durata
from Brano b
join AlbumBrano ab
on ab.BranoID = b.Id
join Album a
on ab.AlbumID = a.ID
join Band bd
on bd.ID = a.BandID)

select * from [Dati Album]

--Scrivere una funzione utente che calcoli per ogni genere 
--musicale quanti album sono inseriti in catalogo;

create function ufnCalcolaGenereAlbum(@Titolo varchar(50), @Genere varchar(20))
returns int
as
begin	
		return(select count(*)
				from Brano b
				join AlbumBrano ab
				on ab.BranoID = b.Id
				join Album a
				on ab.AlbumID = a.ID
				where a.Titolo = @Titolo and a.Genere = @Genere
				group by a.ID)
end

select  dbo.ufnCalcolaGenereAlbum(a.Titolo, a.Genere) 
from album a

			