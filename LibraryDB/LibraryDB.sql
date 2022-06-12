use LibraryDB;

bulk insert Genre from '/genres1.csv'
with (
    fieldterminator  = ',',
    rowterminator = '\n',
    firstrow = 1
    );

DBCC CHECKIDENT (BooksLending, RESEED, 10);

