#!/bin/bash

# Fix iOS WebKit crash by cleaning and rebuilding without flutter_inappwebview

echo "🔧 Fixing iOS WebKit crash (SIGABRT - libswiftWebKit.dylib missing)"
echo "================================================"

# Stop any running processes
echo "📱 Stopping iOS Simulator..."
xcrun simctl shutdown all 2>/dev/null || true

# Navigate to project directory
cd "$(dirname "$0")"

# Clean Flutter
echo "🧹 Cleaning Flutter build cache..."
flutter clean

# Remove iOS build artifacts
echo "🗑️  Removing iOS build artifacts..."
rm -rf ios/build/
rm -rf ios/.symlinks/
rm -rf ios/Pods/
rm -rf ios/Podfile.lock
rm -rf build/

# Clean Xcode derived data
echo "🧹 Cleaning Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*
rm -rf ~/Library/Developer/Xcode/DerivedData/digital_payments-*

# Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Update iOS deployment target in Podfile to ensure compatibility
echo "⚙️  Updating iOS deployment target..."
if [ -f "ios/Podfile" ]; then
    # Ensure minimum iOS 15.0 for WebKit compatibility
    sed -i '' "s/platform :ios, '[0-9.]*'/platform :ios, '15.0'/g" ios/Podfile
fi

# Add WebKit framework linking fix to Podfile
echo "🔗 Adding WebKit framework fix to Podfile..."
cat >> ios/Podfile << 'EOF'

# Fix for WebKit framework linking
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
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
      
      # WebKit framework linking fix
      config.build_settings['OTHER_LDFLAGS'] ||= []
      config.build_settings['OTHER_LDFLAGS'] << '-framework WebKit'
      config.build_settings['OTHER_LDFLAGS'] << '-weak_framework WebKit'
      
      # Ensure Swift standard libraries are embedded
      config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'YES'
    end
  end
end
EOF

# Install pods with verbose output
echo "📦 Installing CocoaPods dependencies..."
cd ios
pod install --verbose
cd ..

# Build iOS app
echo "🔨 Building iOS app..."
flutter build ios --debug --simulator

echo "✅ iOS WebKit crash fix completed!"
echo "📱 You can now run: flutter run"
echo "================================================"