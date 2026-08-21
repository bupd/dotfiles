#!/usr/bin/env bash
# Deterministic jj workspace lifecycle for skills and platform hooks.
set -euo pipefail

die() {
  echo "jj-skipper: $1" >&2
  exit 1
}

usage() {
  cat >&2 <<'EOF'
Usage:
  workspace.sh create --repo PATH --name NAME [--base fresh|head|REVSET] [--description TEXT]
  workspace.sh remove --repo PATH --path PATH
  workspace.sh hook-create
  workspace.sh hook-remove
EOF
  exit 2
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "$1 is required"
}

validate_name() {
  local name="$1"
  [[ ${#name} -le 64 ]] || die "workspace name must be at most 64 characters"
  [[ "$name" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] ||
    die "invalid workspace name '$name' (start with a letter or number; then use letters, numbers, dot, underscore, or dash)"
}

workspace_root() {
  jj -R "$1" workspace root --color=never 2>/dev/null ||
    die "'$1' is not inside a jj workspace"
}

main_workspace_root() {
  local hint="$1" source_root candidate
  source_root=$(workspace_root "$hint")

  candidate=$(jj -R "$source_root" workspace root --name default --color=never 2>/dev/null || true)
  if [[ -n "$candidate" && -d "$candidate/.jj" ]]; then
    (cd "$candidate" && pwd -P)
  elif [[ -d "$source_root/.jj" ]]; then
    (cd "$source_root" && pwd -P)
  else
    die "cannot locate the primary jj workspace from '$hint'"
  fi
}

canonical_path() {
  local path="$1" parent base
  if [[ -d "$path" ]]; then
    (cd "$path" && pwd -P)
    return
  fi
  parent=$(dirname "$path")
  base=$(basename "$path")
  [[ -d "$parent" ]] || die "parent directory '$parent' does not exist"
  printf '%s/%s\n' "$(cd "$parent" && pwd -P)" "$base"
}

workspace_name_for_path() {
  local repo="$1" wanted="$2" name root canonical_root
  while IFS=$'\t' read -r name root; do
    [[ -n "$name" && -n "$root" ]] || continue
    canonical_root=$(canonical_path "$root")
    if [[ "$canonical_root" == "$wanted" ]]; then
      printf '%s\n' "$name"
      return 0
    fi
  done < <(jj -R "$repo" workspace list --color=never -T 'name ++ "\t" ++ root ++ "\n"')
  return 1
}

resolve_base_args() {
  local source_root="$1" base="$2" revset id found=0 trunk_state
  case "$base" in
    fresh)
      revset='trunk()'
      trunk_state=$(jj -R "$source_root" log -r "$revset" --no-graph --color=never \
        -T 'if(root, "root", "nonroot")' 2>/dev/null || true)
      if [[ -z "$trunk_state" || "$trunk_state" == "root" ]]; then
        revset='@-'
      fi
      ;;
    head) revset='@' ;;
    *) revset="$base" ;;
  esac

  while IFS= read -r id; do
    [[ -n "$id" ]] || continue
    BASE_ARGS+=(--revision "$id")
    found=1
  done < <(jj -R "$source_root" log -r "$revset" --no-graph --color=never -T 'commit_id ++ "\n"' 2>/dev/null)
  [[ $found -eq 1 ]] || die "base '$base' does not resolve to a revision"
}

create_workspace() {
  local repo_hint="$1" name="$2" base="$3" description="$4"
  local source_root main_root workspace_dir workspace_path created=0
  local -a BASE_ARGS=()

  require_command jj
  validate_name "$name"
  source_root=$(workspace_root "$repo_hint")
  main_root=$(main_workspace_root "$source_root")
  workspace_dir="$main_root/.worktrees"
  mkdir -p "$workspace_dir"
  workspace_dir=$(canonical_path "$workspace_dir")
  workspace_path="$workspace_dir/$name"

  [[ ! -e "$workspace_path" && ! -L "$workspace_path" ]] ||
    die "workspace path already exists: $workspace_path"
  if jj -R "$main_root" workspace list --color=never -T 'name ++ "\n"' | grep -Fxq -- "$name"; then
    die "workspace name already exists: $name"
  fi
  if jj -R "$main_root" bookmark list "$name" --color=never -T 'name ++ "\n"' 2>/dev/null | grep -Fxq -- "$name"; then
    die "bookmark already exists: $name"
  fi

  resolve_base_args "$source_root" "$base"

  rollback() {
    local rc=$?
    if [[ $created -eq 1 ]]; then
      jj -R "$main_root" workspace forget -- "$name" >/dev/null 2>&1 || true
      rm -rf -- "$workspace_path"
    fi
    exit "$rc"
  }
  trap rollback ERR INT TERM

  jj -R "$main_root" workspace add "$workspace_path" --name "$name" \
    "${BASE_ARGS[@]}" --message "$description" >&2
  created=1
  jj -R "$workspace_path" bookmark create "$name" -r @ >&2

  trap - ERR INT TERM
  printf '%s\n' "$workspace_path"
}

preserve_unbookmarked_work() {
  local workspace_path="$1" name="$2" state bookmarks recovery change
  state=$(jj -R "$workspace_path" log -r @ --no-graph --color=never \
    -T 'if(empty, "empty", "changed") ++ " " ++ if(conflict, "conflicted", "clean")')
  bookmarks=$(jj -R "$workspace_path" bookmark list -r @ --color=never -T 'name ++ "\n"')
  if [[ -z "$bookmarks" && "$state" != "empty clean" ]]; then
    change=$(jj -R "$workspace_path" log -r @ --no-graph --color=never -T 'change_id.short()')
    recovery="jj-skipper-recovery-$name-$change"
    jj -R "$workspace_path" bookmark set "$recovery" -r @ >&2
    echo "jj-skipper: preserved unbookmarked work as '$recovery'" >&2
  fi
}

remove_workspace() {
  local repo_hint="$1" path="$2" main_root workspace_dir workspace_path name

  require_command jj
  [[ "$path" = /* ]] || die "workspace path must be absolute"
  main_root=$(main_workspace_root "$repo_hint")
  workspace_dir="$main_root/.worktrees"
  [[ -d "$workspace_dir" ]] || die "workspace directory does not exist: $workspace_dir"
  workspace_dir=$(canonical_path "$workspace_dir")
  workspace_path=$(canonical_path "$path")

  case "$workspace_path" in
    "$workspace_dir"/*) ;;
    *) die "refusing to remove path outside '$workspace_dir': $workspace_path" ;;
  esac

  name=$(workspace_name_for_path "$main_root" "$workspace_path") ||
    die "path is not a registered jj workspace: $workspace_path"
  validate_name "$name"

  if [[ -d "$workspace_path" ]]; then
    preserve_unbookmarked_work "$workspace_path" "$name"
  fi
  jj -R "$main_root" workspace forget -- "$name" >&2
  [[ ! -e "$workspace_path" && ! -L "$workspace_path" ]] || rm -rf -- "$workspace_path"
}

parse_create_args() {
  REPO=""
  NAME=""
  BASE="fresh"
  DESCRIPTION=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --repo) [[ $# -ge 2 ]] || usage; REPO="$2"; shift 2 ;;
      --name) [[ $# -ge 2 ]] || usage; NAME="$2"; shift 2 ;;
      --base) [[ $# -ge 2 ]] || usage; BASE="$2"; shift 2 ;;
      --description) [[ $# -ge 2 ]] || usage; DESCRIPTION="$2"; shift 2 ;;
      *) usage ;;
    esac
  done
  [[ -n "$REPO" && -n "$NAME" ]] || usage
  [[ -n "$DESCRIPTION" ]] || DESCRIPTION="work: $NAME"
}

parse_remove_args() {
  REPO=""
  PATH_TO_REMOVE=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --repo) [[ $# -ge 2 ]] || usage; REPO="$2"; shift 2 ;;
      --path) [[ $# -ge 2 ]] || usage; PATH_TO_REMOVE="$2"; shift 2 ;;
      *) usage ;;
    esac
  done
  [[ -n "$REPO" && -n "$PATH_TO_REMOVE" ]] || usage
}

hook_create() {
  local input name cwd
  require_command jq
  input=$(cat)
  name=$(jq -er '.name | select(type == "string" and length > 0)' <<<"$input") ||
    die "hook payload must include a non-empty string 'name'"
  cwd=$(jq -er '.cwd | select(type == "string" and length > 0)' <<<"$input") ||
    die "hook payload must include a non-empty string 'cwd'"
  create_workspace "$cwd" "$name" "${JJ_SKIPPER_WORKSPACE_BASE:-fresh}" "worktree: $name"
}

hook_remove() {
  local input path cwd
  require_command jq
  input=$(cat)
  path=$(jq -er '.worktree_path | select(type == "string" and length > 0)' <<<"$input") ||
    die "hook payload must include a non-empty string 'worktree_path'"
  cwd=$(jq -er '.cwd | select(type == "string" and length > 0)' <<<"$input") ||
    die "hook payload must include a non-empty string 'cwd'"
  remove_workspace "$cwd" "$path"
}

COMMAND=${1:-}
[[ $# -gt 0 ]] && shift
case "$COMMAND" in
  create) parse_create_args "$@"; create_workspace "$REPO" "$NAME" "$BASE" "$DESCRIPTION" ;;
  remove) parse_remove_args "$@"; remove_workspace "$REPO" "$PATH_TO_REMOVE" ;;
  hook-create) [[ $# -eq 0 ]] || usage; hook_create ;;
  hook-remove) [[ $# -eq 0 ]] || usage; hook_remove ;;
  *) usage ;;
esac
