#!/usr/bin/env bash
set -euo pipefail

umask 077

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
path_list="$script_dir/paths.txt"
destination="${1:-}"

if [[ -z "$destination" ]]; then
  printf 'Usage: %s DESTINATION_DIRECTORY\n' "$0" >&2
  printf 'Example: %s /mnt/external-drive\n' "$0" >&2
  exit 2
fi

if ! command -v zip >/dev/null 2>&1; then
  printf 'Required command not found: zip\n' >&2
  exit 1
fi

if [[ ! -d "$destination" ]]; then
  printf 'Destination is not a directory: %s\n' "$destination" >&2
  exit 1
fi

timestamp="$(date +%Y-%m-%d_%H-%M-%S)"
archive="$destination/identity-backup-${timestamp}.zip"
partial_archive="$destination/.identity-backup-${timestamp}.partial.zip"
declare -a backup_paths=()

cleanup() {
  rm -f -- "$partial_archive"
}
trap cleanup EXIT

while IFS= read -r entry || [[ -n "$entry" ]]; do
  entry="${entry%$'\r'}"
  [[ -z "$entry" || "$entry" == \#* ]] && continue

  if [[ "$entry" == /* || "$entry" == ".." || "$entry" == ../* || "$entry" == */../* ]]; then
    printf 'Unsafe entry in %s: %s\n' "$path_list" "$entry" >&2
    exit 1
  fi

  if [[ -e "$HOME/$entry" ]]; then
    backup_paths+=("$entry")
  else
    printf 'Skipping missing path: ~/%s\n' "$entry"
  fi
done <"$path_list"

if [[ ${#backup_paths[@]} -eq 0 ]]; then
  printf 'None of the paths in %s exist.\n' "$path_list" >&2
  exit 1
fi

printf 'Creating UNENCRYPTED credential backup.\n'

(
  cd -- "$HOME"
  zip -q -r "$partial_archive" "${backup_paths[@]}" \
    -x '*.sock' '*/S.gpg-agent*' '.gnupg/random_seed'
)

mv -- "$partial_archive" "$archive"
chmod 600 "$archive"

printf 'Backup created: %s\n' "$archive"
printf 'WARNING: This ZIP is not encrypted and contains readable private credentials.\n'
