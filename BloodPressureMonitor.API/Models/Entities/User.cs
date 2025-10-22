using System;

namespace BloodPressureMonitor.API.Models.Entities
{
    /// <summary>
    /// Represents a user account in the system
    /// </summary>
    public class User
    {
        /// <summary>
        /// Unique identifier for the user (internal database ID)
        /// </summary>
        public Guid UserId { get; set; }

        /// <summary>
        /// Clerk User ID (from Clerk authentication system)
        /// This is the primary identifier for authenticated users
        /// </summary>
        public string? ClerkUserId { get; set; }

        /// <summary>
        /// User's email address
        /// </summary>
        public string Email { get; set; } = string.Empty;

        /// <summary>
        /// BCrypt hashed password (legacy - now optional with Clerk)
        /// Nullable because Clerk handles authentication
        /// </summary>
        public string? PasswordHash { get; set; }

        /// <summary>
        /// User's first name
        /// </summary>
        public string? FirstName { get; set; }

        /// <summary>
        /// User's last name
        /// </summary>
        public string? LastName { get; set; }

        /// <summary>
        /// User's date of birth
        /// </summary>
        public DateTime? DateOfBirth { get; set; }

        /// <summary>
        /// Storage quota in MB (default 500MB)
        /// </summary>
        public int StorageQuotaMB { get; set; } = 500;

        /// <summary>
        /// Current storage used in MB (calculated field)
        /// </summary>
        public decimal CurrentStorageUsedMB { get; set; }

        /// <summary>
        /// Indicates if the user account is active
        /// </summary>
        public bool IsActive { get; set; } = true;

        /// <summary>
        /// Last login timestamp
        /// </summary>
        public DateTime? LastLoginDate { get; set; }

        /// <summary>
        /// Account creation timestamp
        /// </summary>
        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// Last modification timestamp
        /// </summary>
        public DateTime ModifiedDate { get; set; } = DateTime.UtcNow;
    }
}