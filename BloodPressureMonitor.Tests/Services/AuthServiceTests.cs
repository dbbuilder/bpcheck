using BloodPressureMonitor.API.Models.Entities;
using BloodPressureMonitor.API.Services.Interfaces;
using FluentAssertions;
using Moq;
using Xunit;

namespace BloodPressureMonitor.Tests.Services;

/// <summary>
/// TDD tests for AuthService
/// Tests written BEFORE implementation
/// </summary>
public class AuthServiceTests
{
    [Fact]
    public void HashPassword_Should_ReturnHashedString()
    {
        // Arrange
        var authService = CreateAuthService();
        var plainPassword = "MySecurePassword123!";

        // Act
        var hashedPassword = authService.HashPassword(plainPassword);

        // Assert
        hashedPassword.Should().NotBeNullOrEmpty();
        hashedPassword.Should().NotBe(plainPassword);
        hashedPassword.Should().StartWith("$2"); // BCrypt hash prefix
    }

    [Fact]
    public void HashPassword_Should_ProduceDifferentHashesForSamePassword()
    {
        // Arrange
        var authService = CreateAuthService();
        var password = "TestPassword123!";

        // Act
        var hash1 = authService.HashPassword(password);
        var hash2 = authService.HashPassword(password);

        // Assert - BCrypt uses salt, so hashes should differ
        hash1.Should().NotBe(hash2);
    }

    [Fact]
    public void VerifyPassword_Should_ReturnTrue_WhenPasswordMatches()
    {
        // Arrange
        var authService = CreateAuthService();
        var password = "CorrectPassword123!";
        var hashedPassword = authService.HashPassword(password);

        // Act
        var result = authService.VerifyPassword(password, hashedPassword);

        // Assert
        result.Should().BeTrue();
    }

    [Fact]
    public void VerifyPassword_Should_ReturnFalse_WhenPasswordDoesNotMatch()
    {
        // Arrange
        var authService = CreateAuthService();
        var correctPassword = "CorrectPassword123!";
        var wrongPassword = "WrongPassword456!";
        var hashedPassword = authService.HashPassword(correctPassword);

        // Act
        var result = authService.VerifyPassword(wrongPassword, hashedPassword);

        // Assert
        result.Should().BeFalse();
    }

    [Fact]
    public async Task RegisterUserAsync_Should_CreateNewUser_WithHashedPassword()
    {
        // Arrange
        var authService = CreateAuthService();
        var email = "newuser@example.com";
        var password = "SecurePassword123!";
        var firstName = "John";
        var lastName = "Doe";

        // Act
        var user = await authService.RegisterUserAsync(email, password, firstName, lastName);

        // Assert
        user.Should().NotBeNull();
        user!.Email.Should().Be(email);
        user.FirstName.Should().Be(firstName);
        user.LastName.Should().Be(lastName);
        user.PasswordHash.Should().NotBe(password); // Password should be hashed
        user.PasswordHash.Should().StartWith("$2"); // BCrypt hash
        user.IsActive.Should().BeTrue();
        user.StorageQuotaMB.Should().Be(500); // Default quota
    }

    [Fact]
    public async Task RegisterUserAsync_Should_ReturnNull_WhenEmailAlreadyExists()
    {
        // Arrange
        var authService = CreateAuthService();
        var email = "existing@example.com";
        var password = "Password123!";

        // Register user first time
        await authService.RegisterUserAsync(email, password);

        // Act - Try to register same email again
        var duplicateUser = await authService.RegisterUserAsync(email, password);

        // Assert
        duplicateUser.Should().BeNull();
    }

    [Fact]
    public async Task AuthenticateAsync_Should_ReturnUser_WithValidCredentials()
    {
        // Arrange
        var authService = CreateAuthService();
        var email = "test@example.com";
        var password = "ValidPassword123!";

        // Register user first
        var registeredUser = await authService.RegisterUserAsync(email, password);

        // Act - Authenticate with same credentials
        var authenticatedUser = await authService.AuthenticateAsync(email, password);

        // Assert
        authenticatedUser.Should().NotBeNull();
        authenticatedUser!.UserId.Should().Be(registeredUser!.UserId);
        authenticatedUser.Email.Should().Be(email);
    }

    [Fact]
    public async Task AuthenticateAsync_Should_ReturnNull_WithInvalidPassword()
    {
        // Arrange
        var authService = CreateAuthService();
        var email = "test@example.com";
        var correctPassword = "CorrectPassword123!";
        var wrongPassword = "WrongPassword456!";

        // Register user
        await authService.RegisterUserAsync(email, correctPassword);

        // Act - Try to authenticate with wrong password
        var authenticatedUser = await authService.AuthenticateAsync(email, wrongPassword);

        // Assert
        authenticatedUser.Should().BeNull();
    }

