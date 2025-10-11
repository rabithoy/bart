#!/bin/bash

while true; do
  # Lấy danh sách tất cả container wipter*, sorted theo tên
  CONTAINERS=$(sudo docker ps --format '{{.Names}}' | grep ^wipter | sort)

  for cname in $CONTAINERS; do
      echo "Restarting $cname at $(date)"
      sudo docker restart "$cname"
      sleep 180
  done
done
