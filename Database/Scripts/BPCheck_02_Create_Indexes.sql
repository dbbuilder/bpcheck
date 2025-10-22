/*
================================================================================
Blood Pressure Monitor - Database Indexes Creation Script
================================================================================
Script: 02_Create_Indexes.sql
Description: Creates all indexes for optimal query performance
Author: Development Team
Date: October 21, 2025
Version: 1.0
================================================================================
*/

USE [BPCheckDB]
GO

PRINT 'Starting index creation for Blood Pressure Monitor database...'
GO

-- ============================================================================
-- Indexes for Users table
-- ============================================================================

-- Email is already indexed via UNIQUE constraint (UQ_Users_Email)
-- UserId is already indexed via PRIMARY KEY (PK_Users)

-- Index for active user queries
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Users_IsActive' AND object_id = OBJECT_ID('dbo.Users'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Users_IsActive]
    ON [dbo].[Users] ([IsActive])
    INCLUDE ([Email], [FirstName], [LastName])
    PRINT 'Index [IX_Users_IsActive] created'
END
ELSE
BEGIN
    PRINT 'Index [IX_Users_IsActive] already exists'
END
GO

-- ============================================================================
-- Indexes for BloodPressureReadings table
-- ============================================================================

-- Index for user's readings queries (most common)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_BloodPressureReadings_UserId_ReadingDate' AND object_id = OBJECT_ID('dbo.BloodPressureReadings'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_BloodPressureReadings_UserId_ReadingDate]
    ON [dbo].[BloodPressureReadings] ([UserId], [ReadingDate] DESC)
    INCLUDE ([SystolicValue], [DiastolicValue], [PulseValue], [IsFlagged])
    PRINT 'Index [IX_BloodPressureReadings_UserId_ReadingDate] created'
END
ELSE
BEGIN
    PRINT 'Index [IX_BloodPressureReadings_UserId_ReadingDate] already exists'
END
GO

-- Index for date range queries
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_BloodPressureReadings_ReadingDate' AND object_id = OBJECT_ID('dbo.BloodPressureReadings'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_BloodPressureReadings_ReadingDate]
    ON [dbo].[BloodPressureReadings] ([ReadingDate] DESC)
    INCLUDE ([UserId], [SystolicValue], [DiastolicValue])
    PRINT 'Index [IX_BloodPressureReadings_ReadingDate] created'
END
ELSE
BEGIN
    PRINT 'Index [IX_BloodPressureReadings_ReadingDate] already exists'
END
GO

-- Index for flagged readings
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_BloodPressureReadings_UserId_IsFlagged' AND object_id = OBJECT_ID('dbo.BloodPressureReadings'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_BloodPressureReadings_UserId_IsFlagged]
    ON [dbo].[BloodPressureReadings] ([UserId], [IsFlagged])
    WHERE [IsFlagged] = 1
    INCLUDE ([ReadingDate], [SystolicValue], [DiastolicValue])
    PRINT 'Index [IX_BloodPressureReadings_UserId_IsFlagged] created'
END
ELSE
BEGIN
    PRINT 'Index [IX_BloodPressureReadings_UserId_IsFlagged] already exists'
END
GO

-- ============================================================================
-- Indexes for ReadingImages table
-- ============================================================================

-- Index for user's images queries
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ReadingImages_UserId_UploadDate' AND object_id = OBJECT_ID('dbo.ReadingImages'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_ReadingImages_UserId_UploadDate]
    ON [dbo].[ReadingImages] ([UserId], [UploadDate] DESC)
    INCLUDE ([Thumbnail150Url], [Thumbnail400Url], [IsFavorite])
    PRINT 'Index [IX_ReadingImages_UserId_UploadDate] created'
END
ELSE
BEGIN
    PRINT 'Index [IX_ReadingImages_UserId_UploadDate] already exists'
END
GO

