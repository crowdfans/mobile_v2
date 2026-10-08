#!/usr/bin/env bash
# Copia GoogleService-Info.plist do stub do flavor → ios/Runner/.
# Uso: ./scripts/sync_firebase_flavor.sh gcp|digitalocean
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FLAVOR="${1:-gcp}"
case "$FLAVOR" in
  local) FLAVOR=gcp ;;
  do) FLAVOR=digitalocean ;;
esac
SRC="$ROOT/ios/Firebase/$FLAVOR/GoogleService-Info.plist"
DST="$ROOT/ios/Runner/GoogleService-Info.plist"
if [[ ! -f "$SRC" ]]; then
  echo "stub ausente: $SRC" >&2
  exit 1
fi
cp "$SRC" "$DST"
echo "→ iOS GoogleService-Info.plist = flavor $FLAVOR"
