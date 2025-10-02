#!/bin/bash

SERVER="http://54.36.60.95:6666"
UPDATE_FILE="/home/cloudshell-user/updateproxy.txt"
COUNT=17

# ✅ Tạo tên worker duy nhất theo thời gian + UUID rút gọn
SDT="worker-$(date +%s)-$(uuidgen | cut -c1-8)"

# ✅ Hàm log có timestamp
log() {
  echo "[$(date '+%H:%M:%S')] $1"
}

log "🛠️ Worker $SDT khởi động..."

# ✅ Đảm bảo thư mục chứa update file tồn tại
mkdir -p "$(dirname "$UPDATE_FILE")"

# ✅ Vòng lặp để lấy proxy ban đầu đủ số lượng yêu cầu
while true; do
  log "📦 Đang lấy proxy từ server..."
  curl -s -X POST "$SERVER/request-proxies" \
    -H "Content-Type: application/json" \
    -d "{\"sdt\":\"$SDT\", \"count\":$COUNT}" |
    jq -r '.proxies[]' > proxies.txt

  PROXY_COUNT=$(wc -l < proxies.txt)
  log "✅ Nhận được $PROXY_COUNT proxy."

  if [ "$PROXY_COUNT" -lt "$COUNT" ]; then
    log "⚠️ Số lượng proxy chưa đủ ($PROXY_COUNT/$COUNT). Đợi 10 phút rồi thử lại..."
    sleep 600
  else
    break
  fi
done

# ✅ Lưu proxy lần đầu
cp proxies.txt "$UPDATE_FILE"
log "📝 Đã tạo $UPDATE_FILE"

# ✅ Gửi ping 2 phút/lần, gửi kèm proxy đang dùng
while true; do
  log "📶 Ping giữ kết nối cho $SDT..."

  # Đọc file proxy thành mảng JSON
  proxy_array=$(jq -Rs 'split("\n") | map(select(length > 0))' proxies.txt)

  # Gửi ping (retry 3 lần nếu lỗi mạng)
  res=$(curl -s --max-time 10 --retry 3 --retry-delay 3 -X POST "$SERVER/ping" \
    -H "Content-Type: application/json" \
    -d "{\"sdt\":\"$SDT\", \"proxies\":$proxy_array}")

  # Nếu server trả về updated = true thì cập nhật lại danh sách
  updated=$(echo "$res" | jq -r '.updated')

  if [ "$updated" = "true" ]; then
    log "♻️ Proxy bị thay, cập nhật lại..."
    echo "$res" | jq -r '.proxies[]' > proxies.txt
    cp proxies.txt "$UPDATE_FILE"
    log "📝 Đã cập nhật $UPDATE_FILE"
  fi

  sleep 120
done