    [Fact]
    public async Task AuthenticateAsync_Should_ReturnNull_WithNonExistentEmail()
    {
        // Arrange
        var authService = CreateAuthService();
        var email = "nonexistent@example.com";
        var password = "AnyPassword123!";

        // Act - Try to authenticate without registering
        var authenticatedUser = await authService.AuthenticateAsync(email, password);

        // Assert
        authenticatedUser.Should().BeNull();
    }

    [Fact]
    public void GenerateJwtToken_Should_ReturnNonEmptyToken()
    {
        // Arrange
        var authService = CreateAuthService();
        var user = new User
        {
            UserId = Guid.NewGuid(),
            Email = "test@example.com",
            PasswordHash = "hashed",
            FirstName = "John",
            LastName = "Doe"
        };

        // Act
        var token = authService.GenerateJwtToken(user);

        // Assert
        token.Should().NotBeNullOrEmpty();
        token.Split('.').Length.Should().Be(3); // JWT has 3 parts: header.payload.signature
    }

    [Fact]
    public void GenerateJwtToken_Should_ProduceDifferentTokensForDifferentUsers()
    {
        // Arrange
        var authService = CreateAuthService();
        var user1 = new User { UserId = Guid.NewGuid(), Email = "user1@example.com", PasswordHash = "hash1" };
        var user2 = new User { UserId = Guid.NewGuid(), Email = "user2@example.com", PasswordHash = "hash2" };

        // Act
        var token1 = authService.GenerateJwtToken(user1);
        var token2 = authService.GenerateJwtToken(user2);

        // Assert
        token1.Should().NotBe(token2);
    }

    [Fact]
    public async Task ValidateTokenAsync_Should_ReturnUserId_ForValidToken()
    {
        // Arrange
        var authService = CreateAuthService();
        var user = new User
        {
            UserId = Guid.NewGuid(),
            Email = "test@example.com",
            PasswordHash = "hashed"
        };
        var token = authService.GenerateJwtToken(user);

        // Act
        var userId = await authService.ValidateTokenAsync(token);

        // Assert
        userId.Should().NotBeNull();
        userId.Should().Be(user.UserId);
    }

    [Fact]
    public async Task ValidateTokenAsync_Should_ReturnNull_ForInvalidToken()
    {
        // Arrange
        var authService = CreateAuthService();
        var invalidToken = "invalid.jwt.token";

        // Act
        var userId = await authService.ValidateTokenAsync(invalidToken);

        // Assert
        userId.Should().BeNull();
    }

    [Theory]
    [InlineData("")]
    [InlineData("short")]
    [InlineData("NoNumber!")]
    [InlineData("nonumber123")]
    [InlineData("NoSpecial123")]
    public async Task RegisterUserAsync_Should_Reject_WeakPasswords(string weakPassword)
    {
        // Arrange
        var authService = CreateAuthService();
        var email = $"test{Guid.NewGuid()}@example.com";

        // Act & Assert
        var act = async () => await authService.RegisterUserAsync(email, weakPassword);

        // Should throw ArgumentException for weak passwords
        await act.Should().ThrowAsync<ArgumentException>()
            .WithMessage("*password*");
    }

    [Theory]
    [InlineData("invalid-email")]
    [InlineData("@example.com")]
    [InlineData("user@")]
    [InlineData("")]
    public async Task RegisterUserAsync_Should_Reject_InvalidEmails(string invalidEmail)
    {
        // Arrange
        var authService = CreateAuthService();
        var password = "ValidPassword123!";

        // Act & Assert
        var act = async () => await authService.RegisterUserAsync(invalidEmail, password);

        // Should throw ArgumentException for invalid emails
        await act.Should().ThrowAsync<ArgumentException>()
            .WithMessage("*email*");
    }

    /// <summary>
    /// Helper method to create AuthService instance
    /// Note: For now, this creates a mock/in-memory implementation
    /// Once we implement real AuthService with DB, we'll update this
    /// </summary>
    private static IAuthService CreateAuthService()
    {
        // For now, return a mock implementation
        // We'll replace this with the real implementation once we write it
        return new InMemoryAuthService();
    }
}

/// <summary>
/// Temporary in-memory implementation of IAuthService for TDD
/// This allows us to write and run tests before implementing the real service
/// WILL BE REPLACED with actual AuthService implementation
/// </summary>
internal class InMemoryAuthService : IAuthService
{
    private readonly List<User> _users = new();
    private const string JwtSecret = "TestSecretKeyForJwtTokenGenerationMustBe32Characters!";

