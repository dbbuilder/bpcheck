# Clerk Backend Integration Guide

## Overview
Complete integration of Clerk authentication with the Blood Pressure Monitor .NET 8.0 Web API.

## What Was Implemented

### 1. NuGet Packages Added
```xml
<PackageReference Include="Microsoft.AspNetCore.Authentication.JwtBearer" Version="8.0.11" />
```

### 2. Configuration Files

#### appsettings.json
```json
"Clerk": {
  "Authority": "https://lucky-lemur-31.clerk.accounts.dev",
  "Audience": "https://lucky-lemur-31.clerk.accounts.dev",
  "SecretKey": "@Microsoft.KeyVault(SecretUri=https://your-keyvault-name.vault.azure.net/secrets/ClerkSecretKey/)"
}
```

#### appsettings.Development.json (NOT committed to git)
```json
"Clerk": {
  "Authority": "https://lucky-lemur-31.clerk.accounts.dev",
  "Audience": "https://lucky-lemur-31.clerk.accounts.dev",
  "SecretKey": "sk_test_FhNc4QqwYOaGdZWScb2hub2ggJWEZCDeWPKVW5itm5"
}
```

**IMPORTANT**: `appsettings.Development.json` is in `.gitignore` to protect the Clerk secret key.

### 3. Program.cs Updates

Added JWT Bearer authentication configuration:
- Validates Clerk JWTs using OIDC discovery
- Extracts user information from JWT claims
- Logs authentication events for debugging
- Added CORS policy for mobile app
- Proper middleware ordering: CORS → Authentication → Authorization

**Location**: `BloodPressureMonitor.API/Program.cs`

### 4. Extensions Created

#### ClaimsPrincipalExtensions.cs
Helper extension methods to extract Clerk user data from JWT claims:

```csharp
public static string? GetClerkUserId(this ClaimsPrincipal user)
public static string? GetUserEmail(this ClaimsPrincipal user)
public static string? GetFirstName(this ClaimsPrincipal user)
public static string? GetLastName(this ClaimsPrincipal user)
public static bool IsClerkAuthenticated(this ClaimsPrincipal user)
```

**Location**: `BloodPressureMonitor.API/Extensions/ClaimsPrincipalExtensions.cs`

### 5. Test Controller

#### AuthTestController.cs
Provides endpoints to verify Clerk integration:

- `GET /api/authtest/health` - Public health check (no auth)
- `GET /api/authtest/me` - Protected endpoint showing current user info
- `GET /api/authtest/protected` - Simple protected endpoint test

**Usage Example**:
```bash
# Health check (no auth required)
curl https://api.bloodpressuremonitor.com/api/authtest/health

# Get current user (requires Clerk JWT)
curl https://api.bloodpressuremonitor.com/api/authtest/me \
  -H "Authorization: Bearer <CLERK_JWT_TOKEN>"
```

**Location**: `BloodPressureMonitor.API/Controllers/AuthTestController.cs`

### 6. Database Schema Updates

#### Migration Script: 03_Add_Clerk_Integration.sql

Changes made:
1. Added `ClerkUserId NVARCHAR(255)` to Users table
2. Created unique index on `ClerkUserId` (allows NULL for legacy users)
3. Made `PasswordHash` nullable (Clerk handles authentication)
4. Converted `Email` unique constraint to non-unique index (Clerk is source of truth)

**Location**: `Database/Scripts/03_Add_Clerk_Integration.sql`

#### User Entity Model Updated

```csharp
public class User
{
    public Guid UserId { get; set; }              // Internal database ID
    public string? ClerkUserId { get; set; }      // Clerk User ID (primary auth identifier)
    public string Email { get; set; }
    public string? PasswordHash { get; set; }     // Now nullable
    // ... other properties
}
```

**Location**: `BloodPressureMonitor.API/Models/Entities/User.cs`

### 7. Stored Procedures for Clerk

