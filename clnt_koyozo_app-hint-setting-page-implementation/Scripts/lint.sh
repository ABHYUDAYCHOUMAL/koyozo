#!/bin/bash

# Linting script for Koyozo iOS App

set -e

echo "Running SwiftLint..."

# Check if SwiftLint is installed
if ! command -v swiftlint &> /dev/null; then
    echo "SwiftLint is not installed. Install it using: brew install swiftlint"
    exit 1
fi

# Run SwiftLint
swiftlint lint --strict

echo "Linting completed!"

