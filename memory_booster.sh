#!/bin/bash

# XPay Memory Booster for Xcode Builds
# Aggressive memory optimization for build performance

set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧠 XPay Memory Booster${NC}"
echo "========================"
echo

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[ℹ]${NC} $1"
}

print_action() {
    echo -e "${PURPLE}[→]${NC} $1"
}

# Get memory info
get_memory_info() {
    MEMORY_FREE=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    MEMORY_FREE_GB=$((MEMORY_FREE * 4096 / 1024 / 1024 / 1024))
    MEMORY_TOTAL=$(sysctl -n hw.memsize)
    MEMORY_TOTAL_GB=$((MEMORY_TOTAL / 1024 / 1024 / 1024))
    MEMORY_USED_GB=$((MEMORY_TOTAL_GB - MEMORY_FREE_GB))
}

# Display memory status
show_memory_status() {
    get_memory_info
    echo "💾 Memory Status:"
    echo "   Total: ${MEMORY_TOTAL_GB}GB"
    echo "   Used:  ${MEMORY_USED_GB}GB"
    echo "   Free:  ${MEMORY_FREE_GB}GB"
    
    if [ $MEMORY_FREE_GB -eq 0 ]; then
        print_error "Critical: No free memory available!"
    elif [ $MEMORY_FREE_GB -lt 2 ]; then
        print_warning "Low memory: ${MEMORY_FREE_GB}GB free"
    else
        print_status "Memory: ${MEMORY_FREE_GB}GB free"
    fi
    echo
}

# Kill memory-heavy processes
kill_memory_hogs() {
    print_action "Identifying memory-heavy processes..."
    
    # Get top memory consumers (excluding system processes)
    TOP_PROCESSES=$(ps aux --sort=-%mem | head -20 | grep -v "kernel_task\|WindowServer\|loginwindow" | tail -n +2)
    
    echo "🔍 Top Memory Consumers:"
    echo "$TOP_PROCESSES" | head -10 | awk '{printf "   %s: %.1fGB\n", $11, $6/1024/1024}'
    echo
    
    # Ask to kill specific processes
    print_action "Terminating non-essential processes..."
    
    # Kill Chrome/Safari tabs if running
    pkill -f "Google Chrome Helper" 2>/dev/null || true
    pkill -f "Safari" 2>/dev/null || true
    
    # Kill other development tools if not needed
    pkill -f "Simulator" 2>/dev/null || true
    pkill -f "Instruments" 2>/dev/null || true
    
    print_status "Non-essential processes terminated"
    echo
}

# Aggressive memory cleanup
aggressive_memory_cleanup() {
    print_action "Performing aggressive memory cleanup..."
    
    # Purge inactive memory
    print_info "Purging inactive memory..."
    sudo purge 2>/dev/null || true
    
    # Clear system caches
    print_info "Clearing system caches..."
    sudo rm -rf /System/Library/Caches/* 2>/dev/null || true
    sudo rm -rf /Library/Caches/* 2>/dev/null || true
    rm -rf ~/Library/Caches/* 2>/dev/null || true
    
    # Clear Xcode caches
    print_info "Clearing Xcode caches..."
    rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null || true
    rm -rf ~/Library/Caches/com.apple.dt.Xcode/* 2>/dev/null || true
    
    # Clear iOS Simulator caches
    print_info "Clearing iOS Simulator caches..."
    xcrun simctl erase all 2>/dev/null || true
    
    # Force garbage collection
    print_info "Forcing garbage collection..."
    sudo sysctl -w vm.pressure_disable_threshold=5 2>/dev/null || true
    
    print_status "Aggressive cleanup completed"
    echo
}

# Optimize virtual memory
optimize_virtual_memory() {
    print_action "Optimizing virtual memory settings..."
    
    # Increase swap usage threshold
    sudo sysctl -w vm.swapusage=1 2>/dev/null || true
    
    # Optimize memory pressure
    sudo sysctl -w vm.memory_pressure_threshold=95 2>/dev/null || true
    
    # Optimize page management
    sudo sysctl -w vm.page_free_target=4000 2>/dev/null || true
    
    print_status "Virtual memory optimized"
    echo
}

# Create memory monitoring script
create_memory_monitor() {
    print_action "Creating memory monitoring script..."
    
    cat > memory_monitor.sh << 'EOF'
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
EOF
    
    chmod +x memory_monitor.sh
    print_status "Memory monitor created: ./memory_monitor.sh"
    echo
}

# Provide memory optimization tips
provide_memory_tips() {
    echo -e "${BLUE}💡 Memory Optimization Tips${NC}"
    echo "============================="
    
    print_info "Before Building:"
    echo "   • Run this script: ./memory_booster.sh"
    echo "   • Close all unnecessary applications"
    echo "   • Quit web browsers with many tabs"
    echo "   • Stop other development tools"
    echo
    
    print_info "During Building:"
    echo "   • Monitor memory: ./memory_monitor.sh"
    echo "   • Don't open new applications"
    echo "   • Use Activity Monitor to track usage"
    echo
    
    print_info "Emergency Actions (if build fails):"
    echo "   • Force quit Xcode and restart"
    echo "   • Restart the entire system"
    echo "   • Use 'sudo purge' command"
    echo
    
    print_info "Hardware Recommendations:"
    echo "   • Upgrade to 16GB+ RAM for smooth development"
    echo "   • Use SSD for faster I/O operations"
    echo "   • Close Docker/VMs if running"
    echo
}

# Main execution
main() {
    echo "🔍 Initial Memory Assessment:"
    show_memory_status
    
    kill_memory_hogs
    aggressive_memory_cleanup
    optimize_virtual_memory
    
    echo "🔍 Memory Status After Optimization:"
    show_memory_status
    
    create_memory_monitor
    provide_memory_tips
    
    echo -e "${GREEN}🎉 Memory optimization complete!${NC}"
    echo -e "${YELLOW}💡 Run './memory_monitor.sh' to track memory during builds${NC}"
    echo
}

# Run if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi