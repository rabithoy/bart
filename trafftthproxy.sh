#!/bin/bash

SERVER="http://142.171.114.6:8888"
UPDATE_FILE="/home/cloudshell-user/updateproxy.txt"
COUNT=20

# ✅ Tạo ID worker duy nhất
SDT="worker-$(date +%s)-$(uuidgen | cut -c1-8)"

log() { echo "[$(date '+%H:%M:%S')] $1"; }

log "🛠️ Worker $SDT khởi động..."

mkdir -p "$(dirname "$UPDATE_FILE")"

# ✅ Lấy proxy lần đầu
while true; do
  log "📦 Đang lấy proxy từ server..."
  curl -s -X POST "$SERVER/request-proxies" \
    -H "Content-Type: application/json" \
    -d "{\"sdt\":\"$SDT\", \"count\":$COUNT}" |
    jq -r '.proxies[]' > proxies.txt

  PROXY_COUNT=$(wc -l < proxies.txt)
  log "✅ Nhận được $PROXY_COUNT proxy."

  if [ "$PROXY_COUNT" -lt "$COUNT" ]; then
    log "⚠️ Còn thiếu ($PROXY_COUNT/$COUNT). Đợi 10 phút rồi thử lại..."
    sleep 600
  else
    break
  fi
done

cp proxies.txt "$UPDATE_FILE"
log "📝 Đã tạo $UPDATE_FILE"

# Tải & giải nén nếu chưa có
[ ! -f "main.zip" ] && wget -O main.zip https://github.com/rabithoy/tth/raw/a7ef3df05ba3e835133506490849cc3750f8aaea/main.zip && unzip -o main.zip

cd InternetIncome-main || exit 1

sudo rm -rf traffmonetizerdata
sudo rm -f *.txt
sudo rm -rf resolv.conf
sudo sed -i "s|^USE_PROXIES=.*|USE_PROXIES=true|" properties.conf
sudo sed -i "s|^CASTAR_SDK_KEY=.*|CASTAR_SDK_KEY=cskLEggSnhicxN|" properties.conf
sudo sed -i 's|^TRAFFMONETIZER_TOKEN=.*|TRAFFMONETIZER_TOKEN=yp9vtOAuQU9wzrXLQtMajunEkEKTsozGNa1m8md/Ksc=|' properties.conf

[ -f "/home/cloudshell-user/updateproxy.txt" ] && cp /home/cloudshell-user/updateproxy.txt proxies.txt

sudo bash internetIncome.sh --start

# ✅ Light Ping – không gửi danh sách proxy
while true; do
  log "📶 Ping giữ kết nối cho $SDT..."

  res=$(curl -s --max-time 10 --retry 3 --retry-delay 3 -X POST "$SERVER/ping" \
    -H "Content-Type: application/json" \
    -d "{\"sdt\":\"$SDT\", \"count\":$COUNT}")

  updated=$(echo "$res" | jq -r '.updated')

  # Nếu server cấp thêm proxy do thiếu
  if [ "$updated" = "true" ]; then
    added=$(echo "$res" | jq -r '.added')
    log "♻️ Server cấp thêm $added proxy, cập nhật lại..."

    echo "$res" | jq -r '.newProxies[]' >> proxies.txt
    sort -u proxies.txt -o proxies.txt
    cp proxies.txt "$UPDATE_FILE"
    log "📝 Đã cập nhật $UPDATE_FILE"
  fi

  sleep 120
done
