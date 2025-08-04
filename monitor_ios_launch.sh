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
