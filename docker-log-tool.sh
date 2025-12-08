#!/bin/bash
# Docker Log Management Tool: shows or cleans container logs

set -e

CLEAN_MODE=false
if [ "$1" == "--clean" ]; then
  CLEAN_MODE=true
fi

echo "Docker Log Management Tool"
echo "-------------------------------------------"
printf "%-30s %-15s %-10s\n" "CONTAINER NAME" "CONTAINER ID" "LOG SIZE (MB)"
echo "-------------------------------------------"

total_size=0

for container_id in $(docker ps -aq); do
    name=$(docker inspect --format='{{.Name}}' "$container_id" | sed 's/\///')
    log_file=$(docker inspect --format='{{.LogPath}}' "$container_id")

    if [ -f "$log_file" ]; then
        size_bytes=$(stat -c%s "$log_file")
        size_mb=$(echo "scale=2; $size_bytes/1024/1024" | bc)
        total_size=$(echo "$total_size + $size_mb" | bc)

        printf "%-30s %-15s %-10s\n" "$name" "$container_id" "$size_mb"

        if [ "$CLEAN_MODE" = true ]; then
            truncate -s 0 "$log_file"
        fi
    else
        printf "%-30s %-15s %-10s\n" "$name" "$container_id" "N/A"
    fi
done

echo "-------------------------------------------"
printf "%-30s %-15s %-10.2f\n" "TOTAL:" "" "$total_size"

if [ "$CLEAN_MODE" = true ]; then
    echo ""
    echo "🧹 All container logs have been cleaned."
fi
