# Blood Pressure Monitor

A mobile-first web application for tracking blood pressure and heart rate measurements using computer vision and OCR technology.

## Overview

Blood Pressure Monitor enables users to capture blood pressure readings by photographing their digital blood pressure cuff displays. The application uses Azure Computer Vision to extract readings via OCR, maintains a comprehensive history with image album functionality, and provides trend analysis over time.

### Key Features

- **Smart OCR Processing**: Automatically extracts systolic, diastolic, and pulse readings from cuff display photos
- **Image Album**: Browse, search, and manage all captured images with thumbnail gallery view
- **Historical Tracking**: Comprehensive reading history with statistical analysis and trend visualization
- **Flexible Entry**: Supports both OCR-based and manual reading entry
- **Image Reprocessing**: Reprocess historical images when OCR initially fails or produces inaccurate results
- **Tag System**: Organize images with custom tags and colors
- **Data Export**: Export readings to CSV or PDF with embedded images
- **Alert Thresholds**: Configure custom thresholds and receive visual alerts for abnormal readings
- **Secure Storage**: All images stored securely in Azure Blob Storage with time-limited access

## Technology Stack

### Backend
- **.NET Core 8.0** - Cross-platform framework
- **Azure SQL Database** - Relational data storage with T-SQL stored procedures
- **Azure Blob Storage** - Image and thumbnail storage
- **Azure Computer Vision API** - OCR processing
- **Azure Key Vault** - Secure configuration management
- **Entity Framework Core 8.0** - Data access (stored procedures only)
- **Serilog** - Structured logging with Application Insights integration
- **Hangfire** - Background job processing
- **Polly** - Resilience and transient fault handling

### Frontend
- **Vue.js 3** - Progressive JavaScript framework with Composition API
- **Tailwind CSS** - Utility-first CSS framework
- **Pinia** - State management
- **Chart.js** - Data visualization
- **Axios** - HTTP client

### Infrastructure
- **Azure App Service** - Hosting (Linux)
- **Azure Application Insights** - Monitoring and telemetry
- **Azure Active Directory** - Authentication (future)

## Prerequisites

### Development Environment
- **.NET SDK 8.0** or later
- **Node.js 18.x** or later
- **npm 9.x** or later
- **Azure CLI** 2.50 or later
- **SQL Server Management Studio** or **Azure Data Studio**
- **Visual Studio Code** or **Visual Studio 2022**

### Azure Resources
- Azure Subscription (active)
- Resource Group created
- Azure SQL Database (S1 or higher)
- Azure Storage Account (Standard, LRS minimum)
- Azure Computer Vision resource (S1 tier)
- Azure Key Vault (Standard tier)
- Azure App Service Plan (B2 minimum for development)

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/yourorg/blood-pressure-monitor.git
cd blood-pressure-monitor
```

### 2. Azure Resource Provisioning

Execute the following Azure CLI commands to create required resources:

```bash
# Set variables
RESOURCE_GROUP="bpm-rg"
LOCATION="eastus"
SQL_SERVER="bpm-sql-server"
SQL_DATABASE="bpm-db"
STORAGE_ACCOUNT="bpmstorage$(openssl rand -hex 4)"
KEYVAULT="bpm-kv-$(openssl rand -hex 4)"
COMPUTER_VISION="bpm-cv"
APP_SERVICE_PLAN="bpm-asp"
WEB_APP="bpm-api-$(openssl rand -hex 4)"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create SQL Server and Database
az sql server create --name $SQL_SERVER --resource-group $RESOURCE_GROUP \
  --location $LOCATION --admin-user sqladmin --admin-password 'YourSecurePassword123!'

az sql db create --resource-group $RESOURCE_GROUP --server $SQL_SERVER \
  --name $SQL_DATABASE --service-objective S1

# Create Storage Account
az storage account create --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP \
  --location $LOCATION --sku Standard_LRS

# Create blob containers
az storage container create --name originals --account-name $STORAGE_ACCOUNT
az storage container create --name thumbnails-150 --account-name $STORAGE_ACCOUNT
az storage container create --name thumbnails-400 --account-name $STORAGE_ACCOUNT
az storage container create --name archive --account-name $STORAGE_ACCOUNT

