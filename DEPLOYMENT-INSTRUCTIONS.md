# Database Deployment Instructions

## Current Status
- ✅ All SQL scripts prepared and ready
- ✅ Backend API running on http://localhost:5000
- ⏸️ SQL Server instance needed for deployment

## Option 1: Deploy with Docker SQL Server (Recommended for Testing)

### Start SQL Server Container
```bash
# Start SQL Server 2022 in Docker
docker run -e "ACCEPT_EULA=Y" \
  -e "SA_PASSWORD=YourStrong@Passw0rd" \
  -p 1433:1433 \
  --name sqlserver-bp \
  -d mcr.microsoft.com/mssql/server:2022-latest

# Wait for SQL Server to start (30 seconds)
sleep 30

# Verify it's running
docker ps | grep sqlserver-bp
```

### Deploy Database
```bash
cd /mnt/d/Dev2/blood-pressure-check/Database/Scripts

# Set connection variables
SERVER="localhost"
USER="sa"
PASS="YourStrong@Passw0rd"

# 1. Create database
sqlcmd -S $SERVER -U $USER -P $PASS -C -i 00_Create_Database.sql

# 2. Create tables
sqlcmd -S $SERVER -U $USER -P $PASS -C -d BloodPressureMonitor -i 01_Create_Tables.sql

# 3. Create indexes
sqlcmd -S $SERVER -U $USER -P $PASS -C -d BloodPressureMonitor -i 02_Create_Indexes.sql

# 4. Apply Clerk migration
sqlcmd -S $SERVER -U $USER -P $PASS -C -d BloodPressureMonitor -i 03_Add_Clerk_Integration.sql

# 5. Deploy user procedures
cd ../StoredProcedures
sqlcmd -S $SERVER -U $USER -P $PASS -C -d BloodPressureMonitor -i User_Procedures.sql

# 6. Deploy Clerk procedures
sqlcmd -S $SERVER -U $USER -P $PASS -C -d BloodPressureMonitor -i Clerk_User_Procedures.sql
```

### Update API Connection String
```bash
# Update appsettings.Development.json
cd ../../BloodPressureMonitor.API

# Edit connection string to:
# "Server=localhost;Database=BloodPressureMonitor;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;Encrypt=Optional;"
```

## Option 2: Deploy to Azure SQL Database

### Create Azure SQL Database
```bash
# Login to Azure
az login

# Create resource group
az group create --name rg-bloodpressure --location eastus

# Create SQL server
az sql server create \
  --name sqlsrv-bloodpressure \
  --resource-group rg-bloodpressure \
  --location eastus \
  --admin-user sqladmin \
  --admin-password "YourStrong@Passw0rd123"

# Create database
az sql db create \
  --resource-group rg-bloodpressure \
  --server sqlsrv-bloodpressure \
  --name BloodPressureMonitor \
  --service-objective S0

# Configure firewall
az sql server firewall-rule create \
  --resource-group rg-bloodpressure \
  --server sqlsrv-bloodpressure \
  --name AllowMyIP \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 255.255.255.255
```

### Deploy Scripts
```bash
cd /mnt/d/Dev2/blood-pressure-check/Database/Scripts

SERVER="sqlsrv-bloodpressure.database.windows.net"
USER="sqladmin"
PASS="YourStrong@Passw0rd123"
DB="BloodPressureMonitor"

# Run all scripts
sqlcmd -S $SERVER -U $USER -P $PASS -C -i 00_Create_Database.sql
sqlcmd -S $SERVER -U $USER -P $PASS -C -d $DB -i 01_Create_Tables.sql
sqlcmd -S $SERVER -U $USER -P $PASS -C -d $DB -i 02_Create_Indexes.sql
sqlcmd -S $SERVER -U $USER -P $PASS -C -d $DB -i 03_Add_Clerk_Integration.sql

cd ../StoredProcedures
sqlcmd -S $SERVER -U $USER -P $PASS -C -d $DB -i User_Procedures.sql
sqlcmd -S $SERVER -U $USER -P $PASS -C -d $DB -i Clerk_User_Procedures.sql
```

## Option 3: Existing SQL Server Instance

If you have access to an existing SQL Server:

