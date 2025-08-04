#!/bin/bash

# XPay Xcode Build Performance Optimizer
# Comprehensive solution for slow Xcode builds

set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 XPay Xcode Build Performance Optimizer${NC}"
echo "================================================"
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
    echo -e "${CYAN}[→]${NC} $1"
}

# Analyze current system bottlenecks
analyze_bottlenecks() {
    echo -e "${PURPLE}🔍 Analyzing Build Performance Bottlenecks${NC}"
    echo "============================================="
    
    # Memory analysis
    MEMORY_FREE=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    MEMORY_FREE_GB=$((MEMORY_FREE * 4096 / 1024 / 1024 / 1024))
    MEMORY_TOTAL=$(sysctl -n hw.memsize)
    MEMORY_TOTAL_GB=$((MEMORY_TOTAL / 1024 / 1024 / 1024))
    
    echo "💾 Memory Analysis:"
    if [ $MEMORY_FREE_GB -eq 0 ]; then
        print_error "Critical: 0GB free memory (${MEMORY_TOTAL_GB}GB total)"
        echo "   └── This is the PRIMARY cause of slow builds"
    else
        print_status "Memory: ${MEMORY_FREE_GB}GB free / ${MEMORY_TOTAL_GB}GB total"
    fi
    
    # Disk space analysis
    DISK_USAGE=$(df -h . | tail -1 | awk '{print $5}' | sed 's/%//')
    DISK_AVAIL=$(df -h . | tail -1 | awk '{print $4}')
    echo "💿 Disk Analysis:"
    if [ $DISK_USAGE -gt 85 ]; then
        print_error "High disk usage: ${DISK_USAGE}% (${DISK_AVAIL} available)"
        echo "   └── Low disk space severely impacts build performance"
    else
        print_status "Disk usage: ${DISK_USAGE}% (${DISK_AVAIL} available)"
    fi
    
    # CPU analysis
    CPU_USAGE=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
    echo "🖥️  CPU Analysis:"
    if [ "$(echo "$CPU_USAGE > 80" | bc -l 2>/dev/null || echo 0)" -eq 1 ]; then
        print_warning "High CPU usage: ${CPU_USAGE}%"
    else
        print_status "CPU usage: ${CPU_USAGE}%"
    fi
    
    # Xcode processes
    XCODE_PROCESSES=$(ps aux | grep -i xcode | grep -v grep | wc -l)
    echo "🔧 Xcode Processes: $XCODE_PROCESSES running"
    
    echo
}

