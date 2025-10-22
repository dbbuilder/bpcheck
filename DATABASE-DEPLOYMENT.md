# Database Deployment Guide
Blood Pressure Monitor - Complete Database Setup

## Prerequisites

- SQL Server 2019 or later
- sqlcmd command-line tool
- Database permissions to CREATE DATABASE and execute DDL

## Deployment Steps

### Step 1: Create Database

```bash
cd /mnt/d/Dev2/blood-pressure-check/Database/Scripts

# Using sqlcmd (adjust connection parameters as needed)
sqlcmd -S <server> -U <username> -P <password> -C -i 00_Create_Database.sql
```

**For local development**:
```bash
sqlcmd -S localhost -C -i 00_Create_Database.sql
```

**For remote server** (example from global config):
```bash
sqlcmd -S sqltest.schoolvision.net,14333 -U sv -P <password> -C -i 00_Create_Database.sql
```

### Step 2: Create Tables

```bash
sqlcmd -S <server> -U <username> -P <password> -C -d BloodPressureMonitor -i 01_Create_Tables.sql
```

This creates:
- Users table
- BloodPressureReadings table
- ReadingImages table
- Albums table
- ImageTags table
- ImageTagAssociations table
- UserAlertThresholds table
- OcrProcessingLog table

### Step 3: Create Indexes

```bash
sqlcmd -S <server> -U <username> -P <password> -C -d BloodPressureMonitor -i 02_Create_Indexes.sql
```

Creates 15 performance indexes including:
- Covering indexes for readings by user and date
- Filtered indexes for flagged readings
- Orphaned images detection
- Tag search optimization

### Step 4: Apply Clerk Integration Migration

```bash
sqlcmd -S <server> -U <username> -P <password> -C -d BloodPressureMonitor -i 03_Add_Clerk_Integration.sql
```

This migration:
- Adds `ClerkUserId` column to Users table
- Creates unique index on ClerkUserId
- Makes `PasswordHash` nullable
- Converts Email unique constraint to non-unique index

### Step 5: Deploy User Stored Procedures

```bash
cd ../StoredProcedures

# Original user procedures
sqlcmd -S <server> -U <username> -P <password> -C -d BloodPressureMonitor -i User_Procedures.sql

# Clerk-specific procedures
sqlcmd -S <server> -U <username> -P <password> -C -d BloodPressureMonitor -i Clerk_User_Procedures.sql
```

**Note**: You may need to deploy other stored procedure files as development continues:
- Reading_Procedures.sql (when created)
- Image_Procedures.sql (when created)
- Tag_Procedures.sql (when created)
- Alert_Procedures.sql (when created)

## Verification

After deployment, verify the schema:

```sql
-- Check database exists
SELECT name, database_id, create_date
FROM sys.databases
WHERE name = 'BloodPressureMonitor';

-- Check all tables exist
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
-- Expected: 8 tables

-- Check ClerkUserId column exists
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Users'
AND COLUMN_NAME = 'ClerkUserId';
-- Expected: ClerkUserId, nvarchar, YES

-- Check indexes
SELECT
    i.name AS IndexName,
    t.name AS TableName,
    i.type_desc AS IndexType
FROM sys.indexes i
INNER JOIN sys.tables t ON i.object_id = t.object_id
WHERE t.name IN ('Users', 'BloodPressureReadings', 'ReadingImages')
ORDER BY t.name, i.name;

-- Check stored procedures
SELECT
    ROUTINE_NAME,
    ROUTINE_TYPE
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'PROCEDURE'
AND ROUTINE_NAME LIKE 'usp_%'
ORDER BY ROUTINE_NAME;
-- Should see User and Clerk procedures
```

## Connection Strings

### Development (local SQL Server)
```
Server=localhost;Database=BloodPressureMonitor;Trusted_Connection=True;TrustServerCertificate=True;
```

### Development (remote SQL Server with credentials)
```
Server=sqltest.schoolvision.net,14333;Database=BloodPressureMonitor;User Id=sv;Password=<password>;TrustServerCertificate=True;Encrypt=Optional;MultipleActiveResultSets=true;Connection Timeout=30;
```

### Azure SQL Database
```
Server=tcp:bloodpressure.database.windows.net,1433;Database=BloodPressureMonitor;User ID=<admin>@bloodpressure;Password=<password>;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;
```

## Troubleshooting

### Issue: Login timeout or connection refused
**Solution**: Check SQL Server is running and accepting connections
```bash
# Check SQL Server service status (Windows)
Get-Service MSSQLSERVER

# Test connectivity
sqlcmd -S <server> -U <username> -P <password> -C -Q "SELECT @@VERSION"
```

