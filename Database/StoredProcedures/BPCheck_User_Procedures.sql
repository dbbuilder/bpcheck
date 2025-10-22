/*
================================================================================
Blood Pressure Monitor - User Management Stored Procedures
================================================================================
Script: User_Procedures.sql
Description: Stored procedures for user authentication and management
Author: Development Team
Date: October 21, 2025
Version: 1.0
================================================================================
*/

USE [BPCheckDB]
GO

PRINT 'Creating User Management stored procedures...'
GO

-- ============================================================================
-- Procedure: usp_User_Create
-- Description: Creates a new user account
-- Parameters:
--   @Email - User's email address (must be unique)
--   @PasswordHash - BCrypt hashed password
--   @FirstName - User's first name (optional)
--   @LastName - User's last name (optional)
-- Returns: User record or NULL if email exists
-- ============================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_User_Create]') AND type in (N'P'))
    DROP PROCEDURE [dbo].[usp_User_Create]
GO

CREATE PROCEDURE [dbo].[usp_User_Create]
    @Email NVARCHAR(256),
    @PasswordHash NVARCHAR(MAX),
    @FirstName NVARCHAR(100) = NULL,
    @LastName NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Check if email already exists
        IF EXISTS (SELECT 1 FROM [dbo].[Users] WHERE [Email] = @Email)
        BEGIN
            -- Return NULL to indicate email already exists
            SELECT NULL AS UserId
            RETURN
        END

        -- Create new user
        DECLARE @NewUserId UNIQUEIDENTIFIER = NEWID()
        DECLARE @Now DATETIME2(7) = GETUTCDATE()

        INSERT INTO [dbo].[Users]
        (
            [UserId],
            [Email],
            [PasswordHash],
            [FirstName],
            [LastName],
            [StorageQuotaMB],
            [CurrentStorageUsedMB],
            [IsActive],
            [LastLoginDate],
            [CreatedDate],
            [ModifiedDate]
        )
        VALUES
        (
            @NewUserId,
            @Email,
            @PasswordHash,
            @FirstName,
            @LastName,
            500, -- Default quota
            0.00, -- No storage used yet
            1, -- Active by default
            NULL, -- Never logged in
            @Now,
            @Now
        )

        -- Return the created user
        SELECT
            [UserId],
            [Email],
            [PasswordHash],
            [FirstName],
            [LastName],
            [DateOfBirth],
            [StorageQuotaMB],
            [CurrentStorageUsedMB],
            [IsActive],
            [LastLoginDate],
            [CreatedDate],
            [ModifiedDate]
        FROM [dbo].[Users]
        WHERE [UserId] = @NewUserId

    END TRY
    BEGIN CATCH
        -- Log error and re-throw
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END
GO

PRINT 'Procedure [usp_User_Create] created'
GO

-- ============================================================================
-- Procedure: usp_User_GetByEmail
-- Description: Retrieves a user by email address (for authentication)
-- Parameters:
--   @Email - User's email address
-- Returns: User record or NULL if not found
-- ============================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_User_GetByEmail]') AND type in (N'P'))
    DROP PROCEDURE [dbo].[usp_User_GetByEmail]
GO

CREATE PROCEDURE [dbo].[usp_User_GetByEmail]
    @Email NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        [UserId],
        [Email],
        [PasswordHash],
        [FirstName],
        [LastName],
        [DateOfBirth],
        [StorageQuotaMB],
        [CurrentStorageUsedMB],
        [IsActive],
        [LastLoginDate],
        [CreatedDate],
        [ModifiedDate]
    FROM [dbo].[Users]
    WHERE [Email] = @Email
END
GO

PRINT 'Procedure [usp_User_GetByEmail] created'
GO

-- ============================================================================
-- Procedure: usp_User_GetById
-- Description: Retrieves a user by UserId
-- Parameters:
--   @UserId - User's unique identifier
-- Returns: User record or NULL if not found
-- ============================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_User_GetById]') AND type in (N'P'))
    DROP PROCEDURE [dbo].[usp_User_GetById]
GO

CREATE PROCEDURE [dbo].[usp_User_GetById]
    @UserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        [UserId],
        [Email],
        [PasswordHash],
        [FirstName],
        [LastName],
        [DateOfBirth],
        [StorageQuotaMB],
        [CurrentStorageUsedMB],
        [IsActive],
        [LastLoginDate],
        [CreatedDate],
        [ModifiedDate]
    FROM [dbo].[Users]
    WHERE [UserId] = @UserId
END
GO

PRINT 'Procedure [usp_User_GetById] created'
GO

