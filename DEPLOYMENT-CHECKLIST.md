# Railway Deployment Checklist

## Pre-Deployment

- [ ] Database BPCheckDB deployed and accessible
- [ ] All database tables and stored procedures created
- [ ] Clerk authentication configured
- [ ] Local testing completed successfully
- [ ] Git repository up to date

## Railway Setup

### 1. Create Railway Account
- [ ] Sign up at https://railway.app
- [ ] Connect GitHub account (if deploying via GitHub)

### 2. Deploy API to Railway

**Option A: GitHub Integration (Recommended)**
- [ ] Push code to GitHub repository
- [ ] Create new project in Railway
- [ ] Select "Deploy from GitHub repo"
- [ ] Choose blood-pressure-check repository
- [ ] Railway auto-detects Dockerfile in BloodPressureMonitor.API

**Option B: Railway CLI**
```bash
npm i -g @railway/cli
railway login
cd BloodPressureMonitor.API
railway init
railway up
```

### 3. Configure Environment Variables

In Railway Dashboard > Service > Variables, add:

- [ ] `ConnectionStrings__DefaultConnection`
  ```
  Server=sqltest.schoolvision.net,14333;Database=BPCheckDB;User Id=sv;Password=Gv51076!;TrustServerCertificate=True;Encrypt=Optional;MultipleActiveResultSets=true;Connection Timeout=30;
  ```

- [ ] `Clerk__SecretKey`
  ```
  sk_test_FhNc4QqwYOaGdZWScb2hub2ggJWEZCDeWPKVW5itm5
  ```

- [ ] `Clerk__Authority`
  ```
  https://lucky-lemur-31.clerk.accounts.dev
  ```

- [ ] `Clerk__Audience`
  ```
  https://lucky-lemur-31.clerk.accounts.dev
  ```

- [ ] `ASPNETCORE_ENVIRONMENT`
  ```
  Production
  ```

- [ ] `PORT`
  ```
  8080
  ```

### 4. Test Railway Deployment

- [ ] Wait for deployment to complete
- [ ] Note the Railway URL (e.g., `your-service.railway.app`)
- [ ] Test health endpoint:
  ```bash
  curl https://your-service.railway.app/api/authtest/health
  ```
- [ ] Verify response shows healthy status

## DNS Configuration

### 5. Add Custom Domain in Railway

- [ ] Go to Railway Dashboard > Service > Settings > Domains
- [ ] Click "Custom Domain"
- [ ] Enter: `bpcheck.servicevision.io`
- [ ] Copy the CNAME target (e.g., `your-service.up.railway.app`)

### 6. Configure DNS at Name.com

**Option A: Automated Script**
```bash
cd /mnt/d/Dev2/blood-pressure-check
./setup-dns.sh your-service.up.railway.app
```

**Option B: Manual via Name.com Dashboard**
- [ ] Login to https://www.name.com
- [ ] Go to My Domains > servicevision.io > DNS Records
- [ ] Add CNAME record:
  - Type: `CNAME`
  - Host: `bpcheck`
  - Answer: `your-service.up.railway.app`
  - TTL: `300`

**Option C: Via Name.com API**
```bash
curl -X POST "https://api.name.com/v4/domains/servicevision.io/records" \
  -u "TEDTHERRIAULT:4790fea6e456f7fe9cf4f61a30f025acd63ecd1c" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "CNAME",
    "host": "bpcheck",
    "answer": "your-service.up.railway.app",
    "ttl": 300
  }'
```

### 7. Verify DNS

- [ ] Wait 5-15 minutes for DNS propagation
- [ ] Check DNS resolution:
  ```bash
  nslookup bpcheck.servicevision.io
  # OR
  dig bpcheck.servicevision.io CNAME
  ```
- [ ] Verify it points to Railway CNAME target

### 8. Wait for SSL Certificate

