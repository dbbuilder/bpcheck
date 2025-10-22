# Blood Pressure Monitor - Architecture Decision Record

**Date**: October 20, 2025  
**Status**: Accepted  
**Decision**: Pivot from PWA (Vue.js) to React Native + Expo Native Mobile Applications

---

## Context and Problem Statement

The Blood Pressure Monitor application was initially designed as a Progressive Web App (PWA) using Vue.js 3 for the frontend. The core user workflow requires:

1. **Photo Library Integration**: Users need to browse and select existing photos from their iOS Photos app or Android Gallery to process historical blood pressure monitor images
2. **Camera Integration**: Users need professional camera experience to capture new BP monitor display photos with proper controls (focus, flash, alignment)
3. **Hospital/Home Use**: Application must work seamlessly in both environments, including areas with poor or no internet connectivity
4. **OCR Processing**: Extract three numbers (systolic, diastolic, heart rate) from BP monitor display photos

## Decision Drivers

### Critical Requirements
- **Full photo library access** - Users must browse ALL photos in their device photo library, not just select via file picker
- **Native camera experience** - Professional camera controls (focus, flash, grid overlay, HDR) for optimal photo capture
- **Offline-first operation** - Must work completely offline in hospital settings with intermittent connectivity
- **On-device OCR** - Fast, offline OCR processing using device ML capabilities
- **Healthcare UX standards** - Native look and feel expected by healthcare users

### PWA Limitations Identified

#### Photo Library Access ❌
- PWAs **cannot** access native photo libraries (iOS Photos, Android Gallery)
- `<input type="file">` only provides a file picker, not gallery browsing
- No ability to filter photos by date, album, or location
- No thumbnail grid view of user's existing photos
- Users cannot select multiple photos for batch processing

#### Camera Experience ❌
- Browser camera APIs (MediaDevices) work but feel non-native
- Limited control over camera settings (focus, flash, HDR)
- Poor UX compared to native camera apps
- No grid overlay or alignment assistance
- Cannot leverage device-specific camera optimizations

#### Performance and Offline ❌
- Service Workers provide limited offline capability
- Cannot efficiently cache large numbers of images
- No native background sync
- IndexedDB is slower than native SQLite
- Limited local storage capacity

#### ML/OCR Capabilities ❌
- Cannot access iOS Vision Framework or Android ML Kit
- Must rely entirely on cloud OCR (Azure Computer Vision)
- Adds latency and requires internet connectivity
- Higher operational costs (cloud API calls)
- Cannot process photos offline

## Decision

**Pivot to React Native + Expo** for native iOS and Android mobile applications.

### Technology Stack

```
Mobile Frontend:
├── React Native + Expo SDK 50.x
├── Expo Camera (native camera)
├── Expo Image Picker (photo library access)
├── Expo SQLite (local storage)
├── React Navigation (native navigation)
└── Optional: Expo ML Kit (on-device OCR)

Backend (Unchanged):
├── .NET Core 8.0 Web API
├── Azure SQL Database
├── Azure Blob Storage
├── Azure Computer Vision (fallback OCR)
└── Azure Key Vault
```

## Rationale

### Why React Native + Expo

#### Native Photo Library Integration ✅
- **Expo Image Picker** provides full access to iOS Photos and Android Gallery
- Users can browse photos by date, album, location
- Support for multi-select (batch processing)
- Native thumbnail grid view
- Maintains photo metadata (EXIF, location, date)

#### Professional Camera Experience ✅
- **Expo Camera** provides native camera with full device controls
- Access to focus, flash, HDR, and other camera features
- Can add custom UI overlays (grid, alignment guides)
- Native preview and retake functionality
- Leverages device-specific camera optimizations

#### Offline-First Architecture ✅
- **Expo SQLite** for robust local data persistence
- Full CRUD operations work offline
- Background sync when connectivity restored
- Native file system for image caching
- NetInfo for connectivity detection

#### On-Device OCR ✅
- **iOS Vision Framework** - Free, fast, accurate text recognition
- **Android ML Kit** - Google's on-device ML for text recognition
- Process photos instantly without internet
- Fallback to Azure Computer Vision for validation
- Significantly reduced operational costs

#### Native UX ✅
- Native navigation patterns (tab bar, stack navigation)
- Platform-specific UI components (iOS, Material Design)
- Native gestures (swipe, pinch-zoom)
- System integration (share, notifications, widgets)
- Professional healthcare app appearance

#### Single Codebase ✅
- 90%+ code shared between iOS and Android
- Write once, deploy to both platforms
- TypeScript for type safety
- Large ecosystem and community support

### Why Not Alternatives

#### Flutter ❌
- Team has JavaScript/TypeScript expertise, not Dart
- Smaller ecosystem than React Native
- Less mature healthcare app examples

