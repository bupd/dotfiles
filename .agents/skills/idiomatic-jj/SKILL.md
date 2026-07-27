---
name: idiomatic-jj
description: Use when operating in a Jujutsu (jj) repository, translating Git habits to jj, reviewing jj workflows, or advising agents/users on idiomatic jj. Covers jj mental models, Git contrasts, safe command choices, bookmarks, revsets, history editing, conflicts, and best practices.
---

# Idiomatic Jujutsu (`jj`)

Use this skill whenever you are working in a repository that uses Jujutsu (`jj`), helping a Git user adopt `jj`, or reviewing/authoring instructions that mention `jj` commands.

`jj` is not just Git with different command names. It is a Git-compatible VCS front end with a different local model: the working copy is a commit, history editing is normal, branches are bookmarks, and the operation log is the safety net.

## First response checklist

Before giving advice or running commands:

1. Prefer `jj` commands over Git commands when the repo is jj-managed.
2. Run or ask for the current state with:
   ```bash
   jj status
   jj log
   ```
3. If a command is risky or the repo state is unclear, inspect the safety net:
   ```bash
   jj op log --limit 5
   ```
4. If command syntax may vary by installed version, verify with:
   ```bash
   jj help <command>
   ```
5. If backend behavior matters, check it with:
   ```bash
   jj util backend name
   ```
6. Do not assume a "current branch" exists. Ask which commit/change/bookmark should be affected.

## Core mental model

Teach and apply these rules first:

- The working copy is a real commit named `@`.
- The parent of the working-copy commit is usually `@-`.
- After `jj commit`, `@` becomes a new empty working commit; the finished work is usually `@-`.
- There is no staging area/index. Use `jj split`, `jj squash -i`, and `jj restore` to organize changes.
- Commits have two identities:
  - Git commit ID: content-addressed hash; changes after rewrites.
  - jj change ID: stable identity for an evolving change.
- Branches are bookmarks. A bookmark is a named pointer; it is not checked out and does not automatically advance.
- Most local rewrites are ordinary, undoable operations. Use `jj undo`, `jj redo`, `jj op log`, and `jj op restore`.

Useful shorthand:

```bash
@            # working-copy commit
@-           # parent of @, often last completed change
@+           # children of @
::@          # ancestors of @
main..@      # ancestors of @ not in main
trunk()..@   # ancestors of @ not in configured trunk
```

## Git-to-jj contrasts

Use this table to translate intent, not just command spelling.

| Git habit / concept | Idiomatic jj equivalent | Important difference |
|---|---|---|
| `HEAD` plus working tree | `@` | File edits are automatically part of the working-copy commit. |
| `git add` / staging | `jj split`, `jj squash -i`, `jj restore` | Organize commits after or during work; no index exists. |
| `git commit -m msg` | `jj commit -m msg` | Describes current `@` and creates a new empty `@`; completed change becomes `@-`. |
| `git commit --amend` | `jj squash`, `jj describe`, or direct `jj edit REV` | Amending is routine and preserves the change ID. |
| `git checkout branch` / `git switch branch` | `jj new bookmark` or `jj edit REV` | You choose a commit to base work on or edit; no active branch moves with you. |
| Git branch | jj bookmark | Publication pointer, not local editing context. |
| `git pull --rebase` | `jj git fetch` then `jj rebase ...` | Fetch and integration are explicit separate steps. |
| `git rebase -i` | `jj rebase`, `jj split`, `jj squash -i`, `jj edit` | History surgery is composed from normal commands. |
| `git reflog` | `jj op log` | Operation log records repo operations and supports direct undo/restore. |
| Conflict stops rebase/merge | Conflicts stored in commits | Resolve by editing conflicted commits; no `--continue` loop. |

## Default command choices

Prefer these commands for common tasks:

```bash
jj status                         # current working-copy state
jj log                            # graph and nearby changes
jj diff                           # @ relative to parent
jj show REV...                    # inspect one or more changes/commits
jj describe -m "message"          # name/edit current change without moving on
jj commit -m "message"            # finish @ and start a new empty @
jj new DEST                       # start new work on DEST
jj edit REV                       # edit an existing change directly
jj split                          # split a messy change interactively
jj squash                         # move @ changes into parent
jj squash -i                      # move selected hunks into parent
jj restore path                   # restore path in @ from parent
jj abandon REV                    # abandon visible local change
jj git fetch                      # fetch Git remote state; jj 0.42+ also imports change-ID evolution history when available
jj git push -c REV                # push a change with generated bookmark
jj git push --bookmark NAME        # push a named bookmark
jj bookmark create NAME -r REV     # create publication pointer
jj bookmark move NAME --to REV     # move publication pointer explicitly
jj undo                           # undo last jj operation
jj op log                         # inspect operation history
```

Avoid reflexively using these Git commands in jj-managed work unless the user explicitly asks or a project tool requires them:

- `git add`
- `git commit --amend`
- `git checkout` / `git switch`
- `git reset --hard`
- `git rebase -i`
- force-push commands written as Git incantations

When you must use Git in a colocated repo, run `jj status` afterward so jj imports/syncs Git-side changes before further jj advice.

## Idiomatic workflows

### Simple commit-as-you-go

Good for small work and new users.

```bash
jj new main        # or: jj new trunk()
# edit files
jj diff
jj commit -m "feat: useful change"
# finished change is now @-
```

### Describe early, evolve the change

Good for intent-driven work.

```bash
jj new trunk()
jj describe -m "feat: add useful thing"
# edit freely; @ keeps evolving with same change ID
jj diff
jj commit          # only when ready to move on
```

### Scratch child plus squash

Good replacement for Git's amend/index loop.

