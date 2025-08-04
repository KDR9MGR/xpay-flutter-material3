#!/bin/bash

# XPay Flutter App - Enhanced Xcode Build Monitor
# This script provides comprehensive monitoring of Xcode builds with performance metrics

set -e

echo "🔍 XPay Enhanced Xcode Build Monitor Started"
echo "==========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} ✅ $1"
}

print_warning() {
    echo -e "${YELLOW}[$(date '+%H:%M:%S')]${NC} ⚠️  $1"
}

print_error() {
    echo -e "${RED}[$(date '+%H:%M:%S')]${NC} ❌ $1"
}

# Function to log with timestamp
log_with_time() {
    echo "[$(date '+%H:%M:%S')] $1"
}

# Function to check system resources
check_system_resources() {
    print_status "Checking system resources..."
    
    # Memory usage
    MEMORY_USAGE=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    MEMORY_TOTAL=$(sysctl -n hw.memsize)
    MEMORY_FREE_GB=$((MEMORY_USAGE * 4096 / 1024 / 1024 / 1024))
    MEMORY_TOTAL_GB=$((MEMORY_TOTAL / 1024 / 1024 / 1024))
    
    echo "  💾 Memory: ${MEMORY_FREE_GB}GB free / ${MEMORY_TOTAL_GB}GB total"
    
    # CPU usage
    CPU_USAGE=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    echo "  🖥️  CPU Usage: ${CPU_USAGE}%"
    
    # Disk space
    DISK_USAGE=$(df -h . | tail -1 | awk '{print $5}' | sed 's/%//')
    echo "  💿 Disk Usage: ${DISK_USAGE}%"
    
    # Check if Xcode is running
    if pgrep -x "Xcode" > /dev/null; then
        print_warning "Xcode is currently running"
    else
        print_status "Xcode is not running"
    fi
}

# Function to check for build errors
check_build_errors() {
    local log_file="$1"
    if [ -f "$log_file" ]; then
        # Check for compilation errors
        if grep -q "error:" "$log_file"; then
            echo -e "${RED}❌ BUILD ERRORS DETECTED:${NC}"
            grep "error:" "$log_file" | tail -10
            echo ""
        fi
        
        # Check for warnings
        if grep -q "warning:" "$log_file"; then
            echo -e "${YELLOW}⚠️  BUILD WARNINGS DETECTED:${NC}"
            grep "warning:" "$log_file" | tail -5
            echo ""
        fi
        
        # Check for linker errors
        if grep -q "ld:" "$log_file"; then
            echo -e "${RED}🔗 LINKER ERRORS DETECTED:${NC}"
            grep "ld:" "$log_file" | tail -5
            echo ""
        fi
    fi
}

# Function to check for runtime errors
check_runtime_errors() {
    local log_file="$1"
    if [ -f "$log_file" ]; then
        # Check for crashes
        if grep -q "SIGABRT\|SIGSEGV\|EXC_BAD_ACCESS\|Fatal error" "$log_file"; then
            echo -e "${RED}💥 RUNTIME CRASH DETECTED:${NC}"
            grep -A 5 -B 5 "SIGABRT\|SIGSEGV\|EXC_BAD_ACCESS\|Fatal error" "$log_file" | tail -15
            echo ""
        fi
        
        # Check for memory issues
        if grep -q "Memory warning\|Low memory\|malloc" "$log_file"; then
            echo -e "${YELLOW}🧠 MEMORY ISSUES DETECTED:${NC}"
            grep "Memory warning\|Low memory\|malloc" "$log_file" | tail -5
            echo ""
        fi
        
        # Check for threading issues
        if grep -q "Main Thread Checker\|Thread.*violation" "$log_file"; then
            echo -e "${YELLOW}🧵 THREADING ISSUES DETECTED:${NC}"
            grep "Main Thread Checker\|Thread.*violation" "$log_file" | tail -5
            echo ""
        fi
    fi
}

