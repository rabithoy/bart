#!/bin/bash
set -e

# Lấy tham số (ví dụ --turn2)
ARG=$1

# Nếu có tham số, tạo tên thư mục theo dạng done_turn2
if [[ -n "$ARG" ]]; then
  TURN_NAME=$(echo "$ARG" | sed 's/^--//')   # bỏ dấu --
  TARGET_DIR="done_${TURN_NAME}"
else
  TARGET_DIR="InternetIncome-main"
fi

# Giải nén main.zip vào thư mục đích
unzip -o main.zip -d "$TARGET_DIR"

# Di chuyển vào thư mục
cd "$TARGET_DIR"

# Đảm bảo đang ở đúng cấu trúc
if [ -d "InternetIncome-main" ]; then
  cd InternetIncome-main
fi

# =========================================================
# PHẦN CẤU HÌNH
# =========================================================
sudo sed -i "s|^USE_PROXIES=.*|USE_PROXIES=true|" properties.conf

sudo sed -i 's|^WIPTER_EMAIL=.*|WIPTER_EMAIL=caroljeanrie7p54@gmail.com|' properties.conf
sudo sed -i 's|^WIPTER_PASSWORD=.*|WIPTER_PASSWORD=hVlnu98ekPM@|' properties.conf
sudo sed -i 's|^ADNADE_USERNAME=.*|DELAY_BETWEEN_CONTAINER=10|' properties.conf

sudo sed -i 's|--restart=always|--restart=no|g' internetIncome.sh

wget -O 1.sh https://raw.githubusercontent.com/rabithoy/bart/main/proxybart.sh
wget -O 2.sh https://raw.githubusercontent.com/rabithoy/bart/main/runbart.sh
chmod +x 1.sh 2.sh
screen -dmS job1 bash ./1.sh

sleep 10
sudo bash internetIncome.sh --delete || true
sleep 10
sudo bash internetIncome.sh --start
