#!/bin/bash

# Script to generate Flutter launcher icons

echo "Running app icon generation..."

# Move to project root directory
cd "$(dirname "$0")/.." || exit

# Generate launcher icons from pubspec.yaml config
dart run flutter_launcher_icons

echo "App icon generation completed!"
