---
name: jj
description: >
  Work with Jujutsu (jj) version control: workflows, workspaces, bookmarks,
  commit/push/PR delivery, revsets, recovery, and git-to-jj translation.
  Also covers bupd's harbor repos, which use a colocated/bare git store
  with many named jj workspaces under ws/. Use whenever the working
  directory is a jj repo (a .jj dir exists at/above the root) or the user
  mentions jj, jujutsu, workspaces, bookmarks, megamerge, revsets, or
  recovery of lost jj work. Prefer jj commands over raw git in jj repos.
  Triggers: "use jj", "jj workspace", "bookmark", "jj rebase", "resolve
  conflicts with jj", cherry-picking or rebasing PRs, shipping/pushing
  work, opening PRs from a jj repo.
---

# Jujutsu (jj)

Prefer `jj` over `git` inside jj repos. Detect one with `jj root` (exits 0)
or by a `.jj/` directory at/above the repo root.

## Invariants (differences from git)

- The working copy IS a commit (`@`). Every jj command auto-snapshots it —
  there is no staging area, no `add`, no stash. Edits automatically amend `@`.
- `@-` is the parent of `@`. After `jj commit -m "msg"`, committed content
  is at `@-` and the new `@` is empty.
- Use `-m` for descriptions and commits; never open an editor or use `-i`.
- Prefer stable change IDs over commit IDs.
- Bookmarks ≈ git branches, but they do NOT move automatically; after
  creating commits, point the bookmark with
  `jj bookmark set <name> -r <rev>` (add `--allow-backwards` for rewinds).
- Conflicts are first-class: a rebase never stops. Conflicted commits are
  recorded and shown with `(conflict)`. Resolve later with `jj resolve` or
  by editing the file, then the fix auto-propagates to descendants.
- Every operation is logged: `jj op log`; undo anything with `jj undo` or
  `jj op restore <op-id>`.
- Anonymous branches are fine — commits need no bookmark to exist. Find
  strays with `jj log -r 'heads(all())'`.

## Daily commands

```bash
jj st                                  # status
jj log -r 'main..@'                    # what's new on this line of work
jj diff                                # diff of @ (add -r <rev> for others)
jj new <rev>                           # start new empty commit on <rev>
jj describe -m "msg"                   # set commit message of @
jj commit -m "msg"                     # describe @ then jj new on top
jj squash                              # fold @ into @-
jj rebase -r <rev> -d <dest>           # move one commit
jj rebase -s <rev> -d <dest>           # move commit + descendants
jj abandon <rev>                       # drop a commit
jj duplicate <rev> -d <dest>           # cherry-pick equivalent
jj git fetch --remote <r>              # fetch
jj bookmark set <name> -r @            # point bookmark at @
jj git push --remote <r> -b <name>     # push bookmark
jj git push --remote <r> --change @    # push @ as auto-named branch
```

Sign-off: jj has no `-s` flag; add the trailer in the message body:
`Signed-off-by: Prasanth Baskar <prasanth@8gears.com>`.

## Deep references — load only what the task needs

- Git command translation: [references/git-to-jj.md](references/git-to-jj.md)
- Bookmarks, syncing, rewriting, review, selective changes:
  [references/workflows.md](references/workflows.md)
- Revsets and filesets: [references/revsets-filesets.md](references/revsets-filesets.md)
- Repository diagnosis, lost work, divergence, conflicts, stale state:
  [references/recovery.md](references/recovery.md)

Do not read every reference. Select the narrowest relevant one.

## Create an isolated workspace

Derive a safe feature name and run the bundled manager from this skill
directory:

```bash
bash scripts/workspace.sh create \
  --repo "$(jj root)" \
  --name <feature-name> \
  --base fresh \
  --description "feat: <description>"
```

Use `--base head` only when the new workspace must include the current
local change; otherwise keep the clean `fresh` base. The manager creates
the workspace and bookmark atomically and prints its path. Report the
path, bookmark, base, and change ID. When finished shipping, remove it:
`bash scripts/workspace.sh remove --repo <repo> --path <workspace-path>`.

## Ship work: commit, push, PR

1. Inspect state and identify the bookmark:

```bash
jj st
jj bookmark list
```

2. If `@` has no bookmark, create one: `jj bookmark create <feature-name> -r @`

3. Commit and verify the bookmark follows the content at `@-`:

```bash
jj commit -m "<message>"
jj bookmark list
jj bookmark set <feature-name> -r @-   # only if mispointed
```

4. Push and open the PR:

```bash
jj git push -b <feature-name>
gh pr create --repo <owner/repository> --base main --head <feature-name> \
  --title "<title>" --body "<body>"
```

Derive `<owner/repository>` from `jj git remote list`; do not add git
work-tree metadata to a jj workspace. Return the PR URL and a
`jj log -r '@ | @-'` summary.

## Cherry-picking / PR conflict resolution recipe

To redo a botched cherry-pick or resolve PR conflicts:

```bash
jj git fetch --remote next             # or the relevant remote
jj new main@next                       # fresh base
jj duplicate <upstream-commit> -d @-   # cherry-pick; conflicts recorded, not blocking
jj log -r 'conflicts()'                # find conflicted commits
jj edit <conflicted-rev>               # make it @, fix files, snapshot is automatic
jj describe -m "..."                   # proper message + Signed-off-by trailer
jj bookmark set <pr-branch> -r @ --allow-backwards
jj git push --remote next -b <pr-branch>   # force-push semantics are implicit
```

## Harbor repo layout (bupd machines)

- Repo store: `/var/home/bupd/code/harbor` (git dir lives here; also
  `~/code/OSS/harbor` bare repo per worktree rules).
- jj workspaces live in `ws/<name>` (e.g. `ws/next-prs2`). `jj workspace list`
  shows dozens. Each workspace has its own `@`.
- **Workspace/worktree name prefix before the first `-` IS the push remote**:
  `next-*` → `next` (PRIVATE, container-registry/harbor-next),
  `8gcr-*` → `8gcr` (PRIVATE), `bupd-*` → `bupd` (fork),
  `upstream-*` → `upstream` (PUBLIC goharbor/harbor), `glab-*` → `glab`
  (PRIVATE). NEVER push `next`/`8gcr` content to `upstream`. Confirm
  remote + bookmark before any forced move; ask when unsure.
- Remote-tracking revs: `main@next`, `main@upstream`, etc.
- A stale workspace: `jj git fetch --remote next && jj new main@next`
  (an empty, undescribed old `@` is abandoned automatically).
- If git was used behind jj's back, any jj command auto-imports git refs;
  `jj git import` forces it.

## Safety

- Before rewriting shared history check `jj op log` context; recover
  mistakes with `jj undo`.
- `jj git push` only pushes bookmarks you name (`-b`) or `--change`; never
  push `--all` in the harbor repos.
- Squash-merge-only repos (harbor-next): keep PR branches as a single
  commit when possible (`jj squash` chains into one).