```bash
jj new trunk()
jj describe -m "feat: add parser"
jj new             # scratch child above described commit
# experiment, test, edit
jj squash -i       # move selected good hunks into parent
```

Mental model: `@` is scratch; `@-` is the polished change.

### Stacked work

Good for dependent reviewable changes.

```bash
jj new trunk()
jj commit -m "refactor: isolate storage layer"
jj commit -m "feat: add import pipeline"
jj commit -m "test: cover import pipeline"
jj log -r 'trunk()..@'
```

To fix an earlier change:

```bash
jj edit <earlier-change>
# edit fix into that change
jj new @+          # or edit the stack tip when finished
```

Descendants auto-rebase as the earlier change evolves.

## Bookmarks, remotes, and PR guidance

Use this framing: **edit commits; publish bookmarks**.

Rules:

- Do not expect `main`, `feature`, or any bookmark to advance when committing.
- Use anonymous local changes freely; create/move bookmarks when publishing or naming a line of work.
- Prefer `jj git push -c @-` for quick PR branches when branch names do not matter.
- Use named bookmarks when the team or hosting workflow requires stable branch names.

Examples:

```bash
# Fast generated PR branch after committing
jj git push -c @-

# Named PR branch/bookmark
jj bookmark create my-feature -r @-
jj git push --bookmark my-feature

# Update named PR after rewriting/fixing the top change
jj bookmark move my-feature --to @-
jj git push --bookmark my-feature
```

If updating from remote:

```bash
jj git fetch
jj rebase -b @ -d trunk()   # adjust -b and -d for the intended stack/destination
```

In `jj 0.42.0` and newer, fetch can use preserved remote change IDs to generate evolution history and rebase local descendants onto rewritten parents. Still inspect with `jj log` before mutating local stacks, especially when collaborating with Git-only users.

Do not say "checkout a branch" unless you are intentionally translating for a Git user. Prefer:

```bash
jj new feature@origin       # start new work on a remote bookmark
jj bookmark track feature@origin  # if a local tracked bookmark is desired
```

## Revset best practices

Revsets are jj's composable way to select commits. Quote revsets that contain shell metacharacters.

Start with:

```bash
jj log -r 'trunk()..@'                 # current local line after trunk
jj log -r 'remote_bookmarks()..@'      # unpublished ancestors of @
jj log -r 'conflicts()'                # conflicted commits
jj log -r 'mine() & remote_bookmarks()..' # my unpublished commits
```

Use revsets in commands instead of scripting fragile log parsing:

```bash
jj show 'latest(mine(), 1)'
jj show '@-' '@--'        # jj 0.42+ accepts multiple revisions
jj rebase -b 'description(regex:"parser")' -d trunk()
```

When unsure, first inspect with `jj log -r '<revset>'` before using the same revset in a mutating command.

## Conflict handling

In jj, conflicts are stored in commits. A rebase can complete while leaving conflicted commits in the graph.

Typical flow:

```bash
jj log -r 'conflicts()'
jj edit <conflicted-rev>
# resolve files
jj status
jj diff
jj new             # move on when resolved
```

Do not advise `git rebase --continue` or `git merge --continue` for jj conflicts. The resolution happens by editing the conflicted commit until `jj status` is clean.

## Safety and recovery

Before risky history edits, create an easy restore point mentally or in notes:

```bash
jj op log --limit 1
```

If the last operation was wrong:

```bash
jj undo
```

If the bad operation was earlier:

```bash
jj op log
jj op show <op>
jj op restore <op>
```

Remember:

- The operation log is local; it is not a remote backup.
- It protects tracked repository state, not ignored files, generated artifacts, databases, or secrets.
- Prefer reversible jj operations over destructive Git commands.

## Best-practice guidance for agents

When implementing, reviewing, or advising in a jj repo:

1. Keep the user oriented around commits/change IDs/bookmarks, not Git's HEAD/index/branch triad.
2. Mention `@` and `@-` explicitly when a command depends on the post-`jj commit` empty working-copy behavior.
3. Use `jj diff`/`jj show` for inspection and `jj log -r '<revset>'` to validate selections before mutation.
4. Prefer small, coherent changes; split messy work after the fact with `jj split` rather than forcing staging discipline up front.
5. Use `jj describe` early for planned changes and `jj commit` when moving on to the next change.
6. Treat bookmarks as publication handles. Move them deliberately and explain why.
7. Separate fetching from rebasing/merging. Avoid saying "pull" as if it were one atomic jj operation.
8. For PRs, identify whether the user wants a generated bookmark (`jj git push -c REV`) or a named bookmark.
9. For stacks, edit the commit that should own the change; let jj auto-rebase descendants.
10. For conflicts, find conflicted commits, edit them, and continue by creating/editing commits—not by invoking a continue command.
11. When uncertain or before destructive operations, lean on `jj op log`, `jj undo`, and `jj help`.
12. If interacting with teammates still using Git, keep pushes/bookmarks conventional and avoid surprising remote bookmark moves.

## Common explanations to give Git users

Use these concise phrases:

- "In jj, your working copy is already a commit: `@`."
- "`jj commit` names the current change and opens a new empty change, so the thing you just committed is usually `@-`."
- "There is no staging area; split or squash changes between commits instead."
- "Bookmarks are branch-like pointers for publication, not the place where local editing happens."
- "Rewriting local history is normal in jj because operations are recorded and undoable."
- "Conflicts are data in commits; resolve the conflicted commit rather than continuing a rebase."

## Version caveat

`jj` command names and flags evolve. This skill is current with `jj 0.42.0` idioms. Command details should be checked against the installed version with `jj help` when precision matters. In particular, avoid removed pre-0.42 deprecated options such as `jj git push --allow-new`, `jj commit --reset-author`, and old `jj describe --edit`/`--no-edit`/author flags.
