# Expo Explained: How It Works with iOS and Android

## What is Expo?

**Expo** is a framework and platform built on top of React Native that simplifies mobile app development. Think of it as a **supercharged toolbox** that handles the complex native code configuration for you.

```
React Native (base framework)
    ↓
Expo (adds tools, APIs, and workflows)
    ↓
Your App (write JavaScript/TypeScript)
    ↓
Native iOS and Android Apps
```

## How Expo Works

### 1. **Managed Workflow** (Recommended for Most Apps)

Expo provides **pre-built native modules** for common device features:

```javascript
// Want to use the camera? Just import it:
import { Camera } from 'expo-camera';

// Want photo library access? Import it:
import * as ImagePicker from 'expo-image-picker';

// Want SQLite database? Import it:
import * as SQLite from 'expo-sqlite';
```

**Behind the scenes**, Expo has already:
- Written the Objective-C/Swift code (iOS)
- Written the Java/Kotlin code (Android)
- Configured permissions and entitlements
- Created the bridge between JavaScript and native code

### 2. **How Device Features Work**

#### Example: Camera Access

```javascript
// 1. Request permission (Expo handles platform differences)
const { status } = await Camera.requestCameraPermissionsAsync();

// 2. Use the camera (same code for iOS and Android)
<Camera
  style={{ flex: 1 }}
  type={CameraType.back}
  onCameraReady={() => console.log('Ready!')}
  ref={cameraRef}
/>

// 3. Take a photo
const photo = await cameraRef.current.takePictureAsync();
// Returns: { uri: 'file:///path/to/photo.jpg', width: 1920, height: 1080 }
```

**What Expo does:**
- **iOS**: Calls AVFoundation framework (native camera API)
- **Android**: Calls Camera2 API (native camera API)
- **JavaScript Bridge**: Converts native callbacks to JavaScript promises
- **Permissions**: Handles both iOS Info.plist and Android AndroidManifest.xml

#### Example: Photo Library Access

```javascript
// Request permission
const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();

// Launch picker (native UI on each platform)
const result = await ImagePicker.launchImageLibraryAsync({
  mediaTypes: ImagePicker.MediaTypeOptions.Images,
  allowsMultipleSelection: true,
  quality: 1,
});

// Result contains selected photos
// result.assets = [{ uri, width, height, exif, ... }]
```

**What happens:**
- **iOS**: Opens native Photos app picker (UIImagePickerController)
- **Android**: Opens native Gallery picker (Intent.ACTION_PICK)
- Both return standardized JavaScript objects

## Architecture Diagram

```
┌─────────────────────────────────────────────────────┐
│           Your React Native Code (JS/TS)            │
│  - Components, screens, business logic              │
│  - import { Camera } from 'expo-camera'             │
└─────────────────┬───────────────────────────────────┘
                  │
        ┌─────────┴─────────┐
        │   Expo SDK APIs   │
        │  (JavaScript API) │
        └─────────┬─────────┘
                  │
      ┌───────────┴───────────┐
      │   Native Bridge       │
      │ (React Native Bridge) │
      └───────────┬───────────┘
                  │
        ┌─────────┴─────────┐
        │                   │
    ┌───▼────┐         ┌────▼───┐
    │  iOS   │         │Android │
    │ Native │         │ Native │
    │  Code  │         │  Code  │
    └────────┘         └────────┘
        │                   │
    ┌───▼────┐         ┌────▼───┐
    │AVFound-│         │Camera2 │
    │ation   │         │  API   │
    │Photos  │         │Gallery │
    │Vision  │         │ML Kit  │
    └────────┘         └────────┘
```

## Key Expo SDK Modules for Blood Pressure Monitor

### 1. **Expo Camera**
```javascript
import { Camera } from 'expo-camera';
```

**iOS**: Uses AVFoundation framework
- Access to focus, exposure, flash, torch
- High-resolution photo capture
- Video recording support

**Android**: Uses Camera2 API
- Manual focus control
- Flash modes
- Image stabilization

**Shared Features**:
- Front/back camera toggle
- Photo/video capture
- Barcode scanning
- Face detection

### 2. **Expo Image Picker**
```javascript
import * as ImagePicker from 'expo-image-picker';
```

**iOS**: 
- Uses PHPickerViewController (iOS 14+)
- Access to entire Photos library
- EXIF metadata included
- HEIC format support

