# Railway Project Setup - BPCheck

## Project Information
- **Project ID**: 48fc11cc-910d-43ee-a10b-07c455d16a3a
- **Project URL**: https://railway.com/project/48fc11cc-910d-43ee-a10b-07c455d16a3a
- **Project Name**: BPCheck

## Step 1: Deploy via Dashboard

Since you've already created the project, let's deploy via the Railway dashboard:

1. **Go to your project**: https://railway.com/project/48fc11cc-910d-43ee-a10b-07c455d16a3a

2. **Create a new service:**
   - Click "+ New"
   - Select "Empty Service"
   - Name it "bpcheck-api"

3. **Connect to GitHub:**
   - In the service, click "Settings"
   - Under "Source", click "Connect Repo"
   - Select your blood-pressure-check repository
   - Set Root Directory: `BloodPressureMonitor.API`
   - Railway will auto-detect the Dockerfile

4. **Or deploy directly:**
   - Click "Deploy"
   - Railway will build and deploy using the Dockerfile

## Step 2: Configure Environment Variables

In your service > Variables tab, add these:

```bash
ConnectionStrings__DefaultConnection=Server=sqltest.schoolvision.net,14333;Database=BPCheckDB;User Id=sv;Password=Gv51076!;TrustServerCertificate=True;Encrypt=Optional;MultipleActiveResultSets=true;Connection Timeout=30;

Clerk__SecretKey=sk_test_FhNc4QqwYOaGdZWScb2hub2ggJWEZCDeWPKVW5itm5

Clerk__Authority=https://lucky-lemur-31.clerk.accounts.dev

Clerk__Audience=https://lucky-lemur-31.clerk.accounts.dev

ASPNETCORE_ENVIRONMENT=Production

PORT=8080
```

## Step 3: Get Your Railway URL

After deployment, Railway will provide a URL like:
- `bpcheck-api-production.up.railway.app`
- Or similar format

You'll need this for DNS configuration.

## Step 4: Add Custom Domain

1. In Railway service > Settings > Domains
2. Click "Custom Domain"
3. Enter: `bpcheck.servicevision.io`
4. Railway will show you the CNAME target (usually ends with `.up.railway.app`)
5. Copy this CNAME target - you'll need it for the next step

## Step 5: Use the Script Below

Once you have the Railway CNAME target, I'll configure the DNS automatically.
