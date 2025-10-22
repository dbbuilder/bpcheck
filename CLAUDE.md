# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Blood Pressure Monitor is a **React Native + Expo** native mobile application (iOS and Android) that captures blood pressure readings by photographing digital BP cuff displays. Uses Azure Computer Vision OCR and on-device ML for reading extraction, with offline-first SQLite storage and cloud sync.

**Key Architecture Decision**: Pivoted from PWA to React Native (October 2025) to enable native photo library access and professional camera integration. See `ARCHITECTURE.md` for rationale.

## Common Build and Development Commands

### Backend (.NET 8.0 API)

```bash
# Build and run API
dotnet build BloodPressureMonitor.API/BloodPressureMonitor.API.csproj
dotnet run --project BloodPressureMonitor.API

# API runs at https://localhost:5001
# Swagger UI at https://localhost:5001/swagger

# Tests (once test project created)
dotnet test
dotnet test --filter "FullyQualifiedName~ClassName.MethodName"
```

### Mobile App (React Native + Expo)

```bash
# Setup and run
cd BloodPressureMonitor.Mobile
npm install
npx expo start

# Development servers
npx expo start --ios      # iOS Simulator (macOS only)
npx expo start --android  # Android Emulator
# Or press 'i' for iOS, 'a' for Android in interactive mode

# Production builds
eas build --platform ios
eas build --platform android
eas submit --platform ios      # App Store submission
eas submit --platform android  # Play Store submission

# Tests (once created)
npm test
```

### Database

```bash
# Deploy schema (requires Azure SQL or local SQL Server)
sqlcmd -S <server> -d BloodPressureMonitor -U <user> -P <password> -i Database/Scripts/01_Create_Tables.sql
sqlcmd -S <server> -d BloodPressureMonitor -U <user> -P <password> -i Database/Scripts/02_Create_Indexes.sql
sqlcmd -S <server> -d BloodPressureMonitor -U <user> -P <password> -i Database/Scripts/03_Create_StoredProcedures.sql

# WSL to SQL Server: Use WSL host IP (172.31.208.1), not localhost
sqlcmd -S 172.31.208.1,14333 -U <user> -P <password> -C -d BloodPressureMonitor
```

## Architecture and Code Structure

### High-Level Architecture

**3-Tier Architecture**: React Native Mobile → .NET API → Azure SQL + Blob Storage

- **Mobile Layer**: React Native + Expo with offline-first SQLite storage
- **API Layer**: .NET 8.0 REST API with JWT authentication
- **Data Layer**: Azure SQL (stored procedures only), Azure Blob Storage (images)
- **ML/OCR**: iOS Vision Framework + Android ML Kit (on-device), Azure Computer Vision (cloud fallback)

### Critical Architectural Principles

1. **Stored Procedures Only**: All database access through stored procedures - NO LINQ queries, NO EF Core queries, NO dynamic SQL
2. **Offline-First**: Mobile app must work completely offline using local SQLite, sync when online
3. **On-Device OCR First**: Use local Vision Framework/ML Kit, fallback to Azure CV for validation
4. **Native Platform Features**: Leverage native photo library (iOS Photos, Android Gallery) and camera APIs

### Backend Structure (`BloodPressureMonitor.API/`)

```
Controllers/        # REST API endpoints (Auth, Reading, Image, etc.)
Services/
  ├── Interfaces/   # Service contracts (IAuthService, IReadingService, IOcrService, etc.)
  └── Implementations/  # Service implementations
Data/               # Database context and stored procedure execution
Models/
  ├── Entities/     # Database entities (User, BloodPressureReading, ReadingImage, etc.)
  ├── DTOs/         # Data transfer objects for API requests/responses
  └── ViewModels/   # Response models
Utilities/          # Helper classes (JwtTokenGenerator, ImageProcessor, etc.)
BackgroundJobs/     # Hangfire background tasks
Middleware/         # Custom middleware (exception handling, logging)
```

**Service Pattern**: Controllers call Services, Services call Stored Procedures via Data layer. Never bypass this pattern.

### Mobile Structure (`BloodPressureMonitor.Mobile/` - to be created)

