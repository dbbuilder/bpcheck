/*
================================================================================
Blood Pressure Monitor - Database Creation Script
================================================================================
Script: 00_Create_Database.sql
Description: Creates the BPCheckDB database if it doesn't exist
Author: Development Team
Date: October 21, 2025
================================================================================
*/

-- Check if database exists, create if not
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'BPCheckDB')
BEGIN
    CREATE DATABASE [BPCheckDB];
    PRINT 'Database [BPCheckDB] created successfully';
END
ELSE
BEGIN
    PRINT 'Database [BPCheckDB] already exists';
END
GO
