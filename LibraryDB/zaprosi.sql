use LibraryDB;

/* 1.Запросы, указанные в функциональных требованиях
   (в заголовке указать, что за требование) (10 шт. +) */

-- ОПЕРАЦИОННЫЕ

-- 1) По запросу пользователя будет возможность добавлять, удалять
-- и редактировать информацию о книге, любом читателе
-- и сотруднике, секциях книг и их выдачах.
go
insert into Reader(FullName) values ('Романов Роман Романович');
select * from Reader where ID = 12; -- любое ID по необходимости
update Reader set Debt = 1 where ID = 12;
delete Reader where ID = 12; go

-- 2) Программа будет способна выдавать текущее местонахождение
-- конкретной книги (секция или на руках у читателя)
select top 1 BookID, BL.ReturnDate as ReturtnDate, BL.ID as LendingID,
             R2.FullName as ReaderFIO, S.Name as Section
from Book B
join BookToLending BTL on B.ID = BTL.BookID
join BooksLending BL on BTL.LendingID = BL.ID
join Reader R2 on BL.ReaderID = R2.ID
join Section S on B.SectionID = S.ID
where BookID = 1 -- любое ID по необходимости
order by BL.LendingDate, BL.ID desc;

-- 3) Отображение списка всех сотрудников библиотеки.
select P.Name as Position, P.Wage as Wage, FullName
from Staff
join Position P on P.ID = Staff.PositionID
where LibraryID = 4 -- любое ID по необходимости
order by PositionID;

-- 4) Отображение списка всех выдач для любого читателя TODO добавить фильтр библиотеки
select R2.FullName, LendingDate, ReturnDate, S.FullName as StuffFIO, B.Name as Book
from BooksLending BL
join BookToLending BTL on BL.ID = BTL.LendingID
join Book B on B.ID = BTL.BookID
join Reader R2 on R2.ID = BL.ReaderID
join Staff S on S.ID = BL.StaffID
where ReaderID = 4 -- любое ID по необходимости
order by LendingDate;

-- 5) Отображение всех книг по жанрам и авторам. TODO добавить фильтр библиотеки
select *
from Book
join BookToGenre BTG on Book.ID = BTG.BookID
join Genre G on G.ID = BTG.GenreID
where G.Name like '%Роман%' --Любое название жанра
order by Book.Name;
select *
from Book
join Author A on A.ID = Book.AuthorID
where A.FullName like '%Толстой%' --Любое имя автора
order by Book.Name;

-- АНАЛИТИЧЕСКИЕ

-- 6) Выявление самых эффективных работников (По кол-ву выдач) TODO добавить фильтр библиотеки
select top 30 percent S.FullName, count(BL.ID) as LendingsCount --Имя для наглядности, лучше заменить на ID
from Staff S
left join BooksLending BL on S.ID = BL.StaffID
group by S.FullName
order by count(BL.ID) desc;

-- 7) Определение популярности книг. TODO добавить фильтр библиотеки
select Book.Name, count(BL.ID) as LendingsCount
from Book
join BookToLending BTL on Book.ID = BTL.BookID
join BooksLending BL on BL.ID = BTL.LendingID
group by Book.Name
order by count(BL.ID) desc;

-- 8) Выявление самых востребованных жанров и секций. TODO добавить фильтр библиотеки
select S.Name, count(BL.ID) as LendingsCount
from Section S
join Book B on S.ID = B.SectionID
join BookToLending BTL on B.ID = BTL.BookID
join BooksLending BL on BL.ID = BTL.LendingID
join Library L on S.LibraryID = L.ID
where L.ID = 4 --конкретная библиотека
group by S.Name;
select top 30 percent G.Name, count(BL.ID) as LendingsCount
from Genre G
join BookToGenre BTG on G.ID = BTG.GenreID
join Book B on B.ID = BTG.BookID
join BookToLending BTL on B.ID = BTL.BookID
join BooksLending BL on BL.ID = BTL.LendingID
join Section S on B.SectionID = S.ID
join Library L on S.LibraryID = L.ID
where L.ID = 4 --конкретная библиотека
group by G.Name
order by count(BL.ID) desc;

