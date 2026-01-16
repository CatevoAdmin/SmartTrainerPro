using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace SmartTrainerPro.Api.Data
{
    public class Practitioner
    {
        public int Id { get; set; }
        [Required]
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        
        [JsonIgnore] // Prevent cycles
        public List<User> Patients { get; set; } = new();
    }

    public class User
    {
        public int Id { get; set; }
        [Required]
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;

        // Foreign Key to Practitioner
        public int? PractitionerId { get; set; }
        [JsonIgnore]
        public Practitioner? Practitioner { get; set; }
        
        public List<Prescription> Prescriptions { get; set; } = new();
    }

    public class Prescription
    {
        public int Id { get; set; }
        [Required]
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public int TargetWatts { get; set; }
        public int DurationMinutes { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public bool IsCompleted { get; set; }

        // Foreign Key to User
        public int UserId { get; set; }
        [JsonIgnore]
        public User? User { get; set; }
    }

    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<Practitioner> Practitioners { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<Prescription> Prescriptions { get; set; }
    }
}