    public string HashPassword(string password)
    {
        return BCrypt.Net.BCrypt.HashPassword(password);
    }

    public bool VerifyPassword(string password, string passwordHash)
    {
        return BCrypt.Net.BCrypt.Verify(password, passwordHash);
    }

    public Task<User?> RegisterUserAsync(string email, string password, string? firstName = null, string? lastName = null)
    {
        // Validate email
        if (string.IsNullOrWhiteSpace(email))
        {
            throw new ArgumentException("Email cannot be empty", nameof(email));
        }

        // Basic email validation
        var emailParts = email.Split('@');
        if (emailParts.Length != 2 || string.IsNullOrWhiteSpace(emailParts[0]) || string.IsNullOrWhiteSpace(emailParts[1]))
        {
            throw new ArgumentException("Invalid email address", nameof(email));
        }

        // Validate password strength
        if (string.IsNullOrWhiteSpace(password) || password.Length < 8)
        {
            throw new ArgumentException("Password must be at least 8 characters", nameof(password));
        }

        if (!password.Any(char.IsDigit))
        {
            throw new ArgumentException("Password must contain at least one digit", nameof(password));
        }

        if (!password.Any(ch => !char.IsLetterOrDigit(ch)))
        {
            throw new ArgumentException("Password must contain at least one special character", nameof(password));
        }

        // Check if email already exists
        if (_users.Any(u => u.Email == email))
        {
            return Task.FromResult<User?>(null);
        }

        // Create new user
        var user = new User
        {
            UserId = Guid.NewGuid(),
            Email = email,
            PasswordHash = HashPassword(password),
            FirstName = firstName,
            LastName = lastName,
            StorageQuotaMB = 500,
            CurrentStorageUsedMB = 0,
            IsActive = true,
            CreatedDate = DateTime.UtcNow,
            ModifiedDate = DateTime.UtcNow
        };

        _users.Add(user);
        return Task.FromResult<User?>(user);
    }

    public Task<User?> AuthenticateAsync(string email, string password)
    {
        var user = _users.FirstOrDefault(u => u.Email == email);

        if (user == null)
        {
            return Task.FromResult<User?>(null);
        }

        var isValidPassword = VerifyPassword(password, user.PasswordHash);

        return Task.FromResult(isValidPassword ? user : null);
    }

    public string GenerateJwtToken(User user)
    {
        var tokenHandler = new System.IdentityModel.Tokens.Jwt.JwtSecurityTokenHandler();
        var key = System.Text.Encoding.ASCII.GetBytes(JwtSecret);

        var tokenDescriptor = new Microsoft.IdentityModel.Tokens.SecurityTokenDescriptor
        {
            Subject = new System.Security.Claims.ClaimsIdentity(new[]
            {
                new System.Security.Claims.Claim("userId", user.UserId.ToString()),
                new System.Security.Claims.Claim(System.Security.Claims.ClaimTypes.Email, user.Email)
            }),
            Expires = DateTime.UtcNow.AddHours(1),
            SigningCredentials = new Microsoft.IdentityModel.Tokens.SigningCredentials(
                new Microsoft.IdentityModel.Tokens.SymmetricSecurityKey(key),
                Microsoft.IdentityModel.Tokens.SecurityAlgorithms.HmacSha256Signature)
        };

        var token = tokenHandler.CreateToken(tokenDescriptor);
        return tokenHandler.WriteToken(token);
    }

    public Task<Guid?> ValidateTokenAsync(string token)
    {
        try
        {
            var tokenHandler = new System.IdentityModel.Tokens.Jwt.JwtSecurityTokenHandler();
            var key = System.Text.Encoding.ASCII.GetBytes(JwtSecret);

            tokenHandler.ValidateToken(token, new Microsoft.IdentityModel.Tokens.TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new Microsoft.IdentityModel.Tokens.SymmetricSecurityKey(key),
                ValidateIssuer = false,
                ValidateAudience = false,
                ClockSkew = TimeSpan.Zero
            }, out var validatedToken);

            var jwtToken = (System.IdentityModel.Tokens.Jwt.JwtSecurityToken)validatedToken;
            var userIdClaim = jwtToken.Claims.First(x => x.Type == "userId").Value;

            return Task.FromResult<Guid?>(Guid.Parse(userIdClaim));
        }
        catch
        {
            return Task.FromResult<Guid?>(null);
        }
    }
}
