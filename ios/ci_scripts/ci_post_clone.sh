#!/bin/sh

# Xcode Cloud CI Script - Runs after repository clone
# This script sets up Flutter and CocoaPods for iOS builds

set -e

echo "========================================"
echo "Starting Xcode Cloud Post-Clone Script"
echo "========================================"

# Navigate to project root
cd $CI_PRIMARY_REPOSITORY_PATH

echo "📍 Current directory: $(pwd)"

# Install Flutter if not available
if ! command -v flutter &> /dev/null; then
    echo "📦 Flutter not found, installing..."
    
    # Clone Flutter SDK
    git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
    export PATH="$PATH:$HOME/flutter/bin"
    
    # Disable analytics
    flutter config --no-analytics
fi

echo "🔧 Flutter version:"
flutter --version

# Get Flutter dependencies
echo "📥 Getting Flutter dependencies..."
flutter pub get

# Navigate to iOS directory
cd ios

# Install CocoaPods dependencies
echo "📦 Installing CocoaPods dependencies..."

# Check if pod command exists
if ! command -v pod &> /dev/null; then
    echo "Installing CocoaPods..."
    gem install cocoapods
fi

# Clean and install pods
echo "🧹 Cleaning CocoaPods cache..."
rm -rf Pods
rm -rf Podfile.lock

echo "🔄 Running pod install..."
pod install --repo-update

echo "========================================"
echo "✅ Post-Clone Script Completed!"
echo "========================================"

exit 0
