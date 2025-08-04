#!/bin/bash

# Fast iOS Build Script
echo "⚡ Starting Fast iOS Build..."

# Pre-build optimizations
echo "🔧 Pre-build optimizations..."
flutter clean
flutter pub get

# Build with optimizations
echo "🏗️  Building iOS app..."
time flutter build ios --release --no-codesign

echo "✅ Build completed!"
