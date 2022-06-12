use LibraryDB;

bulk insert Genre from '/genres1.csv'
with (
    fieldterminator  = ',',
    rowterminator = '\n',
    firstrow = 1
    );

DBCC CHECKIDENT (BooksLending, RESEED, 10);

/* Индексы */

go
set statistics time on;
-- 1) Инфо о библиотеке: название, адрес, ФИО персонала, должность персонала, дни работы, секции книг,
--    вместимость зала
select top 100 L.Name as LibName, L.Address as LibAddr, S.FullName as StaffFio, P.Name as StaffPos,
               OH.DayOfTheWeek as WorkingDay, S2.Name as Section, RR.Capacity as ReadingRoomCapacity
from Library L
join Staff S on L.ID = S.LibraryID
join Position P on P.ID = S.PositionID
join OpeningHours OH on L.ID = OH.LibraryID
join ReadingRoom RR on L.ID = RR.LibraryID
join Section S2 on L.ID = S2.LibraryID
where (RR.Capacity = 909) and (S2. location is not null) and
      (P.Wage between 100000 and 200000) and OH.DayOfTheWeek in ('Среда', 'Четверг')
order by L.Name asc, S.PositionID;
set statistics time off;
go

create index idx_capacity on ReadingRoom(Capacity);
drop index  idx_capacity on ReadingRoom;

go
set statistics time on;
-- 2) Для заданной библиотеки, для заданной секции вывести все книги заданного автора
select B.Name as Books
from Library L
join Section S on L.ID = S.LibraryID
join Book B on S.ID = B.SectionID
join Author A on A.ID = B.AuthorID
where A.FullName like 'Д. Рихтер' and L.ID = 4 and -- Заданные данные
      lower(S.Name) like '%техническая литература%';
set statistics time off;
go

create index idx_name on Author(FullName);
drop index idx_name on Author;

go
set statistics time on;
-- 1) Для заданного читателя, в заданной библиотеке, в заданный день вывести
-- список взятий и возращений книг, через запятую названия книг, упорядочить по дате взятия по убыванию топ 3
select top 3 BL.LendingDate as LendingDate, BL.ReturnDate as ReturnDate, string_agg(B.Name, ', ') as Books
from Reader R
join BooksLending BL on R.ID = BL.ReaderID
join BookToLending BTL on BL.ID = BTL.LendingID
join Book B on B.ID = BTL.BookID
join Section S on S.ID = B.SectionID
join Library L on S.LibraryID = L.ID
where R.ID = 2 and L.ID = 4 and BL.LendingDate = '2021-09-13' -- Заданные данные
group by BL.LendingDate, BL.ReturnDate
order by  BL.LendingDate desc;
set statistics time off;
go

create index idx_lendingDate on BooksLending(LendingDate);
drop index idx_lendingDate on BooksLending;

go
set statistics time on;
-- 8) Выявление самых востребованных жанров в библиотеке
select top 30 percent G.Name, count(BL.ID) as LendingsCount
from Genre G
join BookToGenre BTG on G.ID = BTG.GenreID
join Book B on B.ID = BTG.BookID
join BookToLending BTL on B.ID = BTL.BookID
join BooksLending BL on BL.ID = BTL.LendingID
join Section S on B.SectionID = S.ID
join Library L on S.LibraryID = L.ID
where L.Name like 'Российская государственная библиотека'
group by G.Name
order by count(BL.ID) desc;
set statistics time off;
go

create index idx_libName on Library(Name);
drop index idx_libName on Library;

go
set statistics time on;
-- 6) Получить книги написанные на Немецком, Русском или Французком
select Name, OriginalLanguage
from Book
where OriginalLanguage in(N'Немецкий', N'Русский', N'Французкий');
set statistics time off;
go

create index idx_originalLanguage on Book(OriginalLanguage);
drop index idx_originalLanguage on Book;

/* Процедуры */

-- 1) Выводит всех работников в библиотеке с заданным названием
create procedure EmployeesCount @LibraryName nvarchar(50)
as
    begin
        select S.FullName
        from Staff S
        join Library L on L.ID = S.LibraryID
        where L.Name like @LibraryName
    end;
go

exec EmployeesCount 'Российская государственная библиотека';

