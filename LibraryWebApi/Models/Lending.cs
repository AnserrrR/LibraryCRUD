namespace LibraryWebApi.Models
{
    public class Lending
    {
        public int Id { get; set; }

        public string LendingDate { get; set; }

        public string? ReturnDate { get; set; }

        public int ReaderId { get; set; }

        public int? ReadingRoomId { get; set; }

        public int StaffId { get; set; }
    }
}
