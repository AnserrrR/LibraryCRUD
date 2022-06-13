use LibraryDB;

-- Get запрос книг

select top 500 B.ID as ID, B.Name as BookName, B.OriginalLanguage as OriginalLanguage,
B.PagesCount as PagesCount, S.Name as Section, PH.Name as PublishingHouseName, A.FullName as Author,
B.PublishingYear as PublishingYear
from Book B
inner join Author A on A.ID = B.AuthorID
inner join Section S on S.ID = B.SectionID
inner join PublishingHouse PH on PH.ID = B.PublishingHouseID
order by B.ID desc;

-- Get запрос для секций книг
select ID, Name
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

select top 500 BL.ID as ID, BL.LendingDate as LendingDate, BL.ReturnDate as ReturnDate, R2.FullName as ReaderName,
       RR.Location as ReadingRoomLocation, S.FullName as StaffName
from BooksLending BL
join Reader R2 on R2.ID = BL.ReaderID
join ReadingRoom RR on RR.ID = BL.ReadingRoomID
join Staff S on S.ID = BL.StaffID
order by BL.ID desc;

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
