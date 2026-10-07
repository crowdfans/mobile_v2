#!/usr/bin/env bash
# Roda o app com flavor/backend GCP ou DigitalOcean.
# Uso:
#   ./scripts/run_backend.sh gcp
#   ./scripts/run_backend.sh digitalocean
#   ./scripts/run_backend.sh local
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BACKEND="${1:-gcp}"
CONFIG="config/${BACKEND}.json"
if [[ ! -f "$CONFIG" ]]; then
  echo "config ausente: $CONFIG (backends: gcp | digitalocean | local)" >&2
  exit 1
fi

export PATH="${HOME}/sdk/flutter/bin:${PATH:-}"

# Android: --flavor gcp|digitalocean. local usa flavor gcp + API_MODE=local.
FLAVOR_ARGS=()
IOS_FLAVOR=gcp
case "$BACKEND" in
  gcp|digitalocean)
    FLAVOR_ARGS=(--flavor "$BACKEND")
    IOS_FLAVOR="$BACKEND"
    ;;
  local)
    FLAVOR_ARGS=(--flavor gcp)
    IOS_FLAVOR=gcp
    ;;
  *)
    echo "backend inválido: $BACKEND" >&2
    exit 1
    ;;
esac

bash "$ROOT/scripts/sync_firebase_flavor.sh" "$IOS_FLAVOR"

exec flutter run "${FLAVOR_ARGS[@]}" --dart-define-from-file="$CONFIG" "${@:2}"