# Function to monitor simulator logs
monitor_simulator() {
    echo -e "${BLUE}📱 Monitoring iOS Simulator logs...${NC}"
    
    # Get device ID
    DEVICE_ID=$(xcrun simctl list devices | grep "Booted" | head -1 | grep -o "([A-F0-9-]*)" | tr -d "()")
    
    if [ -n "$DEVICE_ID" ]; then
        log_with_time "Found booted simulator: $DEVICE_ID"
        
        # Monitor simulator logs
        xcrun simctl spawn "$DEVICE_ID" log stream --predicate 'processImagePath endswith "Runner"' --info --debug 2>&1 | while read line; do
            echo "$line"
            
            # Check for specific error patterns
            if echo "$line" | grep -q "error\|Error\|ERROR"; then
                echo -e "${RED}🚨 RUNTIME ERROR: $line${NC}"
            elif echo "$line" | grep -q "warning\|Warning\|WARNING"; then
                echo -e "${YELLOW}⚠️  RUNTIME WARNING: $line${NC}"
            elif echo "$line" | grep -q "crash\|Crash\|CRASH"; then
                echo -e "${RED}💥 CRASH DETECTED: $line${NC}"
            fi
        done &
        
        SIMULATOR_PID=$!
        echo "Simulator monitoring started with PID: $SIMULATOR_PID"
    else
        echo -e "${YELLOW}⚠️  No booted simulator found${NC}"
    fi
}

# Function to monitor build process with detailed metrics
monitor_build() {
    local BUILD_TYPE=${1:-"release"}
    local START_TIME=$(date +%s)
    
    print_status "Starting ${BUILD_TYPE} build monitoring..."
    
    # Create log directory
    mkdir -p logs
    LOG_FILE="logs/xcode_build_$(date +%Y%m%d_%H%M%S).log"
    
    # Monitor build command based on type
    case $BUILD_TYPE in
        "debug")
            print_status "Building iOS Debug with optimizations..."
            flutter build ios --debug --verbose --dart-define=FLUTTER_WEB_USE_SKIA=true 2>&1 | tee "$LOG_FILE"
            ;;
        "release")
            print_status "Building iOS Release with optimizations..."
            flutter build ios --release --verbose --dart-define=FLUTTER_WEB_USE_SKIA=true --tree-shake-icons 2>&1 | tee "$LOG_FILE"
            ;;
        "profile")
            print_status "Building iOS Profile..."
            flutter build ios --profile --verbose 2>&1 | tee "$LOG_FILE"
            ;;
        "ipa")
            print_status "Building IPA for distribution..."
            flutter build ipa --release --verbose --tree-shake-icons 2>&1 | tee "$LOG_FILE"
            ;;
        *)
            print_error "Unknown build type: $BUILD_TYPE"
            exit 1
            ;;
    esac
    
    local BUILD_EXIT_CODE=$?
    local END_TIME=$(date +%s)
    local BUILD_DURATION=$((END_TIME - START_TIME))
    
    # Build summary with detailed metrics
    echo ""
    echo "📊 Build Performance Summary"
    echo "============================"
    echo "Build Type: $BUILD_TYPE"
    echo "Duration: ${BUILD_DURATION}s ($(date -u -r $BUILD_DURATION +'%H:%M:%S'))"
    echo "Log File: $LOG_FILE"
    
    if [ $BUILD_EXIT_CODE -eq 0 ]; then
        print_success "Build completed successfully!"
        
        # Analyze build artifacts and optimizations
        analyze_build_artifacts "$BUILD_TYPE"
        
        # Show optimization results
        show_optimization_results "$LOG_FILE"
        
    else
        print_error "Build failed with exit code: $BUILD_EXIT_CODE"
        
        # Extract and analyze errors
        analyze_build_errors "$LOG_FILE"
    fi
    
    return $BUILD_EXIT_CODE
}

