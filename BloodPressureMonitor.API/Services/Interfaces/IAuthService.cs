using BloodPressureMonitor.API.Models.Entities;

namespace BloodPressureMonitor.API.Services.Interfaces;

/// <summary>
/// Authentication service interface
/// Handles user registration, login, and token management
/// </summary>
public interface IAuthService
{
    /// <summary>
    /// Registers a new user with email and password
    /// </summary>
    /// <param name="email">User's email address (must be unique)</param>
    /// <param name="password">Plain text password (will be hashed)</param>
    /// <param name="firstName">User's first name (optional)</param>
    /// <param name="lastName">User's last name (optional)</param>
    /// <returns>Registered user or null if email already exists</returns>
    Task<User?> RegisterUserAsync(string email, string password, string? firstName = null, string? lastName = null);

    /// <summary>
    /// Authenticates a user with email and password
    /// </summary>
    /// <param name="email">User's email address</param>
    /// <param name="password">Plain text password</param>
    /// <returns>User if authentication successful, null otherwise</returns>
    Task<User?> AuthenticateAsync(string email, string password);

    /// <summary>
    /// Generates a JWT token for an authenticated user
    /// </summary>
    /// <param name="user">The user to generate a token for</param>
    /// <returns>JWT token string</returns>
    string GenerateJwtToken(User user);

    /// <summary>
    /// Validates a JWT token
    /// </summary>
    /// <param name="token">JWT token to validate</param>
    /// <returns>UserId if valid, null otherwise</returns>
    Task<Guid?> ValidateTokenAsync(string token);

    /// <summary>
    /// Hashes a plain text password using BCrypt
    /// </summary>
    /// <param name="password">Plain text password</param>
    /// <returns>Hashed password</returns>
    string HashPassword(string password);

    /// <summary>
    /// Verifies a plain text password against a hashed password
    /// </summary>
    /// <param name="password">Plain text password</param>
    /// <param name="passwordHash">Hashed password to compare against</param>
    /// <returns>True if password matches, false otherwise</returns>
    bool VerifyPassword(string password, string passwordHash);
}