# Create Key Vault
az keyvault create --name $KEYVAULT --resource-group $RESOURCE_GROUP --location $LOCATION

# Create Computer Vision resource
az cognitiveservices account create --name $COMPUTER_VISION --resource-group $RESOURCE_GROUP \
  --kind ComputerVision --sku S1 --location $LOCATION --yes

# Create App Service Plan (Linux)
az appservice plan create --name $APP_SERVICE_PLAN --resource-group $RESOURCE_GROUP \
  --location $LOCATION --is-linux --sku B2

# Create Web App
az webapp create --name $WEB_APP --resource-group $RESOURCE_GROUP \
  --plan $APP_SERVICE_PLAN --runtime "DOTNET|8.0"
```

### 3. Database Setup

#### Run Database Schema Scripts

```bash
cd Database/Scripts

# Connect to Azure SQL Database using SQL Server Management Studio or Azure Data Studio
# Connection string: Server=tcp:{SQL_SERVER}.database.windows.net,1433;Database=bpm-db;User ID=sqladmin;Password={YourPassword}

# Execute scripts in order:
# 1. 01_Create_Tables.sql
# 2. 02_Create_Indexes.sql
# 3. Run all stored procedure scripts in Database/StoredProcedures/
```

Alternatively, use sqlcmd:

```bash
sqlcmd -S tcp:$SQL_SERVER.database.windows.net,1433 -d $SQL_DATABASE -U sqladmin -P 'YourSecurePassword123!' \
  -i 01_Create_Tables.sql

sqlcmd -S tcp:$SQL_SERVER.database.windows.net,1433 -d $SQL_DATABASE -U sqladmin -P 'YourSecurePassword123!' \
  -i 02_Create_Indexes.sql

