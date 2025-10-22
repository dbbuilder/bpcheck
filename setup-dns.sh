#!/bin/bash
#================================================================================
# Name.com DNS Setup for bpcheck.servicevision.io
#================================================================================

# Name.com credentials
USERNAME="TEDTHERRIAULT"
TOKEN="4790fea6e456f7fe9cf4f61a30f025acd63ecd1c"
DOMAIN="servicevision.io"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "BPCheck DNS Configuration"
echo "========================================="
echo ""

# Check if Railway CNAME target is provided
if [ -z "$1" ]; then
    echo -e "${YELLOW}Usage: $0 <railway-cname-target>${NC}"
    echo ""
    echo "Example:"
    echo "  $0 your-service.up.railway.app"
    echo ""
    echo "To get your Railway CNAME target:"
    echo "  1. Go to Railway dashboard"
    echo "  2. Click your service > Settings > Domains"
    echo "  3. Add custom domain: bpcheck.servicevision.io"
    echo "  4. Copy the CNAME target provided"
    echo "  5. Run this script with that target"
    echo ""
    exit 1
fi

RAILWAY_CNAME="$1"

echo "Configuration:"
echo "  Domain: ${DOMAIN}"
echo "  Subdomain: bpcheck"
echo "  Target: ${RAILWAY_CNAME}"
echo ""

# Check if record already exists
echo "Checking for existing records..."
EXISTING=$(curl -s -u "${USERNAME}:${TOKEN}" \
    "https://api.name.com/v4/domains/${DOMAIN}/records" | \
    grep -o '"host":"bpcheck"')

if [ ! -z "$EXISTING" ]; then
    echo -e "${YELLOW}Warning: A record for 'bpcheck' already exists${NC}"
    echo "Please delete it first via Name.com dashboard or API"
    echo ""
    echo "To delete via API:"
    echo "  1. List records: curl -u \"${USERNAME}:${TOKEN}\" https://api.name.com/v4/domains/${DOMAIN}/records"
    echo "  2. Find the record ID for bpcheck"
    echo "  3. Delete: curl -X DELETE -u \"${USERNAME}:${TOKEN}\" https://api.name.com/v4/domains/${DOMAIN}/records/{id}"
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Create CNAME record
echo "Creating CNAME record..."
RESPONSE=$(curl -s -X POST "https://api.name.com/v4/domains/${DOMAIN}/records" \
    -u "${USERNAME}:${TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{
        \"type\": \"CNAME\",
        \"host\": \"bpcheck\",
        \"answer\": \"${RAILWAY_CNAME}\",
        \"ttl\": 300
    }")

# Check response
if echo "$RESPONSE" | grep -q '"id"'; then
    echo -e "${GREEN}✓ CNAME record created successfully${NC}"
    echo ""
    echo "Record details:"
    echo "$RESPONSE" | jq '.'
else
    echo -e "${RED}✗ Failed to create CNAME record${NC}"
    echo ""
    echo "Response:"
    echo "$RESPONSE" | jq '.'
    exit 1
fi

echo ""
echo "========================================="
echo "DNS Configuration Complete"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Wait 5-15 minutes for DNS propagation"
echo "  2. Verify DNS: nslookup bpcheck.servicevision.io"
echo "  3. Railway will auto-provision SSL certificate"
echo "  4. Test: curl https://bpcheck.servicevision.io/api/authtest/health"
echo ""
echo "Monitor DNS propagation:"
echo "  watch -n 10 nslookup bpcheck.servicevision.io"
echo ""
