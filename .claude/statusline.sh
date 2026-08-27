#!/usr/bin/env bash
# Claude Code status line: PR number, repo/branch, last 3 path components.

input=$(cat)
cwd=$(jq -r '.workspace.current_dir // empty' <<<"$input")
[ -z "$cwd" ] && cwd=$PWD
cd "$cwd" 2>/dev/null || true

# Last three path components (fewer if the path is shorter).
short_path=$(rev <<<"$cwd" | cut -d'/' -f1-3 | rev)
short_path=${short_path#/}

dim=$'\e[2m'
cyan=$'\e[36m'
magenta=$'\e[35m'
green=$'\e[32m'
reset=$'\e[0m'

parts=()

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  repo=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
  branch=$(git branch --show-current 2>/dev/null)

  # jj repos/workspaces keep git HEAD detached; show the nearest bookmark
  # reachable from @ instead of a bare commit hash.
  if [ -z "$branch" ] && command -v jj >/dev/null 2>&1; then
    branch=$(timeout 1 jj log --ignore-working-copy --no-graph \
      -r 'latest(::@ & bookmarks())' -T 'bookmarks.join(",")' 2>/dev/null)
  fi
  [ -z "$branch" ] && branch=$(git rev-parse --short HEAD 2>/dev/null)

  # PR number for the current branch, cached for 60s per repo+branch.
  cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}/claude-statusline
  mkdir -p "$cache_dir"
  key=$(printf '%s' "$repo-$branch" | tr -c 'A-Za-z0-9._-' '_')
  cache="$cache_dir/$key"
  now=$(date +%s)
  if [ -f "$cache" ] && [ $((now - $(stat -c %Y "$cache" 2>/dev/null || echo 0))) -lt 60 ]; then
    pr=$(<"$cache")
  else
    pr=$(timeout 2 gh pr view --json number -q .number 2>/dev/null)
    printf '%s' "$pr" >"$cache"
  fi

  [ -n "$pr" ] && parts+=("${green}PR#${pr}${reset}")
  parts+=("${magenta}${repo}${reset}${dim}/${reset}${cyan}${branch}${reset}")
fi

parts+=("${dim}${short_path}${reset}")

out=""
for p in "${parts[@]}"; do
  [ -n "$out" ] && out+="${dim} · ${reset}"
  out+="$p"
done
printf '%s' "$out"
