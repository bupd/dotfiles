# Git to jj Command Reference

## Daily Operations

| Task | Git | jj | Notes |
|------|-----|----|-------|
| Check status | `git status` | `jj st` | Shows all tracked changes (no staging) |
| View diff | `git diff` | `jj diff` | Diff of working copy vs parent |
| Diff staged | `git diff --cached` | N/A | No staging area in jj |
| Diff between revs | `git diff a..b` | `jj diff --from a --to b` | |
| View log | `git log` | `jj log` | Default shows all visible heads |
| Log one-line | `git log --oneline` | `jj log --no-graph -T 'change_id.short() ++ " " ++ description.first_line() ++ "\n"'` | Custom template |
| Show commit | `git show <ref>` | `jj show <rev>` | |
| Blame | `git blame <file>` | `jj file annotate <file>` | |

## Committing

| Task | Git | jj | Notes |
|------|-----|----|-------|
| Stage all + commit | `git add -A && git commit -m "msg"` | `jj commit -m "msg"` | All changes auto-tracked |
| Stage specific + commit | `git add file && git commit -m "msg"` | `jj commit -m "msg" file` | Fileset arguments |
| Amend message | `git commit --amend -m "msg"` | `jj describe -m "msg"` | Message only |
| Amend content | `git add . && git commit --amend` | `jj squash` | Fold @ into @- |
| Amend specific files | `git add file && git commit --amend` | `jj squash file` | Partial squash |
| Empty commit | `git commit --allow-empty -m "msg"` | `jj commit -m "msg"` | Empty commits natural in jj |

## Branching / Bookmarks

| Task | Git | jj | Notes |
|------|-----|----|-------|
| List branches | `git branch` | `jj bookmark list` | |
| Create branch | `git branch <name>` | `jj bookmark create <name> -r @` | Must specify revision |
| Create + switch | `git checkout -b <name>` | `jj new main -m "desc"` then bookmark | Two-step in jj |
| Switch branch | `git checkout <branch>` | `jj new <branch>` or `jj edit <branch>` | `new` creates child; `edit` edits in place |
| Delete branch | `git branch -d <name>` | `jj bookmark delete <name>` | |
| Rename branch | `git branch -m old new` | `jj bookmark rename old new` | |
| Track remote | `git branch -u origin/main` | `jj bookmark track main@origin` | |

## Remote Operations

| Task | Git | jj | Notes |
|------|-----|----|-------|
| Push | `git push` | `jj git push` | Pushes all bookmarks with remote tracking |
| Push specific | `git push origin <branch>` | `jj git push -b <bookmark>` | |
| Push new branch | `git push -u origin <branch>` | `jj git push -c <rev>` | Auto-creates bookmark from change description |
| Fetch | `git fetch` | `jj git fetch` | |
| Pull (fast-forward) | `git pull` | `jj git fetch && jj bookmark set main -r main@origin` | Advances local bookmark |
| Pull (rebase local) | `git pull --rebase` | `jj git fetch && jj rebase -o main@origin` | Rebases your commits; never `-s main` |
| Clone | `git clone <url>` | `jj git clone <url>` | |
| Add remote | `git remote add <name> <url>` | `jj git remote add <name> <url>` | |

## History Rewriting

| Task | Git | jj | Notes |
|------|-----|----|-------|
| Rebase | `git rebase <base>` | `jj rebase -o <dest>` | |
| Rebase range | `git rebase --onto <new> <old>` | `jj rebase -s <source> -o <dest>` | |
| Cherry-pick | `git cherry-pick <ref>` | `jj duplicate <rev>` | Creates independent copy |
| Revert | `git revert <ref>` | `jj revert -r <rev>` | Creates inverse change |
| Interactive rebase | `git rebase -i` | `jj rebase` + `jj squash` + `jj edit` | Multiple commands |
| Squash last N | `git rebase -i HEAD~N` (squash) | `jj squash --from <rev>` | |
| Absorb hunks | N/A | `jj absorb` | Auto-routes hunks to correct ancestors |
| Parallelize | N/A | `jj parallelize <revs>` | Make sequential commits concurrent |

## Stashing / Context Switching

| Task | Git | jj | Notes |
|------|-----|----|-------|
| Stash | `git stash` | `jj new` | Old work stays in parent; @ is fresh |
| Stash pop | `git stash pop` | `jj edit <change-id>` | Go back to the change |
| Stash specific | `git stash push <file>` | `jj commit -m "wip" file` then `jj new` | |

## Undoing / Restoring

| Task | Git | jj | Notes |
|------|-----|----|-------|
| Undo last action | `git reflog` + `git reset` | `jj undo` | Single command |
| Restore file | `git checkout -- <file>` | `jj restore --from @- <file>` | |
| Restore all | `git checkout .` | `jj restore` | |
| Hard reset | `git reset --hard <ref>` | `jj restore --from <rev>` or `jj abandon` | |
| Operation history | `git reflog` | `jj op log` | Full operation log |
| Time travel | `git reset --hard <reflog>` | `jj op restore <op-id>` | Restore any prior state |

## Workspace / Worktree

| Task | Git | jj | Notes |
|------|-----|----|-------|
| Add worktree | `git worktree add <path>` | `jj workspace add <path>` | Shared commit graph |
| List worktrees | `git worktree list` | `jj workspace list` | |
| Remove worktree | `git worktree remove <path>` | `jj workspace forget <name>` | Forgets metadata; remove the directory separately |
| Update stale | N/A | `jj workspace update-stale` | Re-sync workspace |

## Fileset Patterns

Used wherever jj accepts file arguments:

| Pattern | Meaning |
|---------|---------|
| `file.txt` | Exact file |
| `glob:src/**/*.rs` | Glob pattern |
| `root:path` | Path relative to repo root |
| `a \| b` | Union of filesets |
| `a & b` | Intersection of filesets |
| `~a` | Complement (all except a) |
| `all()` | All files |
| `none()` | No files |