```bash
cd /mnt/d/Dev2/blood-pressure-check/Database/Scripts

# Set your connection details
SERVER="your-server,port"
USER="your-username"
PASS="your-password"
DB="BloodPressureMonitor"

# Run deployment
sqlcmd -S $SERVER -U $USER -P "$PASS" -C -i 00_Create_Database.sql
sqlcmd -S $SERVER -U $USER -P "$PASS" -C -d $DB -i 01_Create_Tables.sql
sqlcmd -S $SERVER -U $USER -P "$PASS" -C -d $DB -i 02_Create_Indexes.sql
sqlcmd -S $SERVER -U "$PASS" -P "$PASS" -C -d $DB -i 03_Add_Clerk_Integration.sql

cd ../StoredProcedures
sqlcmd -S $SERVER -U $USER -P "$PASS" -C -d $DB -i User_Procedures.sql
sqlcmd -S $SERVER -U $USER -P "$PASS" -C -d $DB -i Clerk_User_Procedures.sql
```

## Verification After Deployment

```bash
# Connect to database
sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -C -d BloodPressureMonitor

# Run these queries:
```

```sql
-- Check tables exist
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
-- Should return: 8 tables

-- Check ClerkUserId column
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Users' AND COLUMN_NAME = 'ClerkUserId';
-- Should return: ClerkUserId, nvarchar, YES

-- Check stored procedures
SELECT ROUTINE_NAME
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME LIKE 'usp_%'
ORDER BY ROUTINE_NAME;
-- Should return: 11 procedures

-- Test user sync procedure
EXEC usp_User_SyncFromClerk
    @ClerkUserId = 'test_user_123',
    @Email = 'test@example.com',
    @FirstName = 'Test',
    @LastName = 'User';

-- Verify user created
SELECT * FROM Users WHERE ClerkUserId = 'test_user_123';
```

## Update Backend Connection String

After deploying the database, update the API configuration:

### appsettings.Development.json
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=BloodPressureMonitor;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;Encrypt=Optional;MultipleActiveResultSets=true;Connection Timeout=30;"
  }
}
```

### Restart API
```bash
# Stop current API (Ctrl+C)
# Restart it
cd /mnt/d/Dev2/blood-pressure-check/BloodPressureMonitor.API
dotnet run
```

## Test End-to-End

1. **API Health Check**
   ```bash
   curl http://localhost:5000/api/authtest/health
   ```

2. **Start Mobile App**
   ```bash
   cd /mnt/d/Dev2/blood-pressure-check/BloodPressureMonitor.Mobile
   npx expo start
   ```

3. **Sign Up New User**
   - Open Expo app on phone/emulator
   - Navigate to Register screen
   - Create account with Clerk
   - Should auto-sync to database

4. **Verify in Database**
   ```sql
   SELECT ClerkUserId, Email, FirstName, LastName, CreatedDate
   FROM Users
   ORDER BY CreatedDate DESC;
   ```

5. **Test Protected Endpoint**
   - Copy JWT token from mobile app network logs
   - Test API endpoint:
   ```bash
   curl http://localhost:5000/api/authtest/me \
     -H "Authorization: Bearer <JWT_TOKEN>"
   ```

## Current Limitations

- **No SQL Server Running**: Need to start Docker container or use Azure SQL
- **Docker Desktop Not Running**: May need to start Docker Desktop first
- **Remote Server Access**: sqltest.schoolvision.net requires correct credentials

## Recommended Next Step

**Use Docker SQL Server for local testing:**
1. Start Docker Desktop
2. Run SQL Server container (see Option 1 above)
3. Deploy all scripts
4. Test end-to-end authentication flow
5. Deploy to Azure SQL for production later

## Scripts Ready for Deployment

All scripts are in `/mnt/d/Dev2/blood-pressure-check/Database/`:

- ✅ `Scripts/00_Create_Database.sql` (34 lines)
- ✅ `Scripts/01_Create_Tables.sql` (295 lines, 8 tables)
- ✅ `Scripts/02_Create_Indexes.sql` (157 lines, 15 indexes)
- ✅ `Scripts/03_Add_Clerk_Integration.sql` (117 lines, Clerk integration)
- ✅ `StoredProcedures/User_Procedures.sql` (275 lines, 8 procedures)
- ✅ `StoredProcedures/Clerk_User_Procedures.sql` (175 lines, 3 procedures)

**Total**: 1053 lines of production-ready SQL code
