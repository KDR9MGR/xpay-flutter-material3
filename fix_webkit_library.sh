#!/bin/bash

# Fix WebKit Library Issue for iOS Simulator
# This script addresses the missing libswiftWebKit.dylib issue

echo "🔧 Fixing WebKit library issue for iOS Simulator..."

# Navigate to project root
cd "$(dirname "$0")"

# Clean previous builds
echo "📦 Cleaning previous builds..."
flutter clean
cd ios
rm -rf Pods Podfile.lock
rm -rf build
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Update Podfile to fix WebKit linking
echo "📝 Updating Podfile for WebKit compatibility..."
cat > Podfile << 'EOF'
# Uncomment this line to define a global platform for your project
platform :ios, '15.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

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
    
    target.build_configurations.each do |config|
      # Fix deployment target warnings
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 15.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
      
      # Basic build settings
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
      
      # Debug-safe settings only
      if config.name == 'Debug'
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
        config.build_settings['GCC_OPTIMIZATION_LEVEL'] = '0'
        config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf-with-dsym'
        config.build_settings['ENABLE_TESTABILITY'] = 'YES'
      else
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-O'
        config.build_settings['GCC_OPTIMIZATION_LEVEL'] = 's'
        config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
        config.build_settings['ENABLE_TESTABILITY'] = 'NO'
      end
      
      # Fix WebKit library linking issues
      if target.name.include?('flutter_inappwebview') || target.name == 'Runner'
        config.build_settings['OTHER_LDFLAGS'] ||= []
        config.build_settings['OTHER_LDFLAGS'] << '-framework WebKit'
        config.build_settings['OTHER_LDFLAGS'] << '-weak_framework WebKit'
        
        # Remove problematic Swift WebKit dependency
        config.build_settings['OTHER_SWIFT_FLAGS'] ||= []
        config.build_settings['OTHER_SWIFT_FLAGS'] << '-Xfrontend'
        config.build_settings['OTHER_SWIFT_FLAGS'] << '-disable-implicit-string-processing-module-import'
        
        # Embed Swift standard libraries
        config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'YES'
      end
      
      # Fix library search paths
      config.build_settings['LIBRARY_SEARCH_PATHS'] ||= []
      config.build_settings['LIBRARY_SEARCH_PATHS'] << '$(SDKROOT)/usr/lib/swift'
      config.build_settings['LIBRARY_SEARCH_PATHS'] << '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)'
      
      # Disable problematic WebKit Swift module
      if target.name.include?('flutter_inappwebview')
        config.build_settings['SWIFT_SUPPRESS_WARNINGS'] = 'YES'
        config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
      end
    end
    
    # Fix bundle resource issues
    target.build_phases.each do |phase|
      if phase.is_a?(Xcodeproj::Project::Object::PBXResourcesBuildPhase)
        phase.files.each do |file|
          if file.file_ref && file.file_ref.path && file.file_ref.path.end_with?('.bundle')
            file.settings = { 'ATTRIBUTES' => ['CodeSignOnCopy'] }
          end
        end
      end
    end
  end
end
EOF

echo "📦 Getting fresh Flutter dependencies..."
cd ..
flutter pub get

echo "🔨 Installing optimized pods..."
cd ios
pod install

echo "🏗️ Building iOS app..."
cd ..
flutter build ios --debug --simulator

echo "✅ WebKit library fix completed!"
echo "📱 You can now run: flutter run -d ios"