#!/usr/bin/env bash

set -Eeuo pipefail

# Использование:
#   ./fix_ios_build.sh
#   ./fix_ios_build.sh /путь/к/flutter-проекту
#
# Скрипт ищет pubspec.yaml:
# 1) в переданном пути;
# 2) в текущей папке и выше;
# 3) в папке самого скрипта и выше.

log() {
  printf '\n==> %s\n' "$1"
}

fail() {
  printf '\nОшибка: %s\n' "$1" >&2
  exit 1
}

find_flutter_root() {
  local dir="$1"

  [[ -d "$dir" ]] || return 1
  dir="$(cd "$dir" && pwd)"

  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/pubspec.yaml" && -d "$dir/ios" ]]; then
      printf '%s\n' "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done

  return 1
}

command -v flutter >/dev/null 2>&1 \
  || fail "команда flutter не найдена в PATH."

command -v pod >/dev/null 2>&1 \
  || fail "CocoaPods не установлен или команда pod не найдена."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR=""

if [[ $# -gt 0 ]]; then
  PROJECT_DIR="$(find_flutter_root "$1")" \
    || fail "по пути '$1' не найден Flutter-проект с pubspec.yaml и папкой ios."
else
  PROJECT_DIR="$(find_flutter_root "$PWD" 2>/dev/null || true)"

  if [[ -z "$PROJECT_DIR" ]]; then
    PROJECT_DIR="$(find_flutter_root "$SCRIPT_DIR" 2>/dev/null || true)"
  fi

  if [[ -z "$PROJECT_DIR" ]]; then
    fail "Flutter-проект не найден.

Запустите скрипт из папки проекта:
  cd /путь/к/проекту
  /путь/к/fix_ios_build.sh

или передайте путь явно:
  ./fix_ios_build.sh /путь/к/проекту"
  fi
fi

printf 'Flutter-проект: %s\n' "$PROJECT_DIR"

cd "$PROJECT_DIR"

log "Очистка Flutter-проекта"
flutter clean

log "Загрузка Flutter-зависимостей"
flutter pub get

log "Подготовка iOS-артефактов Flutter"
flutter precache --ios

log "Удаление DerivedData проекта Runner"
rm -rf "$HOME/Library/Developer/Xcode/DerivedData/Runner-"*

log "Переустановка CocoaPods"
cd "$PROJECT_DIR/ios"

pod deintegrate || true
rm -rf Pods
pod install --repo-update

cd "$PROJECT_DIR"

log "Готово"
printf 'Открываю: %s\n' "$PROJECT_DIR/ios/Runner.xcworkspace"
open "$PROJECT_DIR/ios/Runner.xcworkspace"
