# Blood Pressure Monitor

A native mobile application for iOS and Android that tracks blood pressure and heart rate measurements using computer vision and OCR technology with seamless photo library integration.

## Overview

Blood Pressure Monitor enables users to capture blood pressure readings by photographing their digital blood pressure cuff displays using their device camera or selecting images from their photo library. The application uses Azure Computer Vision to extract readings via OCR, maintains a comprehensive history with image album functionality, and provides trend analysis over time.

### Key Features

- **Native Photo Library Integration**: Access all photos in iOS Photos and Android Gallery to process historical BP images
- **Professional Camera Experience**: Native camera integration with full device controls (focus, flash, HDR)
- **Smart OCR Processing**: Automatically extracts systolic, diastolic, and pulse readings from cuff display photos
- **On-Device OCR Option**: Fast, offline OCR using iOS Vision Framework and Android ML Kit (with Azure CV fallback)
- **Historical Tracking**: Comprehensive reading history with statistical analysis and trend visualization
- **Flexible Entry**: Supports OCR-based, photo library, camera capture, and manual reading entry
- **Image Reprocessing**: Reprocess historical images when OCR initially fails or produces inaccurate results
- **Tag System**: Organize images with custom tags and colors
- **Data Export**: Export readings to CSV or PDF with embedded images
- **Alert Thresholds**: Configure custom thresholds and receive visual alerts for abnormal readings
- **Secure Storage**: All images stored securely in Azure Blob Storage with time-limited access
- **Offline Capable**: Local SQLite storage with cloud sync for seamless offline usage

## Technology Stack

### Mobile Frontend
- **React Native + Expo** - Cross-platform native mobile framework
- **Expo Camera** - Native camera integration
- **Expo Image Picker** - Full photo library access (iOS Photos/Android Gallery)
- **React Navigation** - Native navigation patterns
- **React Native Paper** - Material Design components
- **Victory Native** - Data visualization charts
- **Axios** - HTTP client
- **SQLite** - Local data persistence
- **Expo ML Kit** (optional) - On-device OCR for instant processing

### Backend
- **.NET Core 8.0** - Cross-platform API framework
- **Azure SQL Database** - Relational data storage with T-SQL stored procedures
- **Azure Blob Storage** - Image and thumbnail storage
- **Azure Computer Vision API** - Cloud OCR processing
- **Azure Key Vault** - Secure configuration management
- **Entity Framework Core 8.0** - Data access (stored procedures only)
- **Serilog** - Structured logging with Application Insights integration
- **Hangfire** - Background job processing
- **Polly** - Resilience and transient fault handling

### Infrastructure
- **Azure App Service** - API hosting (Linux)
- **Azure Application Insights** - Monitoring and telemetry
- **Apple App Store** - iOS distribution
- **Google Play Store** - Android distribution

## Prerequisites

### Development Environment
- **Node.js 18.x** or later (LTS recommended)
- **npm or yarn** - Package manager
- **Expo CLI** - `npm install -g expo-cli`
- **EAS CLI** - `npm install -g eas-cli` (for builds)
- **.NET SDK 8.0** or later
- **Azure CLI** 2.50 or later
- **SQL Server Management Studio** or **Azure Data Studio**
- **Xcode 14+** (macOS only, for iOS development)
- **Android Studio** (for Android development)
- **iOS Simulator** (macOS) or **Android Emulator**

### Mobile Development
- **Apple Developer Account** (for iOS distribution)
- **Google Play Developer Account** (for Android distribution)
- **Physical devices recommended** for camera/photo testing

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

```bash
cd Database/Scripts

# Connect using sqlcmd
sqlcmd -S tcp:$SQL_SERVER.database.windows.net,1433 -d $SQL_DATABASE -U sqladmin -P YourSecurePassword123! -i 01_Create_Tables.sql
```

### 4. Configure Key Vault Secrets

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

# Store secrets
az keyvault secret set --vault-name $KEYVAULT --name "SqlConnectionString" --value "$SQL_CONNECTION_STRING"
az keyvault secret set --vault-name $KEYVAULT --name "StorageConnectionString" --value "$STORAGE_CONNECTION_STRING"
az keyvault secret set --vault-name $KEYVAULT --name "ComputerVisionEndpoint" --value "$CV_ENDPOINT"
az keyvault secret set --vault-name $KEYVAULT --name "ComputerVisionApiKey" --value "$CV_KEY"
az keyvault secret set --vault-name $KEYVAULT --name "JwtSecretKey" --value "$(openssl rand -base64 32)"
```

### 5. Backend Setup

```bash
cd BloodPressureMonitor.API