-- 9) Рейтинг читателя (на основе своевременных возращений книг,
-- пожертвовании книг в библиотеку и т.д.) TODO добавить фильтр библиотеки + кол-во выдач пожертвованых книг

select R.ID, (select FullName from Reader R2 where R2.ID = R.ID) as FIO,
       count(BL.ID) as LendingsCount, count(distinct B.ID) as BooksDonatedCount
from Reader R
left join Book B on R.ID = B.DonatorID
left join BooksLending BL on R.ID = BL.ReaderID and
                             datediff(day, BL.LendingDate, BL.ReturnDate) < 30 and
                             BL.ReturnDate is not null
group by R.ID;

-- 10) Возможность отслеживать сколько выдавалось книг за месяц. TODO добавить фильтр библиотеки
select count(*) as MonthLendingsCount
from BooksLending BL
where month(BL.LendingDate) = month(getdate()) and --Любая необходимая дата
      year(BL.LendingDate) = year(getdate());

/* 2. UPDATE в разных таблицах, с WHERE, можно условно, например,
   изменить заранее созданные некорректные данные (5 шт.) */

-- Некорректные данные
insert into Author(fullname, dateofbirth, dateofdeath, citizenship) values
    ('А. Дюма', '1802-07-24', '1871-12-05', 'Франция');

insert into PublishingHouse(name, headofficeaddress) values
    ('Верхне-Волжское книжное издательство', 'ул. Трефолева, 12, Ярославль, Ярославская обл., 150000');

insert into BooksSupply([bulk], date, suppliername) values
    (30, '2020-03-24', 'OZON');

insert into Book(Name, OriginalLanguage, PagesCount, SectionID, SupplyID, PublishingHouseID,
                  AuthorID, PublishingYear) values
    ('Шевалье д`Арманталь', 'Французкий', 399, 2, 10, 1, 4, 1991);

insert into Library(name, address) values
    ('Библиотека     №9', 'Россия, Волгоград, Кузнецкая ул., 73');

-- 1) Изменить некорректный год рождения автора
update Author
set DateOfDeath = '1870-12-05'
where ID = 14;

-- 2) Изменить неправильный формат адреса для издательского дома
update PublishingHouse
set HeadOfficeAddress = 'Ярославль, ул. Трефолева, 12'
where ID = 11;

-- 3) Увеличить объем поставки на 2
update BooksSupply
set [Bulk] += 2
where ID = 11;

-- 4) Изменить неправильные айди поставки, издательского дома и автора
update Book
set SupplyID = 11,
    PublishingHouseID = 11,
    AuthorID = 14
where ID = 17;

-- 5) Убрать лишние пробелы в названии библиотеки
update Library
set Name = trim(Name)
where Name = '   Библиотека №9  ';

/* 3. DELETE в разных таблицах, с WHERE, можно условно, например,
   удалить заранее созданные некорректные данные (5 шт.) */

-- 1) Удалить ненужную книгу
delete Book where ID = 17;

-- 2) Удалить ненужного автора
delete Author where ID = 14;

-- 3) Удалить ненужный издательский дом
delete PublishingHouse where ID = 11;

-- 4) Удалить ненужную поставку
delete BooksSupply where ID = 11;

-- 5) Удалить ненужную библиотеку
delete Library where ID = 14;

/* 4. SELECT, DISTINCT, WHERE, AND/OR/NOT, IN, BETWEEN, различная работа
   с датами и числами, преобразование данных, IS NULL, AS для таблиц и
   столбцов и др. в различных вариациях (15 шт. +) */

-- 1) Получить всю информацию о всех библиотеках
select * from Library;

-- 2) Получить уникальные часы работы
select distinct OpeningTime, ClosingTime
from OpeningHours;

-- 3) Получить ФИО всего персонала библиотеки с ID 4
select FullName as [ФИО]
from Staff
where LibraryID = 4;

-- 4) Получить все должности с ЗП >= 100к
select Name as [Должность]
from Position
where Wage >= 100000;

-- 5) Получить всех живых авторов из Англии и США
select FullName, DateOfBirth, Citizenship
from Author
where (Citizenship = 'Англия' or Citizenship = 'США') and DateOfDeath is null;

-- 6) Получить книги написанные на Немецком, Русском или Французком
select Name, OriginalLanguage
from Book
where OriginalLanguage in(N'Немецкий', N'Русский', N'Французкий');

