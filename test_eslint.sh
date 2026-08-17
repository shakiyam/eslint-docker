#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/tools/colored_echo.sh
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/tools/container_engine.sh

CONTAINER_ENGINE=$(detect_container_engine)
readonly CONTAINER_ENGINE

IMAGE_NAME=ghcr.io/shakiyam/eslint
readonly IMAGE_NAME

if [[ $CONTAINER_ENGINE == docker ]]; then
  ENGINE_OPTS=(-u "$(id -u):$(id -g)")
else
  ENGINE_OPTS=(--security-opt label=disable)
fi
readonly ENGINE_OPTS

WORK_DIR=$(mktemp -d)
readonly WORK_DIR
trap 'rm -rf "$WORK_DIR"' EXIT

cat >"$WORK_DIR"/eslint.config.js <<'EOF'
module.exports = [
  {
    rules: {
      'no-unused-vars': 'error'
    }
  }
];
EOF

echo 'const unused = 1;' >"$WORK_DIR"/sample.js

set +e
OUTPUT=$($CONTAINER_ENGINE container run \
  --name "test_eslint_$(uuidgen | head -c8)" \
  --rm \
  --pull=never \
  "${ENGINE_OPTS[@]}" \
  -v "$WORK_DIR":/work:ro \
  "$IMAGE_NAME" sample.js 2>&1)
STATUS=$?
set -e
readonly OUTPUT STATUS

if [[ $STATUS -eq 0 ]]; then
  echo_error 'Test failed: eslint did not detect the rule violation.'
  exit 1
elif [[ $STATUS -ne 1 ]]; then
  echo_error "Test failed: eslint exited with an unexpected status $STATUS."
  echo "$OUTPUT"
  exit 1
fi

if ! grep -q 'no-unused-vars' <<<"$OUTPUT"; then
  echo_error 'Test failed: eslint output does not mention no-unused-vars.'
  echo "$OUTPUT"
  exit 1
fi

echo_success 'Test passed: eslint detected the no-unused-vars violation.'
