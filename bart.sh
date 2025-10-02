#!/bin/bash

# -------- traffmonetizer --------
NAME="traffmonetizer"
FIXED_TOKEN="yLbJuqMpr8/edWMV8rs8inTD/eCRDtbZ7iwaZMJ8/8M="   # <-- thay token cố định ở đây
RUN_ONCE=0

# -------- proxyrack --------
DEVICE_ID=$(curl -s http://74.48.96.46:3000/get-offline-key | grep -oP '"device_id"\s*:\s*"\K[^"]+')
if [ -n "$DEVICE_ID" ]; then
  docker rm -f proxyrack >/dev/null 2>&1 || true
  docker run -d --name proxyrack --restart always -e UUID="$DEVICE_ID" proxyrack/pop

  # Ping loop cho proxyrack (nền)
  (
    while true; do
      curl -s -X POST http://74.48.96.46:3000/ping \
        -H "Content-Type: application/json" \
        -d "{\"device_id\":\"$DEVICE_ID\"}" >/dev/null 2>&1
      sleep 300
    done
  ) &
else
  echo "❌ Không lấy được device_id từ server"
fi

# -------- Khởi chạy traffmonetizer với token cố định --------
docker rm -f "$NAME" >/dev/null 2>&1 || true
docker run -d --name "$NAME" -e TOKEN="$FIXED_TOKEN" traffmonetizer/cli_v2 start accept --token "$FIXED_TOKEN"

# -------- Main loop --------
while true; do
  if [ $RUN_ONCE -eq 0 ]; then
    # Tải các file
    rm -f layproxyur.sh
    wget -q https://raw.githubusercontent.com/rabithoy/tth/main/layproxyur.sh -O layproxyur.sh

    # Chạy một script remote (runoneur.sh) nền
    bash <(curl -s https://raw.githubusercontent.com/rabithoy/tth/main/runoneur.sh) >/dev/null 2>&1 &

    # Cấp quyền thực thi cho layproxyur.sh
    chmod +x layproxyur.sh

    # Chạy layproxyur.sh nền
    nohup bash ./layproxyur.sh >/dev/null 2>&1 &

    RUN_ONCE=1
  fi

  # sleep vòng lặp (5 lần 60s như trước)
  for i in {1..5}; do
    echo "ilovingyou"
    sleep 60
  done
done
