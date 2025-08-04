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
