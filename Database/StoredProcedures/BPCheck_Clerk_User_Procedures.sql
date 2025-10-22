/*
================================================================================
Clerk User Management Stored Procedures
================================================================================
Description: Procedures for managing users authenticated via Clerk
Author: Development Team
Date: October 21, 2025
================================================================================
*/

USE [BPCheckDB]
GO

-- ============================================================================
-- Procedure: usp_User_SyncFromClerk
-- Description: Syncs or creates a user from Clerk authentication
-- Returns: User record (creates if doesn't exist)
-- ============================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_User_SyncFromClerk]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[usp_User_SyncFromClerk]
GO

CREATE PROCEDURE [dbo].[usp_User_SyncFromClerk]
    @ClerkUserId NVARCHAR(255),
    @Email NVARCHAR(256),
    @FirstName NVARCHAR(100) = NULL,
    @LastName NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UserId UNIQUEIDENTIFIER;
    DECLARE @Now DATETIME2(7) = GETUTCDATE();

    -- Check if user exists by ClerkUserId
    SELECT @UserId = UserId
    FROM [dbo].[Users]
    WHERE [ClerkUserId] = @ClerkUserId;

    IF @UserId IS NULL
    BEGIN
        -- User doesn't exist, create new one
        SET @UserId = NEWID();

        INSERT INTO [dbo].[Users] (
            [UserId],
            [ClerkUserId],
            [Email],
            [FirstName],
            [LastName],
            [PasswordHash],
            [StorageQuotaMB],
            [CurrentStorageUsedMB],
            [IsActive],
            [LastLoginDate],
            [CreatedDate],
            [ModifiedDate]
        )
        VALUES (
            @UserId,
            @ClerkUserId,
            @Email,
            @FirstName,
            @LastName,
            NULL, -- No password hash for Clerk users
            500, -- Default quota
            0.00,
            1,
            @Now,
            @Now,
            @Now
        );
    END
    ELSE
    BEGIN
        -- User exists, update their info and last login
        UPDATE [dbo].[Users]
        SET
            [Email] = @Email,
            [FirstName] = COALESCE(@FirstName, [FirstName]),
            [LastName] = COALESCE(@LastName, [LastName]),
            [LastLoginDate] = @Now,
            [ModifiedDate] = @Now
        WHERE [UserId] = @UserId;
    END

    -- Return the user record
    SELECT
        [UserId],
        [ClerkUserId],
        [Email],
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
    WHERE [UserId] = @UserId;
END
GO

-- ============================================================================
-- Procedure: usp_User_GetByClerkId
-- Description: Gets user by Clerk User ID
-- ============================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_User_GetByClerkId]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[usp_User_GetByClerkId]
GO

CREATE PROCEDURE [dbo].[usp_User_GetByClerkId]
    @ClerkUserId NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        [UserId],
        [ClerkUserId],
        [Email],
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
    WHERE [ClerkUserId] = @ClerkUserId
    AND [IsActive] = 1;
END
GO

-- ============================================================================
-- Procedure: usp_User_UpdateProfile
-- Description: Updates user profile information (for Clerk users)
-- ============================================================================
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_User_UpdateProfile]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[usp_User_UpdateProfile]
GO

CREATE PROCEDURE [dbo].[usp_User_UpdateProfile]
    @ClerkUserId NVARCHAR(255),
    @FirstName NVARCHAR(100) = NULL,
    @LastName NVARCHAR(100) = NULL,
    @DateOfBirth DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UserId UNIQUEIDENTIFIER;

    -- Get UserId from ClerkUserId
    SELECT @UserId = UserId
    FROM [dbo].[Users]
    WHERE [ClerkUserId] = @ClerkUserId
    AND [IsActive] = 1;

    IF @UserId IS NULL
    BEGIN
        SELECT NULL AS UserId;
        RETURN;
    END

    -- Update profile
    UPDATE [dbo].[Users]
    SET
        [FirstName] = COALESCE(@FirstName, [FirstName]),
        [LastName] = COALESCE(@LastName, [LastName]),
        [DateOfBirth] = COALESCE(@DateOfBirth, [DateOfBirth]),
        [ModifiedDate] = GETUTCDATE()
    WHERE [UserId] = @UserId;

    -- Return updated record
    SELECT
        [UserId],
        [ClerkUserId],
        [Email],
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
    WHERE [UserId] = @UserId;
END
GO

PRINT 'Clerk user procedures created successfully'
GO
