#!/bin/bash
# Build Performance Monitor

echo "📊 Build Performance Monitor"
echo "============================"

# Monitor memory usage
echo "Memory Usage:"
vm_stat | grep -E "(free|active|inactive|wired|compressed)"

# Monitor CPU usage
echo "\nCPU Usage:"
top -l 1 -n 5 | grep -E "(Xcode|flutter|dart)"

# Monitor disk I/O
echo "\nDisk I/O:"
iostat -d 1 1

# Monitor build times
if [ -f "build_times.log" ]; then
    echo "\nRecent Build Times:"
    tail -5 build_times.log
fi