-- 7) Получить читальные залы вместимостью между 35 и 60 человек
select *
from ReadingRoom
where Capacity between 35 and 60;

-- 8) Получить все пожертвованые книги у которых страниц больше 500
select Name, PagesCount
from Book
where PagesCount > 500 and DonatorID is not null;

-- 9) Получить все секции у которых есть информация о нахождении
select Name, Location
from Section
where Location is not null;

-- 10) Получить все должности с зп между 70к и 140к
select Name, Wage
from Position
where Wage between 70000 and 140000;

-- 11) Получить все поставки c 30 марта по 12 ноября 21 года
select *
from BooksSupply
where Date between '2021-03-30' and '2021-11-12';

-- 12) Получить все поставки с 20 года и объёмом больше 70 книг
select Date, SupplierName as Supplier, [Bulk]
from BooksSupply
where Date >= '2020-01-01' and [Bulk] > 70;

-- 13) Узнать все выдачи после 10 сентября 21 года, которые были возращены
select LendingDate as [Дата получения], ReturnDate as [Дата возвращения]
from BooksLending
where LendingDate > '2021-09-10' and ReturnDate is not null;

-- 14) Узнать были ли выдачи в читальный зал 10 и 11 сентября 21 года
select distinct LendingDate, ReadingRoomID
from BooksLending
where LendingDate in('2021-09-10', '2021-09-11') and ReadingRoomID is not null;

-- 15) Получить всех должников
select FullName as [Фио должника]
from Reader
where Debt = 'true';

/* 5. LIKE и другая работа со строками (5-7 шт.+) */

-- 1) Найти все издательские дома из Москвы
select *
from PublishingHouse
where HeadOfficeAddress like 'Москва%';

-- 2) Найти всех читателей мужчин
select *
from Reader
where FullName like '%и_';

-- 3) Узнать всех поставщиков с названием на латинице
select distinct SupplierName
from BooksSupply
where SupplierName not like '[А-Я]%';

-- 4) Получить все библиотеки Волгограда
select Name, Address
from Library
where Address like '%[Вв]олгоград%'

-- 5) Список всех поставок в 21 году
select SupplierName, Date
from BooksSupply
where Date like '__21%';

-- 6) Список всех издательских домов с адресом формата: Город, улица, дом[, стр. N].
select Name, HeadOfficeAddress
from PublishingHouse
where HeadOfficeAddress like '[А-Я]%, [а-я]%, %[0-9].';

-- 7) Проверка на корректно заданое ФИО у работников
select FullName
from Staff
where FullName like '[А-Я][а-я]% [А-Я][а-я]% [А-Я][а-я]%';

/* 6. SELECT INTO или INSERT SELECT, что поддерживается СУБД (2-3 шт.). Для использования
   запроса INSERT SELECT вначале можно создать новую тестовую таблицу или несколько,
   в которые будут скопированы данные из существующих таблиц с помощью данного запроса.
   Код создания таблиц также приложить в лабораторную работу */

-- 1) Создать копию таблицы библиотек и вывести её
go
select *
into LibraryCpy
from Library;
select * from LibraryCpy;
drop table LibraryCpy; go

-- 2) Создать список всех жанров в бд в новой таблице
go
select Name
into GenreNames
from Genre;
select * from GenreNames;
drop table GenreNames;

-- 3) Создать отдельную таблицу для русскоязычных авторов
go
create table RussianAuthors
(
    ID          int identity,
    FullName    varchar(50) not null,
    DateOfBirth date        not null,
    DateOfDeath date
);
insert into RussianAuthors(FullName, DateOfBirth, DateOfDeath)
select FullName, DateOfBirth, DateOfDeath
from Author
where Citizenship like 'Россия%';
select * from  RussianAuthors;
drop table RussianAuthors; go

/* 7. JOIN: INNER, OUTER (LEFT, RIGHT, FULL), CROSS, NATURAL, разных, в различных
   вариациях, несколько запросов с более, чем одним JOIN (15 шт.+) */

-- 1) Полное расположение читальных залов
select R.Location as ReadingRoomLocation, L.Name as LibraryName, L.Address as LibraryAdress
from ReadingRoom R
inner join Library L on L.ID = R.LibraryID;

