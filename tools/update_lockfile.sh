#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

readonly NODE_IMAGE="docker.io/library/node:26.5.0-trixie-slim"

[[ -e package-lock.json ]] || echo '{}' >package-lock.json
if command -v docker &>/dev/null; then
  docker container run \
    --name "update_lockfile_$(uuidgen | head -c8)" \
    --rm \
    -u "$(id -u):$(id -g)" \
    -v "$PWD/package.json":/work/package.json:ro \
    -v "$PWD/package-lock.json":/work/package-lock.json \
    -w /work \
    "$NODE_IMAGE" sh -c 'HOME=/tmp npm update --package-lock-only --no-audit --no-fund'
elif command -v podman &>/dev/null; then
  podman container run \
    --name "update_lockfile_$(uuidgen | head -c8)" \
    --rm \
    --security-opt label=disable \
    -v "$PWD/package.json":/work/package.json:ro \
    -v "$PWD/package-lock.json":/work/package-lock.json \
    -w /work \
    "$NODE_IMAGE" sh -c 'HOME=/tmp npm update --package-lock-only --no-audit --no-fund'
else
  echo_error 'Neither docker nor podman is installed.'
  exit 1
fi
