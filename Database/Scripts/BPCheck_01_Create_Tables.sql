/*
================================================================================
Blood Pressure Monitor - Database Schema Creation Script
================================================================================
Script: 01_Create_Tables.sql
Description: Creates all database tables for the Blood Pressure Monitor application
Author: Development Team
Date: October 21, 2025
Version: 2.0 - Complete Schema
================================================================================
*/

USE [BPCheckDB]
GO

PRINT 'Starting table creation for Blood Pressure Monitor database...'
GO

-- ============================================================================
-- Table: Users
-- Description: Stores user account information including authentication data
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Users]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Users]
    (
        [UserId] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
        [Email] NVARCHAR(256) NOT NULL,
        [PasswordHash] NVARCHAR(MAX) NOT NULL,
        [FirstName] NVARCHAR(100) NULL,
        [LastName] NVARCHAR(100) NULL,
        [DateOfBirth] DATE NULL,
        [StorageQuotaMB] INT NOT NULL DEFAULT 500,
        [CurrentStorageUsedMB] DECIMAL(10,2) NOT NULL DEFAULT 0.00,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [LastLoginDate] DATETIME2(7) NULL,
        [CreatedDate] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        [ModifiedDate] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED ([UserId] ASC),
        CONSTRAINT [UQ_Users_Email] UNIQUE NONCLUSTERED ([Email] ASC),
        CONSTRAINT [CK_Users_StorageQuota] CHECK ([StorageQuotaMB] >= 0),
        CONSTRAINT [CK_Users_StorageUsed] CHECK ([CurrentStorageUsedMB] >= 0)
    )
    PRINT 'Table [Users] created successfully'
END
ELSE
BEGIN
    PRINT 'Table [Users] already exists'
END
GO

-- ============================================================================
-- Table: BloodPressureReadings
-- Description: Stores blood pressure and heart rate readings
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BloodPressureReadings]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[BloodPressureReadings]
    (
        [ReadingId] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
        [UserId] UNIQUEIDENTIFIER NOT NULL,
        [PrimaryImageId] UNIQUEIDENTIFIER NULL,
        [SystolicValue] INT NOT NULL,
        [DiastolicValue] INT NOT NULL,
        [PulseValue] INT NULL,
        [ReadingDate] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        [Notes] NVARCHAR(500) NULL,
        [IsManualEntry] BIT NOT NULL DEFAULT 0,
        [OcrConfidence] DECIMAL(5,2) NULL,
        [IsFlagged] BIT NOT NULL DEFAULT 0,
        [CreatedDate] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        [ModifiedDate] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [PK_BloodPressureReadings] PRIMARY KEY CLUSTERED ([ReadingId] ASC),
        CONSTRAINT [FK_BloodPressureReadings_Users] FOREIGN KEY ([UserId])
            REFERENCES [dbo].[Users]([UserId]) ON DELETE CASCADE,
        CONSTRAINT [CK_Readings_Systolic] CHECK ([SystolicValue] BETWEEN 70 AND 250),
        CONSTRAINT [CK_Readings_Diastolic] CHECK ([DiastolicValue] BETWEEN 40 AND 150),
        CONSTRAINT [CK_Readings_Pulse] CHECK ([PulseValue] IS NULL OR [PulseValue] BETWEEN 30 AND 220),
        CONSTRAINT [CK_Readings_OcrConfidence] CHECK ([OcrConfidence] IS NULL OR [OcrConfidence] BETWEEN 0 AND 100)
    )
    PRINT 'Table [BloodPressureReadings] created successfully'
END
ELSE
BEGIN
    PRINT 'Table [BloodPressureReadings] already exists'
END
GO

