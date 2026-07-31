#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/container_engine.sh

readonly NODE_IMAGE="docker.io/library/node:26.5.1-trixie-slim"

CONTAINER_ENGINE=$(detect_container_engine)
readonly CONTAINER_ENGINE
if [[ $CONTAINER_ENGINE == docker ]]; then
  ENGINE_OPTS=(-u "$(id -u):$(id -g)")
else
  ENGINE_OPTS=(--security-opt label=disable)
fi
readonly ENGINE_OPTS

[[ -e package-lock.json ]] || echo '{}' >package-lock.json
$CONTAINER_ENGINE container run \
  --name "update_lockfile_$(uuidgen | head -c8)" \
  --rm \
  "${ENGINE_OPTS[@]}" \
  -v "$PWD/package.json":/work/package.json:ro \
  -v "$PWD/package-lock.json":/work/package-lock.json \
  -w /work \
  "$NODE_IMAGE" sh -c 'HOME=/tmp npm update --package-lock-only --no-audit --no-fund'
