#!/bin/bash

SERVER="http://54.36.60.95:8887"
UPDATE_FILE="/home/cloudshell-user/updateproxy.txt"
COUNT=15

COOLDOWN=300
LAST_RESTART=0

# ✅ Tạo ID worker duy nhất
SDT="worker-$(date +%s)-$(uuidgen | cut -c1-8)"

log() { echo "[$(date '+%H:%M:%S')] $1"; }

log "🛠️ Worker $SDT khởi động..."

mkdir -p "$(dirname "$UPDATE_FILE")"

# =========================
# LẤY PROXY LẦN ĐẦU
# =========================
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

# =========================
# TẢI TOOL NẾU CHƯA CÓ
# =========================
[ ! -f "main.zip" ] && \
  wget -O main.zip https://github.com/rabithoy/tth/raw/a7ef3df05ba3e835133506490849cc3750f8aaea/main.zip && \
  unzip -o main.zip

cd InternetIncome-main || exit 1

# =========================
# CONFIG + START LẦN ĐẦU
# =========================
AUTH_CODE=$(curl -s "http://54.36.60.95:9876/get-auth" | jq -r '.auth_code')
sudo sed -i "s|^UR_AUTH_TOKEN=.*|UR_AUTH_TOKEN='$AUTH_CODE'|" properties.conf

sudo rm -rf traffmonetizerdata
sudo rm -f *.txt
sudo rm -rf resolv.conf

sudo sed -i "s|^USE_PROXIES=.*|USE_PROXIES=true|" properties.conf
sudo sed -i "s|^CASTAR_SDK_KEY=.*|CASTAR_SDK_KEY=cskLEggSnhicxN|" properties.conf

[ -f "$UPDATE_FILE" ] && cp "$UPDATE_FILE" proxies.txt

sudo bash internetIncome.sh --start

# =========================
# FUNCTION RESTART CASTAR
# =========================
restart_castar() {
  log "🔴 castar <= 1 → delete & restart..."

  cd InternetIncome-main || return

  sudo bash internetIncome.sh --delete

  AUTH_CODE=$(curl -s "http://54.36.60.95:9876/get-auth" | jq -r '.auth_code')
  sudo sed -i "s|^UR_AUTH_TOKEN=.*|UR_AUTH_TOKEN='$AUTH_CODE'|" properties.conf

  sudo bash internetIncome.sh --start
}

# =========================
# VÒNG LẶP PING + GIÁM SÁT
# =========================
while true; do
  log "📶 Ping giữ kết nối cho $SDT..."

  res=$(curl -s --max-time 10 --retry 3 --retry-delay 3 -X POST "$SERVER/ping" \
    -H "Content-Type: application/json" \
    -d "{\"sdt\":\"$SDT\", \"count\":$COUNT}")

  updated=$(echo "$res" | jq -r '.updated')

  if [ "$updated" = "true" ]; then
    added=$(echo "$res" | jq -r '.added')
    log "♻️ Server cấp thêm $added proxy, cập nhật lại..."

    echo "$res" | jq -r '.newProxies[]' >> proxies.txt
    sort -u proxies.txt -o proxies.txt
    cp proxies.txt "$UPDATE_FILE"
    log "📝 Đã cập nhật $UPDATE_FILE"
  fi

  # 🔍 KIỂM TRA CONTAINER CASTAR
  CASTAR_COUNT=$(docker ps --format '{{.Names}}' | grep -c '^castar')
  log "📦 castar đang chạy: $CASTAR_COUNT"

  NOW=$(date +%s)
  if [ "$CASTAR_COUNT" -le 1 ] && [ $((NOW - LAST_RESTART)) -gt $COOLDOWN ]; then
    restart_castar
    LAST_RESTART=$NOW
  fi

  sleep 120
done
