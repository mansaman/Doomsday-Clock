#!/bin/bash
set -e

# Install Flutter onto Vercel's build environment
FLUTTER_BIN="$HOME/flutter/bin/flutter"

if [ ! -x "$FLUTTER_BIN" ]; then
  echo "Installing Flutter..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$HOME/flutter" > /dev/null 2>&1 || {
    curl -fsSL -o /tmp/flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.3-stable.tar.xz
    mkdir -p "$HOME/flutter"
    tar -xf /tmp/flutter.tar.xz -C "$HOME" 
    mv "$HOME"/flutter_*/* "$HOME/flutter"
  }
else
  echo "Flutter already installed."
fi

export PATH="$PATH:$HOME/flutter/bin"
flutter config --no-analytics > /dev/null 2>&1 || true
flutter pub get > /dev/null
flutter build web --release