#!/bin/bash
# Optimize Xcode build phases
echo "Optimizing build phases..."

# Set parallel build settings
export CLANG_ENABLE_MODULES=YES
export SWIFT_COMPILATION_MODE=wholemodule
export COMPILER_INDEX_STORE_ENABLE=NO

echo "Build phases optimized"
