#!/bin/bash

# Build script for Koyozo iOS App

set -e

echo "Building Koyozo iOS App..."

# Build command
xcodebuild -project koyozoclub.xcodeproj \
           -scheme koyozoclub \
           -configuration Debug \
           -destination 'platform=iOS Simulator,name=iPhone 15' \
           clean build

echo "Build completed successfully!"

