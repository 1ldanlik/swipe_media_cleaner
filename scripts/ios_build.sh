#!/usr/bin/env bash
set -euo pipefail

APP_NAME="Runner"
IPA_NAME="swipe_media_cleaner"

# Если скрипт лежит в scripts/, корень проекта — на уровень выше.
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Папка для готовых IPA на рабочем столе.
OUTPUT_DIR="$HOME/Desktop/builds"

cd "$ROOT_DIR"

echo "==> Project root: $ROOT_DIR"
echo "==> Output dir: $OUTPUT_DIR"

if [ ! -f "pubspec.yaml" ]; then
  echo "ERROR: pubspec.yaml not found in $ROOT_DIR"
  exit 1
fi

# Extracts only the version string, for example: 1.0.10 or 1.0.10+3
VERSION=$(grep '^version: ' pubspec.yaml | sed 's/version: //')

if [ -z "$VERSION" ]; then
  echo "ERROR: version not found in pubspec.yaml"
  exit 1
fi

echo "==> App Version: $VERSION"

IPA_VERSION="${VERSION%%+*}"
BUILD_NUMBER="${VERSION##*+}"

if [ "$BUILD_NUMBER" = "$VERSION" ]; then
  IPA_FILE="${IPA_NAME}_v${IPA_VERSION}.ipa"
else
  IPA_FILE="${IPA_NAME}_v${IPA_VERSION}_build${BUILD_NUMBER}.ipa"
fi

echo "==> IPA file: $IPA_FILE"

mkdir -p "$OUTPUT_DIR"

echo "==> Cleaning old temporary files..."
rm -rf Payload
rm -f "$OUTPUT_DIR/$IPA_FILE"

echo "==> Flutter clean..."
flutter clean

echo "==> Flutter pub get..."
flutter pub get

echo "==> Installing CocoaPods..."
cd ios
pod install
cd ..

echo "==> Building iOS app without codesign..."
flutter build ios --release --no-codesign

APP_PATH="build/ios/iphoneos/${APP_NAME}.app"

if [ ! -d "$APP_PATH" ]; then
  echo "ERROR: $APP_PATH not found"
  exit 1
fi

echo "==> Creating Payload..."
rm -rf Payload
mkdir -p Payload
cp -R "$APP_PATH" Payload/

echo "==> Creating IPA..."
zip -r "$OUTPUT_DIR/$IPA_FILE" Payload

echo "==> Cleaning temporary Payload..."
rm -rf Payload

echo "==> Done:"
echo "$OUTPUT_DIR/$IPA_FILE"