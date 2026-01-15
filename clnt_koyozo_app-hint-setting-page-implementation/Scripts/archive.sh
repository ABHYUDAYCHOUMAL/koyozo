#!/bin/bash

# Archive script for Koyozo iOS App

set -e

echo "Creating archive..."

# Archive command (adjust paths as needed)
xcodebuild archive -project koyozoclub.xcodeproj \
                   -scheme koyozoclub \
                   -configuration Release \
                   -archivePath ./build/koyozoclub.xcarchive

echo "Archive created successfully at ./build/koyozoclub.xcarchive"

