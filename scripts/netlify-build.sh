#!/bin/bash
set -e

echo "=== PINCUS WORK NETLIFY BUILD ==="

FLUTTER_VERSION="3.44.4"
FLUTTER_DIR="$HOME/flutter"

if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
    echo "=== INSTALLIERE FLUTTER ${FLUTTER_VERSION} ==="
    git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

echo "=== FLUTTER ==="
flutter --version

echo "=== DEPENDENCIES ==="
flutter pub get

echo "=== BUILD WEB ==="
flutter build web --release

echo "=== BUILD FERTIG ==="
ls -lah build/web
