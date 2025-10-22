@echo off
REM ================================================================================
REM BPCheckDB Database Deployment Script (Windows)
REM ================================================================================
REM Server: sqltest.schoolvision.net,14333
REM Database: BPCheckDB
REM User: sv
REM ================================================================================

set SERVER=sqltest.schoolvision.net,14333
set USER=sv
set PASS=Gv51076!
set DB=BPCheckDB

echo =========================================
echo BPCheckDB Database Deployment
echo =========================================
echo Server: %SERVER%
echo Database: %DB%
echo.

echo Step 1: Creating database...
cd Scripts
sqlcmd -S %SERVER% -U %USER% -P %PASS% -N -C -i BPCheck_00_Create_Database.sql
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Database creation failed
    pause
    exit /b 1
)
echo SUCCESS: Database created
echo.

echo Step 2: Creating tables...
sqlcmd -S %SERVER% -U %USER% -P %PASS% -N -C -d %DB% -i BPCheck_01_Create_Tables.sql
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Table creation failed
    pause
    exit /b 1
)
echo SUCCESS: Tables created
echo.

echo Step 3: Creating indexes...
sqlcmd -S %SERVER% -U %USER% -P %PASS% -N -C -d %DB% -i BPCheck_02_Create_Indexes.sql
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Index creation failed
    pause
    exit /b 1
)
echo SUCCESS: Indexes created
echo.

echo Step 4: Applying Clerk integration...
sqlcmd -S %SERVER% -U %USER% -P %PASS% -N -C -d %DB% -i BPCheck_03_Add_Clerk_Integration.sql
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Clerk integration failed
    pause
    exit /b 1
)
echo SUCCESS: Clerk integration applied
echo.

echo Step 5: Deploying user procedures...
cd ..\StoredProcedures
sqlcmd -S %SERVER% -U %USER% -P %PASS% -N -C -d %DB% -i BPCheck_User_Procedures.sql
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: User procedures deployment failed
    pause
    exit /b 1
)
echo SUCCESS: User procedures deployed
echo.

echo Step 6: Deploying Clerk procedures...
sqlcmd -S %SERVER% -U %USER% -P %PASS% -N -C -d %DB% -i BPCheck_Clerk_User_Procedures.sql
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Clerk procedures deployment failed
    pause
    exit /b 1
)
echo SUCCESS: Clerk procedures deployed
echo.

echo =========================================
echo Deployment Complete!
echo =========================================
echo.

echo Verifying deployment...
sqlcmd -S %SERVER% -U %USER% -P %PASS% -N -C -d %DB% -Q "SELECT COUNT(*) as TableCount FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'"
sqlcmd -S %SERVER% -U %USER% -P %PASS% -N -C -d %DB% -Q "SELECT COUNT(*) as ProcedureCount FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE'"
echo.

echo Next steps:
echo 1. Restart the .NET API
echo 2. Test with: curl http://localhost:5000/api/authtest/health
echo 3. Sign up in mobile app to test end-to-end
echo.
pause
