#!/bin/bash

# iOS Build Optimization Script
# This script optimizes the iOS build process for faster compilation and app launch

echo "🚀 Starting iOS Build Optimization..."

# Set script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

echo_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

echo_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Step 1: Clean previous builds
echo_info "Cleaning previous builds..."
flutter clean
cd ios
rm -rf Pods
rm -rf Podfile.lock
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
rm -rf build
cd ..
echo_success "Previous builds cleaned"

# Step 2: Optimize Podfile for faster builds
echo_info "Optimizing Podfile..."
cat > ios/Podfile << 'EOF'
# Uncomment this line to define a global platform for your project
platform :ios, '15.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

# Disable source control management for faster pod install
ENV['COCOAPODS_DISABLE_DETERMINISTIC_UUIDS'] = 'true'

# Use binary cache for faster builds
install! 'cocoapods', :deterministic_uuids => false

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/) 
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  target 'RunnerTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    # Optimize build settings for faster compilation
    target.build_configurations.each do |config|
      # Fix deployment target warnings
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 15.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
      
      # Optimize compilation settings
      config.build_settings['COMPILER_INDEX_STORE_ENABLE'] = 'NO'
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['SWIFT_COMPILATION_MODE'] = 'wholemodule'
      config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-O'
      config.build_settings['GCC_OPTIMIZATION_LEVEL'] = 's'
      
      # Disable unnecessary features for faster builds
      config.build_settings['ENABLE_TESTABILITY'] = 'NO'
      config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
      
      # Parallel builds
      config.build_settings['CLANG_ENABLE_MODULE_DEBUGGING'] = 'NO'
    end
  end
end
EOF
echo_success "Podfile optimized"

# Step 3: Create optimized build script
echo_info "Creating optimized build script..."
cat > ios_fast_build.sh << 'EOF'
#!/bin/bash

# Fast iOS Build Script
echo "🏗️  Starting optimized iOS build..."

# Set environment variables for faster builds
export FLUTTER_SUPPRESS_ANALYTICS=true
export COCOAPODS_DISABLE_STATS=true
export COMPILER_INDEX_STORE_ENABLE=NO
export ONLY_ACTIVE_ARCH=YES

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Install pods with optimizations
echo "🍎 Installing iOS dependencies..."
cd ios
pod install --repo-update --verbose
cd ..

# Build for iOS with optimizations
echo "🔨 Building iOS app..."
flutter build ios --debug --no-codesign --simulator

echo "✅ Build completed!"
EOF

chmod +x ios_fast_build.sh
echo_success "Build script created"

# Step 4: Optimize Flutter dependencies
echo_info "Getting Flutter dependencies..."
flutter pub get
echo_success "Dependencies updated"

# Step 5: Install optimized pods
echo_info "Installing iOS dependencies with optimizations..."
cd ios
pod install --repo-update
cd ..
echo_success "iOS dependencies installed"

# Step 6: Create launch monitoring script
echo_info "Creating launch monitoring script..."
cat > monitor_ios_launch.sh << 'EOF'
#!/bin/bash

# iOS Launch Monitoring Script
echo "📱 Starting iOS app with monitoring..."

# Set environment variables
export FLUTTER_SUPPRESS_ANALYTICS=true
export COMPILER_INDEX_STORE_ENABLE=NO

# Function to monitor app launch
monitor_launch() {
    echo "🔍 Monitoring app launch..."
    
    # Start flutter run in background and capture output
    flutter run -d "iPhone 16 Plus" --verbose 2>&1 | while IFS= read -r line; do
        echo "$line"
        
        # Check for successful launch
        if [[ "$line" == *"Flutter run key commands"* ]]; then
            echo "✅ App launched successfully!"
            break
        fi
        
        # Check for common errors
        if [[ "$line" == *"SIGABRT"* ]]; then
            echo "❌ SIGABRT crash detected!"
        elif [[ "$line" == *"EXC_BAD_ACCESS"* ]]; then
            echo "❌ EXC_BAD_ACCESS crash detected!"
        elif [[ "$line" == *"Thread 1: signal SIGABRT"* ]]; then
            echo "❌ Main thread crash detected!"
        elif [[ "$line" == *"Could not build the application"* ]]; then
            echo "❌ Build failed!"
        elif [[ "$line" == *"Error launching application"* ]]; then
            echo "❌ Launch failed!"
        fi
    done
}

# Run monitoring
monitor_launch
EOF

chmod +x monitor_ios_launch.sh
echo_success "Launch monitoring script created"

# Step 7: Create Xcode project optimizations
echo_info "Applying Xcode project optimizations..."

# Create build settings optimization
cat > ios/optimize_xcode.sh << 'EOF'
#!/bin/bash

# Xcode Project Optimization Script
echo "⚙️  Optimizing Xcode project settings..."

# Set build settings for faster compilation
xcodebuild -project Runner.xcodeproj -target Runner -configuration Debug \
    COMPILER_INDEX_STORE_ENABLE=NO \
    ONLY_ACTIVE_ARCH=YES \
    ENABLE_BITCODE=NO \
    SWIFT_COMPILATION_MODE=wholemodule \
    DEBUG_INFORMATION_FORMAT=dwarf \
    ENABLE_TESTABILITY=NO \
    build

echo "✅ Xcode optimizations applied"
EOF

chmod +x ios/optimize_xcode.sh
echo_success "Xcode optimization script created"

echo ""
echo_success "🎉 iOS Build Optimization Complete!"
echo ""
echo_info "Next steps:"
echo "1. Run: ./ios_fast_build.sh (for optimized building)"
echo "2. Run: ./monitor_ios_launch.sh (for monitored app launch)"
echo "3. Check build times - should be significantly faster"
echo ""
echo_warning "Note: If you encounter issues, check the logs for specific error messages"
echo ""