#!/usr/bin/env bash
set -euo pipefail

# Укажите новую версию здесь перед запуском.
VERSION="1.0.10"
TAG="v${VERSION}"

if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Ошибка: тег $TAG уже существует. Измените VERSION или удалите существующий тег."
  exit 1
fi

echo "Создаю тег $TAG..."
git tag "$TAG"
echo "Пушу тег на origin..."
git push origin "$TAG"

echo "Готово. GitHub Actions будет запущен автоматически для тега $TAG."