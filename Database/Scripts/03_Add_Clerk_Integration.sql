/*
================================================================================
Blood Pressure Monitor - Clerk Integration Migration
================================================================================
Script: 03_Add_Clerk_Integration.sql
Description: Adds Clerk authentication support to existing schema
Author: Development Team
Date: October 21, 2025
Version: 1.0
================================================================================
*/

USE [BloodPressureMonitor]
GO

PRINT 'Starting Clerk integration migration...'
GO

-- ============================================================================
-- Add ClerkUserId to Users table
-- ============================================================================
IF NOT EXISTS (
    SELECT * FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[Users]')
    AND name = 'ClerkUserId'
)
BEGIN
    ALTER TABLE [dbo].[Users]
    ADD [ClerkUserId] NVARCHAR(255) NULL;

    PRINT 'Added [ClerkUserId] column to [Users] table'
END
ELSE
BEGIN
    PRINT '[ClerkUserId] column already exists in [Users] table'
END
GO

-- ============================================================================
-- Create unique index on ClerkUserId
-- ============================================================================
IF NOT EXISTS (
    SELECT * FROM sys.indexes
    WHERE name = 'UQ_Users_ClerkUserId'
    AND object_id = OBJECT_ID(N'[dbo].[Users]')
)
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UQ_Users_ClerkUserId]
    ON [dbo].[Users] ([ClerkUserId])
    WHERE [ClerkUserId] IS NOT NULL;

    PRINT 'Created unique index [UQ_Users_ClerkUserId]'
END
ELSE
BEGIN
    PRINT 'Index [UQ_Users_ClerkUserId] already exists'
END
GO

-- ============================================================================
-- Make PasswordHash nullable (since Clerk handles auth)
-- ============================================================================
IF EXISTS (
    SELECT * FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[Users]')
    AND name = 'PasswordHash'
    AND is_nullable = 0
)
BEGIN
    ALTER TABLE [dbo].[Users]
    ALTER COLUMN [PasswordHash] NVARCHAR(MAX) NULL;

    PRINT 'Modified [PasswordHash] column to be nullable'
END
ELSE
BEGIN
    PRINT '[PasswordHash] column is already nullable'
END
GO

-- ============================================================================
-- Update Email unique constraint to be filtered (allow duplicates for Clerk users)
-- Note: Clerk users are identified by ClerkUserId, Email can be same across platforms
-- ============================================================================
IF EXISTS (
    SELECT * FROM sys.indexes
    WHERE name = 'UQ_Users_Email'
    AND object_id = OBJECT_ID(N'[dbo].[Users]')
)
BEGIN
    DROP INDEX [UQ_Users_Email] ON [dbo].[Users];
    PRINT 'Dropped old [UQ_Users_Email] constraint'
END
GO

IF NOT EXISTS (
    SELECT * FROM sys.indexes
    WHERE name = 'IX_Users_Email'
    AND object_id = OBJECT_ID(N'[dbo].[Users]')
)
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Users_Email]
    ON [dbo].[Users] ([Email]);

    PRINT 'Created new [IX_Users_Email] index'
END
ELSE
BEGIN
    PRINT 'Index [IX_Users_Email] already exists'
END
GO

PRINT 'Clerk integration migration completed successfully!'
GO
