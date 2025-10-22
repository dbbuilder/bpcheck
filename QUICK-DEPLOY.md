# Quick Deploy Guide - 5 Minutes to Production

This is the fastest path to get your API live at `https://bpcheck.servicevision.io`.

## Prerequisites

- Railway account: https://railway.app (sign up takes 30 seconds)
- GitHub repository with your code
- Name.com credentials (already have: TEDTHERRIAULT / token on file)

## Step 1: Deploy to Railway (2 minutes)

### Via Railway Dashboard:

1. Go to https://railway.app
2. Click **"New Project"**
3. Select **"Deploy from GitHub repo"**
4. Choose your repository
5. Railway auto-detects the Dockerfile
6. Wait for build to complete (~2 minutes)

### Quick CLI Method:

```bash
# Install Railway CLI
npm i -g @railway/cli

# Deploy
cd /mnt/d/Dev2/blood-pressure-check/BloodPressureMonitor.API
railway login
railway init
railway up
```

## Step 2: Add Environment Variables (1 minute)

In Railway Dashboard > Your Service > Variables, paste this:

```bash
ConnectionStrings__DefaultConnection=Server=sqltest.schoolvision.net,14333;Database=BPCheckDB;User Id=sv;Password=Gv51076!;TrustServerCertificate=True;Encrypt=Optional;MultipleActiveResultSets=true;Connection Timeout=30;

Clerk__SecretKey=sk_test_FhNc4QqwYOaGdZWScb2hub2ggJWEZCDeWPKVW5itm5

Clerk__Authority=https://lucky-lemur-31.clerk.accounts.dev

Clerk__Audience=https://lucky-lemur-31.clerk.accounts.dev

ASPNETCORE_ENVIRONMENT=Production

PORT=8080
```

**Tip**: Copy each line, Railway will parse `KEY=VALUE` format automatically.

## Step 3: Test Railway URL (30 seconds)

Railway gives you a URL like: `your-service-name.up.railway.app`

Test it:
```bash
curl https://your-service-name.up.railway.app/api/authtest/health
```

Should return: `{"status":"healthy",...}`

## Step 4: Configure Custom Domain (1 minute)

### In Railway:
1. Service > Settings > **Domains**
2. Click **"Custom Domain"**
3. Enter: `bpcheck.servicevision.io`
4. Copy the CNAME target (e.g., `your-service.up.railway.app`)

### Set DNS (automated):

```bash
cd /mnt/d/Dev2/blood-pressure-check
./setup-dns.sh your-service.up.railway.app
```

**OR manually** via Name.com:
- Login → servicevision.io → DNS Records
- Add CNAME: `bpcheck` → `your-service.up.railway.app`

## Step 5: Wait for SSL (5-15 minutes)

Railway automatically provisions SSL certificate after DNS propagates.

Check status:
```bash
# Monitor DNS
watch -n 10 nslookup bpcheck.servicevision.io

# Test HTTPS (will fail until SSL is ready)
curl https://bpcheck.servicevision.io/api/authtest/health
```

## Done!

Once SSL is active:
```bash
curl https://bpcheck.servicevision.io/api/authtest/health
```

Should return: `{"status":"healthy","message":"Blood Pressure Monitor API is running"}`

## Update Mobile App

The production environment file is already created:

```bash
# BloodPressureMonitor.Mobile/.env.production
EXPO_PUBLIC_API_URL=https://bpcheck.servicevision.io/api
```

Just rebuild your mobile app and it will use production API.

## Troubleshooting

**Health check failing?**
- Check Railway logs for errors
- Verify all environment variables are set
- Test database connection from Railway

**DNS not resolving?**
- Wait 15 minutes for propagation
- Clear DNS cache: `ipconfig /flushdns`
- Verify CNAME: `dig bpcheck.servicevision.io CNAME`

**SSL certificate not provisioning?**
- Ensure DNS is pointing to Railway (check with dig/nslookup)
- Wait up to 30 minutes
- Check Railway dashboard for SSL status

## Cost

**Railway Hobby Plan**: $5/month
- Includes $5 credit
- Additional usage: ~$0.000231/GB-hour
- **Expected cost**: $5-15/month

## Full Documentation

For detailed guides, see:
- `RAILWAY-DEPLOYMENT.md` - Complete deployment guide
- `DEPLOYMENT-CHECKLIST.md` - Step-by-step checklist
- `TESTING-GUIDE.md` - Local testing instructions

## Get Help

- Railway Discord: https://discord.gg/railway
- Railway Docs: https://docs.railway.app