-- 2) Полное расположение секций
select S.Name as SectionName, S.Location as SectionLocation, L.Name as LibraryName, L.Address as LibraryAdress
from Section S
inner join Library L on L.ID = S.LibraryID;

-- 3) Инфо о дате выдачи, ФИО персонала, совершившего выдачу, и ФИО читателя
select BL.LendingDate as LendingDate, S.FullName as StaffFIO, R2.FullName as ReaderFIO
from BooksLending BL
inner join Reader R2 on R2.ID = BL.ReaderID
inner join Staff S on S.ID = BL.StaffID;

-- 4) Инфо о книге: название, издательский дом, секция, автор
select B.Name as BookName, A.FullName as AuthorFIO, PH.Name as PublishingHouseName, S.Name as Section
from Book B
inner join Author A on A.ID = B.AuthorID
inner join Section S on S.ID = B.SectionID
inner join PublishingHouse PH on PH.ID = B.PublishingHouseID;

-- 5) Инфо о выдачи и расположении читального зала, если выдача была в читальный зал
select BL.LendingDate as LendingDate, RR.Location as ReadingRoomLocation
from BooksLending BL
left join ReadingRoom RR on RR.ID = BL.ReadingRoomID;

-- 6) Инфо о книге: дата поставки (если есть), название, Жанр
select B.Name as BookName, G.Name as Ganre, BS.Date as SupplyDate
from Book B
join BookToGenre BTG on B.ID = BTG.BookID
join Genre G on G.ID = BTG.GenreID
left join BooksSupply BS on B.SupplyID = BS.ID;

-- 7) Инфо о книге: название, имя подарившего, имя читателя
select B.Name as BookName, R2.FullName as DonaterFIO, R3.FullName as ReaderFIO
from Book B
left join Reader R2 on R2.ID = B.DonatorID
join BookToLending BTL on B.ID = BTL.BookID
join BooksLending BL on BL.ID = BTL.LendingID
join Reader R3 on R3.ID = BL.ReaderID;

-- 8) Инфо о выдачи, если выдача была в читальный зал, и расположении читального зала
select BL.LendingDate as LendingDate, RR.Location as ReadingRoomLocation
from BooksLending BL
right join ReadingRoom RR on RR.ID = BL.ReadingRoomID;

-- 9) Инфо о поставке: дата поставки, название и жанр книг в этой поставке (если есть)
select B.Name as BookName, G.Name as Ganre, BS.Date as SupplyDate
from Book B
join BookToGenre BTG on B.ID = BTG.BookID
join Genre G on G.ID = BTG.GenreID
right join BooksSupply BS on B.SupplyID = BS.ID;

-- 10) Инфо о выдачи и расположении читального зала
select BL.LendingDate as LendingDate, RR.Location as ReadingRoomLocation
from BooksLending BL
full join ReadingRoom RR on RR.ID = BL.ReadingRoomID;

-- 11) Инфо о книге: дата поставки, название, Жанр
select B.Name as BookName, G.Name as Ganre, BS.Date as SupplyDate
from Book B
join BookToGenre BTG on B.ID = BTG.BookID
join Genre G on G.ID = BTG.GenreID
full join BooksSupply BS on B.SupplyID = BS.ID;

-- 12) Все комбинации книг и жанров
select B.Name, G.Name
from Book B
cross join Genre G;

-- 13) Все комбинации книг и выдач
select B.Name, BL.LendingDate
from Book B
cross join BooksLending BL;

-- 14) Полная информация о библиотеке
select L.Name, L.Address, RR.Location as ReadingRoomLocation, RR.Capacity as ReadingRoomCapacity,
       S.Location as SectionLoacation, S.Name as SectionName, S2.FullName as StaffFIO,
       OH.OpeningTime, OH.ClosingTime, OH.DayOfTheWeek as OpeningDay
from Library L
left join OpeningHours OH on L.ID = OH.LibraryID
left join ReadingRoom RR on L.ID = RR.LibraryID
left join Section S on L.ID = S.LibraryID
left join Staff S2 on L.ID = S2.LibraryID;

