#!/bin/bash
SERVER="http://54.36.60.95:6789"
UPDATE_FILE="updateproxy.txt"
WORKER_ID=""

# Bước 1: Xin file proxy
response=$(curl -s "$SERVER/request-proxy")

# Lưu toàn bộ JSON để tiện debug
echo "$response" > "$UPDATE_FILE"

# Lấy workerId an toàn
WORKER_ID=$(echo "$response" | jq -r '.workerId')

if [ "$WORKER_ID" == "null" ] || [ -z "$WORKER_ID" ]; then
  echo "❌ Không nhận được workerId"
  exit 1
fi

echo "✅ Worker ID: $WORKER_ID"

# Bước 2: Ping định kỳ
while true; do
  curl -s -X POST "$SERVER/ping" \
    -H "Content-Type: application/json" \
    -d "{\"workerId\":\"$WORKER_ID\"}" >/dev/null
  echo "📡 Ping server với workerId=$WORKER_ID"
  sleep 300
done