# Restore packages
dotnet restore

# Run the API
dotnet run

# API available at https://localhost:5001
# Swagger UI at https://localhost:5001/swagger
```

### 6. Mobile App Setup

```bash
cd BloodPressureMonitor.Mobile

# Install dependencies
npm install

# Start Expo development server
npx expo start

# Options:
# - Press 'i' for iOS simulator (macOS only)
# - Press 'a' for Android emulator
# - Scan QR code with Expo Go app for physical device testing
```

#### Configure Environment Variables

Create `.env` file in mobile app directory:

```env
API_BASE_URL=https://your-api-url.azurewebsites.net/api
ENABLE_LOCAL_OCR=true
ENABLE_CLOUD_SYNC=true
```

### 7. Build for Production

#### iOS Build
```bash
# Configure EAS
eas build:configure

# Build for iOS
eas build --platform ios

# Submit to App Store
eas submit --platform ios
```

#### Android Build
```bash
# Build for Android
eas build --platform android

# Submit to Play Store
eas submit --platform android
```

## Project Structure

### Mobile App Structure
```
BloodPressureMonitor.Mobile/
├── src/
│   ├── components/          # Reusable React Native components
│   ├── screens/             # Screen components (Camera, Gallery, History, etc.)
│   ├── navigation/          # React Navigation configuration
│   ├── services/            # API service layer
│   │   ├── api.js          # API client
│   │   ├── camera.js       # Camera service
│   │   ├── photoLibrary.js # Photo picker service
│   │   ├── ocr.js          # OCR processing (local + cloud)
│   │   └── storage.js      # SQLite local storage
│   ├── store/               # State management (Context/Redux)
│   ├── utils/               # Helper functions
│   ├── constants/           # App constants
│   └── App.js               # Application entry point
├── assets/                  # Images, fonts, icons
├── app.json                 # Expo configuration
├── eas.json                 # EAS Build configuration
├── package.json             # Dependencies
└── .env                     # Environment variables
```

### Backend Structure
```
BloodPressureMonitor.API/
├── Controllers/             # API endpoints
├── Services/                # Business logic
│   ├── Interfaces/         # Service contracts
│   └── Implementations/    # Service implementations
├── Data/                    # Data access layer
├── Models/                  # Data models
│   ├── Entities/           # Database entities
│   ├── DTOs/               # Data transfer objects
│   └── ViewModels/         # Response models
├── Utilities/              # Helper classes
├── BackgroundJobs/         # Hangfire jobs
├── Middleware/             # Custom middleware
└── appsettings.json        # Configuration
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
    └── Tag_Procedures.sql
```

## Key Mobile Features

### Photo Library Integration
- Access iOS Photos and Android Gallery
- Select multiple photos for batch processing
- Browse historical photos by date
- Filter photos by location/album

### Camera Integration
- Native camera interface
- Auto-focus on BP monitor display
- Flash control for low-light conditions
- Grid overlay for alignment
- Instant capture and preview

### OCR Processing
- **Local OCR** (iOS Vision/ML Kit): Instant processing, works offline
- **Cloud OCR** (Azure CV): Higher accuracy, requires internet
- Automatic fallback between local and cloud
- Confidence scoring for both methods
- Manual correction interface

### Offline Capability
- Local SQLite database for readings
- Queue uploads when offline
- Background sync when connected
- Conflict resolution for sync

## Documentation

- [Requirements Document](REQUIREMENTS.md) - Complete technical requirements
- [TODO List](TODO.md) - Implementation checklist and progress
- [Architecture Decision](ARCHITECTURE.md) - Why React Native over PWA
- [API Documentation](https://your-api-url/swagger) - Interactive API documentation
- [Archived PWA Documentation](archive/) - Original Vue.js/PWA design

## Development Workflow

1. **Backend Development**: .NET API development continues as planned
2. **Mobile Development**: React Native Expo app development
3. **Testing**: Physical device testing required for camera/photo library
4. **CI/CD**: EAS Build for automated builds
5. **Distribution**: App Store and Play Store releases

## Support

### Contact

- **Technical Issues**: Create GitHub issue
- **Security Concerns**: Email security@yourorg.com
- **General Questions**: Email support@yourorg.com

## License

Copyright © 2025 Your Organization. All rights reserved.

This project is proprietary and confidential. Unauthorized copying, distribution, or use of this software is strictly prohibited.

---

**Version**: 2.0.0  
**Architecture**: React Native + Expo (Native Mobile)  
**Last Updated**: October 20, 2025  
**Status**: Architecture Updated - Ready for Implementation
