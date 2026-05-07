#!/usr/bin/env bash
# doc-drift.sh — Detect documentation drift between README.md and repo contents.
# Compares the "Included Files" section of README.md against tracked files.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
README="$REPO_ROOT/README.md"

if [[ ! -f "$README" ]]; then
  echo "ERROR: README.md not found at $README" >&2
  exit 1
fi

# Extract documented entries from the "Included Files" section.
# Each entry looks like: - `name` - description
documented=()
in_section=false
while IFS= read -r line; do
  if [[ "$line" =~ ^###?\ +Included\ Files ]]; then
    in_section=true
    continue
  fi
  if $in_section; then
    # End of section: next heading
    if [[ "$line" =~ ^###?\ + ]] && [[ ! "$line" =~ Included\ Files ]]; then
      break
    fi
    # Match lines like: - `entry` - description  OR  - `.entry` - description
    if [[ "$line" =~ ^-\ +\`([^\`]+)\` ]]; then
      documented+=("${BASH_REMATCH[1]}")
    fi
  fi
done < "$README"

# Build list of top-level tracked items (files and directories) that should be documented.
# Exclude meta/hidden files that don't need documentation.
skip_patterns=(
  '.git' '.gitignore' '.gitattributes' '.git-crypt' '.stow-local-ignore'
  '.claude' '.codex' '.agents' '.config'
  'README.md' 'AGENT-CONFIG.md' 'LICENSE'
)

should_skip() {
  local item="$1"
  for pat in "${skip_patterns[@]}"; do
    [[ "$item" == "$pat" ]] && return 0
  done
  return 1
}

# Get unique top-level items from git ls-files
actual=()
while IFS= read -r entry; do
  top="${entry%%/*}"
  if ! should_skip "$top"; then
    actual+=("$top")
  fi
done < <(git ls-files | sed 's|/.*||' | sort -u)

# Find undocumented items (in repo but not in README)
undocumented=()
for item in "${actual[@]}"; do
  found=false
  for doc in "${documented[@]}"; do
    if [[ "$doc" == "$item" ]]; then
      found=true
      break
    fi
  done
  if ! $found; then
    undocumented+=("$item")
  fi
done

# Find stale entries (in README but not in repo)
stale=()
for doc in "${documented[@]}"; do
  found=false
  for item in "${actual[@]}"; do
    if [[ "$doc" == "$item" ]]; then
      found=true
      break
    fi
  done
  if ! $found; then
    stale+=("$doc")
  fi
done

# Report results
exit_code=0

if [[ ${#undocumented[@]} -gt 0 ]]; then
  echo "Undocumented files/directories (in repo but missing from README):"
  for item in "${undocumented[@]}"; do
    echo "  + $item"
  done
  exit_code=1
fi

if [[ ${#stale[@]} -gt 0 ]]; then
  echo "Stale documentation entries (in README but not in repo):"
  for item in "${stale[@]}"; do
    echo "  - $item"
  done
  exit_code=1
fi

if [[ $exit_code -eq 0 ]]; then
  echo "No documentation drift detected."
fi

exit $exit_code
