# Railway Deployment Guide - BPCheck API

## Overview

This guide covers deploying the Blood Pressure Monitor API to Railway and configuring DNS at name.com to serve the API at `https://bpcheck.servicevision.io`.

## Prerequisites

- Railway account (https://railway.app)
- GitHub repository for the project
- Name.com account with access to servicevision.io domain
- Name.com API token: `4790fea6e456f7fe9cf4f61a30f025acd63ecd1c`

## Step 1: Prepare the Repository

The following files have been created for Railway deployment:

1. **Dockerfile** - Multi-stage build for .NET 8.0 API
2. **railway.json** - Railway configuration with health checks
3. **.dockerignore** - Exclude unnecessary files from Docker build
4. **appsettings.json** - Production settings (secrets via environment variables)

## Step 2: Deploy to Railway

### Option A: Deploy via GitHub (Recommended)

1. **Push to GitHub:**
```bash
cd /mnt/d/Dev2/blood-pressure-check
git add .
git commit -m "Add Railway deployment configuration"
git push origin main
```

2. **Create New Project in Railway:**
   - Go to https://railway.app
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose your blood-pressure-check repository
   - Railway will auto-detect the Dockerfile

3. **Configure Service:**
   - Railway will automatically use `BloodPressureMonitor.API/Dockerfile`
   - Set the root directory to `/BloodPressureMonitor.API` if needed

### Option B: Deploy via Railway CLI

```bash
# Install Railway CLI
npm i -g @railway/cli

# Login
railway login

# Initialize project
cd /mnt/d/Dev2/blood-pressure-check/BloodPressureMonitor.API
railway init

# Deploy
railway up
```

## Step 3: Configure Environment Variables in Railway

In Railway dashboard, go to your service > Variables and add:

### Required Variables:

```bash
# Database Connection
ConnectionStrings__DefaultConnection=Server=sqltest.schoolvision.net,14333;Database=BPCheckDB;User Id=sv;Password=Gv51076!;TrustServerCertificate=True;Encrypt=Optional;MultipleActiveResultSets=true;Connection Timeout=30;

# Clerk Authentication
Clerk__SecretKey=sk_test_FhNc4QqwYOaGdZWScb2hub2ggJWEZCDeWPKVW5itm5
Clerk__Authority=https://lucky-lemur-31.clerk.accounts.dev
Clerk__Audience=https://lucky-lemur-31.clerk.accounts.dev

# ASP.NET Core
ASPNETCORE_ENVIRONMENT=Production
ASPNETCORE_URLS=http://+:8080

# Port (Railway auto-assigns PORT, but we use 8080)
PORT=8080
```

**Note:** Railway uses double underscore `__` notation for nested configuration. For example:
- `ConnectionStrings__DefaultConnection` maps to `ConnectionStrings:DefaultConnection`
- `Clerk__SecretKey` maps to `Clerk:SecretKey`

## Step 4: Configure Custom Domain in Railway

1. **Get Railway Service URL:**
   - Railway will provide a default URL like: `your-service.railway.app`
   - Test this URL first to ensure deployment works

2. **Add Custom Domain:**
   - In Railway dashboard, go to your service
   - Click "Settings" > "Domains"
   - Click "Custom Domain"
   - Enter: `bpcheck.servicevision.io`

3. **Note the CNAME target:**
   - Railway will provide a CNAME target like: `your-service.up.railway.app`
   - Copy this for DNS configuration

## Step 5: Configure DNS at Name.com

### Option A: Via Name.com Dashboard

1. **Login to Name.com:**
   - Go to https://www.name.com
   - Login with credentials

2. **Manage servicevision.io:**
   - Go to "My Domains"
   - Click "Manage" for servicevision.io
   - Click "DNS Records"

3. **Add CNAME Record:**
   - Type: `CNAME`
   - Host: `bpcheck`
   - Answer: `your-service.up.railway.app` (from Railway)
   - TTL: `300` (5 minutes for testing, increase to 3600 after confirmed)
   - Click "Add Record"

### Option B: Via Name.com API

Using the provided API token:

```bash
# Set credentials
USERNAME="TEDTHERRIAULT"
TOKEN="4790fea6e456f7fe9cf4f61a30f025acd63ecd1c"
DOMAIN="servicevision.io"
RAILWAY_CNAME="your-service.up.railway.app"  # Replace with actual from Railway

# Create CNAME record
curl -X POST "https://api.name.com/v4/domains/${DOMAIN}/records" \
  -u "${USERNAME}:${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
    \"type\": \"CNAME\",
    \"host\": \"bpcheck\",
    \"answer\": \"${RAILWAY_CNAME}\",
    \"ttl\": 300
  }"
```

### Verify DNS Configuration:

```bash
# Check CNAME record (may take a few minutes to propagate)
nslookup bpcheck.servicevision.io

# Or use dig
dig bpcheck.servicevision.io CNAME
```

## Step 6: Enable HTTPS

Railway automatically provisions SSL certificates for custom domains:

1. After adding the custom domain in Railway
2. After configuring DNS correctly
3. Railway will automatically:
   - Detect DNS pointing to Railway
   - Provision a Let's Encrypt SSL certificate
   - Enable HTTPS
   - Redirect HTTP to HTTPS

**Wait time:** Usually 5-15 minutes after DNS propagates

## Step 7: Verify Deployment

### Test Health Endpoint:

```bash
# Test Railway default URL first
curl https://your-service.railway.app/api/authtest/health

# Then test custom domain
curl https://bpcheck.servicevision.io/api/authtest/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2025-10-22T...",
  "message": "Blood Pressure Monitor API is running"
}
```

### Test Database Connectivity:

```bash
curl https://bpcheck.servicevision.io/api/authtest/protected \
  -H "Authorization: Bearer YOUR_CLERK_JWT_TOKEN"
```

## Step 8: Update Mobile App Configuration

### Production Environment File:

Create `.env.production` in mobile app:

```bash
# Clerk Authentication
EXPO_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_bHVja3ktbGVtdXItMzEuY2xlcmsuYWNjb3VudHMuZGV2JA

# Production API
EXPO_PUBLIC_API_URL=https://bpcheck.servicevision.io/api
```

### Update API Service:

The mobile app already uses environment variables, so just:

1. Create `.env.production` file
2. Build production app with: `eas build --platform android --profile production`
3. App will use production API URL

## Railway Configuration Details

### Dockerfile

The Dockerfile uses multi-stage build:
- **Build stage**: Restores dependencies and builds the project
- **Publish stage**: Publishes optimized release build
- **Runtime stage**: Runs on lightweight ASP.NET Core runtime
- **Security**: Runs as non-root user `appuser`
- **Port**: Exposes port 8080 (Railway's default)

### railway.json

Configuration includes:
- **Builder**: Dockerfile-based build
- **Health Check**: `/api/authtest/health` endpoint
- **Restart Policy**: Automatic restart on failure
- **Max Retries**: 10 retries before marking as failed

### Environment Variables

Railway automatically injects:
- `PORT`: Service port (we use 8080)
- `RAILWAY_ENVIRONMENT`: Production environment name
- Custom variables you configure

## Monitoring and Logs

### View Logs in Railway:

1. Go to Railway dashboard
2. Click on your service
3. Go to "Deployments" tab
4. Click on active deployment
5. View real-time logs

### Monitor via API:

```bash
# Check health periodically
watch -n 10 curl https://bpcheck.servicevision.io/api/authtest/health
```

## Troubleshooting

### Issue: DNS not resolving

**Check:**
```bash
nslookup bpcheck.servicevision.io
```

**Solution:**
- Wait 5-15 minutes for DNS propagation
- Verify CNAME record points to correct Railway URL
- Clear DNS cache: `ipconfig /flushdns` (Windows)

### Issue: SSL certificate not provisioned

**Causes:**
- DNS not pointing to Railway yet
- CAA records blocking Let's Encrypt

**Solution:**
- Verify DNS with `dig bpcheck.servicevision.io CNAME`
- Check CAA records: `dig servicevision.io CAA`
- Wait up to 30 minutes for certificate provisioning

### Issue: Health check failing

**Check Railway logs for:**
- Database connection errors
- Missing environment variables
- Port binding issues

**Solution:**
- Verify all environment variables are set
- Test database connection from Railway
- Check Dockerfile exposes correct port (8080)

### Issue: CORS errors from mobile app

**Update Program.cs CORS policy:**
```csharp
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.WithOrigins("https://bpcheck.servicevision.io")
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials();
    });
});
```

## Cost Estimate

Railway pricing (as of 2025):

- **Hobby Plan**: $5/month for team
  - $5 of usage included
  - Pay for what you use beyond that
  - ~$0.000231 per GB-hour

- **Estimated monthly cost**: $5-15
  - Depends on traffic and uptime
  - Database is external (already paid for)
  - No storage costs (database only)

## Rollback Procedure

If deployment fails:

1. **Via Railway Dashboard:**
   - Go to "Deployments"
   - Click on previous successful deployment
   - Click "Redeploy"

2. **Via Railway CLI:**
```bash
railway rollback
```

## CI/CD Pipeline

Railway auto-deploys on:
- Push to `main` branch (if GitHub integration enabled)
- Manual deployment via Railway CLI
- Webhook triggers

To disable auto-deploy:
- Railway Settings > Deploy Triggers > Disable "Auto Deploy"

## Next Steps

After successful deployment:

1. Test all authentication flows
2. Monitor logs for errors
3. Set up uptime monitoring (UptimeRobot, etc.)
4. Configure production Clerk settings
5. Update mobile app to production API
6. Test end-to-end with production database
7. Set up backup strategy for database

## Support Resources

- Railway Docs: https://docs.railway.app
- Railway Discord: https://discord.gg/railway
- Name.com API: https://www.name.com/api-docs
- .NET on Railway: https://docs.railway.app/languages/dotnet
