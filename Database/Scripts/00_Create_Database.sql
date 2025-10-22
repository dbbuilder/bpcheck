/*
================================================================================
Blood Pressure Monitor - Database Creation Script
================================================================================
Script: 00_Create_Database.sql
Description: Creates the BloodPressureMonitor database if it doesn't exist
Author: Development Team
Date: October 21, 2025
================================================================================
*/

-- Check if database exists, create if not
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'BloodPressureMonitor')
BEGIN
    CREATE DATABASE [BloodPressureMonitor];
    PRINT 'Database [BloodPressureMonitor] created successfully';
END
ELSE
BEGIN
    PRINT 'Database [BloodPressureMonitor] already exists';
END
GO
