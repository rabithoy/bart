#!/bin/bash

# 🔹 Token cố định
FIXED_TOKEN="Mu3hefwR2XsEoo3K+Kn+yFICzbJgNvdjezTN2FjrGIQ="   # thay token thật vào đây

while true; do
  echo "🔑 Đang dùng token cố định: $FIXED_TOKEN"

  # Đảm bảo thư mục tồn tại trước khi làm việc
  if [ ! -d "InternetIncome-main" ]; then
    echo "❌ Không tìm thấy thư mục InternetIncome-main. Thoát..."
    exit 1
  fi

  cd InternetIncome-main

  # Cập nhật proxy nếu có file update
  PROXY_UPDATE_FILE="/home/cloudshell-user/updateproxy.txt"
  HAS_PROXY_UPDATE=false

  if [ -f "$PROXY_UPDATE_FILE" ]; then
    echo "📂 Tìm thấy file update proxy: $PROXY_UPDATE_FILE"
    cp "$PROXY_UPDATE_FILE" proxies.txt
    echo "✅ Đã cập nhật proxies.txt từ $PROXY_UPDATE_FILE"
    rm -f "$PROXY_UPDATE_FILE"
    HAS_PROXY_UPDATE=true
  fi

  # Kiểm tra proxy có đủ dòng không
  LINE_COUNT=$(wc -l < proxies.txt)
  if [ "$LINE_COUNT" -lt 5 ]; then
    echo "⚠️ proxies.txt có ít hơn 5 dòng ($LINE_COUNT dòng), chờ 2 phút..."
    cd ..
    sleep 120
    continue
  fi

  # Luôn giữ token cố định
  CURRENT_TOKEN=$(sed -n 's/^TRAFFMONETIZER_TOKEN=//p' properties.conf | tr -d '\r')
  if [ "$CURRENT_TOKEN" != "$FIXED_TOKEN" ]; then
    echo "🔄 Token trong file khác với FIXED_TOKEN → cập nhật"
    sudo sed -i "s|^TRAFFMONETIZER_TOKEN=.*|TRAFFMONETIZER_TOKEN=$FIXED_TOKEN|" properties.conf
  fi

  sudo sed -i "s|^USE_PROXIES=.*|USE_PROXIES=true|" properties.conf
  sudo sed -i "s|^CASTAR_SDK_KEY=.*|CASTAR_SDK_KEY=cskLE50HncydFo|" properties.conf

  # Kiểm tra container
  CONTAINER_RUNNING=$(sudo docker ps -q)
  CONTAINER_COUNT=$(echo "$CONTAINER_RUNNING" | wc -l)

  if [ "$CONTAINER_COUNT" -ge 4 ]; then
    echo "🐳 Có $CONTAINER_COUNT container đang chạy"

    if [ "$HAS_PROXY_UPDATE" = true ]; then
      echo "🔁 Proxy thay đổi → restart container"
      sudo docker ps -q | sudo xargs -n1 docker update --restart=no
      sudo bash internetIncome.sh --delete
      sleep 10
      sudo rm -rf traffmonetizerdata resolv.conf
      sleep 2
      sudo bash internetIncome.sh --start
      sleep 60
    else
      echo "✅ Proxy không đổi → giữ nguyên container"
    fi
  else
    echo "⚠️ Có ít hơn 4 container đang chạy ($CONTAINER_COUNT) → start mới"
    sudo rm -rf traffmonetizerdata resolv.conf
    sleep 2
    sudo bash internetIncome.sh --start
    sleep 20
  fi

  echo "⏳ Chờ 2 phút trước vòng ping tiếp theo..."
  sleep 120
  cd
done
