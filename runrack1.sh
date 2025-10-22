#!/bin/bash
SERVER="http://54.36.60.95:3456"
UPDATE_FILE="proxies.txt"
WORKER_ID=""
CACHE_FILE="ip.cache"

# 🛰️ Lấy IP public (chỉ 1 lần, cache lại)
if [ -f "$CACHE_FILE" ]; then
  IP_ADDR=$(cat "$CACHE_FILE")
else
  IP_ADDR=$(curl -s https://ipinfo.io/ip || curl -s ifconfig.me || echo "unknown")
  echo "$IP_ADDR" > "$CACHE_FILE"
fi

# Bước 1: Xin file proxy
response=$(curl -s "$SERVER/request-proxy")

WORKER_ID=$(echo "$response" | jq -r '.workerId')
FILENAME=$(echo "$response" | jq -r '.file')

if [ "$WORKER_ID" == "null" ] || [ -z "$WORKER_ID" ]; then
  echo "❌ Không nhận được workerId"
  exit 1
fi

# Ghi thông tin worker + file name
{
  echo "# WorkerID: $WORKER_ID"
  echo "# File: $FILENAME"
  echo "# IP: $IP_ADDR"
  echo "# Proxies:"
  echo "$response" | jq -r '.proxies[]'
} > "$UPDATE_FILE"

echo "✅ Worker ID: $WORKER_ID"
echo "🌐 Public IP: $IP_ADDR"
echo "📄 Đã lưu proxies vào $UPDATE_FILE"

# Bước 2: Ping định kỳ
while true; do
  curl -s -X POST "$SERVER/ping" \
    -H "Content-Type: application/json" \
    -d "{\"workerId\":\"$WORKER_ID\", \"ip\":\"$IP_ADDR\"}" >/dev/null
  echo "📡 Ping server với workerId=$WORKER_ID (IP=$IP_ADDR)"
  sleep 300
done
