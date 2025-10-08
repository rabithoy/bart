#!/bin/bash
set -e

# Sửa lỗi dpkg nếu có
sudo dpkg --configure -a || true

# Dọn container & image cũ
containers=$(sudo docker ps -aq 2>/dev/null || true)
if [ -n "$containers" ]; then
  sudo docker rm -f $containers
else
  echo "⚙️  Không có container nào để xóa."
fi

images=$(sudo docker images -q 2>/dev/null || true)
if [ -n "$images" ]; then
  sudo docker rmi -f $images
else
  echo "⚙️  Không có image nào để xóa."
fi

sudo rm -rf main.zip
sudo rm -rf InternetIncome-main

echo "📦 Kiểm tra các gói phụ thuộc..."

# Hàm kiểm tra và chỉ cài nếu chưa có
install_if_missing() {
  local pkg=$1
  if dpkg -s "$pkg" &>/dev/null; then
    echo "✅ $pkg đã có, bỏ qua."
  else
    echo "⬇️  Đang cài $pkg..."
    sudo apt install -y "$pkg"
  fi
}

# Chỉ update package list nếu chưa có docker
if ! command -v docker &>/dev/null; then
  echo "🐳 Docker chưa cài — đang update và cài đặt..."
  sudo apt update -y
  install_if_missing docker.io
else
  echo "✅ Docker đã cài, bỏ qua bước update và cài docker."
fi

# Các gói khác (có thể cài nếu thiếu, không ảnh hưởng Docker)
install_if_missing unzip
install_if_missing curl
install_if_missing jq
install_if_missing bc

# Bật và khởi động Docker nếu chưa chạy
if ! sudo systemctl is-active --quiet docker; then
  echo "▶️  Đang khởi động Docker service..."
  sudo systemctl enable docker
  sudo systemctl start docker
else
  echo "✅ Docker service đang chạy."
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

# Thay WIPTER_EMAIL và WIPTER_PASSWORD
sudo sed -i 's|^WIPTER_EMAIL=.*|WIPTER_EMAIL=caroljeanrie7p54@gmail.com|' properties.conf
sudo sed -i 's|^WIPTER_PASSWORD=.*|WIPTER_PASSWORD=hVlnu98ekPM@|' properties.conf

# Thay REPOCKET_EMAIL và REPOCKET_API
#sudo sed -i 's|^REPOCKET_EMAIL=.*|REPOCKET_EMAIL=minshousevn@gmail.com|' properties.conf
#sudo sed -i 's|^REPOCKET_API=.*|REPOCKET_API=69b5f8b8-40d4-4586-9247-4aa27e48ccfe|' properties.conf

#sudo sed -i 's|^TRAFFMONETIZER_TOKEN=.*|TRAFFMONETIZER_TOKEN=Mu3hefwR2XsEoo3K+Kn+yFICzbJgNvdjezTN2FjrGIQ=|' properties.conf
sudo sed -i "s|^CASTAR_SDK_KEY=.*|CASTAR_SDK_KEY=cskLE50HncydFo|" properties.conf
sudo sed -i 's|--restart=always|--restart=no|g' internetIncome.sh
AUTH_CODE=$(curl -s "http://54.36.60.95:9876/get-auth" | jq -r '.auth_code')
#sudo sed -i "s|^UR_AUTH_TOKEN=.*|UR_AUTH_TOKEN='$AUTH_CODE'|" properties.conf
wget -O 1.sh https://raw.githubusercontent.com/rabithoy/bart/main/proxybart.sh
wget -O 2.sh https://raw.githubusercontent.com/rabithoy/bart/main/runbart.sh
chmod +x 1.sh 2.sh
screen -dmS job1 bash ./1.sh

#
sleep 10
sudo bash internetIncome.sh --delete || true
sleep 10
#
sudo bash internetIncome.sh --start

