# Blood Pressure Monitor - Local Testing Guide

## Current Setup Status

- **API**: Running on http://localhost:3500
- **Database**: BPCheckDB on sqltest.schoolvision.net,14333
- **Mobile App**: Configured to connect to http://localhost:3500/api
- **Authentication**: Clerk integration enabled

## Prerequisites

1. API running on port 3500 (already started)
2. Mobile app environment configured (.env file updated)
3. Expo CLI installed
4. iOS Simulator or Android Emulator (or physical device)

## Testing Steps

### 1. Start the Mobile App

```bash
cd /mnt/d/Dev2/blood-pressure-check/BloodPressureMonitor.Mobile
npx expo start
```

Options:
- Press `i` for iOS simulator
- Press `a` for Android emulator
- Scan QR code with Expo Go app on physical device

### 2. Test Health Endpoint (Verify API)

```bash
curl http://localhost:3500/api/authtest/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2025-10-22T07:45:28.0548353Z",
  "message": "Blood Pressure Monitor API is running"
}
```

### 3. Test User Registration Flow

**In the Mobile App:**

1. Launch the app
2. You should see the Login screen
3. Tap "Don't have an account? Sign up"
4. Fill in the registration form:
   - First Name: Test
   - Last Name: User
   - Email: test@example.com
   - Date of Birth: Select a date
   - Password: TestPassword123!
   - Confirm Password: TestPassword123!
5. Tap "Create Account"

**What Happens:**
- Clerk creates the user account
- Clerk signs you in automatically
- API receives JWT token with Clerk user ID
- User is synced to BPCheckDB database via `usp_User_SyncFromClerk`
- You're redirected to the main app

### 4. Verify User in Database

After successful registration, check the database:

```bash
cmd.exe /c "sqlcmd -S sqltest.schoolvision.net,14333 -U sv -P Gv51076! -N -C -d BPCheckDB -Q \"SELECT UserId, ClerkUserId, Email, FirstName, LastName, CreatedDate FROM Users WHERE ClerkUserId IS NOT NULL\""
```

You should see your newly created user with:
- A ClerkUserId (starts with "user_")
- The email you registered with
- First and Last name

### 5. Test Login Flow

**In the Mobile App:**

1. Sign out (Settings tab > Sign Out)
2. You should return to the Login screen
3. Enter your credentials:
   - Email: test@example.com
   - Password: TestPassword123!
4. Tap "Sign In"

**What Happens:**
- Clerk validates credentials
- JWT token is generated
- Token is cached in secure storage
- API validates token on protected endpoints
- User's LastLoginDate is updated in database

### 6. Test Protected Endpoints

After logging in, test the protected endpoints to verify authentication:

#### Option A: Via Mobile App (Recommended)

The mobile app automatically includes the Clerk JWT token in all API requests. Just use the app normally and monitor the API logs:

```bash
# Watch API logs for authentication events
# The API is already running and logging to console
```

#### Option B: Via cURL (Advanced)

1. **Get a JWT token from Clerk** (this requires intercepting the token from the mobile app)
   - Use React Native Debugger or console.log the token
   - Or use Clerk's session token directly

2. **Test protected endpoint:**
```bash
curl http://localhost:3500/api/authtest/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

Expected response:
```json
{
  "authenticated": true,
  "clerkUserId": "user_2abc123xyz",
  "email": "test@example.com",
  "claims": [
    {"type": "sub", "value": "user_2abc123xyz"},
    {"type": "email", "value": "test@example.com"},
    ...
  ]
}
```

### 7. Test Password Reset Flow

**In the Mobile App:**

1. From Login screen, tap "Forgot Password?"
2. Enter your email: test@example.com
3. Tap "Send Reset Link"
4. Check your email for reset instructions from Clerk
5. Follow the link to reset your password

### 8. Monitor API Logs

Watch for these authentication events in the API console:

```
info: JWT Token validated for Clerk User ID: user_2abc123xyz
info: User authenticated successfully
```

Failed authentication will show:
```
info: JWT Authentication failed: [error message]
```

### 9. Test User Profile Update

After logging in, test updating user profile:

1. Navigate to Settings/Profile screen
2. Update your first name or last name
3. Save changes
4. Verify in database:

```bash
cmd.exe /c "sqlcmd -S sqltest.schoolvision.net,14333 -U sv -P Gv51076! -N -C -d BPCheckDB -Q \"SELECT UserId, FirstName, LastName, ModifiedDate FROM Users WHERE ClerkUserId = 'user_YOUR_CLERK_ID_HERE'\""
```

The ModifiedDate should be updated.

## Common Issues and Solutions

### Issue: Mobile app can't connect to API

**Solution:**
1. Verify API is running: `curl http://localhost:3500/api/authtest/health`
2. Check mobile app .env file has correct URL: `http://localhost:3500/api`
3. Restart Expo dev server after .env changes
4. If using physical device, use your computer's IP instead of localhost

For physical device:
```bash
# Find your local IP
ipconfig  # Windows
ifconfig  # Mac/Linux

# Update .env
EXPO_PUBLIC_API_URL=http://192.168.1.XXX:3500/api
```

### Issue: JWT validation fails

**Check these:**
1. Clerk Authority matches in both mobile app and API
2. Clerk Publishable Key in mobile app is correct
3. API appsettings.Development.json has correct Clerk configuration
4. Token hasn't expired (Clerk tokens expire after 1 hour by default)

### Issue: Database connection fails

**Verify:**
1. SQL Server is accessible: Test with sqlcmd
2. Connection string is correct in appsettings.Development.json
3. User 'sv' has permissions on BPCheckDB
4. Firewall allows connection to port 14333

### Issue: User not syncing to database

**Check:**
1. API logs for database errors
2. Stored procedure exists: `usp_User_SyncFromClerk`
3. Users table has ClerkUserId column
4. Database connection string is correct

## Test Data Cleanup

To reset test data:

```sql
-- Delete all test users
DELETE FROM Users WHERE ClerkUserId IS NOT NULL;

-- Or delete specific user
DELETE FROM Users WHERE Email = 'test@example.com';
```

**Note:** This only deletes from local database. Clerk users must be deleted from Clerk Dashboard.

## Next Steps

Once basic authentication is working:

1. Test blood pressure reading creation
2. Test image upload functionality
3. Test alert threshold configuration
4. Test data synchronization
5. Test offline mode
6. Performance testing with multiple users

## Support

If you encounter issues:

1. Check API logs in console
2. Check mobile app console/debugger
3. Verify database connectivity
4. Review Clerk dashboard for user status
5. Check network connectivity between mobile app and API

## Environment Configuration

**API (Port 3500)**
- File: `BloodPressureMonitor.API/appsettings.Development.json`
- Kestrel endpoint configured for http://localhost:3500

**Mobile App**
- File: `BloodPressureMonitor.Mobile/.env`
- API URL: `http://localhost:3500/api`
- Clerk Publishable Key included

**Database**
- Server: sqltest.schoolvision.net,14333
- Database: BPCheckDB
- Connection string in appsettings.Development.json
