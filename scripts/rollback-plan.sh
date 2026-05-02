#!/usr/bin/env bash
#
# rollback-plan.sh - Generate rollback plans for git changes
#
# Usage:
#   rollback-plan.sh [repo-path] [commit-range]
#
# Examples:
#   rollback-plan.sh                        # current repo, uncommitted changes + last commit
#   rollback-plan.sh /path/to/repo          # specific repo, uncommitted changes + last commit
#   rollback-plan.sh /path/to/repo HEAD~3.. # specific repo, last 3 commits
#   rollback-plan.sh . abc1234..def5678     # current repo, specific range

set -euo pipefail

REPO_PATH="${1:-.}"
COMMIT_RANGE="${2:-}"

# Resolve to absolute path and validate
REPO_PATH="$(cd "$REPO_PATH" 2>/dev/null && pwd)" || {
    echo "Error: '$1' is not a valid directory" >&2
    exit 1
}

if ! git -C "$REPO_PATH" rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Error: '$REPO_PATH' is not a git repository" >&2
    exit 1
fi

CURRENT_BRANCH="$(git -C "$REPO_PATH" branch --show-current)"
CURRENT_SHA="$(git -C "$REPO_PATH" rev-parse --short HEAD)"

echo "============================================"
echo "  ROLLBACK PLAN"
echo "============================================"
echo ""
echo "Repository : $REPO_PATH"
echo "Branch     : ${CURRENT_BRANCH:-detached HEAD}"
echo "HEAD       : $CURRENT_SHA"
echo "Generated  : $(date -Iseconds)"
echo ""

# ---------- Section 1: Uncommitted changes ----------

HAS_UNSTAGED=false
HAS_STAGED=false

if [ -n "$(git -C "$REPO_PATH" diff --name-only 2>/dev/null)" ]; then
    HAS_UNSTAGED=true
fi

if [ -n "$(git -C "$REPO_PATH" diff --cached --name-only 2>/dev/null)" ]; then
    HAS_STAGED=true
fi

if $HAS_UNSTAGED || $HAS_STAGED; then
    echo "--------------------------------------------"
    echo "  UNCOMMITTED CHANGES"
    echo "--------------------------------------------"
    echo ""
fi

if $HAS_STAGED; then
    echo "## Staged changes"
    echo ""
    echo "Files:"
    git -C "$REPO_PATH" diff --cached --name-status | while IFS=$'\t' read -r status file; do
        echo "  [$status] $file"
    done
    echo ""
    echo "Rollback commands:"
    echo "  # Unstage all staged changes"
    echo "  git -C \"$REPO_PATH\" restore --staged ."
    echo ""
    echo "  # Discard staged changes entirely"
    echo "  git -C \"$REPO_PATH\" restore --staged . && git -C \"$REPO_PATH\" restore ."
    echo ""
fi

if $HAS_UNSTAGED; then
    echo "## Unstaged changes"
    echo ""
    echo "Files:"
    git -C "$REPO_PATH" diff --name-status | while IFS=$'\t' read -r status file; do
        echo "  [$status] $file"
    done
    echo ""
    echo "Rollback commands:"
    echo "  # Discard all unstaged changes"
    echo "  git -C \"$REPO_PATH\" restore ."
    echo ""
    echo "  # Discard changes to a specific file"
    git -C "$REPO_PATH" diff --name-only | while read -r file; do
        echo "  git -C \"$REPO_PATH\" restore \"$file\""
    done
    echo ""
fi

# Check for untracked files
UNTRACKED="$(git -C "$REPO_PATH" ls-files --others --exclude-standard)"
if [ -n "$UNTRACKED" ]; then
    echo "## Untracked files"
    echo ""
    echo "Files:"
    echo "$UNTRACKED" | while read -r file; do
        echo "  [?] $file"
    done
    echo ""
    echo "Rollback commands:"
    echo "  # Remove all untracked files (dry run first)"
    echo "  git -C \"$REPO_PATH\" clean -n"
    echo "  # Remove all untracked files (for real)"
    echo "  git -C \"$REPO_PATH\" clean -f"
    echo ""
fi

# ---------- Section 2: Committed changes ----------

# Determine commit range
if [ -z "$COMMIT_RANGE" ]; then
    # Default: last commit only
    COMMIT_RANGE="HEAD~1..HEAD"
fi

# Validate that the range is valid
if ! git -C "$REPO_PATH" rev-parse "${COMMIT_RANGE%%.*}" &>/dev/null 2>&1; then
    # Try interpreting as-is
    if ! git -C "$REPO_PATH" log --oneline "$COMMIT_RANGE" &>/dev/null 2>&1; then
        echo "Warning: commit range '$COMMIT_RANGE' is not valid, skipping commit analysis" >&2
        echo ""
        echo "============================================"
        echo "  END OF ROLLBACK PLAN"
        echo "============================================"
        exit 0
    fi
fi

COMMITS="$(git -C "$REPO_PATH" log --reverse --format='%H %h %s' "$COMMIT_RANGE" 2>/dev/null)"

if [ -z "$COMMITS" ]; then
    echo "(No commits in range $COMMIT_RANGE)"
    echo ""
    echo "============================================"
    echo "  END OF ROLLBACK PLAN"
    echo "============================================"
    exit 0
fi

COMMIT_COUNT="$(echo "$COMMITS" | wc -l | tr -d ' ')"

echo "--------------------------------------------"
echo "  COMMITS ($COMMIT_COUNT in range: $COMMIT_RANGE)"
echo "--------------------------------------------"
echo ""

echo "$COMMITS" | while IFS=' ' read -r full_sha short_sha subject; do
    echo "## Commit: $short_sha - $subject"
    echo ""
    echo "Files:"
    git -C "$REPO_PATH" diff-tree --no-commit-id -r --name-status "$full_sha" | while IFS=$'\t' read -r status file; do
        echo "  [$status] $file"
    done
    echo ""
    echo "Rollback command:"
    echo "  # Revert this commit (creates a new commit undoing the changes)"
    echo "  git -C \"$REPO_PATH\" revert --no-edit $short_sha"
    echo ""
    echo "  # Or cherry-pick the inverse (same effect, different semantics)"
    echo "  git -C \"$REPO_PATH\" revert --no-commit $short_sha"
    echo ""
done

# ---------- Section 3: Full rollback summary ----------

echo "--------------------------------------------"
echo "  FULL ROLLBACK OPTIONS"
echo "--------------------------------------------"
echo ""

RANGE_START="${COMMIT_RANGE%%..* }"
# Get the first commit's parent
FIRST_COMMIT="$(echo "$COMMITS" | head -1 | cut -d' ' -f1)"
FIRST_PARENT="$(git -C "$REPO_PATH" rev-parse --short "${FIRST_COMMIT}^" 2>/dev/null || echo "")"

if [ -n "$FIRST_PARENT" ]; then
    echo "Option 1: Revert all commits in range (safe, preserves history)"
    echo ""
    # List commits in reverse order for revert (newest first)
    git -C "$REPO_PATH" log --format='%h' "$COMMIT_RANGE" 2>/dev/null | while read -r sha; do
        echo "  git -C \"$REPO_PATH\" revert --no-edit $sha"
    done
    echo ""
    echo "Option 2: Reset to before these changes (rewrites history, use with caution)"
    echo ""
    echo "  # Soft reset (keeps changes staged)"
    echo "  git -C \"$REPO_PATH\" reset --soft $FIRST_PARENT"
    echo ""
    echo "  # Mixed reset (keeps changes unstaged)"
    echo "  git -C \"$REPO_PATH\" reset $FIRST_PARENT"
    echo ""
    echo "  # Hard reset (discards all changes - DESTRUCTIVE)"
    echo "  git -C \"$REPO_PATH\" reset --hard $FIRST_PARENT"
    echo ""
fi

echo "Option 3: Create a backup branch before rolling back"
echo ""
echo "  git -C \"$REPO_PATH\" branch backup/${CURRENT_BRANCH:-HEAD}-$(date +%Y%m%d)"
echo ""

echo "============================================"
echo "  END OF ROLLBACK PLAN"
echo "============================================"
