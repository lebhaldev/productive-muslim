#!/usr/bin/env bash
# Installs the Flutter SDK that CI uses into /opt/flutter (cloud sessions
# start without it). Safe to re-run.
set -euo pipefail
VERSION="$(grep -oP "flutter-version: \K[0-9.]+" "$(dirname "$0")/../.github/workflows/ci.yml")"
if [ -x /opt/flutter/bin/flutter ] && /opt/flutter/bin/flutter --version 2>/dev/null | grep -q "Flutter $VERSION"; then
  echo "Flutter $VERSION already installed"; exit 0
fi
curl -sSfL -o /tmp/flutter.tar.xz \
  "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${VERSION}-stable.tar.xz"
rm -rf /opt/flutter && tar xf /tmp/flutter.tar.xz -C /opt && rm /tmp/flutter.tar.xz
git config --global --add safe.directory /opt/flutter
/opt/flutter/bin/flutter config --no-analytics >/dev/null
cd "$(dirname "$0")/.." && /opt/flutter/bin/flutter pub get
echo "Flutter $VERSION ready: export PATH=/opt/flutter/bin:\$PATH"
