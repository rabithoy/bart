#!/bin/bash
set -e
sudo rm -rf main.zip
sudo rm -rf InternetIncome-main
# Cài đặt 
sudo docker rmi -f $(sudo docker images -q) || true
# Cài đặt 
sudo docker rm -f $(sudo docker ps -aq) || true



# Cài đặt gói cần thiết
echo "📦 Installing dependencies..."
sudo apt update -y && sudo apt install -y unzip curl jq bc
if sudo docker ps &>/dev/null; then
  echo "✅ Docker đã hoạt động bình thường, bỏ qua cài đặt."
else
  echo "🐳 Docker chưa có hoặc chưa chạy — đang cài đặt..."
  sudo apt install -y docker.io
  echo "✅ Docker đã được cài và khởi động xong."
fi


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
# Tối ưu kernel
echo "🛠️ Setting sysctl options..."
sudo sysctl vm.swappiness=10 vm.vfs_cache_pressure=50
sudo sysctl -p

# 🧩 Bước 1: Tải nếu chưa có main.zip
if [ ! -f "main.zip" ]; then
  wget -O main.zip https://github.com/engageub/InternetIncome/archive/refs/heads/main.zip
fi
#111

unzip -o main.zip

cd InternetIncome-main
#
sudo sed -i "s|^USE_PROXIES=.*|USE_PROXIES=true|" properties.conf
sudo sed -i 's|^TRAFFMONETIZER_TOKEN=.*|TRAFFMONETIZER_TOKEN=Mu3hefwR2XsEoo3K+Kn+yFICzbJgNvdjezTN2FjrGIQ=|' properties.conf
wget -O 1.sh https://raw.githubusercontent.com/rabithoy/bart/main/runrack1.sh
wget -O 2.sh https://raw.githubusercontent.com/rabithoy/bart/main/runbart.sh
chmod +x 1.sh 2.sh
screen -dmS job1 bash ./1.sh

#
sleep 10
sudo bash internetIncome.sh --delete || true
sleep 10
#
sudo bash internetIncome.sh --start
