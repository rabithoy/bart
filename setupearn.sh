#!/bin/bash
set -e

# 🧩 Bước 1: Tải nếu chưa có main.zip
if [ ! -f "main.zip" ]; then
  wget -O main.zip https://github.com/engageub/InternetIncome/archive/refs/heads/main.zip
fi

# 🧩 Bước 2: Kiểm tra xem thư mục đã tồn tại chưa
if [ ! -d "earn/InternetIncome-main" ]; then
    echo "📦 Giải nén main.zip vào earn/ ..."
    unzip -o main.zip -d earn
else
    echo "✅ Thư mục earn/InternetIncome-main đã tồn tại, bỏ qua bước giải nén."
fi

# 🧩 Bước 3: Vào thư mục mới
cd earn/InternetIncome-main

sudo sed -i "s|^USE_PROXIES=.*|USE_PROXIES=true|" properties.conf
sudo sed -i 's|^EARNAPP=.*|EARNAPP=true|' properties.conf
