---
name: git-worktree-management
description: Git worktree management best practices for git worktree, bare repo layouts, parallel branches, stale base sync, branch cleanup, wrong-path recovery, fork remotes, and PR review worktrees. Use when creating, moving, removing, repairing, listing, pruning, or troubleshooting Git worktrees.
---

## Git Worktree Management

Goal: one branch, one folder. No branch switching in busy repos.

## Default Layout

Prefer bare repo with sibling worktrees:

```text
~/code/repo/
  .bare/
  main/
  feature-x/
  bugfix-y/
```

Why: parallel work, clean IDE indexes, no stash dance, fast hotfix/review folders.

## Create Layout

```bash
mkdir -p ~/code/repo
git clone --bare git@github.com:owner/repo.git ~/code/repo/.bare
git -C ~/code/repo/.bare config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
git -C ~/code/repo/.bare fetch origin
git -C ~/code/repo/.bare worktree add ~/code/repo/main origin/main
```

Use real default branch. Do not assume `main`:

```bash
gh repo view owner/repo --json defaultBranchRef --jq '.defaultBranchRef.name'
```

## New Branch

Always sync base first:

```bash
git -C ~/code/repo/.bare fetch origin main:refs/remotes/origin/main
git -C ~/code/repo/.bare worktree add -b feature-x ~/code/repo/feature-x origin/main
```

Use absolute paths when an agent/script runs command. Relative paths with `git -C .bare` resolve relative to `.bare`, not shell cwd.

Wrong:

```bash
git -C .bare worktree add -b feature-x feature-x main
```

Right:

```bash
git -C ~/code/repo/.bare worktree add -b feature-x ~/code/repo/feature-x origin/main
```

## Existing Branch Or PR Review

Existing branch:

```bash
git -C ~/code/repo/.bare fetch origin feature-x
git -C ~/code/repo/.bare worktree add ~/code/repo/feature-x origin/feature-x
```

Detached review worktree:

```bash
git -C ~/code/repo/.bare worktree add --detach ~/code/repo/review-pr origin/feature-x
```

## Daily Safety

- Run `git worktree list` before adding/removing.
- Never use plain `--force` unless command explains why.
- Commit or discard work before removing worktree.
- Rebase on current base before merge/PR final check.
- Do not create worktrees under `.bare/`.

## Before Merge

```bash
git fetch origin
git rebase origin/main
task ci
```

Replace `task ci` with repo check command. Real command must fail loud.

## Cleanup

After PR merged:

```bash
git -C ~/code/repo/.bare worktree remove ~/code/repo/feature-x
git -C ~/code/repo/main branch -D feature-x
git -C ~/code/repo/main fetch --prune origin
git -C ~/code/repo/.bare worktree prune
```

If directory was deleted manually:

```bash
git -C ~/code/repo/.bare worktree prune
```

If worktree moved manually:

```bash
git -C ~/code/repo/.bare worktree repair ~/code/repo/new-path
```

## Wrong-Path Recovery

If worktree got created inside `.bare/`:

```bash
git -C ~/code/repo/.bare worktree move ~/code/repo/.bare/feature-x ~/code/repo/feature-x
```

Use absolute source and dest.

## Fork Remote Rule

When pushing to non-tracking remote, use explicit refspec:

```bash
git push fork HEAD:main
```

Do not trust:

```bash
git push fork main
```

It can be a silent no-op when local branch tracks `origin/main`.

## Useful Commands

```bash
git worktree list --porcelain
git worktree remove <path>
git worktree prune
git worktree repair <path>
git -C <worktree> status -sb
```

## Agent Rules

- Confirm cwd and target path before worktree ops.
- Prefer absolute paths.
- Fetch explicit base ref in bare layouts.
- Stop and ask before removing dirty worktree.
- Never edit installed skill/plugin cache paths by accident.
