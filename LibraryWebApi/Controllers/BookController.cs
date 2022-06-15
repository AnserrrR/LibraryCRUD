using LibraryWebApi.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Data;
using System.Data.SqlClient;

namespace LibraryWebApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BookController : ControllerBase
    {
        private readonly IConfiguration _configuration;

        public BookController(IConfiguration configuration)
        {
            _configuration = configuration;
        }


        [HttpGet]
        public JsonResult Get()
        {
            string query = @"
                            select top 500 B.ID as ID, B.Name as Name, B.OriginalLanguage as OriginalLanguage,
                            B.PagesCount as PagesCount, B.SectionID as SectionID, S.Name as SectionName,
                            B.PublishingHouseID as PublishingHouseID, PH.Name as PublishingHouseName, B.AuthorID as AuthorID, 
                            A.FullName as AuthorName, B.PublishingYear as PublishingYear, B2.GenresID as GenresID, B2.GenresNames as GenresNames
                            from (select B2.ID, string_agg(G.ID, ', ') as GenresID, string_agg(G.Name, ', ') as GenresNames
                                  from Book B2
                                  left join BookToGenre BTG on B2.ID = BTG.BookID
                                  left join Genre G on BTG.GenreID = G.ID
                                  group by B2.ID) B2
                            join Book B on B2.ID = B.ID
                            join Author A on A.ID = B.AuthorID
                            join Section S on S.ID = B.SectionID
                            join PublishingHouse PH on PH.ID = B.PublishingHouseID
                            order by B.ID desc
                            ";
            DataTable table = new DataTable();
            string sqlDataSource = _configuration.GetConnectionString("LibraryAppCon");
            SqlDataReader myReader;
            using (SqlConnection myCon = new SqlConnection(sqlDataSource))
            {
                myCon.Open();
                using (SqlCommand myCommand = new SqlCommand(query, myCon))
                {
                    myReader = myCommand.ExecuteReader();
                    table.Load(myReader);
                    myReader.Close();
                    myCon.Close();
                }
            }

            return new JsonResult(table);
        }

        [Route("Section")]
        [HttpGet]
        public JsonResult GetSections()
        {
            string query = @"
                            select ID, Name
                            from Section;
                            ";
            DataTable table = new DataTable();
            string sqlDataSource = _configuration.GetConnectionString("LibraryAppCon");
            SqlDataReader myReader;
            using (SqlConnection myCon = new SqlConnection(sqlDataSource))
            {
                myCon.Open();
                using (SqlCommand myCommand = new SqlCommand(query, myCon))
                {
                    myReader = myCommand.ExecuteReader();
                    table.Load(myReader);
                    myReader.Close();
                    myCon.Close();
                }
            }

            return new JsonResult(table);
        }

        [Route("PublishingHouse")]
        [HttpGet]
        public JsonResult GetPublishingHouses()
        {
            string query = @"
                            select ID, Name
                            from PublishingHouse;
                            ";
            DataTable table = new DataTable();
            string sqlDataSource = _configuration.GetConnectionString("LibraryAppCon");
            SqlDataReader myReader;
            using (SqlConnection myCon = new SqlConnection(sqlDataSource))
            {
                myCon.Open();
                using (SqlCommand myCommand = new SqlCommand(query, myCon))
                {
                    myReader = myCommand.ExecuteReader();
                    table.Load(myReader);
                    myReader.Close();
                    myCon.Close();
                }
            }

            return new JsonResult(table);
        }

        [Route("Author")]
        [HttpGet]
        public JsonResult GetAuthors()
        {
            string query = @"
                            select ID, FullName
                            from Author
                            ";
            DataTable table = new DataTable();
            string sqlDataSource = _configuration.GetConnectionString("LibraryAppCon");
            SqlDataReader myReader;
            using (SqlConnection myCon = new SqlConnection(sqlDataSource))
            {
                myCon.Open();
                using (SqlCommand myCommand = new SqlCommand(query, myCon))
                {
                    myReader = myCommand.ExecuteReader();
                    table.Load(myReader);
                    myReader.Close();
                    myCon.Close();
                }
            }

            return new JsonResult(table);
        }

        [Route("Genre")]
        [HttpGet]
        public JsonResult GetGenres()
        {
            string query = @"
                            select ID, Name
                            from Genre
                            ";
            DataTable table = new DataTable();
            string sqlDataSource = _configuration.GetConnectionString("LibraryAppCon");
            SqlDataReader myReader;
            using (SqlConnection myCon = new SqlConnection(sqlDataSource))
            {
                myCon.Open();
                using (SqlCommand myCommand = new SqlCommand(query, myCon))
                {
                    myReader = myCommand.ExecuteReader();
                    table.Load(myReader);
                    myReader.Close();
                    myCon.Close();
                }
            }

            return new JsonResult(table);
        }

        [HttpPost]
        public JsonResult Post(Book book)
        {
            string query = @"
                           insert into Book (Name, OriginalLanguage, PagesCount, SectionID, PublishingHouseID, AuthorID, PublishingYear)
                           values (@Name, @OriginalLanguage, @PagesCount, @SectionID, @PublishingHouseID, @AuthorID, @PublishingYear)
                            ";
            string btgQuery = @"
                            insert into BookToGenre (BookID, GenreID) 
                            values (ident_current('Book'), @GenreID)
                             ";
           

            DataTable table = new DataTable();
            string sqlDataSource = _configuration.GetConnectionString("LibraryAppCon");
            SqlDataReader myReader;
            using (SqlConnection myCon = new SqlConnection(sqlDataSource))
            {
                myCon.Open();
                using (SqlCommand myCommand = new SqlCommand(query, myCon))
                {
                    myCommand.Parameters.AddWithValue("@Name", book.Name);
                    myCommand.Parameters.AddWithValue("@OriginalLanguage", book.OriginalLanguage);
                    myCommand.Parameters.AddWithValue("@PagesCount", book.PagesCount);
                    myCommand.Parameters.AddWithValue("@SectionID", book.SectionId);
                    myCommand.Parameters.AddWithValue("@PublishingHouseID", book.PublishingHouseId);
                    myCommand.Parameters.AddWithValue("@AuthorID", book.AuthorId);
                    myCommand.Parameters.AddWithValue("@PublishingYear", book.PublishingYear);

                    myReader = myCommand.ExecuteReader();
                    table.Load(myReader);
                    myReader.Close();
                }
                if(book.GenresId is not null)
                {
                    foreach (var genreId in book.GenresId)
                    {
                        using (SqlCommand myCommand = new SqlCommand(btgQuery, myCon))
                        {
                            myCommand.Parameters.AddWithValue("@GenreID", genreId);

                            myReader = myCommand.ExecuteReader();
                            table.Load(myReader);
                            myReader.Close();
                        }
                    }
                }
                myCon.Close();
            }

            return new JsonResult("Added Successfully");
        }

        [HttpPut]
        public JsonResult Put(Book book)
        {
            string query = @"
                            update Book
                            set Name = @Name, OriginalLanguage = @OriginalLanguage, PagesCount = @PagesCount, SectionID = @SectionID,
                            PublishingHouseID = @PublishingHouseID, AuthorID = @AuthorID, PublishingYear = @PublishingYear
                            where ID = @ID
                            ";

            string btgQueryDelete = @"
                            delete from BookToGenre
                            where BookID = @BookID;
                             ";

            string btgQueryInsert = @"
                            insert into BookToGenre (BookID, GenreID)
                            values (@BookID, @GenreID)
                             ";

            DataTable table = new DataTable();
            string sqlDataSource = _configuration.GetConnectionString("LibraryAppCon");
            SqlDataReader myReader;
            using (SqlConnection myCon = new SqlConnection(sqlDataSource))
            {
                myCon.Open();
                using (SqlCommand myCommand = new SqlCommand(query, myCon))
                {
                    myCommand.Parameters.AddWithValue("@ID", book.Id);
                    myCommand.Parameters.AddWithValue("@Name", book.Name);
                    myCommand.Parameters.AddWithValue("@OriginalLanguage", book.OriginalLanguage);
                    myCommand.Parameters.AddWithValue("@PagesCount", book.PagesCount);
                    myCommand.Parameters.AddWithValue("@SectionID", book.SectionId);
                    myCommand.Parameters.AddWithValue("@PublishingHouseID", book.PublishingHouseId);
                    myCommand.Parameters.AddWithValue("@AuthorID", book.AuthorId);
                    myCommand.Parameters.AddWithValue("@PublishingYear", book.PublishingYear);

                    myReader = myCommand.ExecuteReader();
                    table.Load(myReader);
                    myReader.Close();
                }
                using (SqlCommand myCommand = new SqlCommand(btgQueryDelete, myCon))
                {
                    myCommand.Parameters.AddWithValue("@BookID", book.Id);

                    myReader = myCommand.ExecuteReader();
                    table.Load(myReader);
                    myReader.Close();
                }

                if (book.GenresId is not null)
                {
                    foreach (var genreId in book.GenresId)
                    {
                        using (SqlCommand myCommand = new SqlCommand(btgQueryInsert, myCon))
                        {
                            myCommand.Parameters.AddWithValue("@BookID", book.Id);
                            myCommand.Parameters.AddWithValue("@GenreID", genreId);

                            myReader = myCommand.ExecuteReader();
                            table.Load(myReader);
                            myReader.Close();
                        }
                    }
                }
                myCon.Close();
            }

            return new JsonResult("Updated Successfully");
        }

        [HttpDelete("{id}")]
        public JsonResult Delete(int id)
        {
            string query = @"
                           delete from Book
                            where ID = @ID
                            ";

            DataTable table = new DataTable();
            string sqlDataSource = _configuration.GetConnectionString("LibraryAppCon");
            SqlDataReader myReader;
            using (SqlConnection myCon = new SqlConnection(sqlDataSource))
            {
                myCon.Open();
                using (SqlCommand myCommand = new SqlCommand(query, myCon))
                {
                    myCommand.Parameters.AddWithValue("@ID", id);

                    myReader = myCommand.ExecuteReader();
                    table.Load(myReader);
                    myReader.Close();
                    myCon.Close();
                }
            }

            return new JsonResult("Deleted Successfully");
        }

    }
}
