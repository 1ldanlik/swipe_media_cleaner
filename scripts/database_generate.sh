#!/bin/sh

set -e

echo "📦 Getting dependencies..."
flutter pub get

echo "🧹 Cleaning previous build_runner cache..."
dart run build_runner clean

echo "⚙️ Generating Drift database files..."
dart run build_runner build --delete-conflicting-outputs

echo "✅ Drift database generated successfully"