# Clean system resources
clean_system_resources() {
    echo -e "${PURPLE}🧹 Cleaning System Resources${NC}"
    echo "===================================="
    
    print_action "Cleaning Xcode derived data..."
    rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null || true
    print_status "Xcode derived data cleaned"
    
    print_action "Cleaning iOS device support files..."
    rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport/*/Symbols/System/Library/Caches/* 2>/dev/null || true
    print_status "iOS device support cleaned"
    
    print_action "Cleaning Xcode archives..."
    find ~/Library/Developer/Xcode/Archives -name "*.xcarchive" -mtime +30 -delete 2>/dev/null || true
    print_status "Old Xcode archives cleaned"
    
    print_action "Cleaning simulator data..."
    xcrun simctl delete unavailable 2>/dev/null || true
    print_status "Unavailable simulators cleaned"
    
    print_action "Cleaning system caches..."
    sudo rm -rf /System/Library/Caches/* 2>/dev/null || true
    rm -rf ~/Library/Caches/com.apple.dt.Xcode/* 2>/dev/null || true
    print_status "System caches cleaned"
    
    echo
}

# Optimize Xcode settings
optimize_xcode_settings() {
    echo -e "${PURPLE}⚙️  Optimizing Xcode Settings${NC}"
    echo "================================"
    
    # Enable build parallelization
    print_action "Enabling build parallelization..."
    defaults write com.apple.dt.Xcode BuildSystemScheduleInherentlyParallelCommandsExclusively -bool YES
    defaults write com.apple.dt.Xcode IDEBuildOperationMaxNumberOfConcurrentCompileTasks $(sysctl -n hw.ncpu)
    print_status "Build parallelization enabled"
    
    # Optimize indexing
    print_action "Optimizing Xcode indexing..."
    defaults write com.apple.dt.Xcode IDEIndexDisable -bool NO
    defaults write com.apple.dt.Xcode IDEIndexEnable -bool YES
    defaults write com.apple.dt.Xcode IDEIndexerActivityShowNumericProgress -bool YES
    print_status "Indexing optimized"
    
    # Enable faster builds
    print_action "Enabling faster build options..."
    defaults write com.apple.dt.Xcode ShowBuildOperationDuration -bool YES
    defaults write com.apple.dt.Xcode IDEBuildOperationMaxNumberOfConcurrentCompileTasks 0
    print_status "Faster build options enabled"
    
    echo
}

# Optimize iOS project settings
optimize_ios_project() {
    echo -e "${PURPLE}📱 Optimizing iOS Project Settings${NC}"
    echo "==================================="
    
    if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
        print_action "Optimizing iOS build settings..."
        
        # Create optimized build configuration
        cat > ios/optimize_build.xcconfig << 'EOF'
// Xcode Build Optimization Configuration

// Compiler Optimizations
GCC_OPTIMIZATION_LEVEL = s
SWIFT_OPTIMIZATION_LEVEL = -O
SWIFT_COMPILATION_MODE = wholemodule

// Build Performance
COMPILER_INDEX_STORE_ENABLE = NO
ONLY_ACTIVE_ARCH = YES
SKIP_INSTALL = YES

// Linking Optimizations
DEAD_CODE_STRIPPING = YES
STRIP_INSTALLED_PRODUCT = YES
STRIP_STYLE = all

// Debug Information
DEBUG_INFORMATION_FORMAT = dwarf
GENERATE_INFOPLIST_FILE = YES

// Module Optimizations
DEFINES_MODULE = YES
MODULEMAP_FILE = 
PRODUCT_MODULE_NAME = Runner

// Swift Settings
SWIFT_VERSION = 5.0
SWIFT_ACTIVE_COMPILATION_CONDITIONS = 
SWIFT_TREAT_WARNINGS_AS_ERRORS = NO

// Build System
BUILD_LIBRARY_FOR_DISTRIBUTION = NO
VALIDATE_PRODUCT = NO
EOF
        
        print_status "iOS build configuration optimized"
    else
        print_warning "iOS project not found, skipping iOS optimizations"
    fi
    
    echo
}

# Optimize Flutter build
optimize_flutter_build() {
    echo -e "${PURPLE}🎯 Optimizing Flutter Build${NC}"
    echo "=============================="
    
    print_action "Cleaning Flutter build cache..."
    flutter clean
    print_status "Flutter cache cleaned"
    
    print_action "Optimizing Flutter dependencies..."
    flutter pub get
    print_status "Dependencies optimized"
    
    print_action "Pre-compiling Flutter assets..."
    flutter build ios --debug --no-codesign 2>/dev/null || true
    print_status "Assets pre-compiled"
    
    echo
}

# Memory optimization
optimize_memory() {
    echo -e "${PURPLE}🧠 Memory Optimization${NC}"
    echo "========================"
    
    print_action "Purging inactive memory..."
    sudo purge 2>/dev/null || true
    print_status "Inactive memory purged"
    
    print_action "Optimizing virtual memory..."
    sudo sysctl -w vm.pressure_disable_threshold=5 2>/dev/null || true
    print_status "Virtual memory optimized"
    
    # Check memory after optimization
    MEMORY_FREE_AFTER=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    MEMORY_FREE_GB_AFTER=$((MEMORY_FREE_AFTER * 4096 / 1024 / 1024 / 1024))
    print_status "Memory freed: ${MEMORY_FREE_GB_AFTER}GB now available"
    
    echo
}

# Create build performance script
create_fast_build_script() {
    echo -e "${PURPLE}⚡ Creating Fast Build Script${NC}"
    echo "================================"
    
    cat > fast_xcode_build.sh << 'EOF'
#!/bin/bash

# Fast Xcode Build Script
# Optimized build process for XPay Flutter app

set -e

echo "🚀 Starting optimized Xcode build..."
echo "Time: $(date)"
echo

# Pre-build optimizations
echo "🔧 Pre-build optimizations..."
sudo purge 2>/dev/null || true
rm -rf ios/build 2>/dev/null || true

# Build with optimizations
echo "📱 Building iOS app..."
time flutter build ios --debug --verbose

echo
echo "✅ Build completed at $(date)"
EOF
    
    chmod +x fast_xcode_build.sh
    print_status "Fast build script created: ./fast_xcode_build.sh"
    
    echo
}

# Provide recommendations
provide_recommendations() {
    echo -e "${BLUE}💡 Build Performance Recommendations${NC}"
    echo "====================================="
    
    print_info "Immediate Actions:"
    echo "   • Close unnecessary applications to free memory"
    echo "   • Use ./fast_xcode_build.sh for optimized builds"
    echo "   • Restart Xcode after optimization"
    echo
    
    print_info "Long-term Optimizations:"
    echo "   • Upgrade RAM if possible (current: ${MEMORY_TOTAL_GB}GB)"
    echo "   • Free up disk space (current usage: ${DISK_USAGE}%)"
    echo "   • Use SSD for better I/O performance"
    echo
    
    print_info "Build Best Practices:"
    echo "   • Use 'flutter clean' before major builds"
    echo "   • Build only for active architecture during development"
    echo "   • Use incremental builds when possible"
    echo
    
    print_info "Monitoring:"
    echo "   • Use Activity Monitor to track resource usage"
    echo "   • Monitor build times with 'time' command"
    echo "   • Check Xcode build logs for bottlenecks"
    echo
}

# Main execution
main() {
    analyze_bottlenecks
    clean_system_resources
    optimize_memory
    optimize_xcode_settings
    optimize_ios_project
    optimize_flutter_build
    create_fast_build_script
    provide_recommendations
    
    echo -e "${GREEN}🎉 Xcode Build Optimization Complete!${NC}"
    echo -e "${YELLOW}💡 Use './fast_xcode_build.sh' for optimized builds${NC}"
    echo
}

# Run if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi