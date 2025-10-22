# Expo App Deployment Options

## Overview

Your Blood Pressure Monitor is an **Expo/React Native mobile app**. You have several deployment options:

### Deployment Strategy Comparison

| Platform | Best For | Features | Cost |
|----------|----------|----------|------|
| **iOS App Store** | iOS users | Full native | $99/year |
| **Google Play** | Android users | Full native | $25 one-time |
| **Vercel/Azure (Web)** | Web testing/demo | Limited features | Free |
| **Expo EAS** | Beta testing | Full native | Free tier available |

## Recommended: Native App Deployment

### For Production Use: Deploy to App Stores

**Best approach for a blood pressure monitor app:**
1. Full camera access for BP reading photos
2. Native performance
3. Offline support
4. Best UX

See: `APP-STORE-DEPLOYMENT.md` (will create this)

## Option 1: Web Deployment (Limited Features)

### ⚠️ Important Limitations for Web:

Your app uses features that **won't work on web**:
- Camera/Photo capture (core feature!)
- Some native UI components
- Native navigation feel
- Biometric authentication (if implemented)

**Web deployment is good for:**
- Demo/testing
- Letting users try before downloading app
- Admin dashboard (if you build one)

### Deploy Expo Web to Vercel

**Step 1: Install Web Dependencies**

```bash
cd BloodPressureMonitor.Mobile
npx expo install react-dom react-native-web
```

**Step 2: Build for Web**

```bash
npx expo export:web
```

This creates a `dist/` folder with static HTML/JS/CSS.

**Step 3: Deploy to Vercel**

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
cd BloodPressureMonitor.Mobile
vercel --prod
```

Or via Vercel Dashboard:
1. Go to https://vercel.com
2. Import project from GitHub
3. Set root directory to `BloodPressureMonitor.Mobile`
4. Build command: `npx expo export:web`
5. Output directory: `dist`

**Step 4: Configure Custom Domain**

In Vercel dashboard:
- Add domain: `app.bpcheck.servicevision.io`
- Vercel provides DNS instructions

### Deploy Expo Web to Azure Static Web Apps

**Step 1: Same - Install Dependencies & Build**

```bash
cd BloodPressureMonitor.Mobile
npx expo install react-dom react-native-web
npx expo export:web
```

**Step 2: Create Azure Static Web App**

```bash
# Install Azure CLI
az login

# Create resource group (if not exists)
az group create --name rg-bpcheck --location eastus

# Create static web app
az staticwebapp create \
  --name bpcheck-app \
  --resource-group rg-bpcheck \
  --location eastus2 \
  --source https://github.com/dbbuilder/bpcheck \
  --branch main \
  --app-location "/BloodPressureMonitor.Mobile" \
  --output-location "dist" \
  --build-command "npx expo export:web"
```

**Step 3: Configure Custom Domain**

```bash
az staticwebapp hostname set \
  --name bpcheck-app \
  --resource-group rg-bpcheck \
  --hostname app.bpcheck.servicevision.io
```

Then add CNAME in Name.com:
```
CNAME  app  <azure-staticwebapp-url>
```

## Option 2: Native App Deployment (Recommended)

### Using Expo EAS (Expo Application Services)

**Best for production mobile apps**

**Step 1: Install EAS CLI**

```bash
npm install -g eas-cli
```

**Step 2: Configure EAS**

```bash
cd BloodPressureMonitor.Mobile
eas login
eas build:configure
```

**Step 3: Build for iOS**

```bash
# Development build (for testing)
eas build --platform ios --profile development

# Production build (for App Store)
eas build --platform ios --profile production
```

**Step 4: Build for Android**

```bash
# Development build (for testing)
eas build --platform android --profile development

# Production build (for Play Store)
eas build --platform android --profile production
```

**Step 5: Submit to Stores**

```bash
# iOS App Store
eas submit --platform ios

# Google Play Store
eas submit --platform android
```

### Costs:
- **EAS Free Tier**: 30 builds/month (sufficient for development)
- **EAS Production**: $29/month (unlimited builds)
- **Apple Developer**: $99/year
- **Google Play**: $25 one-time

## Option 3: Hybrid Approach (Best)

Deploy to **both** web and native:

1. **Native apps** for full functionality
2. **Web version** for marketing/demo

### Recommended Setup:

```
https://bpcheck.servicevision.io/api          → API (Railway) ✅
https://bpcheck.servicevision.io              → Marketing site (static)
https://app.bpcheck.servicevision.io          → Web app (Vercel/Azure)
iOS App Store                                  → Native iOS app
Google Play Store                              → Native Android app
```

## Quick Decision Guide

**Choose Native (App Stores) if:**
- ✅ You want full camera/photo features
- ✅ You want best performance
- ✅ You're building for end users
- ✅ You need offline support

**Choose Web (Vercel/Azure) if:**
- ✅ You want quick demo
- ✅ You want to test on web
- ✅ Camera features are optional
- ✅ You want free hosting

**Choose Both if:**
- ✅ You want maximum reach
- ✅ Web for marketing, native for features
- ✅ You have budget for both

## My Recommendation for Blood Pressure Monitor

Given your app's **blood pressure monitoring functionality** (which likely involves camera/photos):

### Phase 1 (Now):
1. ✅ Test mobile app locally with Expo Go
2. ✅ Verify authentication works
3. ✅ Test camera features

### Phase 2 (Next):
1. 🔜 Deploy native app to Expo EAS for TestFlight/Internal testing
2. 🔜 Get feedback from beta testers
3. 🔜 Refine features

### Phase 3 (Production):
1. 📱 Submit to iOS App Store
2. 📱 Submit to Google Play Store
3. 🌐 Deploy web version for marketing (optional)

## Would You Like Me To:

1. **Set up web deployment** (Vercel/Azure) - Good for demo, limited features
2. **Set up EAS for native apps** - Best for production, full features
3. **Set up both** - Maximum reach

Let me know your priority and I'll configure the deployment!
