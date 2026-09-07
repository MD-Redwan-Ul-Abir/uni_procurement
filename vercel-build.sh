#!/bin/bash
set -e

echo "=== Checking Flutter SDK ==="
if [ ! -d "flutter" ]; then
  echo "=== Cloning Flutter SDK (stable branch) ==="
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter
fi

export PATH="$PATH:$(pwd)/flutter/bin"

echo "=== Flutter Version ==="
flutter --version

echo "=== Building Flutter Web Release ==="
flutter config --enable-web
flutter pub get
flutter build web --release --no-wasm-dry-run

echo "=== Flutter Web Build Complete ==="
