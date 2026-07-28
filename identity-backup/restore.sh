#!/usr/bin/env bash
set -euo pipefail

umask 077

usage() {
  printf 'Usage:\n' >&2
  printf '  %s ARCHIVE                 # restore into a new staging directory\n' "$0" >&2
  printf '  %s --home ARCHIVE          # restore directly into your home directory\n' "$0" >&2
  exit 2
}

restore_home=false

if [[ "${1:-}" == "--home" ]]; then
  restore_home=true
  shift
fi

[[ $# -eq 1 ]] || usage
archive="$1"

if ! command -v unzip >/dev/null 2>&1; then
  printf 'Required command not found: unzip\n' >&2
  exit 1
fi

if [[ ! -f "$archive" ]]; then
  printf 'Archive not found: %s\n' "$archive" >&2
  exit 1
fi

if "$restore_home"; then
  target="$HOME"
  printf 'This can overwrite identity and credential files in %s.\n' "$HOME"
  read -r -p 'Type RESTORE to continue: ' answer
  if [[ "$answer" != "RESTORE" ]]; then
    printf 'Restore cancelled.\n'
    exit 1
  fi
else
  target="$PWD/identity-restore-$(date +%Y-%m-%d_%H-%M-%S)"
  mkdir -m 700 -- "$target"
fi

printf 'Restoring into: %s\n' "$target"
unzip -q "$archive" -d "$target"

if "$restore_home"; then
  [[ -d "$HOME/.ssh" ]] && chmod 700 "$HOME/.ssh"
  [[ -d "$HOME/.gnupg" ]] && chmod 700 "$HOME/.gnupg"
fi

printf 'Restore complete: %s\n' "$target"