```
src/
  ├── screens/      # Screen components (Camera, PhotoPicker, Readings, Dashboard)
  ├── components/   # Reusable UI components
  ├── navigation/   # React Navigation configuration (stack, tab navigators)
  ├── services/
  │   ├── api.ts           # Axios HTTP client
  │   ├── auth.ts          # Authentication service
  │   ├── camera.ts        # Expo Camera wrapper
  │   ├── photoLibrary.ts  # Expo Image Picker wrapper
  │   ├── ocr.ts           # On-device + cloud OCR
  │   ├── database.ts      # SQLite operations
  │   └── sync.ts          # Background sync service
  ├── store/        # Global state (Context API)
  ├── utils/        # Helper functions
  └── constants/    # App constants
```

**Offline-First Pattern**: All data operations through SQLite first → sync to API in background → update local state on success.

### Database Schema

8 tables with intelligent relationships:
- `Users` - User accounts and storage quotas
- `BloodPressureReadings` - Core BP readings (systolic, diastolic, pulse)
- `ReadingImages` - Links readings to Azure Blob images
- `Albums` - User-created photo albums
- `ImageTags` - Custom tags for organization
- `ImageTagAssociations` - Many-to-many tags/images
- `UserAlertThresholds` - Configurable BP alerts
- `OcrProcessingLog` - OCR audit trail

**Critical**: Always use stored procedures for all CRUD operations.

## Key Development Patterns

### Backend (.NET)

**Database Access Pattern** (CRITICAL):
```csharp
// ALWAYS use stored procedures
using var connection = new SqlConnection(connectionString);
var parameters = new[]
{
    new SqlParameter("@UserId", userId),
    new SqlParameter("@Systolic", systolic)
};
var result = await connection.QueryAsync<ReadingDto>(
    "dbo.usp_CreateReading",
    parameters,
    commandType: CommandType.StoredProcedure
);

// NEVER use LINQ or EF Core queries
// ❌ BAD: context.Readings.Where(r => r.UserId == userId).ToList()
```

**JWT Authentication**:
- All endpoints except `/auth/register` and `/auth/login` require JWT
- Use `[Authorize]` attribute on controllers
- Tokens expire in 60 minutes, refresh tokens in 30 days

**Azure Key Vault Configuration**:
- All secrets (connection strings, API keys) stored in Azure Key Vault
- `appsettings.json` uses Key Vault references: `@Microsoft.KeyVault(SecretUri=...)`
- Never hardcode secrets

**Error Handling**:
- Use custom exception middleware for centralized error handling
- Return structured error responses with correlation IDs
- Log all exceptions with Serilog → Application Insights

### Mobile (React Native)

**Offline-First Data Flow**:
```typescript
// 1. Save to local SQLite immediately
await db.insertReading(reading);

// 2. Queue for background sync
await syncQueue.enqueue({ type: 'reading', data: reading });

// 3. Update UI immediately (optimistic update)
setReadings([...readings, reading]);

// 4. Sync happens in background when online
// 5. Handle conflicts with last-write-wins strategy
```

**Permission Handling**:
```typescript
// Always check permissions before using camera/photos
const { status } = await Camera.requestCameraPermissionsAsync();
if (status !== 'granted') {
    // Show rationale and request again or guide to settings
}
```

**OCR Processing Priority**:
1. Try on-device OCR first (iOS Vision Framework / Android ML Kit) - instant, offline
2. If confidence < 70%, fallback to Azure Computer Vision
3. Always show extracted values for user confirmation

**TypeScript Strict Mode**:
- Enabled in `tsconfig.json`
- Use explicit types, avoid `any`
- Handle nullable values properly

## Critical Technical Constraints

### Stored Procedures Only (Non-Negotiable)
- **WHY**: Performance, security (parameterized queries), separation of concerns
- **WHAT**: All database operations must use stored procedures
- **NEVER**: Write LINQ queries, EF Core queries, or dynamic SQL in C# code

### Offline-First Mobile Architecture
- **WHY**: Hospital/home environments have poor/no connectivity
- **WHAT**: All features must work offline using local SQLite, sync when online
- **PATTERN**: Write local → queue sync → update cloud → reconcile conflicts

### Azure Resources Required
- Azure SQL Database (S1+ tier)
- Azure Blob Storage (3 containers: originals, thumbnails-150, thumbnails-400)
- Azure Computer Vision (S1 tier)
- Azure Key Vault (all secrets)
- Azure App Service (B2+ tier, Linux, .NET 8.0)