-- ============================================================================
-- Table: ReadingImages
-- Description: Stores image metadata and links to Azure Blob Storage
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReadingImages]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[ReadingImages]
    (
        [ImageId] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
        [ReadingId] UNIQUEIDENTIFIER NULL,
        [UserId] UNIQUEIDENTIFIER NOT NULL,
        [OriginalBlobUrl] NVARCHAR(1000) NOT NULL,
        [Thumbnail150Url] NVARCHAR(1000) NULL,
        [Thumbnail400Url] NVARCHAR(1000) NULL,
        [FileSizeMB] DECIMAL(10,2) NOT NULL,
        [ImageFormat] NVARCHAR(10) NOT NULL,
        [Width] INT NOT NULL,
        [Height] INT NOT NULL,
        [IsFavorite] BIT NOT NULL DEFAULT 0,
        [LastViewedDate] DATETIME2(7) NULL,
        [UploadDate] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        [CreatedDate] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        [ModifiedDate] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [PK_ReadingImages] PRIMARY KEY CLUSTERED ([ImageId] ASC),
        CONSTRAINT [FK_ReadingImages_Readings] FOREIGN KEY ([ReadingId])
            REFERENCES [dbo].[BloodPressureReadings]([ReadingId]) ON DELETE SET NULL,
        CONSTRAINT [FK_ReadingImages_Users] FOREIGN KEY ([UserId])
            REFERENCES [dbo].[Users]([UserId]) ON DELETE CASCADE,
        CONSTRAINT [CK_ReadingImages_FileSize] CHECK ([FileSizeMB] > 0 AND [FileSizeMB] <= 5)
    )
    PRINT 'Table [ReadingImages] created successfully'
END
ELSE
BEGIN
    PRINT 'Table [ReadingImages] already exists'
END
GO

-- ============================================================================
-- Table: Albums
-- Description: User-created photo albums for organization
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Albums]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Albums]
    (
        [AlbumId] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
        [UserId] UNIQUEIDENTIFIER NOT NULL,
        [AlbumName] NVARCHAR(100) NOT NULL,
        [Description] NVARCHAR(500) NULL,
        [CoverImageId] UNIQUEIDENTIFIER NULL,
        [ImageCount] INT NOT NULL DEFAULT 0,
        [CreatedDate] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        [ModifiedDate] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [PK_Albums] PRIMARY KEY CLUSTERED ([AlbumId] ASC),
        CONSTRAINT [FK_Albums_Users] FOREIGN KEY ([UserId])
            REFERENCES [dbo].[Users]([UserId]) ON DELETE CASCADE,
        CONSTRAINT [FK_Albums_CoverImage] FOREIGN KEY ([CoverImageId])
            REFERENCES [dbo].[ReadingImages]([ImageId]) ON DELETE NO ACTION
    )
    PRINT 'Table [Albums] created successfully'
END
ELSE
BEGIN
    PRINT 'Table [Albums] already exists'
END
GO

-- ============================================================================
-- Table: ImageTags
-- Description: User-defined tags for organizing images
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ImageTags]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[ImageTags]
    (
        [TagId] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
        [UserId] UNIQUEIDENTIFIER NOT NULL,
        [TagName] NVARCHAR(50) NOT NULL,
        [TagColor] NVARCHAR(7) NULL, -- Hex color code #RRGGBB
        [UsageCount] INT NOT NULL DEFAULT 0,
        [CreatedDate] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        [ModifiedDate] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [PK_ImageTags] PRIMARY KEY CLUSTERED ([TagId] ASC),
        CONSTRAINT [FK_ImageTags_Users] FOREIGN KEY ([UserId])
            REFERENCES [dbo].[Users]([UserId]) ON DELETE CASCADE,
        CONSTRAINT [UQ_ImageTags_UserTag] UNIQUE ([UserId], [TagName])
    )
    PRINT 'Table [ImageTags] created successfully'
END
ELSE
BEGIN
    PRINT 'Table [ImageTags] already exists'
END
GO

-- ============================================================================
-- Table: ImageTagAssociations
-- Description: Many-to-many relationship between images and tags
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ImageTagAssociations]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[ImageTagAssociations]
    (
        [AssociationId] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
        [ImageId] UNIQUEIDENTIFIER NOT NULL,
        [TagId] UNIQUEIDENTIFIER NOT NULL,
        [CreatedDate] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [PK_ImageTagAssociations] PRIMARY KEY CLUSTERED ([AssociationId] ASC),
        CONSTRAINT [FK_ImageTagAssociations_Images] FOREIGN KEY ([ImageId])
            REFERENCES [dbo].[ReadingImages]([ImageId]) ON DELETE CASCADE,
        CONSTRAINT [FK_ImageTagAssociations_Tags] FOREIGN KEY ([TagId])
            REFERENCES [dbo].[ImageTags]([TagId]) ON DELETE CASCADE,
        CONSTRAINT [UQ_ImageTagAssociations] UNIQUE ([ImageId], [TagId])
    )
    PRINT 'Table [ImageTagAssociations] created successfully'
