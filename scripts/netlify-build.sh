#!/bin/bash
set -e

echo "=== PINCUS WORK NETLIFY BUILD ==="

FLUTTER_VERSION="3.44.4"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter nicht gefunden – installiere Flutter ${FLUTTER_VERSION}..."

  git clone --depth 1 --branch ${FLUTTER_VERSION} \
    https://github.com/flutter/flutter.git "$HOME/flutter"

  export PATH="$HOME/flutter/bin:$PATH"

  flutter --version
fi

export PATH="$HOME/flutter/bin:$PATH"

echo "=== FLUTTER ==="
flutter --version

echo "=== DEPENDENCIES ==="
flutter pub get

echo "=== BUILD WEB ==="
flutter build web --release

echo "=== BUILD FERTIG ==="
ls -lah build/web