-- 2) Вывести кол-во выдач за каждый день у работника, в заданный период
create procedure LendingsCount @StaffName nvarchar(50), @PeriodBeginning date, @PeriodEnd date
as
    begin
        select BL.LendingDate, count(BL.ID) as lendingsCount
        from Staff S
        join BooksLending BL on S.ID = BL.StaffID
        where S.FullName like @StaffName
        group by BL.LendingDate
        having Bl.LendingDate between @PeriodBeginning and @PeriodEnd
    end;
go

drop procedure LendingsCount;

exec LendingsCount 'Федорова Татьяна Никитична', '2000-09-01', '2022-09-30';

-- 3) По названию библиотеки выводит инофрмацию о её читальных залах
create procedure ReadingRoomInfo @LibName nvarchar(50)
as
    begin
        select R.ID as Indeficator, R.Location as Location,
               case
                   when R.Capacity < 50 then 'Малая вмеситмость'
                   when R.Capacity between 50 and 250 then 'Средняя вместимость'
                   else 'Высокая вместимость'
               end
        from ReadingRoom R
        join Library L on L.ID = R.LibraryID
        where L.Name like @LibName
    end;
go

exec ReadingRoomInfo 'Российская государственная библиотека';

/* Функции */

-- 1) Возращает кол-во книг в секции, если книг нет, возращает -1
create function BooksCountInSection (@SectionName nvarchar(50), @LibId int)
returns int
as
    begin
        declare @BooksCount int = (
            select count(B.ID)
            from Section S
            join Book B on S.ID = B.SectionID
            join Library L on S.LibraryID = L.ID
            where S.Name like @SectionName and L.ID = @LibId
            group by S.Name
        );

        declare @res int;
        if @BooksCount is null
            set @res = -1;
        else
            set @res = @BooksCount;
        return @res;
    end;
go

drop function BooksCountInSection;

select dbo.BooksCountInSection ('Русская классика', 4) as res;

-- 2) Получить строку всех книг в заданной секции
create function GetBooksList(@SectionID int)
returns nvarchar(500)
as
    begin
        declare BookCursor cursor for
        select Name
        from Book
        where SectionID = @SectionID;

        open BookCursor;
        declare @buff nvarchar(50);
        declare @res nvarchar(500) = '';
        fetch next from BookCursor into @buff;
        while @@FETCH_STATUS = 0
            begin
                set @res = concat(@res, ', ', @buff);
                fetch next from BookCursor into @buff;
            end;
        close BookCursor;
        deallocate BookCursor;
        return @res;
    end;
go

drop function GetBooksList;

select dbo.GetBooksList(2) as BookList;

-- 3) Получить кол-во выдач для работника/кол-во получений для читателя
create function GetLendingsCount(@PersonName nvarchar(50), @StaffOrReader char(1))
returns int
begin
    declare @LendingsCount int;
    if @StaffOrReader like 'S'
        set @LendingsCount = (
            select count(BooksLending.ID)
            from BooksLending
            join Staff S on S.ID = BooksLending.StaffID
            where S.FullName like @PersonName
            );
    else if @StaffOrReader like 'R'
        set @LendingsCount = (
            select count(BooksLending.ID)
            from BooksLending
            join Reader R2 on BooksLending.ReaderID = R2.ID
            where R2.FullName like @PersonName
            );
    return @LendingsCount;
end;
go

select dbo.GetLendingsCount('Кондратьев Мечеслав Даниилович', 'R') as LendingsCount;

/* Представления */

-- 1) Инфо о библиотеках
create view LibraryInfo
as
select L.Name as [Название библиотеки], L.Address as [Адресс],
       sum(RR.Capacity) as [Суммарная вместимость читальных залов],
       count(S.ID) as [Кол-во работников], string_agg(OH.DayOfTheWeek, ', ') as [Рабочие дни]
from Library L
join OpeningHours OH on L.ID = OH.LibraryID
left join Staff S on L.ID = S.LibraryID
left join ReadingRoom RR on L.ID = RR.LibraryID
group by L.ID, L.Name, L.Address;

drop view LibraryInfo;

select * from LibraryInfo;

-- 2) Инфо о книгах
create view BooksInfo
as
select distinct B.Name as [Название книги], B.OriginalLanguage as [Язык оригинала], B.PagesCount as [Кол-во страниц],
       S.Name as [Секция], string_agg(G.Name, ', ') as [Жанры]
from Book B
join Author A on A.ID = B.AuthorID
join Section S on B.SectionID = S.ID
join BookToGenre BTG on B.ID = BTG.BookID
join Genre G on G.ID = BTG.GenreID
group by B.Name, B.OriginalLanguage, B.PagesCount, S.Name;

select * from BooksInfo;

-- 3) Инфо о выдачах
create view LendingsInfo
as
select R2.FullName as [ФИО читателя], BL.LendingDate as [Дата выдачи], BL.ReturnDate as [Дата возращения книг],
       count(BTL.BookID) as [Кол-во книг], S.FullName as [ФИО работника, совершившего выдачу], RR.Location as [Расположение читального зала]
from BooksLending BL
left join BookToLending BTL on BL.ID = BTL.LendingID
join Reader R2 on R2.ID = BL.ReaderID
left join ReadingRoom RR on RR.ID = BL.ReadingRoomID
join Staff S on S.ID = BL.StaffID
group by R2.FullName, BL.LendingDate, BL.ReturnDate, S.FullName, RR.Location;


select
    *
from
(
    select BL.id, count(BTL.BookID) as btl_count
    from BooksLending BL
    left join BookToLending BTL on BL.ID = BTL.LendingID
    group by BL.id
) as btl_counts
join BooksLending BL on btl_counts.ID = BL.id
join Reader R2 on R2.ID = BL.ReaderID
left join ReadingRoom RR on RR.ID = BL.ReadingRoomID
join Staff S on S.ID = BL.StaffID;

select * from LendingsInfo;

/* Триггер */

-- 1) При добавлении записи в таблицу библиотек делает запись в таблицу с историей добавлений
create table LibHistory
(
    ID int identity primary key ,
    LibID int not null ,
    Operation nvarchar(200) not null,
    CreateAt datetime not null default getdate()
);

create trigger libInsertHist on Library after insert
as
insert into LibHistory (LibID, Operation)
select ID, 'Добавлена библиотека: ' + Name
from inserted;

insert into Library(Name, Address) values ('TestName', 'TestAddress');
select * from LibHistory;

/* Модификация */

--1) Сравнить два запроса
-- примерно 50 мс
go
set statistics time on;
select R2.FullName as [ФИО читателя], BL.LendingDate as [Дата выдачи], BL.ReturnDate as [Дата возращения книг],
       count(BTL.BookID) as [Кол-во книг], S.FullName as [ФИО работника, совершившего выдачу], RR.Location as [Расположение читального зала]
from BooksLending BL
left join BookToLending BTL on BL.ID = BTL.LendingID
join Reader R2 on R2.ID = BL.ReaderID
left join ReadingRoom RR on RR.ID = BL.ReadingRoomID
join Staff S on S.ID = BL.StaffID
group by R2.FullName, BL.LendingDate, BL.ReturnDate, S.FullName, RR.Location;
set statistics time off;
go

--примерно 30 мс
go
set statistics time on;
select
    *
from
(
    select BL.id, count(BTL.BookID) as btl_count
    from BooksLending BL
    left join BookToLending BTL on BL.ID = BTL.LendingID
    group by BL.id
) as btl_counts
join BooksLending BL on btl_counts.ID = BL.id
join Reader R2 on R2.ID = BL.ReaderID
left join ReadingRoom RR on RR.ID = BL.ReadingRoomID
join Staff S on S.ID = BL.StaffID;
set statistics time off;
go

--2) Добавлять выдачу книг по необходимым id читателя, зала, персонала и т.д.
create procedure addBooksLending @ReaderID int, @StaffID int, @RoomID int
as
    begin
        declare @ReturnDate date;
        if @RoomID = 0
            begin set @RoomID = NULL;
                  set @ReturnDate = NULL;
            end;
        else
            set @ReturnDate = getdate();

        insert into BooksLending(lendingdate, returndate, readerid, readingroomid, staffid) values
        (getdate(), @ReturnDate, @ReaderID, @RoomID, @StaffID);
    end;
go

--3) Триггер для обновления долга читателя по обновлению выдачи.
create trigger DebtAutoUpdate on BooksLending after insert, update
as
begin
    update Reader
    set Debt = 'false'
    from Reader R
    join inserted on R.ID = inserted.ReaderID
    where inserted.ReturnDate <= getdate() and inserted.ReturnDate is not null;

    update Reader
    set Debt = 'true'
    from Reader R
    join inserted on R.ID = inserted.ReaderID
    where inserted.ReturnDate > getdate() or inserted.ReturnDate is null;
end;