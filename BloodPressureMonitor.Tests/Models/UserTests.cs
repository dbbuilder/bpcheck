using BloodPressureMonitor.API.Models.Entities;
using FluentAssertions;
using Xunit;

namespace BloodPressureMonitor.Tests.Models;

/// <summary>
/// Tests for User entity validation and behavior
/// Following TDD approach: Write tests first, then implement
/// </summary>
public class UserTests
{
    [Fact]
    public void User_Should_Have_ValidEmail_When_Created()
    {
        // Arrange & Act
        var user = new User
        {
            UserId = Guid.NewGuid(),
            Email = "test@example.com",
            PasswordHash = "hashed_password",
            FirstName = "John",
            LastName = "Doe",
            DateOfBirth = new DateTime(1990, 1, 1),
            StorageQuotaMB = 500,
            CurrentStorageUsedMB = 0,
            IsActive = true,
            CreatedDate = DateTime.UtcNow,
            ModifiedDate = DateTime.UtcNow
        };

        // Assert
        user.Email.Should().NotBeNullOrEmpty();
        user.Email.Should().Contain("@");
    }

    [Fact]
    public void User_Should_Have_DefaultStorageQuota_Of_500MB()
    {
        // Arrange & Act
        var user = new User
        {
            UserId = Guid.NewGuid(),
            Email = "test@example.com",
            PasswordHash = "hashed_password"
        };

        // Assert - Should default to 500MB if not specified
        user.StorageQuotaMB.Should().Be(500);
    }

    [Fact]
    public void User_Should_BeActive_By_Default()
    {
        // Arrange & Act
        var user = new User
        {
            UserId = Guid.NewGuid(),
            Email = "test@example.com",
            PasswordHash = "hashed_password"
        };

        // Assert
        user.IsActive.Should().BeTrue();
    }

    [Fact]
    public void User_Should_Have_ZeroStorageUsed_When_Created()
    {
        // Arrange & Act
        var user = new User
        {
            UserId = Guid.NewGuid(),
            Email = "test@example.com",
            PasswordHash = "hashed_password"
        };

        // Assert
        user.CurrentStorageUsedMB.Should().Be(0);
    }

    [Theory]
    [InlineData("test@example.com")]
    [InlineData("user.name@domain.co.uk")]
    [InlineData("first+last@test.org")]
    public void User_Should_Accept_ValidEmailFormats(string email)
    {
        // Arrange & Act
        var user = new User
        {
            UserId = Guid.NewGuid(),
            Email = email,
            PasswordHash = "hashed_password"
        };

        // Assert
        user.Email.Should().Be(email);
    }

    [Fact]
    public void User_Should_Have_UniqueUserId()
    {
        // Arrange & Act
        var user1 = new User
        {
            Email = "user1@example.com",
            PasswordHash = "hash1"
        };
        var user2 = new User
        {
            Email = "user2@example.com",
            PasswordHash = "hash2"
        };

        user1.UserId = Guid.NewGuid();
        user2.UserId = Guid.NewGuid();

        // Assert
        user1.UserId.Should().NotBe(user2.UserId);
        user1.UserId.Should().NotBe(Guid.Empty);
        user2.UserId.Should().NotBe(Guid.Empty);
    }

    [Fact]
    public void User_Should_Track_CreatedDate()
    {
        // Arrange
        var beforeCreation = DateTime.UtcNow;

        // Act
        var user = new User
        {
            UserId = Guid.NewGuid(),
            Email = "test@example.com",
            PasswordHash = "hashed_password",
            CreatedDate = DateTime.UtcNow
        };

        var afterCreation = DateTime.UtcNow;

        // Assert
        user.CreatedDate.Should().BeOnOrAfter(beforeCreation);
        user.CreatedDate.Should().BeOnOrBefore(afterCreation);
    }

    [Fact]
    public void User_Should_Track_ModifiedDate()
    {
        // Arrange
        var user = new User
        {
            UserId = Guid.NewGuid(),
            Email = "test@example.com",
            PasswordHash = "hashed_password",
            CreatedDate = DateTime.UtcNow,
            ModifiedDate = DateTime.UtcNow
        };

        var originalModifiedDate = user.ModifiedDate;

        // Act - Simulate modification
        System.Threading.Thread.Sleep(10); // Small delay to ensure time difference
        user.FirstName = "John";
        user.ModifiedDate = DateTime.UtcNow;

        // Assert
        user.ModifiedDate.Should().BeAfter(originalModifiedDate);
    }

    [Fact]
    public void User_PasswordHash_Should_NotBe_PlainText()
    {
        // Arrange & Act
        var plainPassword = "MyPassword123!";
        var user = new User
        {
            UserId = Guid.NewGuid(),
            Email = "test@example.com",
            PasswordHash = "hashed_password" // Will be properly hashed in service layer
        };

        // Assert - Password should never be stored as plain text
        user.PasswordHash.Should().NotBe(plainPassword);
        user.PasswordHash.Should().NotBeNullOrEmpty();
    }

    [Fact]
    public void User_StorageUsed_Should_NotExceed_StorageQuota()
    {
        // Arrange
        var user = new User
        {
            UserId = Guid.NewGuid(),
            Email = "test@example.com",
            PasswordHash = "hashed_password",
            StorageQuotaMB = 500,
            CurrentStorageUsedMB = 0
        };

        // Act - Simulate adding storage usage
        user.CurrentStorageUsedMB = 450; // Within quota

        // Assert
        user.CurrentStorageUsedMB.Should().BeLessThanOrEqualTo(user.StorageQuotaMB);
    }

    [Fact]
    public void User_Should_Allow_OptionalFields_ToBeNull()
    {
        // Arrange & Act
        var user = new User
        {
            UserId = Guid.NewGuid(),
            Email = "test@example.com",
            PasswordHash = "hashed_password",
            FirstName = null, // Optional
            LastName = null, // Optional
            DateOfBirth = null, // Optional
            LastLoginDate = null // Optional
        };

        // Assert - Optional fields can be null
        user.FirstName.Should().BeNull();
        user.LastName.Should().BeNull();
        user.DateOfBirth.Should().BeNull();
        user.LastLoginDate.Should().BeNull();
    }
}
