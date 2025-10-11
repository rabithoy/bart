#!/bin/bash

LOG_FILE="/root/restart_wipter.log"

while true; do
  # Lấy danh sách container có tên bắt đầu bằng wipter, sắp xếp theo tên
  CONTAINERS=$(sudo docker ps --format '{{.Names}}' | grep ^wipter | sort)

  for cname in $CONTAINERS; do
      echo "Restarting $cname at $(date)" | tee -a "$LOG_FILE"
      sudo docker restart "$cname" >> "$LOG_FILE" 2>&1
      sleep 180
  done
done
