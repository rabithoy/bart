#!/bin/bash
SERVER="http://54.36.60.95:6789"
UPDATE_FILE="updateproxy.txt"
WORKER_ID=""

# Bước 1: Xin proxy
response=$(curl -s "$SERVER/request-proxy")
echo "$response" > "$UPDATE_FILE"

# Lấy workerId
WORKER_ID=$(echo "$response" | jq -r '.workerId')

# Bước 2: Ping định kỳ
while true; do
  curl -s -X POST "$SERVER/ping" \
    -H "Content-Type: application/json" \
    -d "{\"workerId\":\"$WORKER_ID\"}" >/dev/null
  sleep 300
done
