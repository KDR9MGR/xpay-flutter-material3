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