### SQL Server Connection Strings (CRITICAL)
Use **exact keyword syntax** for Microsoft.Data.SqlClient 5.2+:
```
Server=server.database.windows.net,1433;Database=BloodPressureMonitor;User Id=admin;Password=pass;TrustServerCertificate=True;Encrypt=Optional;MultipleActiveResultSets=true;Connection Timeout=30
```
Note: `Connection Timeout` (with space), NOT `ConnectTimeout` (no space). See global CLAUDE.md for details.

## Testing Requirements

### Backend Testing
- Unit tests for all services (mock stored procedures)
- Integration tests for stored procedures (use test database)
- Test OCR parsing with various BP monitor display formats

### Mobile Testing
- Test on physical iOS and Android devices (camera/photo library)
- Test offline functionality thoroughly
- Test photo library with large libraries (1000+ photos)
- Test OCR accuracy with real BP monitor photos

## Common Pitfalls and Solutions

### 1. EF Core Query Temptation
**Problem**: It's tempting to write LINQ queries instead of calling stored procedures.
**Solution**: Stored procedures are non-negotiable for this project. Always call stored procedures through the Data layer.

### 2. Forgetting Offline-First
**Problem**: API calls fail when offline.
**Solution**: Always save to local SQLite first, then queue sync. Never block UI on API calls.

### 3. Not Handling Image Formats
**Problem**: HEIC images from iPhone don't work on Android.
**Solution**: Expo Image Picker handles conversion automatically. Ensure `allowsEditing: false` for original format preservation.

### 4. OCR Confidence Misinterpretation
**Problem**: Trusting low-confidence OCR results.
**Solution**: Always show extracted values for user confirmation. Confidence < 70% should trigger manual entry option.

### 5. SQL Connection String Syntax
**Problem**: Connection fails with "Keyword not supported" error.
**Solution**: Use `Connection Timeout` (with space) not `ConnectTimeout`. See global CLAUDE.md for Microsoft.Data.SqlClient 5.2+ requirements.

## Current Implementation Status

**Phase**: Foundation (Week 1-2)
**Status**: Documentation complete, basic project structure started, ready for implementation

**Completed**:
- ✅ All documentation (README, REQUIREMENTS, TODO, ARCHITECTURE, AGENTS)
- ✅ .NET project created with NuGet packages
- ✅ Basic entity models (User, BloodPressureReading)
- ✅ Database table creation started (partial)
- ✅ appsettings.json configured with Key Vault references

**Next Steps** (Priority Order):
1. Complete database schema (6 more tables + indexes + 40+ stored procedures)
2. Initialize Expo React Native project with TypeScript
3. Complete backend Program.cs and authentication services
4. Implement mobile navigation structure and auth screens

See `PROJECT-STATUS.md` and `TODO.md` for detailed implementation plan (180+ tasks over 10 weeks).

## Important Documentation Files

- **ARCHITECTURE.md** - Why React Native instead of PWA (critical architectural decision)
- **PROJECT-STATUS.md** - Current status, next steps, implementation phases
- **TODO.md** - Detailed task breakdown (180+ tasks) with time estimates
- **REQUIREMENTS.md** - Complete functional and non-functional requirements
- **FUTURE.md** - Post-MVP roadmap (Apple Health, medication tracking, wearables)
- **README.md** - Setup instructions, Azure provisioning, getting started

## Code Style and Naming Conventions

### Backend (.NET)
- **Framework**: .NET 8.0, C# 12, nullable reference types enabled
- **Naming**: PascalCase (classes/methods/properties), camelCase (parameters/locals)
- **Interfaces**: Prefix with `I` (e.g., `IAuthService`)
- **DTOs**: Suffix with `Dto` (e.g., `UserRegistrationDto`)
- **Async**: All I/O operations use async/await, suffix async methods with `Async`
- **Error Handling**: Never swallow exceptions, always log with correlation IDs

### Mobile (TypeScript)
- **Language**: TypeScript with strict mode enabled
- **Components**: Functional components with hooks, no class components
- **Naming**: PascalCase (components/types), camelCase (functions/variables), UPPER_CASE (constants)
- **Async**: async/await for all async operations, handle errors with try-catch
- **Styling**: StyleSheet.create for performance, avoid inline styles
- **Navigation**: React Navigation v6 with typed navigation props

## Special Notes

### Vite/Rollup Tree-Shaking
Not applicable to this project (React Native, not Vite). See global CLAUDE.md if future web version planned.

### WSL Development
If developing in WSL with SQL Server on Windows, use WSL host IP (172.31.208.1) not localhost.

### No Emojis
Never add emojis to code or output unless explicitly requested by user.
