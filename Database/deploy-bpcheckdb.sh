#!/bin/bash
#================================================================================
# BPCheckDB Database Deployment Script
#================================================================================
# Server: sqltest.schoolvision.net,14333
# Database: BPCheckDB
# User: sv
#================================================================================

SERVER="sqltest.schoolvision.net,14333"
USER="sv"
PASS="Gv51076!"
DB="BPCheckDB"

echo "========================================="
echo "BPCheckDB Database Deployment"
echo "========================================="
echo "Server: $SERVER"
echo "Database: $DB"
echo ""

# Function to run SQL with error handling
run_sql() {
    local script=$1
    local description=$2

    echo ">>> $description..."
    pwsh -Command "sqlcmd -S $SERVER -U $USER -P $PASS -C -i $script" 2>&1

    if [ $? -eq 0 ]; then
        echo "✓ $description completed successfully"
    else
        echo "✗ $description failed"
        return 1
    fi
    echo ""
}

# Change to scripts directory
cd "$(dirname "$0")/Scripts"

# Step 1: Create Database
run_sql "BPCheck_00_Create_Database.sql" "Creating database" || exit 1

# Step 2: Create Tables
run_sql "BPCheck_01_Create_Tables.sql" "Creating tables" || exit 1

# Step 3: Create Indexes
run_sql "BPCheck_02_Create_Indexes.sql" "Creating indexes" || exit 1

# Step 4: Apply Clerk Migration
run_sql "BPCheck_03_Add_Clerk_Integration.sql" "Applying Clerk integration" || exit 1

# Step 5: Deploy User Procedures
cd ../StoredProcedures
run_sql "BPCheck_User_Procedures.sql" "Deploying user stored procedures" || exit 1

# Step 6: Deploy Clerk Procedures
run_sql "BPCheck_Clerk_User_Procedures.sql" "Deploying Clerk stored procedures" || exit 1

echo "========================================="
echo "Deployment Complete!"
echo "========================================="
echo ""
echo "Verifying deployment..."

# Verification
pwsh -Command "sqlcmd -S $SERVER -U $USER -P $PASS -C -d $DB -Q 'SELECT COUNT(*) as TableCount FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = '\''BASE TABLE'\'''" 2>&1

echo ""
echo "Next steps:"
echo "1. Update appsettings.Development.json connection string"
echo "2. Restart the API"
echo "3. Test with: curl http://localhost:5000/api/authtest/health"
echo ""