- [ ] Railway automatically provisions Let's Encrypt SSL
- [ ] Usually takes 5-15 minutes after DNS propagates
- [ ] Check Railway dashboard for SSL status

### 9. Test Production Endpoint

- [ ] Test HTTPS endpoint:
  ```bash
  curl https://bpcheck.servicevision.io/api/authtest/health
  ```
- [ ] Verify healthy response
- [ ] Check Railway logs for any errors

## Mobile App Configuration

### 10. Update Mobile App for Production

- [ ] `.env.production` file already created with production URL
- [ ] Verify API URL: `https://bpcheck.servicevision.io/api`
- [ ] Test mobile app connection to production API

### 11. Build Production Mobile App

```bash
cd BloodPressureMonitor.Mobile

# For testing
npx expo start

# For production build (requires EAS)
eas build --platform android --profile production
eas build --platform ios --profile production
```

## Post-Deployment Verification

### 12. End-to-End Testing

- [ ] Register new user via mobile app
- [ ] Verify user created in production database
- [ ] Test login flow
- [ ] Test protected endpoints
- [ ] Verify JWT authentication working
- [ ] Test password reset flow

### 13. Database Verification

```bash
# Check users in production database
cmd.exe /c "sqlcmd -S sqltest.schoolvision.net,14333 -U sv -P Gv51076! -N -C -d BPCheckDB -Q \"SELECT UserId, ClerkUserId, Email, FirstName, LastName, CreatedDate FROM Users WHERE ClerkUserId IS NOT NULL\""
```

### 14. Monitor Logs

- [ ] Railway Dashboard > Deployments > View Logs
- [ ] Watch for authentication events
- [ ] Check for database connection issues
- [ ] Monitor API response times

## Production Hardening

### 15. Security Review

- [ ] All secrets configured via environment variables
- [ ] No secrets in source code
- [ ] HTTPS enforced (Railway auto-redirects)
- [ ] CORS properly configured
- [ ] Rate limiting enabled (configured in appsettings)

### 16. Monitoring Setup

- [ ] Set up uptime monitoring (UptimeRobot, Pingdom, etc.)
- [ ] Configure alerts for downtime
- [ ] Monitor Railway usage and costs
- [ ] Set up log aggregation if needed

### 17. Backup Strategy

- [ ] Database backup schedule (SQL Server backups)
- [ ] Document rollback procedure
- [ ] Test disaster recovery

## Cost Monitoring

### 18. Railway Costs

- [ ] Review Railway pricing dashboard
- [ ] Set up billing alerts
- [ ] Monitor resource usage
- [ ] Expected: $5-15/month

## Documentation

### 19. Update Documentation

- [ ] Document production URL
- [ ] Update API documentation
- [ ] Create runbook for common issues
- [ ] Document deployment process for team

## Rollback Plan

### 20. Prepare Rollback

- [ ] Document current deployment ID
- [ ] Test rollback procedure in Railway
- [ ] Keep previous working deployment available
- [ ] Document steps to revert DNS if needed

## Success Criteria

✅ API accessible at https://bpcheck.servicevision.io
✅ Health endpoint returns 200 OK
✅ Database connectivity working
✅ Clerk authentication functional
✅ Mobile app can register/login users
✅ SSL certificate active
✅ DNS resolving correctly
✅ Logs showing successful requests
✅ No errors in Railway logs

## Support Contacts

- **Railway Support**: https://discord.gg/railway
- **Name.com Support**: https://www.name.com/support
- **Clerk Support**: https://clerk.com/support
- **SQL Server**: Internal (sqltest.schoolvision.net)

## Next Steps After Deployment

1. [ ] Update Clerk production settings
2. [ ] Configure Clerk webhooks for production
3. [ ] Set up monitoring and alerts
4. [ ] Load testing
5. [ ] Performance optimization
6. [ ] Increase DNS TTL to 3600 after confirmed working
7. [ ] Submit mobile apps to app stores
