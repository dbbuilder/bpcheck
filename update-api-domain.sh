#!/bin/bash
#================================================================================
# Update API Domain from bpcheck to bpcheck-api
#================================================================================

USERNAME="TEDTHERRIAULT"
TOKEN="4790fea6e456f7fe9cf4f61a30f025acd63ecd1c"
DOMAIN="servicevision.io"
OLD_SUBDOMAIN="bpcheck"
NEW_SUBDOMAIN="bpcheck-api"
RAILWAY_CNAME="k5loed3p.up.railway.app"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}Updating API Domain Configuration${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Step 1: Delete old bpcheck CNAME
echo -e "${YELLOW}Step 1: Removing old bpcheck CNAME...${NC}"
EXISTING_RECORDS=$(curl -s -u "${USERNAME}:${TOKEN}" \
    "https://api.name.com/v4/domains/${DOMAIN}/records")

OLD_RECORD_ID=$(echo "$EXISTING_RECORDS" | jq -r ".records[] | select(.host == \"${OLD_SUBDOMAIN}\") | .id")

if [ ! -z "$OLD_RECORD_ID" ]; then
    echo "Found old record ID: ${OLD_RECORD_ID}"
    DELETE_RESPONSE=$(curl -s -X DELETE \
        -u "${USERNAME}:${TOKEN}" \
        "https://api.name.com/v4/domains/${DOMAIN}/records/${OLD_RECORD_ID}")
    echo -e "${GREEN}✓ Old bpcheck record deleted${NC}"
else
    echo "No old record found (may have been deleted already)"
fi

echo ""

# Step 2: Create new bpcheck-api CNAME
echo -e "${YELLOW}Step 2: Creating bpcheck-api CNAME...${NC}"

CREATE_RESPONSE=$(curl -s -X POST \
    "https://api.name.com/v4/domains/${DOMAIN}/records" \
    -u "${USERNAME}:${TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{
        \"type\": \"CNAME\",
        \"host\": \"${NEW_SUBDOMAIN}\",
        \"answer\": \"${RAILWAY_CNAME}\",
        \"ttl\": 300
    }")

if echo "$CREATE_RESPONSE" | grep -q '"id"'; then
    echo -e "${GREEN}✓ bpcheck-api CNAME created successfully!${NC}"
    echo "$CREATE_RESPONSE" | jq '.'
else
    echo -e "${RED}✗ Failed to create CNAME${NC}"
    echo "$CREATE_RESPONSE" | jq '.'
    exit 1
fi

echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}DNS Update Complete!${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo "New API domain: ${NEW_SUBDOMAIN}.${DOMAIN}"
echo "Points to: ${RAILWAY_CNAME}"
echo ""
echo "Next steps:"
echo "1. Update Railway custom domain to: ${NEW_SUBDOMAIN}.${DOMAIN}"
echo "2. Update mobile app .env file"
echo "3. Wait for DNS propagation (5-15 min)"
echo "4. Set up Vercel for bpcheck.servicevision.io"
echo ""
