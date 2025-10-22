# Domain Reorganization - Complete Guide

## New Domain Structure

**API Domain (Railway):**
- Old: `bpcheck.servicevision.io`
- New: `bpcheck-api.servicevision.io` ✅

**Web UI Domain (Vercel):**
- New: `bpcheck.servicevision.io` (to be configured)

## What's Been Changed

### ✅ Completed:

1. **DNS Updated** (Name.com)
   - Deleted old `bpcheck` CNAME
   - Created new `bpcheck-api` CNAME → `k5loed3p.up.railway.app`

2. **Mobile App Configuration Updated**
   - `.env`: `EXPO_PUBLIC_API_URL=https://bpcheck-api.servicevision.io/api`
   - `.env.production`: Updated to new API domain

### ⏳ Pending (Do These Next):

## Step 1: Update Railway Custom Domain

**In Railway Dashboard:**

1. Go to: https://railway.com/project/48fc11cc-910d-43ee-a10b-07c455d16a3a
2. Click on your service
3. Go to **Settings** > **Domains**
4. Remove old domain: `bpcheck.servicevision.io`
5. Add new domain: `bpcheck-api.servicevision.io`
6. Railway will detect DNS automatically

**Expected result:**
- Railway provisions SSL for `bpcheck-api.servicevision.io`
- API accessible at new domain in 5-15 minutes

## Step 2: Test New API Domain

Once DNS propagates (5-15 minutes):

```bash
# Test health endpoint
curl https://bpcheck-api.servicevision.io/api/authtest/health

# Expected response:
{
  "status": "healthy",
  "message": "Blood Pressure Monitor API is running"
}
```

## Step 3: Set Up Vercel for Web UI

### Install Web Dependencies

```bash
cd BloodPressureMonitor.Mobile
npx expo install react-dom react-native-web
```

### Build for Web

```bash
npx expo export:web
```

This creates `dist/` folder with static files.

### Deploy to Vercel

**Option A: Via Vercel CLI**

```bash
# Install Vercel CLI
npm i -g vercel

# Login
vercel login

# Deploy
cd BloodPressureMonitor.Mobile
vercel --prod
```

**During deployment, configure:**
- Project name: `bpcheck`
- Build command: `npx expo export:web`
- Output directory: `dist`
- Install command: `npm install`

**Option B: Via Vercel Dashboard**

1. Go to https://vercel.com/new
2. Import from GitHub: `dbbuilder/bpcheck`
3. Configure:
   - Framework: Other
   - Root Directory: `BloodPressureMonitor.Mobile`
   - Build Command: `npx expo export:web`
   - Output Directory: `dist`
   - Install Command: `npm install`
4. Click **Deploy**

### Add Custom Domain to Vercel

1. In Vercel project settings
2. Go to **Domains**
3. Add domain: `bpcheck.servicevision.io`
4. Vercel will show DNS configuration needed

### Configure DNS for Vercel

Vercel will provide a CNAME target. Use our script:

```bash
# After Vercel gives you the CNAME target (e.g., cname.vercel-dns.com)
./configure-vercel-domain.sh <vercel-cname-target>
```

Or manually via Name.com API:

```bash
curl -X POST "https://api.name.com/v4/domains/servicevision.io/records" \
  -u "TEDTHERRIAULT:4790fea6e456f7fe9cf4f61a30f025acd63ecd1c" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "CNAME",
    "host": "bpcheck",
    "answer": "<vercel-cname-target>",
    "ttl": 300
  }'
```

## Step 4: Commit and Push Changes

```bash
git add .
git commit -m "Update API domain to bpcheck-api.servicevision.io"
git push
```

## Step 5: Update Documentation

Update these files with new API URL:
- `README.md`
- `RAILWAY-DEPLOYMENT.md`
- `TESTING-GUIDE.md`
- `MOBILE-APP-TESTING.md`

## Final Domain Structure

```
https://bpcheck-api.servicevision.io     → Railway (API)
├── /api/authtest/health                 → Health endpoint
├── /api/authtest/me                     → User info (protected)
└── /api/authtest/protected              → Protected endpoint

https://bpcheck.servicevision.io         → Vercel (Web UI)
├── /                                    → Web app home
├── /login                               → Web login
└── /register                            → Web registration
```

## Verification Checklist

After all changes:

### API Domain:
- [ ] DNS resolving: `nslookup bpcheck-api.servicevision.io`
- [ ] Railway shows green SSL status
- [ ] Health endpoint works: `curl https://bpcheck-api.servicevision.io/api/authtest/health`
- [ ] Mobile app connects successfully

### Web UI Domain:
- [ ] DNS resolving: `nslookup bpcheck.servicevision.io`
- [ ] Vercel shows green deployment status
- [ ] SSL certificate active
- [ ] Web app loads: `https://bpcheck.servicevision.io`

### Mobile App:
- [ ] `.env` updated to new API URL
- [ ] Expo dev server restarted
- [ ] Can register/login
- [ ] API calls working

## Rollback Plan (If Needed)

If something goes wrong:

1. **Revert DNS:**
```bash
# Delete bpcheck-api, recreate bpcheck pointing to Railway
curl -X POST "https://api.name.com/v4/domains/servicevision.io/records" \
  -u "TEDTHERRIAULT:4790fea6e456f7fe9cf4f61a30f025acd63ecd1c" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "CNAME",
    "host": "bpcheck",
    "answer": "k5loed3p.up.railway.app",
    "ttl": 300
  }'
```

2. **Revert mobile app:**
```bash
# In .env files, change back to:
EXPO_PUBLIC_API_URL=https://bpcheck.servicevision.io/api
```

## Timeline

- **DNS Propagation**: 5-15 minutes
- **Railway SSL**: 5-15 minutes after DNS
- **Vercel Deployment**: 2-5 minutes
- **Vercel SSL**: 5-15 minutes after DNS
- **Total time**: ~20-30 minutes for everything

## Support

If issues arise:
- Check Railway logs: https://railway.com/project/48fc11cc-910d-43ee-a10b-07c455d16a3a
- Check Vercel deployment logs
- Verify DNS: `dig bpcheck-api.servicevision.io CNAME`
- Test API directly: `curl https://bpcheck-api.servicevision.io/api/authtest/health`
