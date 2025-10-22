# Architecture Pivot Summary

**Date**: October 20, 2025  
**Decision**: PWA (Vue.js) → React Native + Expo

---

## Why We Pivoted

### Critical PWA Limitations
1. ❌ **No photo library access** - Cannot browse iOS Photos or Android Gallery
2. ❌ **Poor camera UX** - Browser APIs lack native controls
3. ❌ **Limited offline** - Service Workers insufficient for healthcare app
4. ❌ **No on-device ML** - Cannot use iOS Vision or Android ML Kit

### What React Native Enables
1. ✅ **Full photo library** - Native iOS Photos and Android Gallery access
2. ✅ **Professional camera** - Native controls (focus, flash, HDR)
3. ✅ **Offline-first** - SQLite storage, background sync
4. ✅ **On-device OCR** - iOS Vision Framework, Android ML Kit
5. ✅ **Healthcare UX** - Native look and feel expected by users

---

## What Changed

### Frontend
- **Before**: Vue.js 3 PWA
- **After**: React Native + Expo mobile apps

### Backend (No Change)
- .NET 8.0 API ✅
- Azure SQL Database ✅
- Azure Blob Storage ✅
- Azure Computer Vision ✅

### Timeline
- 10 weeks (same as original)

---

## Updated Documents

All documentation has been updated:
- ✅ README.md - React Native setup
- ✅ REQUIREMENTS.md - Native mobile requirements
- ✅ TODO.md - React Native implementation plan
- ✅ AGENTS.md - React Native build commands
- ✅ ARCHITECTURE.md - Detailed rationale
- ✅ FUTURE.md - Updated roadmap
- ✅ PROJECT-STATUS.md - Current state

Original PWA docs archived in `archive/` directory.

---

## Quick Start

### Backend
```bash
cd BloodPressureMonitor.API
dotnet restore
dotnet run
```

### Mobile
```bash
npx create-expo-app BloodPressureMonitor.Mobile --template expo-template-blank-typescript
cd BloodPressureMonitor.Mobile
npm install
npx expo start
```

---

## Key Benefits

1. **Better UX**: Native photo library browsing
2. **Faster OCR**: On-device processing in <1 second
3. **Works Offline**: Full functionality without internet
4. **Lower Costs**: 80% fewer cloud API calls
5. **Healthcare Ready**: Native UI appropriate for medical apps

---

See `ARCHITECTURE.md` for complete analysis.
