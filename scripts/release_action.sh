#!/usr/bin/env bash
set -euo pipefail

# Корень проекта: если скрипт лежит в scripts/, поднимаемся на уровень выше.
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if [ ! -f "pubspec.yaml" ]; then
  echo "Ошибка: pubspec.yaml не найден в $ROOT_DIR"
  exit 1
fi

# Extracts only the version string, for example: 1.0.10 or 1.0.10+25
VERSION=$(grep '^version: ' pubspec.yaml | sed 's/version: //')

if [ -z "$VERSION" ]; then
  echo "Ошибка: version не найден в pubspec.yaml"
  exit 1
fi

echo "App Version: $VERSION"

# Из version: 1.0.10+25 берём только 1.0.10
TAG_VERSION="${VERSION%%+*}"
TAG="v${TAG_VERSION}"

echo "Git tag: $TAG"

if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Ошибка: тег $TAG уже существует. Измените version в pubspec.yaml или удалите существующий тег."
  exit 1
fi

echo "Создаю тег $TAG..."
git tag "$TAG"

echo "Пушу тег на origin..."
git push origin "$TAG"

echo "Готово. GitHub Actions будет запущен автоматически для тега $TAG."