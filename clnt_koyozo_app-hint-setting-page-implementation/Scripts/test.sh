#!/bin/bash

# Test runner script for Koyozo iOS App

set -e

echo "Running tests..."

# Run unit tests
xcodebuild test -project koyozoclub.xcodeproj \
                -scheme koyozoclub \
                -destination 'platform=iOS Simulator,name=iPhone 15'

echo "Tests completed!"

