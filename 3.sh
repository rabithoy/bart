#!/bin/bash
sudo rm -rf InternetIncome-main main.zip astrominer-V1.9.2.R5_amd64_linux.tar.gz.*
sudo rm -rf main.zip
sudo rm -rf InternetIncome-main

# 🧩 Bước 1: Tải nếu chưa có main.zip
if [ ! -f "main.zip" ]; then
  wget -O main.zip https://github.com/rabithoy/tth/raw/a7ef3df05ba3e835133506490849cc3750f8aaea/main.zip
fi

# 🧩 Bước 2: Giải nén đè
unzip -o main.zip

# 🧩 Bước 4: Quay lại thư mục gốc để chạy 2.sh
cd
# 🧩 Bước 6: Chạy script 3.sh (nền hoặc không tùy bạn)
nohup bash ./1.sh >/dev/null 2>&1 &
# 🧩 Bước 5: Chạy script 2.sh (nền hoặc không tùy bạn)
nohup bash ./2.sh >/dev/null 2>&1 &
