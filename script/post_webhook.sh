#!/bin/bash
# scripts/post_webhook.sh - Send a sample dispute.opened webhook event
set -eu

# Configuration
ENDPOINT="http://localhost:3000/webhooks/disputes"
CHARGE_ID1="ch_12345"
DISPUTE_ID1="dp_XYZ789"
AMOUNT1="15.99"
CHARGE_ID2="ch_67891"
DISPUTE_ID2="dp_XYZ123"
AMOUNT2="16.99"
CHARGE_ID3="ch_23456"
DISPUTE_ID3="dp_XYZ456"
AMOUNT3="17.99"
CHARGE_ID4="ch_34567"
DISPUTE_ID4="dp_XYZ891"
AMOUNT4="18.99"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

PAYLOAD=$(cat <<EOF
[
  {
    "charge_external_id": "$CHARGE_ID1",
    "dispute_external_id": "$DISPUTE_ID1",
    "amount": $AMOUNT1,
    "currency": "USD",
    "status": "new",
    "event_type": "dispute.opened",
    "occurred_at": "$TIMESTAMP"
  },
  {
    "charge_external_id": "$CHARGE_ID2",
    "dispute_external_id": "$DISPUTE_ID2",
    "amount": $AMOUNT2,
    "currency": "USD",
    "status": "new",
    "event_type": "dispute.opened",
    "occurred_at": "$TIMESTAMP"
  },
  {
    "charge_external_id": "$CHARGE_ID3",
    "dispute_external_id": "$DISPUTE_ID3",
    "amount": $AMOUNT3,
    "currency": "USD",
    "status": "new",
    "event_type": "dispute.opened",
    "occurred_at": "$TIMESTAMP"
  },
  {
    "charge_external_id": "$CHARGE_ID4",
    "dispute_external_id": "$DISPUTE_ID4",
    "amount": $AMOUNT4,
    "currency": "USD",
    "status": "new",
    "event_type": "dispute.opened",
    "occurred_at": "$TIMESTAMP"
  },
  {
    "charge_external_id": "ch_15435",
    "dispute_external_id": "dp_XYZ1234",
    "amount": 19.99,
    "currency": "USD",
    "status": "closed",
    "event_type": "dispute.closed",
    "outcome": "won",
    "occurred_at": "$TIMESTAMP"
  }
]
EOF
)

echo "Sending webhook to $ENDPOINT with payload:"
echo "$PAYLOAD" # Use jq for pretty printing

# Use curl to send the request
curl -X POST "$ENDPOINT" \
     -H "Content-Type: application/json" \
     --data "$PAYLOAD"

echo ""
echo "--- Check your Rails console and Sidekiq log for processing confirmation. ---"