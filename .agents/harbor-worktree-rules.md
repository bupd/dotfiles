# Harbor Worktree Push Rules

**CRITICAL: Wrong remote = private code leaked to public repos.**

Harbor (`~/code/OSS/harbor/`) is a bare Git repo with worktrees named `{remote}-{description}`.
The prefix before the first `-` in the directory name IS the Git remote to push to.

Derive remote: `basename "$PWD" | cut -d'-' -f1`

## Remotes

- `8gcr-*` → `8gcr` (container-registry/8gcr — **PRIVATE**)
- `next-*` → `next` (container-registry/harbor-next — **PRIVATE**)
- `bupd-*` → `bupd` (bupd/harbor — personal fork)
- `upstream-*` → `upstream` (goharbor/harbor — **PUBLIC**)
- `glab-*` → `glab` (8gears/container-registry/harbor — **PRIVATE**)

## Rules

1. ONLY push to the remote matching the directory prefix.
2. NEVER push `8gcr` or `next` code to `upstream` — that is public OSS.
3. When unsure, ask before pushing.
4. Confirm both remote AND branch before any force-push.