-- Index for reading-image relationship
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ReadingImages_ReadingId' AND object_id = OBJECT_ID('dbo.ReadingImages'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_ReadingImages_ReadingId]
    ON [dbo].[ReadingImages] ([ReadingId])
    INCLUDE ([ImageId], [OriginalBlobUrl], [Thumbnail150Url])
    PRINT 'Index [IX_ReadingImages_ReadingId] created'
END
ELSE
BEGIN
    PRINT 'Index [IX_ReadingImages_ReadingId] already exists'
END
GO

-- Index for orphaned images (no associated reading)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ReadingImages_ReadingId_Null' AND object_id = OBJECT_ID('dbo.ReadingImages'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_ReadingImages_ReadingId_Null]
    ON [dbo].[ReadingImages] ([UserId], [UploadDate] DESC)
    WHERE [ReadingId] IS NULL
    INCLUDE ([ImageId], [Thumbnail150Url])
    PRINT 'Index [IX_ReadingImages_ReadingId_Null] created'
END
ELSE
BEGIN
    PRINT 'Index [IX_ReadingImages_ReadingId_Null] already exists'
END
GO

-- Index for favorite images
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ReadingImages_UserId_IsFavorite' AND object_id = OBJECT_ID('dbo.ReadingImages'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_ReadingImages_UserId_IsFavorite]
    ON [dbo].[ReadingImages] ([UserId], [IsFavorite])
    WHERE [IsFavorite] = 1
    INCLUDE ([ImageId], [Thumbnail150Url], [UploadDate])
    PRINT 'Index [IX_ReadingImages_UserId_IsFavorite] created'
END
ELSE
BEGIN
    PRINT 'Index [IX_ReadingImages_UserId_IsFavorite] already exists'
END
GO

-- ============================================================================
-- Indexes for Albums table
-- ============================================================================

-- Index for user's albums
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Albums_UserId' AND object_id = OBJECT_ID('dbo.Albums'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Albums_UserId]
    ON [dbo].[Albums] ([UserId])
    INCLUDE ([AlbumName], [ImageCount], [CoverImageId])
    PRINT 'Index [IX_Albums_UserId] created'
END
ELSE
BEGIN
    PRINT 'Index [IX_Albums_UserId] already exists'
END
GO

-- ============================================================================
-- Indexes for ImageTags table
-- ============================================================================

-- Index for user's tags (with usage count for sorting)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ImageTags_UserId_UsageCount' AND object_id = OBJECT_ID('dbo.ImageTags'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_ImageTags_UserId_UsageCount]
    ON [dbo].[ImageTags] ([UserId], [UsageCount] DESC)
    INCLUDE ([TagName], [TagColor])
    PRINT 'Index [IX_ImageTags_UserId_UsageCount] created'
END
ELSE
BEGIN
    PRINT 'Index [IX_ImageTags_UserId_UsageCount] already exists'
END
GO

-- ============================================================================
-- Indexes for ImageTagAssociations table
-- ============================================================================

-- Index for finding tags by image
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ImageTagAssociations_ImageId' AND object_id = OBJECT_ID('dbo.ImageTagAssociations'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_ImageTagAssociations_ImageId]
    ON [dbo].[ImageTagAssociations] ([ImageId])
    INCLUDE ([TagId])
    PRINT 'Index [IX_ImageTagAssociations_ImageId] created'
END
ELSE
BEGIN
    PRINT 'Index [IX_ImageTagAssociations_ImageId] already exists'
END
GO

-- Index for finding images by tag
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ImageTagAssociations_TagId' AND object_id = OBJECT_ID('dbo.ImageTagAssociations'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_ImageTagAssociations_TagId]
    ON [dbo].[ImageTagAssociations] ([TagId])
    INCLUDE ([ImageId])
    PRINT 'Index [IX_ImageTagAssociations_TagId] created'
END
ELSE
BEGIN
    PRINT 'Index [IX_ImageTagAssociations_TagId] already exists'
