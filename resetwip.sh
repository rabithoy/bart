#!/bin/bash

while true; do
  # Lấy danh sách tất cả container có prefix wipter, traff hoặc caster
  CONTAINERS=$(sudo docker ps --format '{{.Names}}' | grep -E '^(wipter|traff|caster)' | sort)

  for cname in $CONTAINERS; do
      echo "Restarting $cname at $(date)"
      sudo docker restart "$cname"
      sleep 100
  done
done
