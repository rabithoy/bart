#!/bin/bash
SERVER="http://54.36.60.95:6789"
UPDATE_FILE="proxies.txt"
WORKER_ID=""

# Bước 1: Xin file proxy
response=$(curl -s "$SERVER/request-proxy")

# Lấy workerId
WORKER_ID=$(echo "$response" | jq -r '.workerId')
FILENAME=$(echo "$response" | jq -r '.file')

if [ "$WORKER_ID" == "null" ] || [ -z "$WORKER_ID" ]; then
  echo "❌ Không nhận được workerId"
  exit 1
fi

# Ghi thông tin worker + file name trước
{
  echo "# WorkerID: $WORKER_ID"
  echo "# File: $FILENAME"
  echo "# Proxies:"
  echo "$response" | jq -r '.proxies[]'
} > "$UPDATE_FILE"

echo "✅ Worker ID: $WORKER_ID"
echo "📄 Đã lưu proxies vào $UPDATE_FILE"

# Bước 2: Ping định kỳ
while true; do
  curl -s -X POST "$SERVER/ping" \
    -H "Content-Type: application/json" \
    -d "{\"workerId\":\"$WORKER_ID\"}" >/dev/null
  echo "📡 Ping server với workerId=$WORKER_ID"
  sleep 300
done
