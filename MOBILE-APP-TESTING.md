# Mobile App Testing Guide

## Current Setup

✅ **API**: https://bpcheck.servicevision.io (Production, Live)
✅ **Mobile App**: Configured to use production API
✅ **Expo Dev Server**: Starting...

## How to Test the Mobile App

### Option 1: Test on Your Phone (Recommended)

**1. Install Expo Go App:**
- iOS: https://apps.apple.com/app/expo-go/id982107779
- Android: https://play.google.com/store/apps/details?id=host.exp.exponent

**2. Start the Dev Server** (already running):
```bash
cd /mnt/d/Dev2/blood-pressure-check/BloodPressureMonitor.Mobile
npx expo start
```

**3. Scan the QR Code:**
- Expo will show a QR code in the terminal
- iOS: Open Camera app, scan QR code
- Android: Open Expo Go app, scan QR code

**4. App opens on your phone!**

### Option 2: Test on Android Emulator

**1. Start Android Emulator:**
```bash
# If you have Android Studio installed
emulator -avd YOUR_AVD_NAME

# Or from Android Studio:
# Tools > Device Manager > Play button
```

**2. In Expo terminal, press `a`**
- Expo will automatically open app in emulator

### Option 3: Test on iOS Simulator (Mac only)

**1. In Expo terminal, press `i`**
- Expo will automatically open iOS Simulator and install app

### Option 4: Test on Web (Limited - Not Full Native Experience)

**1. In Expo terminal, press `w`**
- Opens in browser
- Limited functionality (some native features won't work)

## Testing Steps

### Step 1: Verify App Loads

- App should open to Login screen
- You should see:
  - "Welcome Back" title
  - Email field
  - Password field
  - "Sign In" button
  - "Don't have an account? Sign up" link

### Step 2: Test Registration

1. **Tap "Sign up"**

2. **Fill in registration form:**
   - First Name: Test
   - Last Name: User
   - Email: `test@example.com` (use your real email if you want to receive verification)
   - Date of Birth: Select any date
   - Password: `TestPassword123!`
   - Confirm Password: `TestPassword123!`

3. **Tap "Create Account"**

4. **What should happen:**
   - Clerk creates your account
   - You're automatically signed in
   - Redirected to main app (Home screen)

### Step 3: Verify User Created in Database

After registration, check the database:

```bash
cd /mnt/d/Dev2/blood-pressure-check

# Query users
cmd.exe /c "sqlcmd -S sqltest.schoolvision.net,14333 -U sv -P Gv51076! -N -C -d BPCheckDB -Q \"SELECT UserId, ClerkUserId, Email, FirstName, LastName, CreatedDate FROM Users WHERE ClerkUserId IS NOT NULL\""
```

You should see your newly registered user with:
- A `ClerkUserId` starting with `user_`
- Your email address
- First and Last name
- CreatedDate timestamp

### Step 4: Test Login Flow

1. **Sign out:**
   - Go to Settings tab
   - Tap "Sign Out"

2. **Sign back in:**
   - Enter email: `test@example.com`
   - Enter password: `TestPassword123!`
   - Tap "Sign In"

3. **Should:**
   - Authenticate via Clerk
   - Redirect to main app
   - User's LastLoginDate updated in database

### Step 5: Monitor Railway Logs

Watch for API calls in Railway:

1. Go to: https://railway.com/project/48fc11cc-910d-43ee-a10b-07c455d16a3a
2. Click on your service
3. Go to **Logs** tab
4. You should see:
   - JWT token validation messages
   - User sync calls
   - Authentication events

### Step 6: Test Password Reset

1. From Login screen, tap **"Forgot Password?"**
2. Enter your email
3. Tap **"Send Reset Link"**
4. Check your email for reset link from Clerk
5. Follow link to reset password

## Expected API Calls

When you register/login, the mobile app makes these calls:

1. **Registration:**
   ```
   POST https://bpcheck.servicevision.io/api/... (via Clerk SDK)
   ```
   - Clerk creates account
   - Clerk returns JWT token
   - Mobile app stores token

2. **First authenticated request:**
   - API receives JWT token
   - API validates with Clerk
   - API calls `usp_User_SyncFromClerk` stored procedure
   - User created/updated in BPCheckDB

3. **Subsequent requests:**
   - Mobile app includes JWT in Authorization header
   - API validates token
   - API processes request

## Troubleshooting

### App won't connect to API

**Check .env file:**
```bash
cd BloodPressureMonitor.Mobile
cat .env
```

Should show:
```
EXPO_PUBLIC_API_URL=https://bpcheck.servicevision.io/api
```

**Restart Expo:**
```bash
# Stop current Expo server (Ctrl+C)
npx expo start --clear
```

### Can't scan QR code

1. Make sure phone and computer are on same WiFi network
2. Or use **Tunnel mode**:
   ```bash
   npx expo start --tunnel
   ```

### Registration fails

**Check Clerk dashboard:**
- Go to https://dashboard.clerk.com
- Check "Users" tab
- Verify user was created in Clerk

**Check Railway logs:**
- Look for authentication errors
- Check for JWT validation issues

### Database connection issues

**Test API directly:**
```bash
curl https://bpcheck.servicevision.io/api/authtest/health
```

Should return:
```json
{"status":"healthy","message":"..."}
```

## What to Test

### Core Authentication:
- ✅ Registration
- ✅ Login
- ✅ Logout
- ✅ Password reset
- ✅ Token refresh

### User Sync:
- ✅ User created in database on first login
- ✅ User info updated on subsequent logins
- ✅ ClerkUserId properly stored

### API Integration:
- ✅ JWT tokens sent with requests
- ✅ Protected endpoints require authentication
- ✅ Unauthorized requests return 401

## Quick Test Script

```bash
# 1. Start mobile app
cd BloodPressureMonitor.Mobile
npx expo start

# 2. In another terminal, monitor Railway logs
# (Open Railway dashboard in browser)

# 3. In another terminal, watch database
watch -n 5 'cmd.exe /c "sqlcmd -S sqltest.schoolvision.net,14333 -U sv -P Gv51076! -N -C -d BPCheckDB -Q \"SELECT COUNT(*) as UserCount FROM Users WHERE ClerkUserId IS NOT NULL\""'

# 4. Test registration on mobile device
# 5. Watch for new user in database
```

## Success Criteria

✅ Can register new user
✅ User appears in BPCheckDB
✅ Can login with credentials
✅ Can logout
✅ API logs show authentication events
✅ JWT tokens working
✅ User sync working

## Next Steps After Testing

Once basic authentication works:
1. Test blood pressure reading creation
2. Test image upload (if implemented)
3. Test offline mode
4. Performance testing
5. Build production app for app stores
