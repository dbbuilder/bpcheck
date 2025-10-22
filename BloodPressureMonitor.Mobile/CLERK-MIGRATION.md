# Clerk Authentication Migration

## Overview
Successfully migrated from custom JWT authentication to Clerk authentication for the Blood Pressure Monitor mobile app.

## What Was Changed

### 1. Packages Installed
- `@clerk/clerk-expo` - Clerk SDK for React Native/Expo
- `expo-web-browser` - Required for Clerk OAuth flows
- `expo-secure-store` - Already installed, used for secure token storage

### 2. Environment Configuration
Created `.env` file with Clerk credentials:
```
EXPO_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_bHVja3ktbGVtdXItMzEuY2xlcmsuYWNjb3VudHMuZGV2JA
CLERK_SECRET_KEY=sk_test_FhNc4QqwYOaGdZWScb2hub2ggJWEZCDeWPKVW5itm5
```

**IMPORTANT**: `.env` is now in `.gitignore` to protect credentials

### 3. App.tsx Updates
- Replaced `AuthProvider` with `ClerkProvider`
- Added secure token cache using `expo-secure-store`
- Integrated Clerk token getter with API service

### 4. Navigation Updates

#### AppNavigator.tsx
- Replaced `useAuth()` from custom context with Clerk's `useAuth()`
- Changed `isAuthenticated` to `isSignedIn`
- Changed `isLoading` to `!isLoaded`

#### MainNavigator.tsx
- Updated SettingsScreen with:
  - User information display from Clerk
  - Sign out button using Clerk's `signOut()`

### 5. Auth Screens Migration

#### LoginScreen.tsx
- Replaced custom `login()` with Clerk's `useSignIn()` hook
- Uses `signIn.create()` with email/password
- Calls `setActive()` to establish session on success

#### RegisterScreen.tsx
- Replaced custom `register()` with Clerk's `useSignUp()` hook
- Uses `signUp.create()` with email, password, firstName, lastName
- Handles email verification flow if required

#### ForgotPasswordScreen.tsx
- Replaced custom password reset with Clerk's reset flow
- Uses `signIn.create()` with `strategy: 'reset_password_email_code'`

### 6. API Service Updates (src/services/api.ts)

**Removed**:
- Custom auth endpoints (login, register, logout, refresh token, forgot password)
- Token refresh logic (Clerk handles this automatically)
- AsyncStorage token management

**Added**:
- `setClerkTokenGetter()` function to inject Clerk's token getter
- Request interceptor now uses Clerk token via `getClerkToken()`
- Simplified error handling (Clerk handles 401s automatically)

### 7. Files Backed Up
- `src/contexts/AuthContext.tsx` → `src/contexts/AuthContext.tsx.backup`
  - Custom auth context is no longer needed
  - Backup preserved for reference

## How Authentication Now Works

### Sign In Flow
1. User enters email/password on LoginScreen
2. `signIn.create({ identifier, password })` called
3. Clerk validates credentials
4. On success, `setActive({ session })` establishes session
5. `isSignedIn` becomes `true`, app navigates to Main stack

### Sign Up Flow
1. User enters email/password/name on RegisterScreen
2. `signUp.create({ emailAddress, password, firstName, lastName })` called
3. Clerk creates user account
4. May require email verification (handled by Clerk)
5. On complete, session established and user signed in

### API Requests
1. API service calls `getClerkToken()` before each request
2. Clerk returns valid JWT token (auto-refreshes if needed)
3. Token added to `Authorization: Bearer {token}` header
4. Backend validates Clerk JWT

### Sign Out
1. User taps "Sign Out" in Settings
2. `signOut()` called
3. Clerk clears session
4. `isSignedIn` becomes `false`, app navigates to Auth stack

## Backend Integration Requirements

The .NET backend will need to:

1. **Validate Clerk JWTs** instead of custom tokens
   - Install Clerk .NET SDK or use standard JWT validation
   - Verify tokens against Clerk's public keys
   - Extract user ID from `sub` claim

2. **Update User Model** mapping
   - Clerk user ID (from JWT `sub`) → your UserId
   - May need user sync webhook from Clerk

3. **Remove Custom Auth Endpoints**
   - DELETE `/auth/login`
   - DELETE `/auth/register`
   - DELETE `/auth/refresh`
   - DELETE `/auth/logout`
   - DELETE `/auth/forgot-password`
   - DELETE `/auth/reset-password`

4. **Update Protected Endpoints**
   - Use Clerk JWT validation middleware
   - Extract user context from Clerk token claims

## Testing Checklist

- [ ] Sign up new user
- [ ] Verify email (if required by Clerk settings)
- [ ] Sign in existing user
- [ ] API requests include Clerk token
- [ ] Token auto-refresh on expiration
- [ ] Sign out clears session
- [ ] Password reset flow
- [ ] User profile displays correctly
- [ ] Settings screen shows user info

## Clerk Dashboard Configuration

App: **ServiceVision**

Recommended settings:
- Enable email/password authentication
- Configure email templates for verification/reset
- Set up user metadata fields (firstName, lastName)
- Add localhost/staging/production URLs to allowed domains

## Environment Variables

Ensure `.env` is never committed to git:
```bash
git rm --cached .env  # if accidentally committed
```

## Rollback Plan

If needed to rollback:
1. Restore `src/contexts/AuthContext.tsx` from backup
2. Revert App.tsx, AppNavigator.tsx changes
3. Restore auth screens from git history
4. Remove Clerk packages
5. Re-enable custom auth endpoints in backend

## Benefits of Clerk

✅ No password hashing/storage complexity
✅ Built-in email verification
✅ Social OAuth ready (Google, Apple, etc.)
✅ Automatic token refresh
✅ Security best practices enforced
✅ User management dashboard
✅ Audit logs and analytics
✅ Multi-factor authentication ready
