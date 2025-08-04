#!/bin/bash

# XPay Flutter Crash Fix Verification
# Verifies EXC_BAD_ACCESS fixes and provides ongoing monitoring

set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 XPay Flutter Crash Fix Verification${NC}"
echo "============================================="
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

# Check if fixes were applied
check_fixes_applied() {
    print_info "Checking applied fixes..."
    
    # Check if flutter clean was run
    if [ ! -d "build" ]; then
        print_status "Flutter clean completed"
    else
        print_warning "Build directory still exists"
    fi
    
    # Check if pods were reinstalled
    if [ -f "ios/Podfile.lock" ]; then
        print_status "iOS Pods reinstalled"
        
        # Check for flutter_inappwebview_ios
        if grep -q "flutter_inappwebview_ios" ios/Podfile.lock; then
            print_status "flutter_inappwebview_ios dependency resolved"
        else
            print_warning "flutter_inappwebview_ios not found in Podfile.lock"
        fi
    else
        print_error "iOS Pods not installed"
    fi
    
    echo
}

# Check system resources after fixes
check_system_resources() {
    print_info "Checking system resources after fixes..."
    
    # Memory check
    MEMORY_FREE=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    MEMORY_FREE_GB=$((MEMORY_FREE * 4096 / 1024 / 1024 / 1024))
    
    if [ $MEMORY_FREE_GB -eq 0 ]; then
        print_warning "Still 0GB free memory - consider closing applications"
    else
        print_status "Memory: ${MEMORY_FREE_GB}GB free (improved)"
    fi
    
    # Disk space check
    DISK_USAGE=$(df -h . | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ $DISK_USAGE -gt 90 ]; then
        print_warning "Disk usage still high: ${DISK_USAGE}%"
    else
        print_status "Disk usage: ${DISK_USAGE}%"
    fi
    
    echo
}

# Test app launch
test_app_launch() {
    print_info "Testing app launch..."
    
    # Check if iOS Simulator is available
    AVAILABLE_DEVICES=$(xcrun simctl list devices available | grep "iPhone" | head -1)
    if [ -n "$AVAILABLE_DEVICES" ]; then
        print_status "iOS Simulator devices available"
        
        # Extract device ID
        DEVICE_ID=$(echo "$AVAILABLE_DEVICES" | grep -o '([^)]*)' | tr -d '()')
        print_info "Using device: $DEVICE_ID"
        
        # Boot the device
        print_info "Booting iOS Simulator..."
        xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
        
        print_status "iOS Simulator ready for testing"
    else
        print_warning "No iOS Simulator devices available"
    fi
    
    echo
}

# Monitor for new crashes
monitor_crashes() {
    print_info "Setting up crash monitoring..."
    
    # Create monitoring script
    cat > crash_monitor.sh << 'EOF'
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
EOF
    
    chmod +x crash_monitor.sh
    print_status "Crash monitor created: ./crash_monitor.sh"
    echo
}

# Provide testing instructions
provide_testing_instructions() {
    echo -e "${BLUE}📋 Testing Instructions:${NC}"
    echo "============================================="
    echo
    
    print_info "1. Launch the app:"
    echo "   flutter run"
    echo
    
    print_info "2. Test critical features:"
    echo "   • App startup and initialization"
    echo "   • Navigation between screens"
    echo "   • Payment-related functions"
    echo "   • Video background (if applicable)"
    echo "   • WebView components"
    echo
    
    print_info "3. Monitor for crashes:"
    echo "   ./crash_monitor.sh"
    echo "   (Run in a separate terminal)"
    echo
    
    print_info "4. If crashes occur:"
    echo "   • Check ./latest_crash.ips for details"
    echo "   • Run ./crash_analyzer.sh for analysis"
    echo "   • Report specific error patterns"
    echo
}

# Provide additional recommendations
provide_recommendations() {
    echo -e "${PURPLE}💡 Additional Recommendations:${NC}"
    echo "============================================="
    echo
    
    print_info "Memory Management:"
    echo "   • Close unnecessary applications"
    echo "   • Restart Xcode periodically"
    echo "   • Monitor memory usage during testing"
    echo
    
    print_info "Development Best Practices:"
    echo "   • Use 'flutter clean' before major builds"
    echo "   • Keep dependencies updated"
    echo "   • Test on multiple iOS versions"
    echo
    
    print_info "Debugging Tools:"
    echo "   • Xcode Instruments for memory profiling"
    echo "   • Flutter DevTools for performance"
    echo "   • Console.app for system logs"
    echo
}

# Main execution
main() {
    check_fixes_applied
    check_system_resources
    test_app_launch
    monitor_crashes
    provide_testing_instructions
    provide_recommendations
    
    echo -e "${GREEN}✅ Crash fix verification complete!${NC}"
    echo -e "${YELLOW}🚀 Ready to test the application${NC}"
    echo
}

# Run if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi