using LibraryWebApi.Models;
using Microsoft.AspNetCore.Mvc;
using System.Data;
using System.Data.SqlClient;

namespace LibraryWebApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class LendingController : ControllerBase
    {
        private readonly IConfiguration _configuration;

        public LendingController(IConfiguration configuration)
        {
            _configuration = configuration;
        }


        [HttpGet]
        public JsonResult Get()
        {
            string query = @"
                            select top 500 BL.ID as ID, BL.LendingDate as LendingDate, BL.ReturnDate as ReturnDate, BL.ReaderID as ReaderID,
                                   R2.FullName as ReaderName, BL.ReadingRoomID as ReadingRoomID, RR.Location as ReadingRoomLocation,
                                   BL.StaffID as StaffID, S.FullName as StaffName, BL3.BooksID as BooksID, BL3.BooksNames as BooksNames
                            from (select BL2.ID, string_agg(B.ID, ', ') as BooksID, string_agg(B.Name, ', ') as BooksNames
                                  from BooksLending BL2
                                  left join BookToLending BTL on BL2.ID = BTL.LendingID
                                  left join Book B on BTL.BookID = B.ID
                                  group by BL2.ID) BL3
                            join BooksLending BL on BL3.ID = BL.ID
                            join Reader R2 on R2.ID = BL.ReaderID
                            left join ReadingRoom RR on RR.ID = BL.ReadingRoomID
                            join Staff S on S.ID = BL.StaffID
                            order by BL.ID desc;
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

        [Route("Reader")]
        [HttpGet]
        public JsonResult GetReaders()
        {
            string query = @"
                            select ID, FullName as Name
                            from Reader;
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

        [Route("ReadingRoom")]
        [HttpGet]
        public JsonResult GetReadingRooms()
        {
            string query = @"
                            select ID, Location
                            from ReadingRoom
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

        [Route("Staff")]
        [HttpGet]
        public JsonResult GetStaff()
        {
            string query = @"
                            select ID, FullName as Name
                            from Staff
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
        public JsonResult Post(Lending lending)
        {
            string query = @"
                           insert into BooksLending(LendingDate, ReturnDate, ReaderID, ReadingRoomID, StaffID)
                            values (@LendingDate, @ReturnDate, @ReaderID, @ReadingRoomID, @StaffID)
                            ";

            DataTable table = new DataTable();
            string sqlDataSource = _configuration.GetConnectionString("LibraryAppCon");
            SqlDataReader myReader;
            using (SqlConnection myCon = new SqlConnection(sqlDataSource))
            {
                myCon.Open();
                using (SqlCommand myCommand = new SqlCommand(query, myCon))
                {
                    myCommand.Parameters.AddWithValue("@LendingDate", lending.LendingDate);
                    myCommand.Parameters.AddWithValue("@ReturnDate", (object)lending.ReturnDate ?? DBNull.Value);
                    myCommand.Parameters.AddWithValue("@ReaderID", lending.ReaderId);
                    myCommand.Parameters.AddWithValue("@ReadingRoomID", (object)lending.ReadingRoomId ?? DBNull.Value);
                    myCommand.Parameters.AddWithValue("@StaffID", lending.StaffId);

                    myReader = myCommand.ExecuteReader();
                    table.Load(myReader);
                    myReader.Close();
                    myCon.Close();
                }
            }

            return new JsonResult("Added Successfully");
        }

        [HttpPut]
        public JsonResult Put(Lending lending)
        {
            string query = @"
                            update BooksLending
                            set LendingDate = @LendingDate, ReturnDate = @ReturnDate, 
                            ReaderID = @ReaderID, ReadingRoomID = @ReadingRoomID, StaffID = @StaffID
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
                    myCommand.Parameters.AddWithValue("@ID", lending.Id);
                    myCommand.Parameters.AddWithValue("@LendingDate", lending.LendingDate);
                    myCommand.Parameters.AddWithValue("@ReturnDate", (object)lending.ReturnDate ?? DBNull.Value);
                    myCommand.Parameters.AddWithValue("@ReaderID", lending.ReaderId);
                    myCommand.Parameters.AddWithValue("@ReadingRoomID", (object)lending.ReadingRoomId ?? DBNull.Value);
                    myCommand.Parameters.AddWithValue("@StaffID", lending.StaffId);
                    myReader = myCommand.ExecuteReader();
                    table.Load(myReader);
                    myReader.Close();
                    myCon.Close();
                }
            }

            return new JsonResult("Updated Successfully");
        }

        [HttpDelete("{id}")]
        public JsonResult Delete(int id)
        {
            string query = @"
                           delete from BooksLending
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
