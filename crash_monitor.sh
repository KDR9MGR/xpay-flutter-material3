#!/bin/bash

# Real-time crash monitor
echo "🔍 Monitoring for new crashes... (Press Ctrl+C to stop)"
echo "Time: $(date)"
echo

# Get initial crash count
INITIAL_COUNT=$(find ~/Library/Logs/DiagnosticReports -name "*Runner*" 2>/dev/null | wc -l)
echo "Initial crash reports: $INITIAL_COUNT"

while true; do
    sleep 5
    CURRENT_COUNT=$(find ~/Library/Logs/DiagnosticReports -name "*Runner*" 2>/dev/null | wc -l)
    
    if [ $CURRENT_COUNT -gt $INITIAL_COUNT ]; then
        echo "🚨 NEW CRASH DETECTED at $(date)"
        echo "Total crashes: $CURRENT_COUNT (was $INITIAL_COUNT)"
        
        # Get the latest crash
        LATEST_CRASH=$(find ~/Library/Logs/DiagnosticReports -name "*Runner*" -exec ls -t {} + | head -1)
        echo "Latest crash: $LATEST_CRASH"
        
        # Copy to working directory for analysis
        cp "$LATEST_CRASH" ./latest_crash.ips 2>/dev/null || true
        echo "Crash report copied to: ./latest_crash.ips"
        echo
        
        INITIAL_COUNT=$CURRENT_COUNT
    fi
done
