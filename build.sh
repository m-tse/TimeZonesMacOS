#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "Building Time Zones..."

SDK_PATH=$(xcrun --show-sdk-path)

swiftc \
    -target arm64-apple-macos13.0 \
    -sdk "$SDK_PATH" \
    -parse-as-library \
    -O \
    -o TimeZones \
    Sources/*.swift

echo "Creating app bundle..."
rm -rf "Time Zones.app"
mkdir -p "Time Zones.app/Contents/MacOS"
mkdir -p "Time Zones.app/Contents/Resources"
cp TimeZones "Time Zones.app/Contents/MacOS/"
cp Info.plist "Time Zones.app/Contents/"
cp Sources/AppIcon.png "Time Zones.app/Contents/Resources/"

# Generate .icns from AppIcon.png
ICONSET_DIR=$(mktemp -d)/AppIcon.iconset
mkdir -p "$ICONSET_DIR"
sips -z 16 16     Sources/AppIcon.png --out "$ICONSET_DIR/icon_16x16.png" > /dev/null 2>&1
sips -z 32 32     Sources/AppIcon.png --out "$ICONSET_DIR/icon_16x16@2x.png" > /dev/null 2>&1
sips -z 32 32     Sources/AppIcon.png --out "$ICONSET_DIR/icon_32x32.png" > /dev/null 2>&1
sips -z 64 64     Sources/AppIcon.png --out "$ICONSET_DIR/icon_32x32@2x.png" > /dev/null 2>&1
sips -z 128 128   Sources/AppIcon.png --out "$ICONSET_DIR/icon_128x128.png" > /dev/null 2>&1
sips -z 256 256   Sources/AppIcon.png --out "$ICONSET_DIR/icon_128x128@2x.png" > /dev/null 2>&1
sips -z 256 256   Sources/AppIcon.png --out "$ICONSET_DIR/icon_256x256.png" > /dev/null 2>&1
sips -z 512 512   Sources/AppIcon.png --out "$ICONSET_DIR/icon_256x256@2x.png" > /dev/null 2>&1
sips -z 512 512   Sources/AppIcon.png --out "$ICONSET_DIR/icon_512x512.png" > /dev/null 2>&1
sips -z 1024 1024 Sources/AppIcon.png --out "$ICONSET_DIR/icon_512x512@2x.png" > /dev/null 2>&1
iconutil -c icns "$ICONSET_DIR" -o "Time Zones.app/Contents/Resources/AppIcon.icns"
rm -rf "$(dirname "$ICONSET_DIR")"

rm TimeZones

echo "Built successfully: Time Zones.app"
echo "Run with: open 'Time Zones.app'"