**Android**:
- Uses MediaStore API
- Access to Gallery
- Multiple selection
- Automatic HEIC conversion

**Features**:
- Single or multiple selection
- Video selection
- Image editing (crop, rotate)
- Compression options

### 3. **Expo SQLite**
```javascript
import * as SQLite from 'expo-sqlite';
```

**Both Platforms**: Uses SQLite engine
- Full SQL database on device
- ACID transactions
- Encrypted storage option
- Async operations

### 4. **Expo FileSystem**
```javascript
import * as FileSystem from 'expo-file-system';
```

**iOS**: Uses NSFileManager
**Android**: Uses File API

**Features**:
- Read/write files
- Download files
- Cache management
- Document directory access

### 5. **Expo SecureStore**
```javascript
import * as SecureStore from 'expo-secure-store';
```

**iOS**: Uses Keychain Services
**Android**: Uses EncryptedSharedPreferences

**Use Cases**:
- Store JWT tokens securely
- Store API keys
- Store user credentials

### 6. **Expo ML Kit** (optional)
```javascript
import * as TextRecognition from 'expo-text-recognition';
```

**iOS**: Uses Vision Framework (Apple's ML)
**Android**: Uses ML Kit (Google's ML)

**Features**:
- On-device text recognition (OCR)
- Works offline
- Fast (<1 second)
- Free to use

## Development Workflow

### 1. **Development with Expo Go**

```bash
# Start development server
npx expo start

# Options:
# - Press 'i' for iOS Simulator
# - Press 'a' for Android Emulator
# - Scan QR code with Expo Go app on physical device
```

**Expo Go App**: Pre-built app with all Expo APIs included
- Install from App Store or Play Store
- Scan QR code to load your app
- See changes instantly (hot reload)
- **Limitation**: Only includes standard Expo modules (no custom native code)

### 2. **Testing on Physical Devices**

```bash
# iOS device (via Expo Go)
1. Install Expo Go from App Store
2. Scan QR code from terminal
3. App loads on device

# Android device (via Expo Go)
1. Install Expo Go from Play Store
2. Scan QR code
3. App loads on device
```

**Why Physical Devices Matter**:
- Camera quality differs from simulators
- Photo library has real photos
- Performance is more accurate
- Test biometric authentication
- Test push notifications

### 3. **Building Production Apps (EAS Build)**

```bash
# Configure EAS
eas build:configure

# Build for iOS
eas build --platform ios --profile production

# Build for Android
eas build --platform android --profile production
```

**What EAS Build Does**:
1. Takes your JavaScript code
2. Bundles it with Expo native runtime
3. Compiles native iOS code (on Mac servers)
4. Compiles native Android code
5. Returns .ipa (iOS) or .apk/.aab (Android)
6. Ready to submit to app stores

### 4. **Over-The-Air (OTA) Updates**

```bash
# Publish update
eas update --branch production
```

**OTA Updates** allow you to push JavaScript/asset changes without app store review:
- **Can update**: JavaScript code, images, translations
- **Cannot update**: Native code, permissions, app icon
- Users get updates automatically on next app launch

## Permissions Handling

Expo simplifies permission requests across platforms:

```javascript
// Camera permission
const { status } = await Camera.requestCameraPermissionsAsync();
if (status !== 'granted') {
  Alert.alert('Permission Denied', 'Camera access is required');
  return;
}

// Photo library permission
const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();

// Expo automatically:
// - Updates Info.plist (iOS)
// - Updates AndroidManifest.xml (Android)
// - Shows native permission dialogs
// - Handles permission denials
```

**Configuration (app.json)**:
```json
{
  "expo": {
    "ios": {
      "infoPlist": {
        "NSCameraUsageDescription": "This app uses the camera to capture blood pressure readings",
        "NSPhotoLibraryUsageDescription": "This app accesses photos to process historical readings"
      }
    },
    "android": {
      "permissions": [
        "CAMERA",
        "READ_EXTERNAL_STORAGE"
      ]
    }
  }
}
```

## Expo Managed vs Bare Workflow

### Managed Workflow (Recommended)
```
✅ Expo handles all native code
✅ Use Expo Go for development
✅ Automatic upgrades
✅ Simple configuration
❌ Limited to Expo modules
```

### Bare Workflow (Advanced)
```
✅ Full access to native code
✅ Add any native library
✅ Complete customization
❌ Manual native configuration
❌ Cannot use Expo Go
❌ More complex
```

**For Blood Pressure Monitor**: Managed workflow is sufficient. All required features (camera, photos, SQLite, OCR) are available in Expo SDK.

## How Expo Compares to Alternatives

### Expo vs React Native CLI

| Feature | Expo | React Native CLI |
|---------|------|------------------|
| Setup Time | 5 minutes | 1-2 hours |
| Native Code | Handled by Expo | Write yourself |
| Camera API | `import { Camera }` | Configure manually |
| Updates | OTA updates | App store only |
| Build Process | Cloud builds | Local Xcode/Android Studio |
| Learning Curve | Easier | Steeper |

### Expo vs Flutter

| Feature | Expo | Flutter |
|---------|------|---------|
| Language | JavaScript/TypeScript | Dart |
| Ecosystem | React Native (huge) | Flutter (growing) |
| Web Support | Yes | Yes |
| Native Feel | 100% native | Custom rendering |
| Team Learning | Easy (JS) | New language |

### Expo vs Capacitor (Ionic)

| Feature | Expo | Capacitor |
|---------|------|-----------|
| Base | React Native | Web (HTML/CSS/JS) |
| Performance | Native | WebView wrapper |
| Feel | Native | Web-like |
| Camera Quality | Native camera | Limited |
| Photo Library | Full access | Basic access |

## Common Misconceptions

### ❌ "Expo apps are slower"
**Reality**: Expo apps use the same React Native engine. Performance is identical to bare React Native.

### ❌ "Expo apps are larger"
**Reality**: Modern Expo apps are ~3-5MB larger due to included modules. Negligible for most apps.

### ❌ "Expo is limiting"
**Reality**: Expo SDK includes 50+ modules covering 95% of app needs. Can eject to bare workflow if needed.

### ❌ "Can't use native code with Expo"
**Reality**: Expo supports custom native modules via "config plugins" without ejecting.

## For Blood Pressure Monitor Specifically

### Why Expo is Perfect:

1. **Camera**: `expo-camera` provides professional controls
2. **Photos**: `expo-image-picker` gives full library access
3. **Storage**: `expo-sqlite` for offline data
4. **OCR**: Can integrate on-device OCR
5. **Fast Development**: Build and test quickly
6. **Easy Deployment**: EAS Build simplifies app store submission

### What You Get Out of the Box:

```javascript
// All these work without any native configuration:
import { Camera } from 'expo-camera';
import * as ImagePicker from 'expo-image-picker';
import * as SQLite from 'expo-sqlite';
import * as FileSystem from 'expo-file-system';
import * as SecureStore from 'expo-secure-store';
import NetInfo from '@react-native-community/netinfo';
import AsyncStorage from '@react-native-async-storage/async-storage';
```

### Example: Complete Camera Flow

```javascript
import { useState, useRef } from 'react';
import { Camera, CameraType } from 'expo-camera';
import { Button, View } from 'react-native';

export default function CameraScreen() {
  const [permission, requestPermission] = Camera.useCameraPermissions();
  const cameraRef = useRef(null);

  if (!permission?.granted) {
    return <Button title="Grant Camera" onPress={requestPermission} />;
  }

  const takePicture = async () => {
    const photo = await cameraRef.current.takePictureAsync();
    // photo.uri contains the image path
    // Send to OCR or save to database
  };

  return (
    <Camera
      style={{ flex: 1 }}
      type={CameraType.back}
      ref={cameraRef}
    >
      <Button title="Capture" onPress={takePicture} />
    </Camera>
  );
}
```

**That's it!** Expo handles:
- Permission requests (iOS Info.plist, Android Manifest)
- Native camera initialization
- Image capture and storage
- Cross-platform differences

## Bottom Line

**Expo = React Native made easy**

Instead of writing native iOS and Android code for every device feature, Expo provides JavaScript APIs that work on both platforms. You write once, it runs natively on both iOS and Android, with full access to cameras, photo libraries, sensors, and all device capabilities needed for a professional healthcare app.

---

**Document Created**: October 20, 2025  
**For Project**: Blood Pressure Monitor  
**Related Docs**: [ARCHITECTURE.md](../ARCHITECTURE.md), [README.md](../README.md)