# Run all stored procedure scripts
for file in ../StoredProcedures/*.sql; do
  sqlcmd -S tcp:$SQL_SERVER.database.windows.net,1433 -d $SQL_DATABASE -U sqladmin -P 'YourSecurePassword123!' -i "$file"
done
```

### 4. Configure Key Vault Secrets

Store sensitive configuration in Azure Key Vault:

```bash
# Get connection strings
SQL_CONNECTION_STRING=$(az sql db show-connection-string --client ado.net \
  --server $SQL_SERVER --name $SQL_DATABASE | sed 's/<username>/sqladmin/g' | sed 's/<password>/YourSecurePassword123!/g')

STORAGE_CONNECTION_STRING=$(az storage account show-connection-string \
  --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP --query connectionString -o tsv)

CV_ENDPOINT=$(az cognitiveservices account show --name $COMPUTER_VISION \
  --resource-group $RESOURCE_GROUP --query properties.endpoint -o tsv)

CV_KEY=$(az cognitiveservices account keys list --name $COMPUTER_VISION \
  --resource-group $RESOURCE_GROUP --query key1 -o tsv)

# Store secrets in Key Vault
az keyvault secret set --vault-name $KEYVAULT --name "SqlConnectionString" --value "$SQL_CONNECTION_STRING"
az keyvault secret set --vault-name $KEYVAULT --name "StorageConnectionString" --value "$STORAGE_CONNECTION_STRING"
az keyvault secret set --vault-name $KEYVAULT --name "ComputerVisionEndpoint" --value "$CV_ENDPOINT"
az keyvault secret set --vault-name $KEYVAULT --name "ComputerVisionApiKey" --value "$CV_KEY"
az keyvault secret set --vault-name $KEYVAULT --name "JwtSecretKey" --value "$(openssl rand -base64 32)"
```

### 5. Backend Setup

#### Install NuGet Packages

```bash
cd BloodPressureMonitor.API

# Install required packages
dotnet add package Microsoft.EntityFrameworkCore.SqlServer --version 8.0.0
dotnet add package Microsoft.Data.SqlClient --version 5.1.0
dotnet add package Azure.Storage.Blobs --version 12.19.0
dotnet add package Azure.AI.Vision.ImageAnalysis --version 1.0.0-beta.1
dotnet add package Azure.Identity --version 1.10.0
dotnet add package Azure.Extensions.AspNetCore.Configuration.Secrets --version 1.3.0
dotnet add package Serilog.AspNetCore --version 8.0.0
dotnet add package Serilog.Sinks.ApplicationInsights --version 4.0.0
dotnet add package Hangfire.AspNetCore --version 1.8.6
dotnet add package Hangfire.SqlServer --version 1.8.6
dotnet add package Polly --version 8.2.0
dotnet add package BCrypt.Net-Next --version 4.0.3
dotnet add package Swashbuckle.AspNetCore --version 6.5.0
dotnet add package System.IdentityModel.Tokens.Jwt --version 7.0.0
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer --version 8.0.0
```

#### Run Backend Locally

```bash
# Ensure you're in the API project directory
cd BloodPressureMonitor.API

# Run the application
dotnet run

# API will be available at https://localhost:5001 and http://localhost:5000
# Swagger UI available at https://localhost:5001/swagger
```

### 6. Frontend Setup

#### Install npm Packages

```bash
cd blood-pressure-monitor-ui

# Install dependencies
npm install
```

Required packages are defined in `package.json`:
- vue@^3.4.0
- vue-router@^4.2.0
- pinia@^2.1.0
- axios@^1.6.0
- chart.js@^4.4.0
- date-fns@^3.0.0
- tailwindcss@^3.4.0
- @headlessui/vue@^1.7.0
- @heroicons/vue@^2.1.0

#### Configure Environment Variables

Create `.env.development` file:

```env
VITE_API_BASE_URL=https://localhost:5001/api
VITE_APP_NAME=Blood Pressure Monitor
VITE_STORAGE_KEY_PREFIX=bpm_
```

#### Run Frontend Locally

```bash
npm run dev

# Frontend will be available at http://localhost:5173
```

## Project Structure

### Backend Structure
```
BloodPressureMonitor.API/
├── Controllers/              # API endpoints
├── Services/                 # Business logic
│   ├── Interfaces/          # Service contracts
│   └── Implementations/     # Service implementations
├── Data/                    # Data access layer
│   └── StoredProcedures/   # EF Core stored procedure wrappers
├── Models/                  # Data models
│   ├── Entities/           # Database entities
│   ├── DTOs/               # Data transfer objects
│   └── ViewModels/         # Response models
├── Utilities/              # Helper classes
├── BackgroundJobs/         # Hangfire jobs
├── Middleware/             # Custom middleware
├── Configuration/          # App configuration
├── appsettings.json        # Configuration file
└── Program.cs              # Application entry point
```

### Frontend Structure
```
blood-pressure-monitor-ui/
├── src/
│   ├── components/         # Reusable Vue components
│   ├── views/              # Page components
│   ├── services/           # API service layer
│   ├── store/              # Pinia state management
│   ├── router/             # Vue Router configuration
│   ├── composables/        # Composition API utilities
│   ├── utils/              # Helper functions
│   ├── App.vue             # Root component
│   └── main.js             # Application entry point
├── public/                 # Static assets
├── index.html              # HTML template
├── tailwind.config.js      # Tailwind configuration
├── vite.config.js          # Vite configuration
└── package.json            # Dependencies
```

### Database Structure
```
Database/
├── Scripts/
│   ├── 01_Create_Tables.sql
│   ├── 02_Create_Indexes.sql
│   └── 03_Create_StoredProcedures.sql
└── StoredProcedures/
    ├── User_Procedures.sql
    ├── Reading_Procedures.sql
    ├── Image_Procedures.sql
    ├── Album_Procedures.sql
    └── Tag_Procedures.sql
```

## Documentation

- [Requirements Document](REQUIREMENTS.md) - Complete technical requirements
- [TODO List](TODO.md) - Implementation checklist and progress
- [Future Enhancements](FUTURE.md) - Planned features and improvements
- [API Documentation](https://your-api-url/swagger) - Interactive API documentation

## Support

### Contact

- **Technical Issues**: Create GitHub issue
- **Security Concerns**: Email security@yourorg.com
- **General Questions**: Email support@yourorg.com

## License

Copyright © 2025 Your Organization. All rights reserved.

This project is proprietary and confidential. Unauthorized copying, distribution, or use of this software is strictly prohibited.

---

**Version**: 1.0.0  
**Last Updated**: October 10, 2025  
**Status**: Development
