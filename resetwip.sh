#!/bin/bash

while true; do
  # Lấy danh sách tất cả container có prefix wipter, traff hoặc caster
  CONTAINERS=$(sudo docker ps --format '{{.Names}}' | grep -E '^(traff|proxyrack
  wipter)' | sort)

  for cname in $CONTAINERS; do
      echo "Restarting $cname at $(date)"
      sudo docker restart "$cname"
      sleep 40
  done
done