# Function to analyze build artifacts
analyze_build_artifacts() {
    local BUILD_TYPE=$1
    
    print_status "Analyzing build artifacts..."
    
    if [ "$BUILD_TYPE" = "ipa" ]; then
        IPA_PATH="build/ios/ipa/*.ipa"
        if ls $IPA_PATH 1> /dev/null 2>&1; then
            IPA_SIZE=$(du -h $IPA_PATH | cut -f1)
            IPA_SIZE_BYTES=$(du -b $IPA_PATH | cut -f1)
            print_success "IPA created: $IPA_SIZE ($IPA_SIZE_BYTES bytes)"
            
            # Check if size is reasonable (under 100MB for most apps)
            if [ $IPA_SIZE_BYTES -gt 104857600 ]; then
                print_warning "IPA size is large (>100MB). Consider optimizing assets."
            fi
        fi
    else
        APP_PATH="build/ios/Release-iphoneos/Runner.app"
        if [ -d "$APP_PATH" ]; then
            APP_SIZE=$(du -sh "$APP_PATH" | cut -f1)
            print_success "App bundle created: $APP_SIZE"
            
            # Check for common optimization opportunities
            if [ -d "$APP_PATH/Frameworks" ]; then
                FRAMEWORKS_SIZE=$(du -sh "$APP_PATH/Frameworks" | cut -f1)
                echo "  📦 Frameworks size: $FRAMEWORKS_SIZE"
            fi
        fi
    fi
}

# Function to show optimization results from build log
show_optimization_results() {
    local LOG_FILE=$1
    
    print_status "Optimization Results:"
    
    # Tree-shaking results
    if grep -q "tree-shaken" "$LOG_FILE"; then
        echo "  🌳 Tree-shaking optimizations:"
        grep "tree-shaken" "$LOG_FILE" | while read line; do
            echo "    $line"
        done
    fi
    
    # Compilation optimizations
    if grep -q "optimization" "$LOG_FILE"; then
        OPTIMIZATION_COUNT=$(grep -c "optimization" "$LOG_FILE")
        echo "  ⚡ Applied $OPTIMIZATION_COUNT optimizations"
    fi
    
    # Asset optimizations
    if grep -q "asset" "$LOG_FILE"; then
        echo "  🖼️  Asset processing completed"
    fi
}

# Function to analyze build errors
analyze_build_errors() {
    local LOG_FILE=$1
    
    print_status "Analyzing build errors..."
    
    if grep -q "error:" "$LOG_FILE"; then
        echo "🔍 Found errors:"
        grep "error:" "$LOG_FILE" | tail -5 | while read line; do
            echo "  ❌ $line"
        done
    fi
    
    if grep -q "warning:" "$LOG_FILE"; then
        WARNING_COUNT=$(grep -c "warning:" "$LOG_FILE")
        print_warning "Found $WARNING_COUNT warnings"
        
        # Show critical warnings
        grep "warning:" "$LOG_FILE" | grep -i "deprecated\|performance\|memory" | head -3 | while read line; do
            echo "  ⚠️  $line"
        done
    fi
    
    # Check for common issues
    if grep -q "No such file or directory" "$LOG_FILE"; then
        print_error "Missing files detected - check dependencies"
    fi
    
    if grep -q "Permission denied" "$LOG_FILE"; then
        print_error "Permission issues detected - check file permissions"
    fi
}

# Function to run continuous monitoring
run_continuous_monitor() {
    print_status "Starting continuous build monitoring..."
    
    while true; do
        clear
        echo "🔍 XPay Continuous Build Monitor - $(date)"
        echo "========================================="
        
        check_system_resources
        
        echo ""
        echo "📊 Recent Build Logs:"
        if [ -d "logs" ]; then
            ls -lt logs/*.log 2>/dev/null | head -3 | while read line; do
                echo "  $line"
            done
        else
            echo "  No build logs found"
        fi
        
        echo ""
        echo "Press Ctrl+C to stop monitoring..."
        echo "Commands: [d]ebug [r]elease [p]rofile [i]pa [c]lean"
        
        # Wait for input with timeout
        read -t 10 -n 1 input 2>/dev/null || input=""
        
        case $input in
            d|D) monitor_build "debug" ;;
            r|R) monitor_build "release" ;;
            p|P) monitor_build "profile" ;;
            i|I) monitor_build "ipa" ;;
            c|C) clean_build ;;
        esac
        
        sleep 2
    done
}

# Function to clean build artifacts
clean_build() {
    print_status "Cleaning build artifacts..."
    
    flutter clean
    
    # Clean iOS build folder
    if [ -d "ios/build" ]; then
        rm -rf ios/build
        print_success "Cleaned iOS build folder"
    fi
    
    # Clean Xcode derived data (optional)
    read -p "Clean Xcode derived data? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -d "~/Library/Developer/Xcode/DerivedData" ]; then
            rm -rf ~/Library/Developer/Xcode/DerivedData/*
            print_success "Cleaned Xcode derived data"
        fi
    fi
    
    # Clean Flutter build
    if [ -d "build" ]; then
        rm -rf build
        print_success "Cleaned Flutter build folder"
    fi
    
    print_success "Clean completed"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  debug     - Build and monitor iOS debug"
    echo "  release   - Build and monitor iOS release (default)"
    echo "  profile   - Build and monitor iOS profile"
    echo "  ipa       - Build and monitor IPA for distribution"
    echo "  monitor   - Run continuous monitoring"
    echo "  clean     - Clean all build artifacts"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 debug     # Build debug with monitoring"
    echo "  $0 release   # Build release with optimizations"
    echo "  $0 ipa       # Build IPA for App Store"
    echo "  $0 monitor   # Continuous monitoring mode"
    echo "  $0 clean     # Clean all build artifacts"
}

# Function to monitor system logs
monitor_system_logs() {
    echo -e "${BLUE}📋 Monitoring system logs for app-related issues...${NC}"
    
    # Monitor system logs for our app
    log stream --predicate 'process == "Runner" OR processImagePath CONTAINS "Runner"' --info --debug 2>&1 | while read line; do
        echo "$line"
        
        # Check for critical issues
        if echo "$line" | grep -q "fault\|Fault\|FAULT"; then
            echo -e "${RED}🚨 SYSTEM FAULT: $line${NC}"
        elif echo "$line" | grep -q "assertion\|Assertion\|ASSERTION"; then
            echo -e "${RED}❌ ASSERTION FAILURE: $line${NC}"
        fi
    done &
    
    SYSTEM_PID=$!
    echo "System log monitoring started with PID: $SYSTEM_PID"
}

# Function to check app launch status
check_app_launch() {
    echo -e "${BLUE}🚀 Checking app launch status...${NC}"
    
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if pgrep -f "Runner" > /dev/null; then
            echo -e "${GREEN}✅ App is running successfully!${NC}"
            log_with_time "App launched and running"
            return 0
        fi
        
        sleep 2
        attempt=$((attempt + 1))
        
        if [ $((attempt % 5)) -eq 0 ]; then
            log_with_time "Still waiting for app to launch... (${attempt}/${max_attempts})"
        fi
    done
    
    echo -e "${RED}❌ App failed to launch within expected time${NC}"
    return 1
}

# Function to cleanup
cleanup() {
    echo -e "\n${BLUE}🧹 Cleaning up monitoring processes...${NC}"
    
    if [ -n "$BUILD_PID" ]; then
        kill $BUILD_PID 2>/dev/null
    fi
    
    if [ -n "$SIMULATOR_PID" ]; then
        kill $SIMULATOR_PID 2>/dev/null
    fi
    
    if [ -n "$SYSTEM_PID" ]; then
        kill $SYSTEM_PID 2>/dev/null
    fi
    
    echo "Monitoring stopped."
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Main script logic
case "${1:-release}" in
    "debug"|"release"|"profile"|"ipa")
        check_system_resources
        echo ""
        monitor_build "$1"
        ;;
    "monitor")
        run_continuous_monitor
        ;;
    "clean")
        clean_build
        ;;
    "help"|*)
        show_usage
        ;;
esac

echo ""
print_status "XPay Enhanced Xcode Build Monitor Finished"