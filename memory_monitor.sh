#!/bin/bash

# Real-time memory monitor for Xcode builds
echo "🧠 Memory Monitor - Press Ctrl+C to stop"
echo "Time: $(date)"
echo

while true; do
    MEMORY_FREE=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    MEMORY_FREE_GB=$((MEMORY_FREE * 4096 / 1024 / 1024 / 1024))
    MEMORY_TOTAL=$(sysctl -n hw.memsize)
    MEMORY_TOTAL_GB=$((MEMORY_TOTAL / 1024 / 1024 / 1024))
    MEMORY_USED_GB=$((MEMORY_TOTAL_GB - MEMORY_FREE_GB))
    MEMORY_PERCENT=$((MEMORY_USED_GB * 100 / MEMORY_TOTAL_GB))
    
    # Color coding based on memory usage
    if [ $MEMORY_FREE_GB -eq 0 ]; then
        COLOR="\033[0;31m" # Red
        STATUS="CRITICAL"
    elif [ $MEMORY_FREE_GB -lt 2 ]; then
        COLOR="\033[1;33m" # Yellow
        STATUS="LOW"
    else
        COLOR="\033[0;32m" # Green
        STATUS="OK"
    fi
    
    printf "\r${COLOR}[%s]\033[0m Memory: %dGB/%dGB used (%d%%) | Free: %dGB | %s" \
           "$(date '+%H:%M:%S')" "$MEMORY_USED_GB" "$MEMORY_TOTAL_GB" "$MEMORY_PERCENT" "$MEMORY_FREE_GB" "$STATUS"
    
    # Alert if memory is critically low
    if [ $MEMORY_FREE_GB -eq 0 ]; then
        echo
        echo "🚨 CRITICAL: No free memory! Consider running memory_booster.sh"
    fi
    
    sleep 2
done
