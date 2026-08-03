#!/bin/bash
set -Eeu -o pipefail

if command -v docker &>/dev/null; then
  docker container run \
    --name "eslint_$(uuidgen | head -c8)" \
    --rm \
    -t \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/work:ro \
    ghcr.io/shakiyam/eslint "$@"
elif command -v podman &>/dev/null; then
  podman container run \
    --name "eslint_$(uuidgen | head -c8)" \
    --rm \
    --security-opt label=disable \
    -t \
    -v "$PWD":/work:ro \
    ghcr.io/shakiyam/eslint "$@"
else
  if [[ -t 2 ]]; then
    echo -e "\033[1;31mNeither docker nor podman is installed.\033[0m" >&2 # Bold Red
  else
    echo 'Neither docker nor podman is installed.' >&2
  fi
  exit 1
fi
