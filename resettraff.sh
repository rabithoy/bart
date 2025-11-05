#!/bin/bash
while true; do
  TRAFF_LIST=($(sudo docker ps --format '{{.Names}}' | grep -E '^traff' | sort))
  CASTAR_LIST=($(sudo docker ps --format '{{.Names}}' | grep -E '^castar' | sort))

  COUNT=${#TRAFF_LIST[@]}
  
  for (( i=0; i<COUNT; i++ )); do
    T=${TRAFF_LIST[$i]}
    C=${CASTAR_LIST[$i]}

    echo "Restarting pair #$((i+1)) at $(date)"

    if [ -n "$T" ]; then
      echo "  Restart traff:  $T"
      sudo docker restart "$T"
    fi

    sleep 5

    if [ -n "$C" ]; then
      echo "  Restart castar: $C"
      sudo docker restart "$C"
    fi

    sleep 120
  done
done