-- 15) Полная информация о персонале
select S.FullName as FIO, L.Name as Job, P.Name as Position
from Staff S
join Library L on L.ID = S.LibraryID
join Position P on P.ID = S.PositionID;

/* 8. GROUP BY (некоторые с HAVING), с LIMIT, ORDER BY (ASC|DESC) вместе с COUNT,
   MAX, MIN, SUM, AVG в различных вариациях, можно по отдельности (15 шт.+) */

-- 1) Отсортировать страны по кол-ву авторов в них по убыванию
select Citizenship, count(FullName) as AuthorsCount
from Author
group by Citizenship
order by count(FullName) desc;

-- 2) Узнать сколько поставок было у каждого поставщика, отсортировать по имени
select SupplierName, count(ID) as Count
from BooksSupply
group by SupplierName
order by SupplierName;

-- 3) Отсротировать страны по средней продолжительности жизни в них по возрастанию
select Citizenship, avg(datediff(YEAR, DateOfBirth, DateOfDeath)) as AvgLife
from Author
where DateOfDeath is not null
group by Citizenship
order by avg(datediff(YEAR, DateOfBirth, DateOfDeath)) asc;

-- 4) Получить страны где минимальная продолжительность жизни больше 60
select Citizenship, min(datediff(YEAR, DateOfBirth, DateOfDeath)) as MinLife
from Author
where DateOfDeath is not null
group by Citizenship
having min(datediff(YEAR, DateOfBirth, DateOfDeath)) > 60
order by min(datediff(YEAR, DateOfBirth, DateOfDeath)) asc;

-- 5) Отсортировать библиотеки по макимальной вместимости читального зала
select L.Name as LibName, max(ALL RR.Capacity) as ReadingRoomMaxCapacity
from Library L
join ReadingRoom RR on L.ID = RR.LibraryID
group by L.Name
order by max(ALL RR.Capacity) desc;

-- 6) Отсортировать библиотеки по суммарной вместимости читальных залов
select L.Name as LibName, sum(ALL RR.Capacity) as ReadingRoomMaxCapacity
from Library L
join ReadingRoom RR on L.ID = RR.LibraryID
group by L.Name
order by sum(ALL RR.Capacity) desc;

-- 7) Получить топ 3 страны по кол-ву авторов
select top 3 Citizenship, count(FullName) as AuthorsCount
from Author
group by Citizenship
order by count(FullName) desc;

-- 8) Получить количество должников
select concat('Кол-во должников: ', count(ID))
from Reader
group by Debt
having Debt = 'true';

-- 9) Отсортировать библиотеки по кол-ву сотрудников
select L.Name as LibName, count(S.ID) as StuffCount
from Library L
join Staff S on L.ID = S.LibraryID
group by L.Name
order by sum(S.ID) desc;

-- 10) Получить количество секций в каждом здании, на кажом этаже, в каждой библиотеке
select Location, count(Name)
from Section
group by LibraryID, Location
having Location is not null;

-- 11) Средние часы работы для каждого дня недели
select DayOfTheWeek, avg(datediff(hour, OpeningTime, ClosingTime)) as AvgWorkingHours
from OpeningHours
group by DayOfTheWeek
order by avg(datediff(hour, OpeningTime, ClosingTime)) desc;

-- 12) Минимальные часы работы для каждого дня недели
select DayOfTheWeek, min(datediff(hour, OpeningTime, ClosingTime)) as MinWorkingHours
from OpeningHours
group by DayOfTheWeek
order by min(datediff(hour, OpeningTime, ClosingTime)) desc;

-- 13) Макимальны часы работы для каждого дня недели
select DayOfTheWeek, max(datediff(hour, OpeningTime, ClosingTime)) as MaxWorkingHours
from OpeningHours
group by DayOfTheWeek
order by max(datediff(hour, OpeningTime, ClosingTime)) desc;

-- 14) Общее часы работы для каждого дня недели
select DayOfTheWeek, sum(datediff(hour, OpeningTime, ClosingTime)) as SumWorkingHours
from OpeningHours
group by DayOfTheWeek
order by sum(datediff(hour, OpeningTime, ClosingTime)) desc;

-- 15) Кол-во людей на каждой позиции
select PositionID, count(Staff.FullName) as Count
from Staff
group by PositionID;

