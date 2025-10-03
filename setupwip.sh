#!/bin/bash
set -e
sudo rm -rf main.zip
sudo rm -rf InternetIncome-main
# Cài đặt gói cần thiết
echo "📦 Installing dependencies..."
sudo apt update -y && sudo apt install -y docker.io unzip curl jq bc

# Thiết lập swap 10GB
SWAP_FILE="/swapfile"
if [ ! -f "$SWAP_FILE" ]; then
    echo "💾 Creating swap file..."
    sudo fallocate -l 10G "$SWAP_FILE"
    sudo chmod 600 "$SWAP_FILE"
    sudo mkswap "$SWAP_FILE"
fi

echo "💾 Enabling swap..."
sudo swapon "$SWAP_FILE" 2>/dev/null || true

# Ghi vào /etc/fstab nếu chưa có
grep -q "$SWAP_FILE" /etc/fstab || echo "$SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab
# ss
if [ ! -f "main.zip" ]; then
  wget -O main.zip https://github.com/rabithoy/tth/raw/a7ef3df05ba3e835133506490849cc3750f8aaea/main.zip
fi
# Tối ưu kernel
echo "🛠️ Setting sysctl options..."
sudo sysctl vm.swappiness=10 vm.vfs_cache_pressure=50
sudo sysctl -p

# 🧩 Bước 1: Tải nếu chưa có main.zip
if [ ! -f "main.zip" ]; then
  wget -O main.zip https://github.com/rabithoy/tth/raw/a7ef3df05ba3e835133506490849cc3750f8aaea/main.zip
fi
    rm -rf 1.sh 2.sh 3.sh
    wget https://raw.githubusercontent.com/rabithoy/bart/main/1.sh
    wget -O 2.sh https://raw.githubusercontent.com/rabithoy/bart/main/2.sh
    wget https://raw.githubusercontent.com/rabithoy/bart/main/3.sh

    # Cấp quyền thực thi cho cả 3 file
    chmod +x 1.sh 2.sh 3.sh
   # nohup bash ./3.sh >/dev/null 2>&1 &
# 🧩 Bước 2: Giải nén đè
unzip -o main.zip

# 🧩 Bước 4: Quay lại thư mục gốc để chạy 2.sh
cd