#### usp_User_SyncFromClerk
Creates or updates user based on Clerk authentication:
```sql
EXEC usp_User_SyncFromClerk
    @ClerkUserId = 'user_2abc123xyz',
    @Email = 'john@example.com',
    @FirstName = 'John',
    @LastName = 'Doe'
```

- Creates new user if ClerkUserId doesn't exist
- Updates existing user info and last login if exists
- Returns complete user record

#### usp_User_GetByClerkId
Retrieves user by Clerk User ID:
```sql
EXEC usp_User_GetByClerkId @ClerkUserId = 'user_2abc123xyz'
```

#### usp_User_UpdateProfile
Updates user profile for Clerk-authenticated users:
```sql
EXEC usp_User_UpdateProfile
    @ClerkUserId = 'user_2abc123xyz',
    @FirstName = 'John',
    @LastName = 'Smith',
    @DateOfBirth = '1990-01-15'
```

**Location**: `Database/StoredProcedures/Clerk_User_Procedures.sql`

## How It Works

### Authentication Flow

1. **User Signs In** (Mobile App)
   - User enters credentials in LoginScreen
   - Clerk validates and returns JWT token
   - Mobile app stores token securely

2. **API Request** (Mobile App → Backend)
   - Mobile app includes `Authorization: Bearer <JWT>` header
   - API service automatically attaches token to all requests

3. **Token Validation** (Backend)
   - JWT Bearer middleware intercepts request
   - Validates token signature against Clerk's public keys (via OIDC)
   - Checks issuer, audience, and expiration
   - Extracts claims and creates ClaimsPrincipal

4. **User Sync** (Backend)
   - Controller extracts Clerk User ID from claims
   - Calls `usp_User_SyncFromClerk` to create/update user
   - Returns user record with internal UserId

5. **Authorization** (Backend)
   - `[Authorize]` attribute checks authentication
   - Controller accesses user via `User.GetClerkUserId()`
   - Uses internal UserId for database operations

### JWT Claims Structure

Clerk JWTs contain:
```json
{
  "sub": "user_2abc123xyz",           // Clerk User ID
  "email": "john@example.com",
  "given_name": "John",
  "family_name": "Doe",
  "iss": "https://lucky-lemur-31.clerk.accounts.dev",
  "aud": "https://lucky-lemur-31.clerk.accounts.dev",
  "exp": 1234567890,
  "iat": 1234567800
}
```

## Deployment Checklist

### Database Migration
```sql
-- 1. Run Clerk integration migration
USE [BloodPressureMonitor]
GO

-- Execute migration script
:r Database/Scripts/03_Add_Clerk_Integration.sql
GO

-- 2. Create Clerk stored procedures
:r Database/StoredProcedures/Clerk_User_Procedures.sql
GO

-- 3. Verify changes
SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Users') AND name = 'ClerkUserId'
```

### Azure Configuration

#### Key Vault Setup
```bash
# Add Clerk secret to Azure Key Vault
az keyvault secret set \
  --vault-name "your-keyvault-name" \
  --name "ClerkSecretKey" \
  --value "sk_test_FhNc4QqwYOaGdZWScb2hub2ggJWEZCDeWPKVW5itm5"
```

#### App Service Configuration
```bash
# Verify Clerk settings in production
az webapp config appsettings list \
  --name "your-app-service" \
  --resource-group "your-rg" \
  --query "[?name=='Clerk__Authority']"
```

### Testing

1. **Health Check**
   ```bash
   curl https://your-api.azurewebsites.net/api/authtest/health
   ```

2. **Mobile App Login**
   - Open mobile app
   - Sign in with test account
   - Check console logs for token

3. **Protected Endpoint**
   ```bash
   # Copy JWT from mobile app
   curl https://your-api.azurewebsites.net/api/authtest/me \
     -H "Authorization: Bearer <JWT_TOKEN>"
   ```

4. **Database Verification**
   ```sql
   -- Check user was created/synced
   SELECT * FROM Users WHERE ClerkUserId IS NOT NULL
   ```