#### Native (Swift + Kotlin) ❌
- 2x development effort (separate codebases)
- Higher maintenance cost
- Longer time to market
- Overkill for current requirements

#### Capacitor (Ionic) ⚠️
- Could keep Vue.js, but still "web in native wrapper"
- Plugin ecosystem smaller than React Native
- Performance not as good as React Native
- Less native feel

## Consequences

### Positive Consequences ✅

1. **Full Photo Library Access**: Users can browse and select from ALL photos in their device library
2. **Professional Camera UX**: Native camera controls provide optimal photo capture experience
3. **Offline Functionality**: Works completely offline with local SQLite storage
4. **Faster OCR**: On-device OCR processes photos in <1 second vs 3-5 seconds cloud
5. **Lower Operational Costs**: On-device OCR reduces Azure Computer Vision API calls by 80%+
6. **Better UX**: Native look and feel appropriate for healthcare application
7. **App Store Distribution**: Presence in App Store and Play Store increases credibility
8. **Single Codebase**: React Native allows shared code between iOS and Android (90%+)

### Negative Consequences ❌

1. **Learning Curve**: Team needs to learn React Native (if Vue.js focused)
2. **App Store Overhead**: Must maintain app store listings, handle reviews, updates
3. **Build Complexity**: EAS Build adds deployment complexity vs simple web hosting
4. **Platform-Specific Code**: Some code will need iOS/Android specific implementations (~10%)
5. **Initial Setup Time**: ~1-2 weeks additional setup vs PWA
6. **Testing Overhead**: Need to test on multiple devices and OS versions

### Mitigation Strategies

1. **Learning Curve**: React Native is JavaScript/TypeScript, similar to Vue.js; large community support
2. **App Store Overhead**: Expo EAS Build automates builds; updates can be pushed via OTA for non-native changes
3. **Build Complexity**: Expo simplifies build process significantly vs bare React Native
4. **Platform-Specific Code**: Expo provides cross-platform APIs for 90% of functionality
5. **Initial Setup**: Invest 1-2 weeks upfront for 10x better user experience
6. **Testing**: Expo Go allows quick testing on physical devices during development

## Implementation Plan

### Phase 1: Foundation (Weeks 1-2)
- Set up Expo project with TypeScript
- Configure Azure backend (unchanged)
- Implement authentication flow
- Test on iOS simulator and Android emulator

### Phase 2: Camera & Photos (Weeks 3-4)
- Implement native camera with Expo Camera
- Integrate photo library with Expo Image Picker
- Add batch photo selection
- Test on physical devices

### Phase 3: OCR (Week 5)
- Implement on-device OCR (Vision/ML Kit)
- Add Azure Computer Vision fallback
- Create BP number parsing logic
- Test accuracy on real BP monitor photos

### Phase 4: Readings & Sync (Weeks 6-7)
- Implement local SQLite storage
- Build sync service with queue
- Create readings list and detail screens
- Test offline-to-online transitions

### Phase 5: Analytics & Polish (Weeks 8-10)
- Add charts and visualizations
- Implement alerts and notifications
- Polish UI and UX
- App Store submission

**Total Timeline**: 10 weeks (same as original PWA timeline)

## Backend Impact

**Minimal Changes Required**:
- Backend .NET API remains unchanged
- Same Azure infrastructure (SQL, Blob Storage, Computer Vision)
- Same authentication (JWT)
- Same database schema
- Same stored procedures

Only addition: Mobile apps consume existing REST API

## Success Metrics

After 90 days post-launch:
- [ ] 90%+ of photos processed using on-device OCR (offline)
- [ ] <2 seconds average time from photo capture to reading confirmation
- [ ] 4.0+ star rating on App Store and Play Store
- [ ] <5% user support requests related to photo library or camera
- [ ] 80%+ reduction in Azure Computer Vision API costs vs cloud-only approach

## Related Documents

- [README.md](README.md) - Updated for React Native architecture
- [REQUIREMENTS.md](REQUIREMENTS.md) - Updated with native mobile requirements (FR-10, FR-11)
- [TODO.md](TODO.md) - React Native implementation plan
- [AGENTS.md](AGENTS.md) - Updated with React Native build commands
- [archive/](archive/) - Original PWA documentation

## References

- [Expo Documentation](https://docs.expo.dev/)
- [React Native Documentation](https://reactnative.dev/)
- [Expo Camera](https://docs.expo.dev/versions/latest/sdk/camera/)
- [Expo Image Picker](https://docs.expo.dev/versions/latest/sdk/imagepicker/)
- [iOS Vision Framework](https://developer.apple.com/documentation/vision)
- [Android ML Kit](https://developers.google.com/ml-kit)

---

**Decision Made By**: Development Team  
**Date**: October 20, 2025  
**Review Date**: November 20, 2025 (after Phase 3 completion)
