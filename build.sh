#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "Building World Clock..."

SDK_PATH=$(xcrun --show-sdk-path)

swiftc \
    -target arm64-apple-macos13.0 \
    -sdk "$SDK_PATH" \
    -parse-as-library \
    -O \
    -o WorldClock \
    Sources/*.swift

echo "Creating app bundle..."
rm -rf "World Clock.app"
mkdir -p "World Clock.app/Contents/MacOS"
mkdir -p "World Clock.app/Contents/Resources"
cp WorldClock "World Clock.app/Contents/MacOS/"
cp Info.plist "World Clock.app/Contents/"
rm WorldClock

echo "Built successfully: World Clock.app"
echo "Run with: open 'World Clock.app'"
