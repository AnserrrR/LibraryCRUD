namespace LibraryWebApi.Models
{
    public class Book
    {
        public int Id { get; set; }

        public string Name { get; set; }

        public string OriginalLanguage { get; set; }

        public int PagesCount { get; set; }

        public int SectionId { get; set; }

        public string PublishingHouseId { get; set; }

        public int AuthorId { get; set; }

        public int PublishingYear { get; set; }

        public int[]? GenresId { get; set; } 
    }
}