-- ============================================================================
-- Procedure: usp_User_Update
-- Description: Updates user profile information
-- Parameters:
--   @UserId - User's unique identifier
--   @FirstName - Updated first name (optional)
--   @LastName - Updated last name (optional)
--   @DateOfBirth - Updated date of birth (optional)
-- Returns: Updated user record
-- ============================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_User_Update]') AND type in (N'P'))
    DROP PROCEDURE [dbo].[usp_User_Update]
GO

CREATE PROCEDURE [dbo].[usp_User_Update]
    @UserId UNIQUEIDENTIFIER,
    @FirstName NVARCHAR(100) = NULL,
    @LastName NVARCHAR(100) = NULL,
    @DateOfBirth DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Update user
        UPDATE [dbo].[Users]
        SET
            [FirstName] = @FirstName,
            [LastName] = @LastName,
            [DateOfBirth] = @DateOfBirth,
            [ModifiedDate] = GETUTCDATE()
        WHERE [UserId] = @UserId

        -- Return updated user
        SELECT
            [UserId],
            [Email],
            [PasswordHash],
            [FirstName],
            [LastName],
            [DateOfBirth],
            [StorageQuotaMB],
            [CurrentStorageUsedMB],
            [IsActive],
            [LastLoginDate],
            [CreatedDate],
            [ModifiedDate]
        FROM [dbo].[Users]
        WHERE [UserId] = @UserId

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END
GO

PRINT 'Procedure [usp_User_Update] created'
GO

-- ============================================================================
-- Procedure: usp_User_UpdateLastLogin
-- Description: Updates the last login timestamp
-- Parameters:
--   @UserId - User's unique identifier
-- Returns: None
-- ============================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_User_UpdateLastLogin]') AND type in (N'P'))
    DROP PROCEDURE [dbo].[usp_User_UpdateLastLogin]
GO

CREATE PROCEDURE [dbo].[usp_User_UpdateLastLogin]
    @UserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[Users]
    SET [LastLoginDate] = GETUTCDATE()
    WHERE [UserId] = @UserId
END
GO

PRINT 'Procedure [usp_User_UpdateLastLogin] created'
GO

-- ============================================================================
-- Procedure: usp_User_UpdateStorageUsage
-- Description: Updates the current storage usage
-- Parameters:
--   @UserId - User's unique identifier
--   @StorageUsedMB - New storage used value in MB
-- Returns: None
-- ============================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_User_UpdateStorageUsage]') AND type in (N'P'))
    DROP PROCEDURE [dbo].[usp_User_UpdateStorageUsage]
GO

CREATE PROCEDURE [dbo].[usp_User_UpdateStorageUsage]
    @UserId UNIQUEIDENTIFIER,
    @StorageUsedMB DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        UPDATE [dbo].[Users]
        SET
            [CurrentStorageUsedMB] = @StorageUsedMB,
            [ModifiedDate] = GETUTCDATE()
        WHERE [UserId] = @UserId

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END
GO

PRINT 'Procedure [usp_User_UpdateStorageUsage] created'
GO

-- ============================================================================
-- Procedure: usp_User_Delete
-- Description: Soft deletes a user (sets IsActive = 0)
-- Parameters:
--   @UserId - User's unique identifier
-- Returns: None
-- ============================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_User_Delete]') AND type in (N'P'))
    DROP PROCEDURE [dbo].[usp_User_Delete]
GO

CREATE PROCEDURE [dbo].[usp_User_Delete]
    @UserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[Users]
    SET
        [IsActive] = 0,
        [ModifiedDate] = GETUTCDATE()
    WHERE [UserId] = @UserId
END
GO

PRINT 'Procedure [usp_User_Delete] created'
GO

-- ============================================================================
-- Procedure: usp_User_CheckEmailExists
-- Description: Checks if an email address is already registered
-- Parameters:
--   @Email - Email address to check
-- Returns: 1 if exists, 0 if not
-- ============================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_User_CheckEmailExists]') AND type in (N'P'))
    DROP PROCEDURE [dbo].[usp_User_CheckEmailExists]
GO

CREATE PROCEDURE [dbo].[usp_User_CheckEmailExists]
    @Email NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM [dbo].[Users] WHERE [Email] = @Email)
        SELECT 1 AS [Exists]
    ELSE
        SELECT 0 AS [Exists]
END
GO

PRINT 'Procedure [usp_User_CheckEmailExists] created'
GO

PRINT 'All User Management stored procedures created successfully!'
PRINT 'Total procedures created: 8'
PRINT '  1. usp_User_Create'
PRINT '  2. usp_User_GetByEmail'
PRINT '  3. usp_User_GetById'
PRINT '  4. usp_User_Update'
PRINT '  5. usp_User_UpdateLastLogin'
PRINT '  6. usp_User_UpdateStorageUsage'
PRINT '  7. usp_User_Delete'
PRINT '  8. usp_User_CheckEmailExists'
GO