/* 9. UNION, EXCEPT, INTERSECT, что поддерживается СУБД (3-5 шт.) */

-- 1) Все люди в базе данных
select FullName from Staff
union
select FullName from Reader;

-- 2) Персонал, который также является читателями
select FullName from Staff
intersect
select FullName from Reader;

-- 3) Персонал, который не являетя читателями
select FullName from Staff
except
select FullName from Reader;

-- 4) Издатели, которые также являются поставщиками
select Name from PublishingHouse
intersect
select SupplierName from BooksSupply;

-- 5) Издатели, которые не являются поставщиками
select Name from PublishingHouse
except
select SupplierName from BooksSupply;

/* 10. Вложенные SELECT с GROUP BY, ALL, ANY, EXISTS (3-5 шт.) */

-- 1) Получить сотрудников с ЗП выше средней
select FullName
from Staff
join Position P on P.ID = Staff.PositionID
where (
    select avg(Position.Wage)
    from Position) > P.Wage;

-- 2) Максимальный объем общих поставок среди всех поставщиков
select max(S.SumBulk) as MaxBulk
from (
     select SupplierName, sum([Bulk]) as SumBulk
     from BooksSupply
     group by SupplierName) as S;

-- 3) Библиотеки, которые имеют содрудников в БД
select *
from Library L
where exists(
    select *
    from Staff S
    where S.LibraryID = L.ID
          );

-- 4) Библиотеки, которые не имеют содрудников в БД
select *
from Library L
where not exists(
    select *
    from Staff S
    where S.LibraryID = L.ID
          );

-- 5) Получить персонал с макимальной зарплатой
select FullName, P.Name, P.Wage, LibraryID
from Staff S
join Position P on P.ID = S.PositionID
where P.Wage > all (
    select P2.Wage
    from Position P2
    where P2.Wage <> P.Wage
    );

/* 11. GROUP_CONCAT и другие разнообразные функции SQL (2-3 шт.) */

-- 1) Список всех авторов по странам
select Citizenship, string_agg(FullName, ', ') as Authors
from Author
group by Citizenship
order by Citizenship;

-- 2) Список всех книг по жанрам
select G.Name as Genre, string_agg(Book.Name, ', ') as Books
from Book
join BookToGenre BTG on Book.ID = BTG.BookID
join Genre G on G.ID = BTG.GenreID
group by G.Name;

-- 3) Список всех читателей по дням
select LendingDate as Day, string_agg(R2.FullName, ', ') as Readers
from BooksLending
join Reader R2 on R2.ID = BooksLending.ReaderID
group by LendingDate;

/* 12. Запросы с WITH (2-3 шт.) */

-- 1) СВО с названием библиотеки и характеристиками её читальных залов
with LibraryReadingRoomTMP (Library, ReadingRoomCapacity, ReadingRoomLocation)
as (
    select L.Name, Capacity, Location
    from ReadingRoom
    join Library L on L.ID = ReadingRoom.LibraryID
    )
select * from LibraryReadingRoomTMP;

-- 2) Получить иерархию(условно) должностей
with PositionCTE(PositionID, Position, SuperiorID, LevelUser)
as (
    select ID, Name, NULL as SuperiorID, 0 as LevelUser
    from Position P
    where P.ID = 3
    union all
    select P2.ID, P2.Name, P2.ID - 1 as SuperiorID, PC.LevelUser + 1
    from Position P2
    join PositionCTE PC on PC.PositionID = P2.ID - 1
    where P2.ID <> 3
    )
select * from PositionCTE;

/* 13. Запросы со строковыми функциями СУБД, с функциями работы с датами
   временем (форматированием дат), с арифметическими функциями (5-7 шт.) */

-- 1) Таблица библиотек одной колонкой
select concat_ws(' | ', ID, Name, Address) as LibInfo
from Library;

-- 2) Вывести только фамилии сотрудников в БД
select substring(FullName, 1, charindex(' ', FullName)) as StaffSurname
from Staff;

-- 3) Узнать сколько дней у читателей находились книги
select concat(Reader.FullName, ' - ', datediff(day, BL.LendingDate, BL.ReturnDate)) as LendingInfo
from Reader
join BooksLending BL on Reader.ID = BL.ReaderID
where BL.ReturnDate is not null