END
ELSE
BEGIN
    PRINT 'Table [ImageTagAssociations] already exists'
END
GO

-- ============================================================================
-- Table: UserAlertThresholds
-- Description: User-configured blood pressure alert thresholds
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserAlertThresholds]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[UserAlertThresholds]
    (
        [ThresholdId] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
        [UserId] UNIQUEIDENTIFIER NOT NULL,
        [SystolicHigh] INT NULL,
        [SystolicLow] INT NULL,
        [DiastolicHigh] INT NULL,
        [DiastolicLow] INT NULL,
        [PulseHigh] INT NULL,
        [PulseLow] INT NULL,
        [IsEnabled] BIT NOT NULL DEFAULT 1,
        [CreatedDate] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        [ModifiedDate] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [PK_UserAlertThresholds] PRIMARY KEY CLUSTERED ([ThresholdId] ASC),
        CONSTRAINT [FK_UserAlertThresholds_Users] FOREIGN KEY ([UserId])
            REFERENCES [dbo].[Users]([UserId]) ON DELETE CASCADE,
        CONSTRAINT [CK_Thresholds_SystolicHigh] CHECK ([SystolicHigh] IS NULL OR [SystolicHigh] BETWEEN 70 AND 250),
        CONSTRAINT [CK_Thresholds_SystolicLow] CHECK ([SystolicLow] IS NULL OR [SystolicLow] BETWEEN 70 AND 250),
        CONSTRAINT [CK_Thresholds_DiastolicHigh] CHECK ([DiastolicHigh] IS NULL OR [DiastolicHigh] BETWEEN 40 AND 150),
        CONSTRAINT [CK_Thresholds_DiastolicLow] CHECK ([DiastolicLow] IS NULL OR [DiastolicLow] BETWEEN 40 AND 150),
        CONSTRAINT [CK_Thresholds_PulseHigh] CHECK ([PulseHigh] IS NULL OR [PulseHigh] BETWEEN 30 AND 220),
        CONSTRAINT [CK_Thresholds_PulseLow] CHECK ([PulseLow] IS NULL OR [PulseLow] BETWEEN 30 AND 220)
    )
    PRINT 'Table [UserAlertThresholds] created successfully'
END
ELSE
BEGIN
    PRINT 'Table [UserAlertThresholds] already exists'
END
GO

-- ============================================================================
-- Table: OcrProcessingLog
-- Description: Audit trail of all OCR processing attempts
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OcrProcessingLog]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[OcrProcessingLog]
    (
        [LogId] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
        [ImageId] UNIQUEIDENTIFIER NOT NULL,
        [UserId] UNIQUEIDENTIFIER NOT NULL,
        [ProcessingMethod] NVARCHAR(50) NOT NULL, -- 'Local' or 'Cloud'
        [RawOcrText] NVARCHAR(MAX) NULL,
        [ExtractedSystolic] INT NULL,
        [ExtractedDiastolic] INT NULL,
        [ExtractedPulse] INT NULL,
        [ConfidenceScore] DECIMAL(5,2) NULL,
        [ProcessingTimeMs] INT NULL,
        [IsSuccessful] BIT NOT NULL DEFAULT 0,
        [ErrorMessage] NVARCHAR(500) NULL,
        [ProcessedDate] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [PK_OcrProcessingLog] PRIMARY KEY CLUSTERED ([LogId] ASC),
        CONSTRAINT [FK_OcrProcessingLog_Images] FOREIGN KEY ([ImageId])
            REFERENCES [dbo].[ReadingImages]([ImageId]) ON DELETE CASCADE,
        CONSTRAINT [FK_OcrProcessingLog_Users] FOREIGN KEY ([UserId])
            REFERENCES [dbo].[Users]([UserId]) ON DELETE NO ACTION
    )
    PRINT 'Table [OcrProcessingLog] created successfully'
END
ELSE
BEGIN
    PRINT 'Table [OcrProcessingLog] already exists'
END
GO

PRINT 'All tables created successfully!'
PRINT 'Total tables created: 8'
PRINT '  1. Users'
PRINT '  2. BloodPressureReadings'
PRINT '  3. ReadingImages'
PRINT '  4. Albums'
PRINT '  5. ImageTags'
PRINT '  6. ImageTagAssociations'
PRINT '  7. UserAlertThresholds'
PRINT '  8. OcrProcessingLog'
GO
