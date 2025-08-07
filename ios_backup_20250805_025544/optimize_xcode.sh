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
