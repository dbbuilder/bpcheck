#!/bin/bash
#================================================================================
# Configure DNS for bpcheck.servicevision.io via Name.com API
#================================================================================

# Name.com credentials from user's CLAUDE.md
USERNAME="TEDTHERRIAULT"
TOKEN="4790fea6e456f7fe9cf4f61a30f025acd63ecd1c"
DOMAIN="servicevision.io"
SUBDOMAIN="bpcheck"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}BPCheck DNS Configuration via Name.com API${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Check if Railway CNAME is provided
if [ -z "$1" ]; then
    echo -e "${YELLOW}Usage: $0 <railway-cname-target>${NC}"
    echo ""
    echo "To get your Railway CNAME target:"
    echo "  1. Go to: https://railway.com/project/48fc11cc-910d-43ee-a10b-07c455d16a3a"
    echo "  2. Click on your service (after deployment)"
    echo "  3. Go to Settings > Domains"
    echo "  4. Click 'Custom Domain'"
    echo "  5. Enter: bpcheck.servicevision.io"
    echo "  6. Copy the CNAME target shown (e.g., xxx.up.railway.app)"
    echo "  7. Run: $0 <that-cname-target>"
    echo ""
    echo "Example:"
    echo "  $0 bpcheck-api-production.up.railway.app"
    echo ""
    exit 1
fi

RAILWAY_CNAME="$1"

echo "Configuration:"
echo "  Domain: ${DOMAIN}"
echo "  Subdomain: ${SUBDOMAIN}"
echo "  Full domain: ${SUBDOMAIN}.${DOMAIN}"
echo "  Target: ${RAILWAY_CNAME}"
echo ""

# Step 1: Check if record already exists
echo -e "${BLUE}Step 1: Checking for existing records...${NC}"
EXISTING_RECORDS=$(curl -s -u "${USERNAME}:${TOKEN}" \
    "https://api.name.com/v4/domains/${DOMAIN}/records")

# Check if bpcheck subdomain exists
EXISTING_BPCHECK=$(echo "$EXISTING_RECORDS" | grep -o "\"host\":\"${SUBDOMAIN}\"")

if [ ! -z "$EXISTING_BPCHECK" ]; then
    echo -e "${YELLOW}Warning: Record for '${SUBDOMAIN}' already exists${NC}"
    echo ""
    echo "Existing records for ${SUBDOMAIN}:"
    echo "$EXISTING_RECORDS" | jq ".records[] | select(.host == \"${SUBDOMAIN}\")"
    echo ""

    # Get the record ID
    RECORD_ID=$(echo "$EXISTING_RECORDS" | jq -r ".records[] | select(.host == \"${SUBDOMAIN}\") | .id")

    if [ ! -z "$RECORD_ID" ]; then
        echo -e "${YELLOW}Found existing record ID: ${RECORD_ID}${NC}"
        read -p "Delete existing record and create new one? (y/N) " -n 1 -r
        echo

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Deleting existing record..."
            DELETE_RESPONSE=$(curl -s -X DELETE \
                -u "${USERNAME}:${TOKEN}" \
                "https://api.name.com/v4/domains/${DOMAIN}/records/${RECORD_ID}")

            if echo "$DELETE_RESPONSE" | grep -q "{}"; then
                echo -e "${GREEN}✓ Existing record deleted${NC}"
            else
                echo -e "${RED}✗ Failed to delete existing record${NC}"
                echo "$DELETE_RESPONSE"
                exit 1
            fi
        else
            echo "Exiting without changes."
            exit 0
        fi
    fi
fi

# Step 2: Create CNAME record
echo ""
echo -e "${BLUE}Step 2: Creating CNAME record...${NC}"

CREATE_RESPONSE=$(curl -s -X POST \
    "https://api.name.com/v4/domains/${DOMAIN}/records" \
    -u "${USERNAME}:${TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{
        \"type\": \"CNAME\",
        \"host\": \"${SUBDOMAIN}\",
        \"answer\": \"${RAILWAY_CNAME}\",
        \"ttl\": 300
    }")

# Check if successful
if echo "$CREATE_RESPONSE" | grep -q '"id"'; then
    echo -e "${GREEN}✓ CNAME record created successfully!${NC}"
    echo ""
    echo "Record details:"
    echo "$CREATE_RESPONSE" | jq '.'
else
    echo -e "${RED}✗ Failed to create CNAME record${NC}"
    echo ""
    echo "Error response:"
    echo "$CREATE_RESPONSE" | jq '.'
    exit 1
fi

# Step 3: Verify the record
echo ""
echo -e "${BLUE}Step 3: Verifying DNS record...${NC}"
sleep 2

VERIFY_RESPONSE=$(curl -s -u "${USERNAME}:${TOKEN}" \
    "https://api.name.com/v4/domains/${DOMAIN}/records")

VERIFIED=$(echo "$VERIFY_RESPONSE" | jq ".records[] | select(.host == \"${SUBDOMAIN}\" and .answer == \"${RAILWAY_CNAME}\")")

if [ ! -z "$VERIFIED" ]; then
    echo -e "${GREEN}✓ DNS record verified in Name.com${NC}"
    echo "$VERIFIED" | jq '.'
else
    echo -e "${YELLOW}⚠ Could not immediately verify record (may take a moment)${NC}"
fi

echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}DNS Configuration Complete!${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo "Next steps:"
echo ""
echo "1. ${YELLOW}Wait for DNS propagation${NC} (5-15 minutes)"
echo "   Monitor with: watch -n 10 nslookup ${SUBDOMAIN}.${DOMAIN}"
echo ""
echo "2. ${YELLOW}Railway will auto-provision SSL${NC} (5-15 minutes after DNS)"
echo "   Check Railway dashboard for SSL status"
echo ""
echo "3. ${YELLOW}Test your API${NC}:"
echo "   curl https://${SUBDOMAIN}.${DOMAIN}/api/authtest/health"
echo ""
echo "4. ${YELLOW}Monitor DNS propagation${NC}:"
echo "   # Check CNAME"
echo "   dig ${SUBDOMAIN}.${DOMAIN} CNAME"
echo ""
echo "   # Check if resolving"
echo "   nslookup ${SUBDOMAIN}.${DOMAIN}"
echo ""
echo "   # Test SSL (will fail until certificate is provisioned)"
echo "   curl -I https://${SUBDOMAIN}.${DOMAIN}"
echo ""
echo -e "${GREEN}Setup complete!${NC} Your API will be available at:"
echo -e "${BLUE}https://${SUBDOMAIN}.${DOMAIN}${NC}"
echo ""
