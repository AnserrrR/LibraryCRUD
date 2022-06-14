use LibraryDB;

-- Get запрос книг
--v1
select top 500 B.ID as ID, B.Name as BookName, B.OriginalLanguage as OriginalLanguage,
B.PagesCount as PagesCount, S.Name as Section, PH.Name as PublishingHouseName, A.FullName as Author,
B.PublishingYear as PublishingYear
from Book B
inner join Author A on A.ID = B.AuthorID
inner join Section S on S.ID = B.SectionID
inner join PublishingHouse PH on PH.ID = B.PublishingHouseID
order by B.ID desc;

select top 500 B.ID as ID, B.Name as BookName, B.OriginalLanguage as OriginalLanguage,
B.PagesCount as PagesCount, S.Name as Section, PH.Name as PublishingHouseName, A.FullName as Author,
B.PublishingYear as PublishingYear, B2.GenresID, B2.GenresNames
from (select B2.ID, string_agg(G.ID, ', ') as GenresID, string_agg(G.Name, ', ') as GenresNames
      from Book B2
      join BookToGenre BTG on B2.ID = BTG.BookID
      join Genre G on BTG.GenreID = G.ID
      group by B2.ID) B2
join Book B on B2.ID = B.ID
join Author A on A.ID = B.AuthorID
join Section S on S.ID = B.SectionID
join PublishingHouse PH on PH.ID = B.PublishingHouseID
order by B.ID desc;
--v2
select B.ID as ID, B.Name as Name, B.OriginalLanguage as OriginalLanguage,
B.PagesCount as PagesCount, B.SectionID as SectionID, S.Name as SectionName,  S.Name as SectionName,
B.PublishingHouseID as PublishingHouseID, PH.Name as PublishingHouseName,
B.AuthorID as AuthorID, FullName as AuthorName, B.PublishingYear as PublishingYear
from Book B
inner join Author A on A.ID = B.AuthorID
inner join Section S on S.ID = B.SectionID
inner join PublishingHouse PH on PH.ID = B.PublishingHouseID
where  S.LibraryID = 2013
order by B.ID desc;

-- Get запрос для секций книг
select ID, Name, LibraryID
from Section;

delete from Section
where Name like 'n/a';

-- Get запрос для издательского дома книги
select ID, Name
from PublishingHouse;

-- Get запрос для секций книг
select ID, FullName
from Author;

-- Post запрос книг

insert into Book (Name, OriginalLanguage, PagesCount, SectionID, PublishingHouseID, AuthorID, PublishingYear)
values (@Name, @OriginalLanguage, @PagesCount, @SectionID, @PublishingHouseID, @AuthorID, @PublishingYear);

-- Put запрос книг

update Book
set Name = @Name, OriginalLanguage = @OriginalLanguage, PagesCount = @PagesCount, SectionID = @SectionID,
    PublishingHouseID = @PublishingHouseID, AuthorID = @AuthorID, PublishingYear = @PublishingYear
where ID = @ID;

-- Delete запрос книг

delete from Book
where ID = @ID;

-- Get запрос выдач
--v1
select top 500 BL.ID as ID, BL.LendingDate as LendingDate, BL.ReturnDate as ReturnDate, R2.FullName as ReaderName,
       RR.Location as ReadingRoomLocation, S.FullName as StaffName
from BooksLending BL
join Reader R2 on R2.ID = BL.ReaderID
join ReadingRoom RR on RR.ID = BL.ReadingRoomID
join Staff S on S.ID = BL.StaffID
order by BL.ID desc;
--v2
select BL.ID as ID, BL.LendingDate as LendingDate, BL.ReturnDate as ReturnDate, BL.ReaderID as ReaderID,
       R2.FullName as ReaderName, BL.ReadingRoomID as ReadingRoomID, RR.Location as ReadingRoomLocation,
       BL.StaffID as StaffID, S.FullName as StaffName
from BooksLending BL
join Reader R2 on R2.ID = BL.ReaderID
left join ReadingRoom RR on RR.ID = BL.ReadingRoomID
join Staff S on S.ID = BL.StaffID
where S.LibraryID = 2008
order by BL.ID desc;

-- Get запрос читателя, для которого произвелась выдача
select ID, FullName as Name
from Reader

-- Get запрос читального зала, в который производилась выдача
select ID, Location
from ReadingRoom

-- Get запрос работника, который осуществил выдачу
select ID, FullName as Name
from Staff

-- Post запрос выдач

insert into BooksLending(LendingDate, ReturnDate, ReaderID, ReadingRoomID, StaffID)
values (@LendingDate, @ReturnDate, @ReaderID, @ReadingRoomID, @StaffID);

-- Put запрос выдач

update BooksLending
set LendingDate = @LendingDate, ReturnDate = @ReturnDate,
    ReaderID = @ReaderID, ReadingRoomID = @ReadingRoomID, StaffID = @StaffID
where ID = @ID desc;

-- Delete запрос выдач

delete from BooksLending
where ID = @ID;


-- Get запрос библиотек

select ID, Name, Address
from Library L
order by L.ID desc;

-- Post запрос библиотек

insert into Library (Name, Address)
values (@Name, @Address);

-- Put запрос библиотек

update Library
set Name = @Name, Address = @Address
where ID = @ID;

-- Delete запрос библиотек

delete from Library
where ID = @ID;