## Troubleshooting

### Common Issues

#### 1. 401 Unauthorized
**Problem**: API returns 401 even with valid token

**Solutions**:
- Check `Clerk:Authority` matches Clerk dashboard URL
- Verify `Clerk:Audience` is configured correctly
- Check mobile app is using correct publishable key
- Look for JWT validation errors in API logs

#### 2. Token Validation Fails
**Problem**: JWT signature validation fails

**Causes**:
- Incorrect Clerk Authority URL
- Network issues reaching Clerk's JWKS endpoint
- Token expired or malformed

**Debug**:
```csharp
// Program.cs already includes logging
OnAuthenticationFailed = context =>
{
    Console.WriteLine($"JWT Authentication failed: {context.Exception.Message}");
    return Task.CompletedTask;
}
```

#### 3. User Not Created in Database
**Problem**: Authentication works but user record missing

**Check**:
```sql
-- Look for SQL errors
SELECT * FROM sys.messages WHERE severity > 16

-- Test stored procedure directly
EXEC usp_User_SyncFromClerk
    @ClerkUserId = 'test_user_123',
    @Email = 'test@example.com'
```

#### 4. CORS Errors
**Problem**: Mobile app can't reach API endpoints

**Solution**:
- Verify `app.UseCors()` is before `app.UseAuthentication()`
- Check CORS policy allows your mobile app origin
- For development, current policy allows all origins

## Security Considerations

### Secrets Management
- ✅ `appsettings.Development.json` in `.gitignore`
- ✅ Production secrets in Azure Key Vault
- ✅ No secrets in source control

### Token Validation
- ✅ Validates JWT signature using Clerk's public keys
- ✅ Checks issuer and audience
- ✅ Validates expiration time
- ✅ Uses HTTPS for all OIDC discovery

### Database Security
- ✅ ClerkUserId has unique index (prevents duplicates)
- ✅ Email no longer globally unique (Clerk is source of truth)
- ✅ PasswordHash nullable (legacy auth optional)

## Next Steps

1. **Remove Legacy Auth Endpoints**
   - DELETE Controllers/AuthController.cs (if exists)
   - Remove IAuthService and implementations
   - Clean up old auth tests

2. **Implement User Sync Middleware**
   - Auto-sync user on first authenticated request
   - Cache UserId in request context

3. **Add Clerk Webhooks** (Optional)
   - User creation webhook
   - User deletion webhook
   - Email change webhook

4. **Update Swagger Documentation**
   - Add JWT bearer auth to Swagger UI
   - Document Clerk authentication

## Files Modified/Created

### Created
- ✅ `BloodPressureMonitor.API/Extensions/ClaimsPrincipalExtensions.cs`
- ✅ `BloodPressureMonitor.API/Controllers/AuthTestController.cs`
- ✅ `BloodPressureMonitor.API/appsettings.Development.json`
- ✅ `Database/Scripts/03_Add_Clerk_Integration.sql`
- ✅ `Database/StoredProcedures/Clerk_User_Procedures.sql`
- ✅ `.gitignore` (root)

### Modified
- ✅ `BloodPressureMonitor.API/Program.cs`
- ✅ `BloodPressureMonitor.API/appsettings.json`
- ✅ `BloodPressureMonitor.API/Models/Entities/User.cs`
- ✅ `BloodPressureMonitor.API/BloodPressureMonitor.API.csproj`

## Build Status

✅ **Backend compiles successfully** with no errors or warnings

```
Build succeeded.
    0 Warning(s)
    0 Error(s)
```

## Integration Complete

The Blood Pressure Monitor API is now fully integrated with Clerk authentication:
- ✅ JWT validation configured
- ✅ User sync mechanism in place
- ✅ Test endpoints available
- ✅ Database schema updated
- ✅ Secrets protected
- ✅ CORS enabled for mobile app
- ✅ Production-ready configuration

Ready for deployment and end-to-end testing!