END
GO

-- ============================================================================
-- Indexes for UserAlertThresholds table
-- ============================================================================

-- Index for user's active thresholds
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_UserAlertThresholds_UserId_IsEnabled' AND object_id = OBJECT_ID('dbo.UserAlertThresholds'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_UserAlertThresholds_UserId_IsEnabled]
    ON [dbo].[UserAlertThresholds] ([UserId], [IsEnabled])
    WHERE [IsEnabled] = 1
    INCLUDE ([SystolicHigh], [SystolicLow], [DiastolicHigh], [DiastolicLow], [PulseHigh], [PulseLow])
    PRINT 'Index [IX_UserAlertThresholds_UserId_IsEnabled] created'
END
ELSE
BEGIN
    PRINT 'Index [IX_UserAlertThresholds_UserId_IsEnabled] already exists'
END
GO

-- ============================================================================
-- Indexes for OcrProcessingLog table
-- ============================================================================

-- Index for image's OCR history
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OcrProcessingLog_ImageId_ProcessedDate' AND object_id = OBJECT_ID('dbo.OcrProcessingLog'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_OcrProcessingLog_ImageId_ProcessedDate]
    ON [dbo].[OcrProcessingLog] ([ImageId], [ProcessedDate] DESC)
    INCLUDE ([ProcessingMethod], [ConfidenceScore], [IsSuccessful])
    PRINT 'Index [IX_OcrProcessingLog_ImageId_ProcessedDate] created'
END
ELSE
BEGIN
    PRINT 'Index [IX_OcrProcessingLog_ImageId_ProcessedDate] already exists'
END
GO

-- Index for user's OCR processing history
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OcrProcessingLog_UserId_ProcessedDate' AND object_id = OBJECT_ID('dbo.OcrProcessingLog'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_OcrProcessingLog_UserId_ProcessedDate]
    ON [dbo].[OcrProcessingLog] ([UserId], [ProcessedDate] DESC)
    INCLUDE ([ImageId], [IsSuccessful], [ProcessingMethod])
    PRINT 'Index [IX_OcrProcessingLog_UserId_ProcessedDate] created'
END
ELSE
BEGIN
    PRINT 'Index [IX_OcrProcessingLog_UserId_ProcessedDate] already exists'
END
GO

-- Index for finding failed OCR attempts
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OcrProcessingLog_UserId_IsSuccessful' AND object_id = OBJECT_ID('dbo.OcrProcessingLog'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_OcrProcessingLog_UserId_IsSuccessful]
    ON [dbo].[OcrProcessingLog] ([UserId], [IsSuccessful])
    WHERE [IsSuccessful] = 0
    INCLUDE ([ImageId], [ErrorMessage], [ProcessedDate])
    PRINT 'Index [IX_OcrProcessingLog_UserId_IsSuccessful] created'
END
ELSE
BEGIN
    PRINT 'Index [IX_OcrProcessingLog_UserId_IsSuccessful] already exists'
END
GO

PRINT 'All indexes created successfully!'
PRINT 'Total indexes created: 15 custom indexes (plus PRIMARY KEY and UNIQUE constraint indexes)'
GO

-- Display index summary
PRINT ''
PRINT 'Index Summary by Table:'
PRINT '  Users: 1 index (+ PK + UNIQUE Email)'
PRINT '  BloodPressureReadings: 3 indexes (+ PK)'
PRINT '  ReadingImages: 4 indexes (+ PK)'
PRINT '  Albums: 1 index (+ PK)'
PRINT '  ImageTags: 1 index (+ PK + UNIQUE UserTag)'
PRINT '  ImageTagAssociations: 2 indexes (+ PK + UNIQUE ImageTag)'
PRINT '  UserAlertThresholds: 1 index (+ PK)'
PRINT '  OcrProcessingLog: 3 indexes (+ PK)'
GO
