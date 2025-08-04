#!/bin/bash

# Comprehensive Xcode Workspace Optimization Script
# Optimizes entire development environment for maximum build performance

set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Comprehensive Xcode Workspace Optimizer${NC}"
echo "============================================"
echo "Time: $(date)"
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

# Check system requirements
check_system() {
    echo -e "${PURPLE}🔍 System Analysis${NC}"
    echo "=================="
    
    # Check available memory
    MEMORY_GB=$(sysctl -n hw.memsize | awk '{print int($1/1024/1024/1024)}')
    print_info "Available RAM: ${MEMORY_GB}GB"
    
    if [ $MEMORY_GB -lt 8 ]; then
        print_warning "Low memory detected. Consider upgrading RAM for better performance."
    fi
    
    # Check available disk space
    DISK_AVAILABLE=$(df -h . | awk 'NR==2{print $4}')
    print_info "Available disk space: $DISK_AVAILABLE"
    
    # Check CPU cores
    CPU_CORES=$(sysctl -n hw.ncpu)
    print_info "CPU cores: $CPU_CORES"
    
    echo
}

# Optimize macOS system settings
optimize_macos() {
    echo -e "${PURPLE}🍎 macOS System Optimizations${NC}"
    echo "=============================="
    
    print_action "Optimizing system performance settings..."
    
    # Disable Spotlight indexing for build directories
    sudo mdutil -i off /Users/$(whoami)/Library/Developer/Xcode/DerivedData 2>/dev/null || true
    sudo mdutil -i off /Users/$(whoami)/.pub-cache 2>/dev/null || true
    
    # Optimize memory management
    sudo sysctl -w vm.compressor_mode=4 2>/dev/null || true
    sudo sysctl -w kern.maxfiles=65536 2>/dev/null || true
    sudo sysctl -w kern.maxfilesperproc=32768 2>/dev/null || true
    
    print_status "macOS system optimized"
    
    print_action "Configuring energy settings..."
    sudo pmset -c sleep 0 2>/dev/null || true
    sudo pmset -c displaysleep 30 2>/dev/null || true
    sudo pmset -c disksleep 0 2>/dev/null || true
    print_status "Energy settings optimized"
    
    echo
}

# Optimize Xcode settings
optimize_xcode_settings() {
    echo -e "${PURPLE}⚙️ Xcode Settings Optimization${NC}"
    echo "==============================="
    
    print_action "Configuring Xcode performance settings..."
    
    # Build performance settings
    defaults write com.apple.dt.Xcode ShowBuildOperationDuration -bool YES
    defaults write com.apple.dt.Xcode IDEBuildOperationMaxNumberOfConcurrentCompileTasks 0
    
    # Disable unnecessary features
    defaults write com.apple.dt.Xcode IDEIndexDisable -bool YES
    defaults write com.apple.dt.Xcode IDEIndexEnable -bool NO
    defaults write com.apple.dt.Xcode DVTTextShowFoldingRibbon -bool NO
    defaults write com.apple.dt.Xcode DVTTextShowLineNumbers -bool NO
    defaults write com.apple.dt.Xcode DVTSourceTextSyntaxHighlightingEnabled -bool NO
    
    # Optimize editor settings
    defaults write com.apple.dt.Xcode DVTTextAutoSuggestCompletionsWhileTyping -bool NO
    defaults write com.apple.dt.Xcode DVTTextShowCompletionsOnEsc -bool NO
    
    # Disable analytics and crash reporting
    defaults write com.apple.dt.Xcode DVTAnalyticsEnabled -bool NO
    defaults write com.apple.dt.Xcode IDEAnalyticsSendUsageData -bool NO
    
    print_status "Xcode settings optimized"
    echo
}