-- 4) Определить сколько дней прошло с последней поставки
select datediff(day, max(Date), getdate())
from BooksSupply;

-- 5) Преобразовать даты выдачи в общепринятый в России формат
select format(LendingDate, 'd', 'ru-RU') as FormattedLendingDates
from BooksLending;

/* 14. Сложные запросы, входящие в большинство групп выше, т.е.
   SELECT ... JOIN ... JOIN ... WHERE ... GROUP BY ... ORDER BY ...
   LIMIT ...; (5-7 шт. +), можно написать больше вместо простых. */

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
where (RR.Capacity > 45) and (S2. location is not null) and
      (P.Wage between 100000 and 200000) and OH.DayOfTheWeek in ('Среда', 'Четверг')
order by L.Name asc, S.PositionID;

-- 2) Сколько раз брали книгу, которую принёс каждый читатель
select R2.ID, (select FullName from Reader where Reader.ID = R2.ID) as DonaterFIO,
       count(BL.ID) as BooksPopularity
from Book
join BookToLending BTL on Book.ID = BTL.BookID
join BooksLending BL on BL.ID = BTL.LendingID
join Reader R2 on R2.ID = Book.DonatorID
group by R2.ID
order by count(BL.ID) desc;

-- 3) Какие секции книг обслуживали работники
select S.FullName, string_agg(S2.Name, char(13))as Sections
from BooksLending
join BookToLending BTL on BooksLending.ID = BTL.LendingID
join Book B on B.ID = BTL.BookID
join Section S2 on B.SectionID = S2.ID
join Staff S on S.ID = BooksLending.StaffID
group by S.ID, S.FullName;

-- 4) Сколько у каждого изд. дома было уникальных читателей
select PH.Name, count(distinct ReaderID) as UnicReadersCount
from PublishingHouse PH
join Book B on PH.ID = B.PublishingHouseID
join BookToLending BTL on B.ID = BTL.BookID
join BooksLending BL on BL.ID = BTL.LendingID
join Reader R2 on R2.ID = BL.ReaderID
group by PH.ID, PH.Name
order by count(distinct ReaderID) desc;

-- 5) Сколько библиотека потратила денег на зарплаты сотрудникам за год
select L.Name as Library, format(sum(all P.Wage) * 12, 'C0', 'en-RU') as SalaryExpenses
from Library L
join Staff S on L.ID = S.LibraryID
join Position P on P.ID = S.PositionID
group by L.ID, L.Name;

/* Модификация */

-- 1) Для заданного читателя, в заданной библиотеке, в заданный период (Between) вывести
-- список взятий и возращений книг, через запятую названия книг, упорядочить по дате взятия по убыванию топ 3
select top 3 BL.LendingDate as LendingDate, BL.ReturnDate as ReturnDate, string_agg(B.Name, ', ') as Books
from Reader R
join BooksLending BL on R.ID = BL.ReaderID
join BookToLending BTL on BL.ID = BTL.LendingID
join Book B on B.ID = BTL.BookID
join Section S on S.ID = B.SectionID
join Library L on S.LibraryID = L.ID
where R.ID = 2 and L.ID = 4 and (BL.LendingDate between '2021-01-01' and '2021-12-31') -- Заданные данные
group by BL.LendingDate, BL.ReturnDate
order by  BL.LendingDate desc;

-- 2) Для заданной библиотеки, для заданной секции вывести все книги заданного автора
select B.Name as Books
from Library L
join Section S on L.ID = S.LibraryID
join Book B on S.ID = B.SectionID
join Author A on A.ID = B.AuthorID
where A.FullName like '%Рихтер%' and L.ID = 4 and -- Заданные данные
      lower(S.Name) like '%техническая литература%';

-- 3) Кол-во уникальных пользователей в каждой библиотеке
select L.Name as Library, count(distinct R2.ID) as ReadersCount
from Library L
left join Section S on L.ID = S.LibraryID
left join Book B on S.ID = B.SectionID
left join BookToLending BTL on B.ID = BTL.BookID
left join BooksLending BL on BL.ID = BTL.LendingID
left join Reader R2 on R2.ID = BL.ReaderID
group by L.Name
order by ReadersCount desc;