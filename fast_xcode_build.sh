#!/bin/bash

# Enhanced Fast Xcode Build Script
# Optimized build process for XPay Flutter app with maximum performance

set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Enhanced Fast Xcode Build Script${NC}"
echo "======================================"
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

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "Not in Flutter project root. Please run from project root directory."
    exit 1
fi

# System optimizations
optimize_system() {
    echo -e "${PURPLE}🔧 System Optimizations${NC}"
    echo "========================"
    
    print_action "Purging system memory..."
    sudo purge 2>/dev/null || true
    print_status "Memory purged"
    
    print_action "Setting Xcode performance preferences..."
    defaults write com.apple.dt.Xcode ShowBuildOperationDuration -bool YES
    defaults write com.apple.dt.Xcode IDEBuildOperationMaxNumberOfConcurrentCompileTasks 0
    defaults write com.apple.dt.Xcode IDEIndexDisable -bool YES
    defaults write com.apple.dt.Xcode IDEIndexEnable -bool NO
    print_status "Xcode preferences optimized"
    
    echo
}

# Clean build artifacts
clean_build_artifacts() {
    echo -e "${PURPLE}🧹 Cleaning Build Artifacts${NC}"
    echo "=============================="
    
    print_action "Cleaning Flutter build cache..."
    flutter clean
    print_status "Flutter cache cleaned"
    
    print_action "Cleaning iOS build directory..."
    rm -rf ios/build 2>/dev/null || true
    rm -rf ios/.symlinks 2>/dev/null || true
    rm -rf ios/Flutter/ephemeral 2>/dev/null || true
    print_status "iOS build directory cleaned"
    
    print_action "Cleaning Xcode derived data..."
    rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null || true
    print_status "Xcode derived data cleaned"
    
    print_action "Cleaning CocoaPods cache..."
    cd ios
    pod cache clean --all 2>/dev/null || true
    rm -rf Pods 2>/dev/null || true
    rm -rf .symlinks 2>/dev/null || true
    cd ..
    print_status "CocoaPods cache cleaned"
    
    echo
}

# Optimize dependencies
optimize_dependencies() {
    echo -e "${PURPLE}📦 Optimizing Dependencies${NC}"
    echo "============================="
    
    print_action "Getting Flutter dependencies..."
    flutter pub get
    print_status "Flutter dependencies updated"
    
    print_action "Installing optimized CocoaPods..."
    cd ios
    
    # Use optimized pod install
    export COCOAPODS_DISABLE_STATS=true
    export COCOAPODS_SKIP_CACHE=false
    
    pod install --repo-update --verbose
    print_status "CocoaPods installed with optimizations"
    
    cd ..
    echo
}

# Apply build optimizations
apply_build_optimizations() {
    echo -e "${PURPLE}⚡ Applying Build Optimizations${NC}"
    echo "================================="
    
    print_action "Applying optimization configuration..."
    
    # Apply optimization config to Debug configuration
    if [ -f "ios/optimize_build.xcconfig" ]; then
        # Include optimization config in Debug.xcconfig
        if ! grep -q "optimize_build.xcconfig" ios/Flutter/Debug.xcconfig; then
            echo '#include "../optimize_build.xcconfig"' >> ios/Flutter/Debug.xcconfig
        fi
        print_status "Debug configuration optimized"
    fi
    
    # Set environment variables for build
    export FLUTTER_BUILD_MODE=debug
    export FLUTTER_BUILD_NAME=1.0.0
    export FLUTTER_BUILD_NUMBER=1
    
    print_status "Build optimizations applied"
    echo
}

# Build with optimizations
build_optimized() {
    echo -e "${PURPLE}📱 Building iOS App (Optimized)${NC}"
    echo "=================================="
    
    print_action "Starting optimized Flutter build..."
    
    # Build with maximum optimizations
    flutter build ios \
        --debug \
        --no-codesign \
        --simulator \
        --target-platform ios-x64 \
        --dart-define=FLUTTER_WEB_USE_SKIA=true \
        --dart-define=FLUTTER_WEB_AUTO_DETECT=true \
        --verbose
    
    print_status "iOS build completed successfully!"
    
    # Get build time
    BUILD_END_TIME=$(date +%s)
    if [ ! -z "$BUILD_START_TIME" ]; then
        BUILD_DURATION=$((BUILD_END_TIME - BUILD_START_TIME))
        print_info "Total build time: ${BUILD_DURATION} seconds"
    fi
    
    echo
}

# Monitor build performance
monitor_performance() {
    echo -e "${PURPLE}📊 Build Performance Summary${NC}"
    echo "=============================="
    
    # Memory usage
    MEMORY_USAGE=$(ps -A -o %mem | awk '{s+=$1} END {print s "%"}')
    print_info "Memory usage: $MEMORY_USAGE"
    
    # Disk usage
    DISK_USAGE=$(df -h . | awk 'NR==2{print $5}')
    print_info "Disk usage: $DISK_USAGE"
    
    # Build artifacts size
    if [ -d "ios/build" ]; then
        BUILD_SIZE=$(du -sh ios/build | cut -f1)
        print_info "Build artifacts size: $BUILD_SIZE"
    fi
    
    echo
}

# Main execution
main() {
    BUILD_START_TIME=$(date +%s)
    
    optimize_system
    clean_build_artifacts
    optimize_dependencies
    apply_build_optimizations
    build_optimized
    monitor_performance
    
    echo -e "${GREEN}✅ Enhanced fast build completed successfully!${NC}"
    echo -e "${CYAN}💡 Tips for even faster builds:${NC}"
    echo "   • Use 'flutter run' for development instead of full builds"
    echo "   • Enable hot reload for instant code changes"
    echo "   • Use iOS Simulator for faster testing"
    echo "   • Keep Xcode and Flutter updated"
    echo "   • Close unnecessary applications during builds"
    echo
}

# Run main function
main "$@"