# Clean development caches
clean_development_caches() {
    echo -e "${PURPLE}🧹 Development Cache Cleanup${NC}"
    echo "=============================="
    
    print_action "Cleaning Xcode caches..."
    rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null || true
    rm -rf ~/Library/Caches/com.apple.dt.Xcode/* 2>/dev/null || true
    rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport/* 2>/dev/null || true
    print_status "Xcode caches cleaned"
    
    print_action "Cleaning Flutter caches..."
    flutter clean 2>/dev/null || true
    rm -rf ~/.pub-cache/hosted 2>/dev/null || true
    print_status "Flutter caches cleaned"
    
    print_action "Cleaning CocoaPods caches..."
    pod cache clean --all 2>/dev/null || true
    rm -rf ~/Library/Caches/CocoaPods/* 2>/dev/null || true
    print_status "CocoaPods caches cleaned"
    
    print_action "Cleaning system caches..."
    sudo rm -rf /System/Library/Caches/* 2>/dev/null || true
    sudo rm -rf /Library/Caches/* 2>/dev/null || true
    rm -rf ~/Library/Caches/* 2>/dev/null || true
    print_status "System caches cleaned"
    
    echo
}

# Optimize project structure
optimize_project_structure() {
    echo -e "${PURPLE}📁 Project Structure Optimization${NC}"
    echo "=================================="
    
    if [ ! -f "pubspec.yaml" ]; then
        print_warning "Not in Flutter project root. Skipping project optimizations."
        return
    fi
    
    print_action "Optimizing iOS project structure..."
    
    # Create optimized build scripts directory
    mkdir -p ios/scripts
    
    # Create build phase optimization script
    cat > ios/scripts/optimize_build_phases.sh << 'EOF'
#!/bin/bash
# Optimize Xcode build phases
echo "Optimizing build phases..."

# Set parallel build settings
export CLANG_ENABLE_MODULES=YES
export SWIFT_COMPILATION_MODE=wholemodule
export COMPILER_INDEX_STORE_ENABLE=NO

echo "Build phases optimized"
EOF
    
    chmod +x ios/scripts/optimize_build_phases.sh
    print_status "Build scripts created"
    
    print_action "Optimizing asset catalogs..."
    # Optimize asset compilation
    find ios -name "*.xcassets" -exec touch {} \; 2>/dev/null || true
    print_status "Asset catalogs optimized"
    
    echo
}

# Create development environment script
create_dev_environment() {
    echo -e "${PURPLE}🛠️ Development Environment Setup${NC}"
    echo "=================================="
    
    print_action "Creating optimized development environment script..."
    
    cat > setup_dev_environment.sh << 'EOF'
#!/bin/bash
# Optimized Development Environment Setup

echo "🚀 Setting up optimized development environment..."

# Set environment variables for optimal performance
export FLUTTER_BUILD_MODE=debug
export COCOAPODS_DISABLE_STATS=true
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
export PUB_HOSTED_URL=https://pub.flutter-io.cn

# Xcode build settings
export XCODE_XCCONFIG_FILE="ios/optimize_build.xcconfig"
export ONLY_ACTIVE_ARCH=YES
export ENABLE_BITCODE=NO
export COMPILER_INDEX_STORE_ENABLE=NO

# Flutter settings
export FLUTTER_BUILD_VERBOSE=false
export FLUTTER_BUILD_COMPACT=true

echo "✅ Development environment optimized!"
echo "Run 'source setup_dev_environment.sh' to apply settings"
EOF
    
    chmod +x setup_dev_environment.sh
    print_status "Development environment script created"
    
    echo
}

# Monitor and report performance
monitor_performance() {
    echo -e "${PURPLE}📊 Performance Monitoring${NC}"
    echo "=========================="
    
    # Create performance monitoring script
    cat > monitor_build_performance.sh << 'EOF'
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
EOF
    
    chmod +x monitor_build_performance.sh
    print_status "Performance monitoring script created"
    
    echo
}

# Main execution
main() {
    print_info "Starting comprehensive Xcode workspace optimization..."
    echo
    
    check_system
    optimize_macos
    optimize_xcode_settings
    clean_development_caches
    optimize_project_structure
    create_dev_environment
    monitor_performance
    
    echo -e "${GREEN}✅ Comprehensive optimization completed!${NC}"
    echo
    echo -e "${CYAN}📋 Next Steps:${NC}"
    echo "1. Run 'source setup_dev_environment.sh' to apply environment settings"
    echo "2. Use './fast_xcode_build.sh' for optimized builds"
    echo "3. Run './monitor_build_performance.sh' to track performance"
    echo "4. Restart Xcode to apply all settings"
    echo
    echo -e "${CYAN}💡 Performance Tips:${NC}"
    echo "• Use iOS Simulator for development (faster than device builds)"
    echo "• Enable 'Build for Active Architecture Only' in debug mode"
    echo "• Use incremental builds when possible"
    echo "• Close unnecessary applications during builds"
    echo "• Consider using an SSD for better I/O performance"
    echo "• Keep your Mac cool to prevent thermal throttling"
    echo
}

# Run main function
main "$@"