#!/bin/bash

# XPay Flutter Crash Analyzer
# Analyzes EXC_BAD_ACCESS and other critical crashes

set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 XPay Flutter Crash Analyzer${NC}"
echo "=========================================="
echo -e "${YELLOW}⚠️  CRITICAL: EXC_BAD_ACCESS Detected${NC}"
echo

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_solution() {
    echo -e "${PURPLE}[SOLUTION]${NC} $1"
}

# Analyze the crash report
analyze_crash() {
    print_status "Analyzing crash report..."
    
    if [ -f "crash_report.ips" ]; then
        echo -e "\n${BLUE}📊 Crash Analysis Results:${NC}"
        echo "==========================================="
        
        # Extract key information
        APP_VERSION=$(grep -o '"CFBundleShortVersionString":"[^"]*"' crash_report.ips | head -1 | cut -d'"' -f4)
        BUNDLE_ID=$(grep -o '"CFBundleIdentifier":"[^"]*"' crash_report.ips | head -1 | cut -d'"' -f4)
        EXCEPTION_TYPE=$(grep -o '"type":"[^"]*"' crash_report.ips | head -1 | cut -d'"' -f4)
        SIGNAL=$(grep -o '"signal":"[^"]*"' crash_report.ips | head -1 | cut -d'"' -f4)
        
        echo "📱 App Version: $APP_VERSION"
        echo "📦 Bundle ID: $BUNDLE_ID"
        echo "💥 Exception: $EXCEPTION_TYPE"
        echo "🚨 Signal: $SIGNAL"
        
        # Check for specific error patterns
        if grep -q "libswiftWebKit.dylib" crash_report.ips; then
            print_error "Missing Swift WebKit Library Detected!"
            echo "   └── flutter_inappwebview_ios framework dependency issue"
        fi
        
        if grep -q "fatalDyldError" crash_report.ips; then
            print_error "Fatal Dynamic Linker Error!"
            echo "   └── Library loading failure at app launch"
        fi
        
        echo
    else
        print_warning "No crash report found in current directory"
    fi
}

# Check system resources
check_system_resources() {
    print_status "Checking system resources..."
    
    # Memory check
    MEMORY_FREE=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    MEMORY_FREE_GB=$((MEMORY_FREE * 4096 / 1024 / 1024 / 1024))
    
    if [ $MEMORY_FREE_GB -eq 0 ]; then
        print_error "Critical: 0GB free memory detected!"
        echo "   └── This can cause EXC_BAD_ACCESS errors"
    else
        print_status "Memory: ${MEMORY_FREE_GB}GB free"
    fi
    
    # Disk space check
    DISK_USAGE=$(df -h . | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ $DISK_USAGE -gt 90 ]; then
        print_warning "High disk usage: ${DISK_USAGE}%"
        echo "   └── Low disk space can cause build issues"
    fi
    
    echo
}

# Check Flutter and iOS setup
check_flutter_setup() {
    print_status "Checking Flutter and iOS setup..."
    
    # Check Flutter version
    if command -v flutter &> /dev/null; then
        FLUTTER_VERSION=$(flutter --version | head -1)
        echo "📱 $FLUTTER_VERSION"
    else
        print_error "Flutter not found in PATH"
    fi
    
    # Check iOS Simulator
    if command -v xcrun &> /dev/null; then
        SIMULATOR_LIST=$(xcrun simctl list devices | grep "Booted" | wc -l)
        if [ $SIMULATOR_LIST -gt 0 ]; then
            print_status "iOS Simulator is running"
        else
            print_warning "No iOS Simulator currently booted"
        fi
    fi
    
    echo
}

# Provide solutions
provide_solutions() {
    echo -e "${BLUE}🛠️  Recommended Solutions:${NC}"
    echo "==========================================="
    
    print_solution "1. Fix Swift WebKit Library Issue:"
    echo "   flutter clean"
    echo "   rm -rf ios/Pods ios/Podfile.lock"
    echo "   cd ios && pod install --repo-update"
    echo "   cd .. && flutter pub get"
    echo
    
    print_solution "2. Update flutter_inappwebview dependency:"
    echo "   # In pubspec.yaml, update to latest version:"
    echo "   flutter_inappwebview: ^6.0.0"
    echo
    
    print_solution "3. Memory Management:"
    echo "   # Close unnecessary applications"
    echo "   # Restart Xcode and iOS Simulator"
    echo "   # Use 'flutter clean' to free disk space"
    echo
    
    print_solution "4. iOS Simulator Reset:"
    echo "   xcrun simctl erase all"
    echo "   # Then restart iOS Simulator"
    echo
    
    print_solution "5. Xcode Clean Build:"
    echo "   # In Xcode: Product → Clean Build Folder"
    echo "   # Or use: xcodebuild clean -workspace ios/Runner.xcworkspace"
    echo
}

# Check for recent crashes
check_recent_crashes() {
    print_status "Checking for recent crashes..."
    
    CRASH_COUNT=$(find ~/Library/Logs/DiagnosticReports -name "*Runner*" -mtime -1 2>/dev/null | wc -l)
    if [ $CRASH_COUNT -gt 0 ]; then
        print_warning "Found $CRASH_COUNT recent Runner crashes in last 24 hours"
        echo "   └── Pattern suggests recurring issue"
    else
        print_status "No recent crashes found"
    fi
    
    echo
}

# Main execution
main() {
    analyze_crash
    check_system_resources
    check_flutter_setup
    check_recent_crashes
    provide_solutions
    
    echo -e "${GREEN}✅ Crash analysis complete!${NC}"
    echo -e "${YELLOW}💡 Tip: Run the suggested solutions in order${NC}"
    echo
}

# Run if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi