# Blood Pressure Monitor - Implementation TODO (React Native)

**Project Start Date**: October 20, 2025
**Architecture**: React Native + Expo (Native Mobile Apps)
**Target Completion**: December 27, 2025 (10 weeks)
**Current Status**: Foundation Phase - Documentation Complete, Basic Setup Started
**Last Updated**: October 21, 2025

---

## ✅ What's Been Completed

### Documentation (100% Complete)
- ✅ **CLAUDE.md** - Claude Code guidance file
- ✅ **TDD-PROGRESS.md** - Full TDD documentation (36 tests passing)
- ✅ **MOBILE-UI-STATUS.md** - Mobile app setup and UI plan
- ✅ **REQUIREMENTS.md** (v2.0) - Updated with native mobile requirements
- ✅ **README.md** (v2.0) - React Native + Expo setup and deployment guide
- ✅ **TODO.md** (v2.0) - This file - implementation checklist
- ✅ **FUTURE.md** (v2.0) - Roadmap including Apple Health, Google Fit, wearables
- ✅ **ARCHITECTURE.md** - Architecture decision record (PWA → React Native)
- ✅ **AGENTS.md** (v2.0) - Updated with React Native build commands
- ✅ **PROJECT-STATUS.md** - Current status and next steps
- ✅ **archive/** - Original PWA documentation preserved

### Backend API (40% Complete)
- ✅ .NET 8.0 project created with all NuGet packages (upgraded to secure versions)
- ✅ Entity models: `User.cs`, `BloodPressureReading.cs` (complete)
- ✅ `Program.cs` - Basic API startup configuration
- ✅ `IAuthService.cs` interface - Complete authentication contract
- ✅ Test project created (xUnit + Moq + FluentAssertions)
- ✅ **36 tests passing (100% success rate)**:
  - 14 User entity validation tests
  - 22 AuthService tests (password hashing, JWT, registration, authentication)
- ❌ **NOT DONE**: Real service implementations, controllers, middleware

### Database (60% Complete)
- ✅ **All 8 tables created** (`01_Create_Tables.sql`):
  - Users, BloodPressureReadings, ReadingImages, Albums
  - ImageTags, ImageTagAssociations, UserAlertThresholds, OcrProcessingLog
- ✅ **15 custom indexes created** (`02_Create_Indexes.sql`)
- ✅ **8 User stored procedures** (`User_Procedures.sql`):
  - Create, GetByEmail, GetById, Update, UpdateLastLogin, UpdateStorageUsage, Delete, CheckEmailExists
- ❌ **NOT DONE**: 32 more stored procedures (Reading, Image, OCR, Tag, Alert)

### Mobile App (20% Complete)
- ✅ **Expo React Native project initialized** with TypeScript
- ✅ **NativeWind** (Tailwind CSS for React Native) configured
- ✅ **React Native Paper** (Material Design) installed
- ✅ All core dependencies installed:
  - Navigation, Camera, Image Picker, SQLite, Secure Store
  - Notifications, Network Status, Axios
- ✅ **app.json** configured with iOS/Android permissions and plugins
- ✅ **tailwind.config.js** with custom medical theme colors
- ✅ **babel.config.js** configured for NativeWind
- ❌ **NOT DONE**: Screen implementations, navigation setup, API integration

---

## Phase 1: Foundation and Infrastructure (Weeks 1-2)

### Stage 1.1: Azure Backend Provisioning
**Priority**: Critical | **Est. Time**: 4 hours | **Status**: Not Started

- [ ] Create Azure Resource Group
- [ ] Provision Azure SQL Database (S1 tier)
- [ ] Configure SQL Server firewall rules
- [ ] Create Azure Storage Account with geo-redundancy
- [ ] Create blob containers: originals, thumbnails-150, thumbnails-400
- [ ] Configure blob container access levels (private)
- [ ] Provision Azure Computer Vision resource (S1 tier)
- [ ] Create Azure Key Vault instance
- [ ] Configure Key Vault access policies
- [ ] Create Azure App Service Plan (B2 tier)
- [ ] Create Azure App Service (Linux, .NET 8.0)
- [ ] Configure Application Insights
- [ ] Document all Azure resource names and endpoints

**Note**: Can be done via Azure Portal or scripted with Azure CLI (see README.md for commands)

### Stage 1.2: Database Schema Creation
**Priority**: Critical | **Est. Time**: 8 hours | **Status**: ✅ COMPLETE

**Completed**:
- ✅ Users table (complete with all constraints)
- ✅ BloodPressureReadings table (complete with validations)
- ✅ ReadingImages table (links readings to blob images)
- ✅ Albums table (user-created photo albums)
- ✅ ImageTags table (custom tags with colors)
- ✅ ImageTagAssociations table (junction table)
- ✅ UserAlertThresholds table (configurable BP alerts)
- ✅ OcrProcessingLog table (audit trail for OCR attempts)

**File**: `Database/Scripts/01_Create_Tables.sql` ✅

### Stage 1.3: Database Indexes
**Priority**: Critical | **Est. Time**: 2 hours | **Status**: ✅ COMPLETE

- ✅ Clustered indexes on all primary keys (via PRIMARY KEY constraints)
- ✅ Non-clustered index on Users.Email (via UNIQUE constraint)
- ✅ Non-clustered indexes on all UserId foreign keys
- ✅ Non-clustered indexes on date fields (ReadingDate, UploadDate, ProcessedDate)
- ✅ Covering indexes for common queries (15 custom indexes created)
- ✅ Filtered indexes for flagged readings, favorites, failed OCR

**File**: `Database/Scripts/02_Create_Indexes.sql` ✅

### Stage 1.4: Stored Procedures - User Management
**Priority**: Critical | **Est. Time**: 6 hours | **Status**: ✅ COMPLETE

- ✅ `usp_User_Create` - Register new user
- ✅ `usp_User_GetByEmail` - Login authentication
- ✅ `usp_User_GetById` - Retrieve user profile
- ✅ `usp_User_Update` - Update profile information
- ✅ `usp_User_UpdateLastLogin` - Track login activity
- ✅ `usp_User_UpdateStorageUsage` - Track storage quota
- ✅ `usp_User_Delete` - Soft delete user account
- ✅ `usp_User_CheckEmailExists` - Email validation

**File**: `Database/StoredProcedures/User_Procedures.sql` ✅

### Stage 1.5: Stored Procedures - Reading Management
**Priority**: Critical | **Est. Time**: 8 hours | **Status**: Not Started

- [ ] `usp_Reading_Create` - Insert new reading
- [ ] `usp_Reading_GetById` - Retrieve single reading
- [ ] `usp_Reading_GetByUserId` - Get all readings for user (paginated)
- [ ] `usp_Reading_GetByDateRange` - Filter by date
- [ ] `usp_Reading_Update` - Update reading values
- [ ] `usp_Reading_Delete` - Delete reading
- [ ] `usp_Reading_GetStatistics` - Calculate avg, min, max, stddev
- [ ] `usp_Reading_GetByValueRange` - Filter by systolic/diastolic ranges
- [ ] `usp_Reading_Search` - Full-text search in notes
- [ ] `usp_Reading_GetRecent` - Get last N readings

**File**: `Database/StoredProcedures/Reading_Procedures.sql` (to be created)

### Stage 1.6: Stored Procedures - Image Management
**Priority**: High | **Est. Time**: 6 hours | **Status**: Not Started

- [ ] `usp_Image_Create` - Insert image record
- [ ] `usp_Image_GetById` - Retrieve image metadata
- [ ] `usp_Image_GetByReadingId` - Get all images for reading
- [ ] `usp_Image_GetByUserId` - Get all user images (paginated)
- [ ] `usp_Image_Update` - Update image metadata
- [ ] `usp_Image_Delete` - Delete image reference
- [ ] `usp_Image_GetOrphaned` - Find images without readings
- [ ] `usp_Image_AssignTags` - Bulk tag assignment
- [ ] `usp_Image_GetByTags` - Filter by tags

**File**: `Database/StoredProcedures/Image_Procedures.sql` (to be created)

### Stage 1.7: Stored Procedures - OCR & Tags & Alerts
**Priority**: Medium | **Est. Time**: 6 hours | **Status**: Not Started

**OCR Procedures**:
- [ ] `usp_OcrLog_Create` - Log OCR attempt
- [ ] `usp_OcrLog_GetByImageId` - Retrieve processing history

**Tag Procedures**:
- [ ] `usp_Tag_Create` - Create custom tag
- [ ] `usp_Tag_Update` - Update tag properties
- [ ] `usp_Tag_Delete` - Delete tag
- [ ] `usp_Tag_GetByUserId` - Get all user tags with counts

**Alert Procedures**:
- [ ] `usp_AlertThreshold_Create` - Configure threshold
- [ ] `usp_AlertThreshold_GetByUserId` - Retrieve user thresholds
- [ ] `usp_AlertThreshold_Update` - Update threshold values
- [ ] `usp_AlertThreshold_Delete` - Delete threshold

**Files**:
- `Database/StoredProcedures/OcrLog_Procedures.sql`
- `Database/StoredProcedures/Tag_Procedures.sql`
- `Database/StoredProcedures/Alert_Procedures.sql`

### Stage 1.8: .NET Backend Core Setup
**Priority**: Critical | **Est. Time**: 8 hours | **Status**: 20% Complete

**Completed**:
- ✅ .NET 8.0 Web API project initialized
- ✅ NuGet packages installed
- ✅ `appsettings.json` configured

**Remaining Tasks**:
- [ ] Create `Program.cs` with:
  - [ ] Configure Key Vault integration
  - [ ] Configure dependency injection (DI)
  - [ ] Add CORS policy
  - [ ] Configure Swagger/OpenAPI
  - [ ] Add authentication middleware (JWT)
  - [ ] Add exception handling middleware
  - [ ] Configure Serilog → Application Insights
  - [ ] Configure Hangfire for background jobs
  - [ ] Add health check endpoints
- [ ] Test API startup: `dotnet run`
- [ ] Verify Swagger UI at https://localhost:5001/swagger

**File**: `BloodPressureMonitor.API/Program.cs` (to be created)

### Stage 1.9: Backend Entity Models
**Priority**: High | **Est. Time**: 4 hours | **Status**: 25% Complete

**Completed**:
- ✅ `User.cs` - User entity
- ✅ `BloodPressureReading.cs` - Reading entity

**Remaining Tasks**:
- [ ] Complete/verify `User.cs` with all properties
- [ ] Complete/verify `BloodPressureReading.cs` with all properties
- [ ] Create `ReadingImage.cs` - Image metadata entity
- [ ] Create `Album.cs` - Photo album entity
- [ ] Create `ImageTag.cs` - Custom tag entity
- [ ] Create `ImageTagAssociation.cs` - Many-to-many junction
- [ ] Create `UserAlertThreshold.cs` - Alert configuration entity
- [ ] Create `OcrProcessingLog.cs` - OCR audit trail entity

**Directory**: `BloodPressureMonitor.API/Models/Entities/`

### Stage 1.10: Backend DTOs (Data Transfer Objects)
**Priority**: High | **Est. Time**: 4 hours | **Status**: Not Started

- [ ] `UserRegistrationDto.cs` - Registration request
- [ ] `UserLoginDto.cs` - Login request
- [ ] `UserProfileDto.cs` - User profile response
- [ ] `ReadingCreateDto.cs` - Create reading request
- [ ] `ReadingUpdateDto.cs` - Update reading request
- [ ] `ReadingResponseDto.cs` - Reading response
- [ ] `ImageUploadDto.cs` - Image upload request
- [ ] `ImageResponseDto.cs` - Image metadata response
- [ ] `OcrResultDto.cs` - OCR processing response
- [ ] `StatisticsDto.cs` - Analytics response
- [ ] `TagDto.cs` - Tag response
- [ ] `ThresholdDto.cs` - Alert threshold response

**Directory**: `BloodPressureMonitor.API/Models/DTOs/`

### Stage 1.11: Backend Service Interfaces
**Priority**: Critical | **Est. Time**: 3 hours | **Status**: Not Started

- [ ] `IAuthService.cs` - Authentication operations
- [ ] `IUserService.cs` - User management
- [ ] `IReadingService.cs` - Reading CRUD and queries
- [ ] `IImageService.cs` - Image upload and management
- [ ] `IOcrService.cs` - OCR processing (Azure CV)
- [ ] `IBlobStorageService.cs` - Azure Blob operations
- [ ] `IAnalyticsService.cs` - Statistics and trends
- [ ] `ITagService.cs` - Tag management
- [ ] `IThresholdService.cs` - Alert threshold management

**Directory**: `BloodPressureMonitor.API/Services/Interfaces/`

### Stage 1.12: Backend Service Implementations (Auth & User)
**Priority**: Critical | **Est. Time**: 10 hours | **Status**: Not Started

- [ ] `AuthService.cs`:
  - [ ] Register user (hash password with BCrypt)
  - [ ] Login authentication
  - [ ] Generate JWT token
  - [ ] Refresh token logic
  - [ ] Password reset flow
- [ ] `UserService.cs`:
  - [ ] Get user profile
  - [ ] Update profile
  - [ ] Track storage usage
  - [ ] Delete user account
- [ ] Unit tests for AuthService
- [ ] Unit tests for UserService

**Directory**: `BloodPressureMonitor.API/Services/Implementations/`

### Stage 1.13: Backend Controllers (Auth & User)
**Priority**: Critical | **Est. Time**: 4 hours | **Status**: Not Started

- [ ] `AuthController.cs`:
  - [ ] POST /api/auth/register
  - [ ] POST /api/auth/login
  - [ ] POST /api/auth/refresh
  - [ ] POST /api/auth/reset-password
- [ ] `UserController.cs`:
  - [ ] GET /api/user/profile
  - [ ] PUT /api/user/profile
  - [ ] DELETE /api/user/account
  - [ ] GET /api/user/storage-usage

**Directory**: `BloodPressureMonitor.API/Controllers/`

### Stage 1.14: Backend Middleware
**Priority**: High | **Est. Time**: 2 hours | **Status**: Not Started

- [ ] `ExceptionHandlingMiddleware.cs` - Centralized error handling
- [ ] `RequestLoggingMiddleware.cs` - Log all requests with correlation IDs
- [ ] Configure middleware in Program.cs
- [ ] Test error responses (structured JSON with correlation ID)

**Directory**: `BloodPressureMonitor.API/Middleware/`

### Stage 1.15: Mobile App Initialization
**Priority**: Critical | **Est. Time**: 4 hours | **Status**: ✅ COMPLETE

- ✅ Expo React Native project created with TypeScript
- ✅ Core dependencies installed:
  - ✅ Navigation (@react-navigation/native, stack, bottom-tabs)
  - ✅ React Native Paper (Material Design components)
  - ✅ NativeWind (Tailwind CSS for React Native)
  - ✅ axios, expo-camera, expo-image-picker
  - ✅ expo-secure-store, expo-sqlite
  - ✅ expo-notifications, @react-native-community/netinfo
- ✅ `app.json` configured:
  - ✅ App name: "Blood Pressure Monitor"
  - ✅ iOS bundle ID: `com.healthtech.bloodpressuremonitor`
  - ✅ Android package: `com.healthtech.bloodpressuremonitor`
  - ✅ Permissions: camera, photo library, notifications
  - ✅ Expo plugins configured
- ✅ `tailwind.config.js` with custom medical theme
- ✅ `babel.config.js` configured for NativeWind
- [ ] Create `.env` file with API_BASE_URL
- [ ] Create folder structure:
  - [ ] `src/screens/`
  - [ ] `src/components/`
  - [ ] `src/services/`
  - [ ] `src/navigation/`
  - [ ] `src/utils/`
  - [ ] `src/constants/`
  - [ ] `src/types/`
  - [ ] `src/store/`
- [ ] Test app runs: `npx expo start --ios` and `npx expo start --android`

**Directory**: `BloodPressureMonitor.Mobile/` ✅

### Stage 1.16: Mobile Core Services (Initial Setup)
**Priority**: Critical | **Est. Time**: 4 hours | **Status**: Not Started

- [ ] `src/services/api.ts` - Axios HTTP client with interceptors
- [ ] `src/services/auth.ts` - Authentication service (login, register, token storage)
- [ ] `src/utils/constants.ts` - App constants (API URLs, colors, dimensions)
- [ ] `src/types/index.ts` - TypeScript interfaces and types
- [ ] Test API connection to backend

**Directory**: `BloodPressureMonitor.Mobile/src/`

### Stage 1.17: Mobile Navigation Structure
**Priority**: High | **Est. Time**: 3 hours | **Status**: Not Started

- [ ] `src/navigation/AppNavigator.tsx` - Root navigation
- [ ] `src/navigation/AuthNavigator.tsx` - Auth stack (Login, Register)
- [ ] `src/navigation/MainNavigator.tsx` - Tab navigator (Dashboard, Camera, Readings, Settings)
- [ ] Configure navigation types for type safety
- [ ] Test navigation flow

**Directory**: `BloodPressureMonitor.Mobile/src/navigation/`

---

## Phase 2: Authentication and User Management (Week 3)

### Stage 2.1: Backend Auth Implementation (Remaining)
**Priority**: High | **Est. Time**: 4 hours | **Status**: Partially in Stage 1

- [ ] Implement token refresh mechanism
- [ ] Add authentication middleware to Program.cs
- [ ] Write integration tests for auth endpoints
- [ ] Test end-to-end auth flow (register → login → refresh)

### Stage 2.2: Mobile Auth Context
**Priority**: High | **Est. Time**: 3 hours | **Status**: Not Started

- [ ] Create `src/store/AuthContext.tsx` - Global auth state
- [ ] Implement login/logout/register actions
- [ ] Persist auth state to Expo SecureStore
- [ ] Auto-restore auth on app launch
- [ ] Handle token expiration

### Stage 2.3: Mobile Auth Screens
**Priority**: High | **Est. Time**: 6 hours | **Status**: Not Started

- [ ] `src/screens/Auth/LoginScreen.tsx`:
  - [ ] Email and password input fields
  - [ ] Form validation
  - [ ] Loading states
  - [ ] Error handling
  - [ ] "Forgot Password" link
- [ ] `src/screens/Auth/RegisterScreen.tsx`:
  - [ ] User information form
  - [ ] Password confirmation
  - [ ] Terms acceptance
  - [ ] Validation with real-time feedback
- [ ] `src/screens/Auth/ForgotPasswordScreen.tsx`:
  - [ ] Email input
  - [ ] Reset flow UI
- [ ] Test auth flow end-to-end

### Stage 2.4: Mobile Biometric Authentication
**Priority**: Medium | **Est. Time**: 2 hours | **Status**: Not Started

- [ ] Install `expo-local-authentication`
- [ ] Implement biometric check (Face ID / Touch ID / Fingerprint)
- [ ] Add biometric login option after initial password login
- [ ] Handle biometric permission requests
- [ ] Test on physical devices

---

## Phase 3: Camera and Photo Library Integration (Week 4)

### Stage 3.1: Camera Implementation
**Priority**: Critical | **Est. Time**: 10 hours | **Status**: Not Started

- [ ] Request camera permissions with rationale
- [ ] `src/screens/Camera/CameraScreen.tsx`:
  - [ ] Implement Expo Camera component
  - [ ] Add camera controls (capture button, flash toggle, camera flip)
  - [ ] Grid overlay for BP monitor alignment
  - [ ] Pinch-to-zoom gesture handler
  - [ ] Loading indicator during capture
- [ ] `src/screens/Camera/PreviewScreen.tsx`:
  - [ ] Display captured photo
  - [ ] Retake button
  - [ ] Confirm button (proceed to OCR)
- [ ] Handle camera permission denials gracefully
- [ ] Image quality validation (dimensions, file size)
- [ ] Test on physical iOS device
- [ ] Test on physical Android device

### Stage 3.2: Photo Library Integration
**Priority**: Critical | **Est. Time**: 8 hours | **Status**: Not Started

- [ ] Request photo library permissions
- [ ] `src/screens/Photos/PhotoPickerScreen.tsx`:
  - [ ] Implement Expo Image Picker
  - [ ] Enable multi-select mode
  - [ ] Display selected photos with thumbnails
  - [ ] Photo count indicator
  - [ ] Clear selection option
- [ ] Handle HEIC/HEIF format conversion (automatic via Expo)
- [ ] `src/screens/Photos/PhotoConfirmationScreen.tsx`:
  - [ ] Review selected photos before processing
  - [ ] Remove individual photos from selection
- [ ] Test with large photo libraries (1000+ photos)
- [ ] Test photo browsing performance

### Stage 3.3: Image Processing Service
**Priority**: High | **Est. Time**: 6 hours | **Status**: Not Started

- [ ] `src/services/imageProcessing.ts`:
  - [ ] Client-side image compression (reduce size for upload)
  - [ ] Resize images to optimal dimensions (max 1920x1080)
  - [ ] Generate local thumbnail (150x150)
  - [ ] Calculate image hash for duplicate detection
  - [ ] Validate image dimensions and file size
- [ ] Image quality feedback UI
- [ ] Handle memory efficiently (release large images after processing)
- [ ] Test with various image formats and sizes

### Stage 3.4: Backend Image Upload Service
**Priority**: High | **Est. Time**: 6 hours | **Status**: Not Started

- [ ] `BlobStorageService.cs`:
  - [ ] Upload to Azure Blob Storage (originals container)
  - [ ] Generate thumbnails (150x150, 400x400)
  - [ ] Upload thumbnails to respective containers
  - [ ] Generate SAS tokens for secure access (15-minute expiry)
  - [ ] Handle upload failures with retry logic (Polly)
- [ ] `ImageService.cs`:
  - [ ] Save image metadata to database (via stored procedures)
  - [ ] Track storage usage
  - [ ] Validate user storage quota
- [ ] `ImageController.cs`:
  - [ ] POST /api/image/upload
  - [ ] GET /api/image/{id}
  - [ ] DELETE /api/image/{id}
  - [ ] GET /api/image/thumbnails/{id}
- [ ] Rate limiting for uploads (10/minute)
- [ ] Test image upload end-to-end

---

## Phase 4: OCR Processing (Week 5)

### Stage 4.1: Backend OCR Service
**Priority**: Critical | **Est. Time**: 10 hours | **Status**: Not Started

- [ ] `OcrService.cs`:
  - [ ] Integrate Azure Computer Vision API
  - [ ] Extract text from image via OCR
  - [ ] Parse blood pressure values (multiple formats):
    - [ ] "120/80 75" (compact)
    - [ ] "SYS 120 DIA 80 PULSE 75" (labeled)
    - [ ] Stacked displays
    - [ ] Various unit indicators
  - [ ] Calculate confidence scores
  - [ ] Log all OCR attempts to OcrProcessingLog table
  - [ ] Implement retry logic with Polly
- [ ] `OcrController.cs`:
  - [ ] POST /api/ocr/process (process image by ID)
  - [ ] POST /api/ocr/reprocess (reprocess with updated algorithm)
  - [ ] GET /api/ocr/history/{imageId}
- [ ] Rate limiting for OCR (5 reprocesses/hour)
- [ ] Test with various BP monitor display formats
- [ ] Test accuracy and confidence scoring

### Stage 4.2: On-Device OCR (Mobile)
**Priority**: Medium | **Est. Time**: 8 hours | **Status**: Not Started

- [ ] Install `expo-vision-camera` or `react-native-mlkit-ocr`
- [ ] `src/services/ocr.ts`:
  - [ ] Implement iOS Vision Framework OCR
  - [ ] Implement Android ML Kit OCR
  - [ ] Create unified OCR interface (platform-agnostic)
  - [ ] Parse BP values from OCR text
  - [ ] Calculate local confidence scores
  - [ ] Fallback to cloud OCR if confidence < 70%
- [ ] Test accuracy comparison: local vs cloud
- [ ] Test offline OCR functionality

### Stage 4.3: Mobile OCR UI
**Priority**: High | **Est. Time**: 6 hours | **Status**: Not Started

- [ ] `src/screens/OCR/OCRProcessingScreen.tsx`:
  - [ ] Loading indicator during OCR
  - [ ] Progress feedback (local → cloud if needed)
- [ ] `src/screens/OCR/OCRConfirmationScreen.tsx`:
  - [ ] Display extracted values (systolic, diastolic, pulse)
  - [ ] Show confidence indicators (color-coded)
  - [ ] Allow editing of extracted values
  - [ ] Manual entry option if OCR fails
  - [ ] Show detected text regions overlay on image
  - [ ] Confirm button (create reading)
  - [ ] Reprocess button (try again)
- [ ] Handle OCR failures gracefully
- [ ] Test user flow: capture → OCR → confirm → save

---

## Phase 5: Readings Management (Week 6)

### Stage 5.1: Backend Reading Service (Remaining)
**Priority**: High | **Est. Time**: 4 hours | **Status**: Partially in Stage 1

- [ ] `ReadingService.cs`:
  - [ ] Validate reading ranges (systolic 70-250, diastolic 40-150, pulse 30-220)
  - [ ] Flag readings outside normal ranges
  - [ ] Calculate statistics (avg, min, max, stddev)
  - [ ] Implement pagination for history
  - [ ] Search readings by notes
- [ ] `ReadingController.cs`:
  - [ ] POST /api/reading
  - [ ] GET /api/reading/{id}
  - [ ] PUT /api/reading/{id}
  - [ ] DELETE /api/reading/{id}
  - [ ] GET /api/reading/history (paginated)
  - [ ] GET /api/reading/statistics
  - [ ] GET /api/reading/search?query={text}
- [ ] Test all endpoints

### Stage 5.2: Local Storage (SQLite)
**Priority**: Critical | **Est. Time**: 8 hours | **Status**: Not Started

- [ ] Design local SQLite schema (mirror cloud schema)
- [ ] `src/services/database.ts`:
  - [ ] Initialize SQLite database on app launch
  - [ ] Create tables (readings, images, sync_queue)
  - [ ] Implement CRUD operations for readings
  - [ ] Implement CRUD for cached images
  - [ ] Add sync status tracking (pending, synced, failed)
  - [ ] Create upload queue for pending readings
  - [ ] Implement data migration logic (version upgrades)
- [ ] Test database operations
- [ ] Test data persistence across app restarts

### Stage 5.3: Readings List UI
**Priority**: High | **Est. Time**: 8 hours | **Status**: Not Started

- [ ] `src/screens/Readings/ReadingsListScreen.tsx`:
  - [ ] FlatList with reading cards
  - [ ] Display: date, systolic/diastolic/pulse, thumbnail
  - [ ] Pull-to-refresh (sync from cloud)
  - [ ] Infinite scroll (load more)
  - [ ] Filter by date range picker
  - [ ] Search bar (filter by notes)
  - [ ] Sync status indicators (pending, synced)
- [ ] `src/screens/Readings/ReadingDetailScreen.tsx`:
  - [ ] Full reading details
  - [ ] Image viewer (zoom, pan)
  - [ ] Reading notes
  - [ ] Edit button → edit screen
  - [ ] Delete button with confirmation
  - [ ] OCR history (show all attempts)
- [ ] `src/screens/Readings/ReadingEditScreen.tsx`:
  - [ ] Editable systolic, diastolic, pulse fields
  - [ ] Editable notes
  - [ ] Save changes
- [ ] Test CRUD operations end-to-end

---

## Phase 6: Sync and Offline Functionality (Week 7)

### Stage 6.1: Sync Service
**Priority**: Critical | **Est. Time**: 12 hours | **Status**: Not Started

- [ ] `src/services/sync.ts`:
  - [ ] Implement sync queue management
  - [ ] Upload pending readings when online
  - [ ] Upload pending images with chunked transfer
  - [ ] Download new readings from cloud
  - [ ] Handle sync conflicts (last-write-wins strategy)
  - [ ] Retry logic for failed syncs (exponential backoff)
  - [ ] Manual sync trigger
  - [ ] Background sync (when app regains connectivity)
- [ ] `src/services/connectivity.ts`:
  - [ ] Monitor network connectivity with NetInfo
  - [ ] Auto-trigger sync when online
  - [ ] Show connectivity status in UI
- [ ] Sync status notifications
- [ ] Test offline → online transitions
- [ ] Test conflict resolution

### Stage 6.2: Image Upload Queue and Caching
**Priority**: High | **Est. Time**: 8 hours | **Status**: Not Started

- [ ] `src/services/imageCache.ts`:
  - [ ] Implement local image cache (100MB limit)
  - [ ] LRU cache eviction policy
  - [ ] Cache thumbnails for quick loading
  - [ ] Clear cache on low storage
- [ ] Implement chunked image upload (for large files)
- [ ] Queue image uploads (process in background)
- [ ] Generate and upload thumbnails
- [ ] SAS token management (request fresh tokens)
- [ ] Handle upload failures with retry
- [ ] Test with poor connectivity (throttle network)

---

## Phase 7: Data Visualization and Analytics (Week 8)

### Stage 7.1: Backend Analytics
**Priority**: Medium | **Est. Time**: 6 hours | **Status**: Not Started

- [ ] Stored procedures for analytics:
  - [ ] `usp_Analytics_GetStatisticsByPeriod` (7d, 30d, 90d, 1y)
  - [ ] `usp_Analytics_GetTrends` (calculate trends)
  - [ ] `usp_Analytics_GetDistribution` (histogram data)
- [ ] `AnalyticsService.cs`:
  - [ ] Calculate statistics (avg, min, max, stddev)
  - [ ] Calculate trend lines
  - [ ] Time-based aggregations
- [ ] `AnalyticsController.cs`:
  - [ ] GET /api/analytics/statistics?period={7d|30d|90d|1y}
  - [ ] GET /api/analytics/trends
  - [ ] GET /api/analytics/distribution
- [ ] Test with sample data

### Stage 7.2: Charts and Graphs
**Priority**: Medium | **Est. Time**: 8 hours | **Status**: Not Started

- [ ] Install Victory Native for charts
- [ ] `src/screens/Dashboard/DashboardScreen.tsx`:
  - [ ] Statistics cards (avg, min, max)
  - [ ] Line chart for BP trends over time
  - [ ] Time period selector (7d, 30d, 90d, 1y)
  - [ ] Threshold lines on charts (configurable)
  - [ ] Distribution histogram
- [ ] `src/components/Charts/BPLineChart.tsx` - Reusable chart component
- [ ] Add chart interactivity (zoom, pan)
- [ ] Test chart performance with large datasets (1000+ readings)

### Stage 7.3: Export Functionality
**Priority**: Low | **Est. Time**: 6 hours | **Status**: Not Started

- [ ] `src/services/export.ts`:
  - [ ] Generate CSV export (readings with metadata)
  - [ ] Generate PDF export with charts (use react-native-pdf)
  - [ ] Include images in exports
- [ ] `src/screens/Export/ExportScreen.tsx`:
  - [ ] Date range selector
  - [ ] Format selector (CSV, PDF)
  - [ ] Include images toggle
  - [ ] Export button
- [ ] Native share functionality
- [ ] Test export with various data sizes

---

## Phase 8: Alerts and Notifications (Week 9)

### Stage 8.1: Threshold Management
**Priority**: Medium | **Est. Time**: 6 hours | **Status**: Not Started

- [ ] Backend threshold service (partially in Stage 1.7)
- [ ] `ThresholdController.cs`:
  - [ ] GET /api/threshold
  - [ ] POST /api/threshold
  - [ ] PUT /api/threshold/{id}
  - [ ] DELETE /api/threshold/{id}
- [ ] `src/screens/Settings/ThresholdSettingsScreen.tsx`:
  - [ ] Configure systolic/diastolic thresholds
  - [ ] Enable/disable alerts
  - [ ] Save settings
- [ ] Implement threshold checking on reading save
- [ ] Test threshold validation

### Stage 8.2: Notifications
**Priority**: Medium | **Est. Time**: 6 hours | **Status**: Not Started

- [ ] Configure Expo Notifications
- [ ] Request notification permissions
- [ ] `src/services/notifications.ts`:
  - [ ] Trigger local notification when reading exceeds threshold
  - [ ] Schedule reminder notifications (optional)
  - [ ] Handle notification taps (navigate to reading)
- [ ] `src/screens/Settings/NotificationSettingsScreen.tsx`:
  - [ ] Enable/disable notifications
  - [ ] Configure reminder schedule
- [ ] Test notifications on iOS
- [ ] Test notifications on Android

---

## Phase 9: Polish and App Store Preparation (Week 10)

### Stage 9.1: UI Polish
**Priority**: High | **Est. Time**: 8 hours | **Status**: Not Started

- [ ] Implement consistent theme and styling
- [ ] Add loading skeletons for async content
- [ ] Improve error messages (user-friendly)
- [ ] Add haptic feedback on interactions
- [ ] Implement splash screen
- [ ] Add app icon (all required sizes)
- [ ] Create onboarding flow (first-time users)
- [ ] Add empty states (no readings, no images)
- [ ] Improve accessibility:
  - [ ] Screen reader support
  - [ ] Sufficient color contrast
  - [ ] Tappable area sizes (44x44 minimum)

### Stage 9.2: Testing and Bug Fixes
**Priority**: Critical | **Est. Time**: 12 hours | **Status**: Not Started

- [ ] End-to-end testing on physical iOS device
- [ ] End-to-end testing on physical Android device
- [ ] Test offline functionality thoroughly
- [ ] Test camera on multiple device models
- [ ] Test photo library with large libraries (5000+ photos)
- [ ] Performance testing:
  - [ ] App launch time (<2 seconds)
  - [ ] Screen transition smoothness
  - [ ] Scroll performance
- [ ] Memory leak detection
- [ ] Battery usage testing
- [ ] Fix all critical bugs
- [ ] Fix all medium-priority bugs
- [ ] Document known minor issues

### Stage 9.3: App Store Assets
**Priority**: Critical | **Est. Time**: 4 hours | **Status**: Not Started

- [ ] App screenshots (iOS):
  - [ ] 6.7" iPhone (iPhone 15 Pro Max)
  - [ ] 6.5" iPhone (iPhone 14 Plus)
  - [ ] 5.5" iPhone (iPhone 8 Plus)
- [ ] App screenshots (Android):
  - [ ] Phone
  - [ ] 7" tablet
  - [ ] 10" tablet
- [ ] App description (both stores)
- [ ] Keywords for search optimization
- [ ] Privacy policy (hosted)
- [ ] Support URL

### Stage 9.4: Build and Submit
**Priority**: Critical | **Est. Time**: 4 hours | **Status**: Not Started

- [ ] Configure EAS Build (`eas.json`)
- [ ] Create production build (iOS):
  - [ ] `eas build --platform ios --profile production`
- [ ] Create production build (Android):
  - [ ] `eas build --platform android --profile production`
- [ ] Test production builds
- [ ] Create App Store listing:
  - [ ] Upload screenshots
  - [ ] Add description
  - [ ] Set pricing (free)
  - [ ] Configure age rating
- [ ] Submit to App Store for review
- [ ] Create Play Store listing:
  - [ ] Upload screenshots
  - [ ] Add description
  - [ ] Set pricing (free)
  - [ ] Configure content rating
- [ ] Submit to Play Store for review
- [ ] Address reviewer feedback (if any)

---

## Additional Tasks (Post-Launch or Ongoing)

### Documentation
- [ ] API documentation (comprehensive Swagger annotations)
- [ ] Mobile app user guide
- [ ] Developer onboarding guide
- [ ] Troubleshooting guide

### DevOps
- [ ] Set up CI/CD pipeline for backend (Azure DevOps or GitHub Actions)
- [ ] Set up CI/CD for mobile (EAS Build automation)
- [ ] Configure automated testing
- [ ] Set up monitoring alerts (Application Insights)

### Security
- [ ] Security audit (penetration testing)
- [ ] OWASP compliance check
- [ ] HIPAA compliance review (if applicable)
- [ ] Data privacy compliance (GDPR, CCPA)

---

## Progress Tracking

### Overall Completion: ~8% (15 / 200+ tasks)

### Phase Breakdown:
- **Phase 1 (Foundation)**: ~15% - Documentation done, basic setup started
- **Phase 2 (Auth)**: 0%
- **Phase 3 (Camera/Photos)**: 0%
- **Phase 4 (OCR)**: 0%
- **Phase 5 (Readings)**: 0%
- **Phase 6 (Sync)**: 0%
- **Phase 7 (Analytics)**: 0%
- **Phase 8 (Alerts)**: 0%
- **Phase 9 (Polish)**: 0%

### Estimated Time Remaining: ~180 hours (4-5 weeks at 40 hours/week)

---

## Priority Task List (Next 5 Days)

### Day 1: Azure + Database
1. Provision Azure resources (4 hours)
2. Complete database schema - all 8 tables (4 hours)

### Day 2: Database Stored Procedures
1. Create User stored procedures (4 hours)
2. Create Reading stored procedures (4 hours)

### Day 3: Database + Backend Core
1. Create Image & OCR stored procedures (3 hours)
2. Create indexes (2 hours)
3. Create Program.cs (3 hours)

### Day 4: Backend Services (Auth & User)
1. Complete entity models and DTOs (3 hours)
2. Create service interfaces (2 hours)
3. Implement AuthService (3 hours)

### Day 5: Backend Controllers + Mobile Init
1. Implement UserService (2 hours)
2. Create AuthController & UserController (2 hours)
3. Initialize Expo mobile project (4 hours)

---

**Last Updated**: October 21, 2025
**Next Review**: After Phase 1 completion (estimated 2 weeks)
**Architecture**: React Native + Expo Native Mobile Apps
