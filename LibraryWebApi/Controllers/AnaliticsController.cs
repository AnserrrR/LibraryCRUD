using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Data;
using System.Data.SqlClient;

namespace LibraryWebApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AnaliticsController : ControllerBase
    {
        private readonly IConfiguration _configuration;

        public AnaliticsController(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        [Route("Staff")]
        [HttpGet]
        public JsonResult GetTopWorkers()
        {
            string query = @"
                            select top 30 percent S.ID as ID, S.FullName as StaffName, count(BL.ID) as LendingsCount
                            from Staff S
                            left join BooksLending BL on S.ID = BL.StaffID
                            group by S.ID, S.FullName
                            order by count(BL.ID) desc
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


        [Route("Books")]
        [HttpGet]
        public JsonResult GetTopBooks()
        {
            string query = @"
                            select Book.ID as ID, Book.Name as BookName, count(BL.ID) as LendingsCount
                            from Book
                            join BookToLending BTL on Book.ID = BTL.BookID
                            join BooksLending BL on BL.ID = BTL.LendingID
                            group by Book.ID, Book.Name
                            order by count(BL.ID) desc
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

        [Route("Readers")]
        [HttpGet]
        public JsonResult GetTopReaders()
        {
            string query = @"
                            select R.ID as ID, R.FullName as ReaderName, count(BL.ID) as DonatedBooksPopularity,
                                    count(distinct B.ID) as DonatedBooksCount, count(distinct BL2.ID) as LendingsCount
                            from Reader R
                            left join Book B on R.ID = B.DonatorID
                            join BookToLending BTL on B.ID = BTL.BookID
                            join BooksLending BL on BL.ID = BTL.LendingID
                            left join BooksLending BL2 on R.ID = BL2.ReaderID and
                                                         datediff(day, BL2.LendingDate, BL2.ReturnDate) < 30 and
                                                         BL2.ReturnDate is not null
                            group by R.ID, R.FullName
                            order by count(BL.ID) desc
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
    }
}
