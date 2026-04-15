#!/usr/bin/env bash
set -euo pipefail

HOSTED_ZONE_ID="Z01237231H0TYJ8VRF1GJ"
RECORD_NAME="mcp.noah.space"
LOG_FILE="/home/nstolmaker/dev/closedclaude/ddns/ddns-update.log"
TTL=60

log() {
  echo "[$(date -u '+%Y-%m-%d %H:%M:%S UTC')] $*" | tee -a "$LOG_FILE"
}

# Get current WAN IP
CURRENT_IP=$(curl -sf https://checkip.amazonaws.com || curl -sf https://api4.my-ip.io/ip)
if [[ -z "$CURRENT_IP" ]]; then
  log "ERROR: Could not determine WAN IP"
  exit 1
fi

# Get IP currently in Route 53
DNS_IP=$(aws route53 list-resource-record-sets \
  --hosted-zone-id "$HOSTED_ZONE_ID" \
  --query "ResourceRecordSets[?Name=='${RECORD_NAME}.' && Type=='A'].ResourceRecords[0].Value" \
  --output text)

if [[ "$CURRENT_IP" == "$DNS_IP" ]]; then
  log "IP unchanged ($CURRENT_IP), no update needed"
  exit 0
fi

log "IP changed: $DNS_IP -> $CURRENT_IP, updating Route 53..."

aws route53 change-resource-record-sets \
  --hosted-zone-id "$HOSTED_ZONE_ID" \
  --change-batch "{
    \"Changes\": [{
      \"Action\": \"UPSERT\",
      \"ResourceRecordSet\": {
        \"Name\": \"$RECORD_NAME\",
        \"Type\": \"A\",
        \"TTL\": $TTL,
        \"ResourceRecords\": [{\"Value\": \"$CURRENT_IP\"}]
      }
    }]
  }"

log "Done. $RECORD_NAME now points to $CURRENT_IP"
