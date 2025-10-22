# Complete Railway Setup for BPCheck

## Your Railway Project
- **Project**: BPCheck
- **Project ID**: 48fc11cc-910d-43ee-a10b-07c455d16a3a
- **URL**: https://railway.com/project/48fc11cc-910d-43ee-a10b-07c455d16a3a

## Step-by-Step Deployment

### Step 1: Deploy via Railway Dashboard

Since `railway up` requires linking, let's use the dashboard:

1. **Open your project**:
   https://railway.com/project/48fc11cc-910d-43ee-a10b-07c455d16a3a

2. **Add a new service**:
   - Click the **"+ New"** button
   - Select **"GitHub Repo"** (if you've pushed to GitHub)
   - OR select **"Empty Service"** and we'll configure it

3. **If using GitHub**:
   - Connect your blood-pressure-check repository
   - Railway will scan for Dockerfile
   - Set **Root Directory**: `/BloodPressureMonitor.API`
   - Railway auto-detects the Dockerfile
   - Click **"Deploy"**

4. **If using Empty Service**:
   - After creating the service, go to Settings
   - Under "Source" click "Connect Repo"
   - Select your repository
   - Set root directory: `BloodPressureMonitor.API`

### Step 2: Configure Environment Variables

While deployment is running, configure variables:

1. Click on your service name
2. Go to **"Variables"** tab
3. Click **"New Variable"** or **"Raw Editor"**
4. Add these variables:

```
ConnectionStrings__DefaultConnection=Server=sqltest.schoolvision.net,14333;Database=BPCheckDB;User Id=sv;Password=Gv51076!;TrustServerCertificate=True;Encrypt=Optional;MultipleActiveResultSets=true;Connection Timeout=30;
Clerk__SecretKey=sk_test_FhNc4QqwYOaGdZWScb2hub2ggJWEZCDeWPKVW5itm5
Clerk__Authority=https://lucky-lemur-31.clerk.accounts.dev
Clerk__Audience=https://lucky-lemur-31.clerk.accounts.dev
ASPNETCORE_ENVIRONMENT=Production
PORT=8080
```

5. Click **"Save"** - Railway will redeploy with new variables

### Step 3: Get Your Railway URL

After successful deployment:

1. In your service view, look for the **"Deployments"** tab
2. Click on the latest deployment
3. You'll see a generated URL like:
   - `bpcheck-api-production.up.railway.app`
   - Or `xxx-xxx-xxx.up.railway.app`

4. **Test this URL**:
   ```bash
   curl https://your-service.up.railway.app/api/authtest/health
   ```

   Should return:
   ```json
   {"status":"healthy","message":"Blood Pressure Monitor API is running"}
   ```

### Step 4: Add Custom Domain in Railway

1. In your service, go to **Settings** tab
2. Scroll to **"Domains"** section
3. Click **"Custom Domain"**
4. Enter: `bpcheck.servicevision.io`
5. Railway will show you a **CNAME target**, like:
   - `bpcheck.up.railway.app`
   - Or similar format ending in `.up.railway.app`

6. **COPY THIS CNAME TARGET** - you'll need it for DNS!

### Step 5: Configure DNS via Name.com API

Now use the automated script I created:

```bash
cd /mnt/d/Dev2/blood-pressure-check

# Run the DNS configuration script with your Railway CNAME
./configure-dns-namecom.sh YOUR_RAILWAY_CNAME_HERE

# Example:
./configure-dns-namecom.sh bpcheck.up.railway.app
```

The script will:
- ✓ Check for existing DNS records
- ✓ Delete old records if needed (with confirmation)
- ✓ Create new CNAME record pointing to Railway
- ✓ Verify the record was created
- ✓ Show you next steps

**What it does behind the scenes**:
```bash
# Uses Name.com API with your credentials
# Username: TEDTHERRIAULT
# Token: 4790fea6e456f7fe9cf4f61a30f025acd63ecd1c
# Creates: bpcheck.servicevision.io -> your-railway-url
```

### Step 6: Wait for DNS Propagation

DNS takes 5-15 minutes to propagate globally.

**Monitor DNS propagation**:
```bash
# Watch for DNS updates (Ctrl+C to stop)
watch -n 10 nslookup bpcheck.servicevision.io

# Or check with dig
dig bpcheck.servicevision.io CNAME

# Windows PowerShell
while ($true) { nslookup bpcheck.servicevision.io; Start-Sleep 10 }
```

### Step 7: Wait for SSL Certificate

After DNS propagates, Railway automatically provisions SSL:

1. Takes 5-15 minutes after DNS is live
2. Railway uses Let's Encrypt
3. Check Railway dashboard for SSL status
4. Look for "SSL Certificate: Active" in Domains section

**Test SSL**:
```bash
# Will fail until SSL is provisioned
curl -I https://bpcheck.servicevision.io

# When working, you'll see:
# HTTP/2 200
# Or redirect from HTTP -> HTTPS
```

### Step 8: Verify Production Deployment

Once SSL is active:

```bash
# Test health endpoint
curl https://bpcheck.servicevision.io/api/authtest/health

# Expected response:
{
  "status": "healthy",
  "timestamp": "2025-10-22T...",
  "message": "Blood Pressure Monitor API is running"
}
```

### Step 9: Update Mobile App

The production environment file is ready:

**File**: `BloodPressureMonitor.Mobile/.env.production`
```bash
EXPO_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_bHVja3ktbGVtdXItMzEuY2xlcmsuYWNjb3VudHMuZGV2JA
CLERK_SECRET_KEY=sk_test_FhNc4QqwYOaGdZWScb2hub2ggJWEZCDeWPKVW5itm5
EXPO_PUBLIC_API_URL=https://bpcheck.servicevision.io/api
```

**To use in mobile app**:
```bash
cd BloodPressureMonitor.Mobile

# Development (uses .env)
npx expo start

# Production (uses .env.production) - requires EAS
eas build --platform android --profile production
```

### Step 10: Test End-to-End

1. **Register a new user** via mobile app
2. **Verify in database**:
   ```bash
   cmd.exe /c "sqlcmd -S sqltest.schoolvision.net,14333 -U sv -P Gv51076! -N -C -d BPCheckDB -Q \"SELECT UserId, ClerkUserId, Email, FirstName, LastName FROM Users WHERE ClerkUserId IS NOT NULL\""
   ```
3. **Test login** flow
4. **Monitor Railway logs** for authentication events

## Troubleshooting

### Issue: Railway CLI won't link

**Solution**: Use Railway dashboard instead
- Dashboard is more reliable for initial setup
- CLI can be configured later if needed

### Issue: Deployment failing

**Check Railway logs**:
1. Go to service > Deployments
2. Click on failed deployment
3. View build logs
4. Common issues:
   - Dockerfile path incorrect
   - Port configuration wrong
   - Environment variables missing

**Fix**:
- Ensure root directory is `BloodPressureMonitor.API`
- Verify Dockerfile exists at that path
- Check all environment variables are set

### Issue: Health check failing

**Check**:
1. Railway logs for errors
2. Database connectivity
3. Environment variables

**Test manually**:
```bash
# Use Railway's generated URL first
curl https://your-service.up.railway.app/api/authtest/health
```

### Issue: DNS not resolving

**Check**:
```bash
# See if CNAME exists
dig bpcheck.servicevision.io CNAME

# Check from different DNS servers
nslookup bpcheck.servicevision.io 8.8.8.8
nslookup bpcheck.servicevision.io 1.1.1.1
```

**Fix**:
- Wait longer (up to 1 hour for global propagation)
- Clear local DNS cache: `ipconfig /flushdns`
- Verify Name.com record is correct

### Issue: SSL not provisioning

**Causes**:
- DNS not pointing to Railway yet
- CAA records blocking Let's Encrypt
- Railway hasn't detected DNS yet

**Fix**:
1. Verify DNS with `dig bpcheck.servicevision.io CNAME`
2. Wait up to 30 minutes
3. Check Railway dashboard for SSL status
4. Contact Railway support if stuck

## Manual DNS Configuration (Backup Method)

If the script doesn't work, configure manually:

### Via Name.com Dashboard:
1. Go to https://www.name.com
2. Login
3. My Domains > servicevision.io > Manage
4. DNS Records tab
5. Add Record:
   - Type: CNAME
   - Host: bpcheck
   - Answer: [your-railway-cname]
   - TTL: 300

### Via Name.com API (Manual):
```bash
curl -X POST "https://api.name.com/v4/domains/servicevision.io/records" \
  -u "TEDTHERRIAULT:4790fea6e456f7fe9cf4f61a30f025acd63ecd1c" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "CNAME",
    "host": "bpcheck",
    "answer": "YOUR_RAILWAY_CNAME_HERE",
    "ttl": 300
  }'
```

## Monitoring

### Railway Dashboard:
- View logs in real-time
- Monitor resource usage
- Check deployment history
- View SSL certificate status

### External Monitoring:
Set up uptime monitoring (optional):
- UptimeRobot: https://uptimerobot.com
- Pingdom: https://www.pingdom.com
- StatusCake: https://www.statuscake.com

Monitor:
- `https://bpcheck.servicevision.io/api/authtest/health`
- Check every 5 minutes
- Alert if down > 5 minutes

## Cost Tracking

**Railway Hobby Plan**: $5/month
- Includes $5 usage credit
- Additional: ~$0.000231/GB-hour
- **Expected**: $5-15/month

**Monitor costs**:
1. Railway Dashboard > Project > Usage
2. Set up billing alerts
3. Review monthly usage

## Next Steps After Going Live

1. ✓ API deployed to Railway
2. ✓ DNS configured via Name.com
3. ✓ SSL certificate active
4. ✓ Health endpoint working
5. ✓ Mobile app configured

**Then**:
- [ ] Test full authentication flow
- [ ] Monitor Railway logs for errors
- [ ] Set up uptime monitoring
- [ ] Load testing
- [ ] Performance optimization
- [ ] Backup strategy
- [ ] Increase DNS TTL to 3600 (after confirmed working)

## Support

- **Railway**: https://discord.gg/railway
- **Railway Docs**: https://docs.railway.app
- **Name.com API**: https://www.name.com/api-docs
- **This project**: See RAILWAY-DEPLOYMENT.md for more details