### Issue: Database already exists
**Solution**: Scripts are idempotent - they check before creating. Safe to re-run.

### Issue: Permission denied
**Solution**: User needs CREATE DATABASE permission
```sql
-- Grant to user (run as admin)
USE master;
GRANT CREATE DATABASE TO [username];
```

### Issue: "Keyword not supported" in connection string
**Solution**: Use exact keyword syntax (see global instructions)
- Use `Connection Timeout` not `ConnectTimeout`
- Use `Encrypt=Optional` for named instances
- Include `TrustServerCertificate=True` for self-signed certs

## Post-Deployment Tasks

### 1. Test User Sync
```sql
-- Test Clerk user sync procedure
EXEC usp_User_SyncFromClerk
    @ClerkUserId = 'user_test123',
    @Email = 'test@example.com',
    @FirstName = 'Test',
    @LastName = 'User';

-- Verify user created
SELECT * FROM Users WHERE ClerkUserId = 'user_test123';
```

### 2. Configure Application
Update `appsettings.Development.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=<your-server>;Database=BloodPressureMonitor;..."
  }
}
```

### 3. Test API Connection
```bash
# Start API
cd BloodPressureMonitor.API
dotnet run

# In another terminal, test health endpoint
curl http://localhost:5000/api/authtest/health
```

## Deployment Checklist

- [ ] SQL Server accessible and running
- [ ] Database created (00_Create_Database.sql)
- [ ] Tables created (01_Create_Tables.sql)
- [ ] Indexes created (02_Create_Indexes.sql)
- [ ] Clerk migration applied (03_Add_Clerk_Integration.sql)
- [ ] User procedures deployed (User_Procedures.sql)
- [ ] Clerk procedures deployed (Clerk_User_Procedures.sql)
- [ ] Schema verified (8 tables, ClerkUserId column exists)
- [ ] Stored procedures verified (11+ procedures)
- [ ] Connection string updated in appsettings
- [ ] API tested with database connection

## Automated Deployment Script

For convenience, you can run all steps sequentially:

```bash
#!/bin/bash
# deploy-database.sh

SERVER="your-server"
USER="your-username"
PASS="your-password"
DB="BloodPressureMonitor"

echo "Deploying Blood Pressure Monitor Database..."

# Create database
sqlcmd -S $SERVER -U $USER -P $PASS -C -i Database/Scripts/00_Create_Database.sql

# Create tables
sqlcmd -S $SERVER -U $USER -P $PASS -C -d $DB -i Database/Scripts/01_Create_Tables.sql

# Create indexes
sqlcmd -S $SERVER -U $USER -P $PASS -C -d $DB -i Database/Scripts/02_Create_Indexes.sql

# Apply Clerk migration
sqlcmd -S $SERVER -U $USER -P $PASS -C -d $DB -i Database/Scripts/03_Add_Clerk_Integration.sql

# Deploy procedures
sqlcmd -S $SERVER -U $USER -P $PASS -C -d $DB -i Database/StoredProcedures/User_Procedures.sql
sqlcmd -S $SERVER -U $USER -P $PASS -C -d $DB -i Database/StoredProcedures/Clerk_User_Procedures.sql

echo "Deployment complete!"
```

Make executable and run:
```bash
chmod +x deploy-database.sh
./deploy-database.sh
```

## Rollback

If you need to rollback the Clerk migration:

```sql
USE [BloodPressureMonitor];

-- Remove ClerkUserId column
ALTER TABLE Users DROP COLUMN ClerkUserId;

-- Restore Email unique constraint
CREATE UNIQUE NONCLUSTERED INDEX UQ_Users_Email
ON Users (Email);

-- Make PasswordHash required again
ALTER TABLE Users ALTER COLUMN PasswordHash NVARCHAR(MAX) NOT NULL;

-- Drop Clerk procedures
DROP PROCEDURE IF EXISTS usp_User_SyncFromClerk;
DROP PROCEDURE IF EXISTS usp_User_GetByClerkId;
DROP PROCEDURE IF EXISTS usp_User_UpdateProfile;
```

## Next Steps

After successful database deployment:

1. **Start the API** - `dotnet run` in BloodPressureMonitor.API
2. **Test authentication** - Sign up in mobile app
3. **Verify user sync** - Check Users table for new record
4. **Deploy to Azure** - Follow Azure SQL Database deployment guide
