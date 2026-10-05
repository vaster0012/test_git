#!/usr/bin/env bash
set -Eeuo pipefail

readonly URL="https://raw.githubusercontent.com/vaster0012/test_git/main/setup_enviroment.sh"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

curl -fsSL "$URL" -o "$tmp"
bash "$tmp" --zsh-only
