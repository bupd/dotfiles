# jj Recovery

Diagnose from repository evidence. Do not guess, mutate state prematurely, or fall back to bare Git.

## Protocol

1. Capture the current state:

```bash
jj st
jj log -r 'all()' --limit 30
jj op log --limit 20
jj bookmark list --all
```

2. Explain the root cause in plain language.
3. Present the least destructive repair and its effect.
4. Obtain confirmation before abandoning changes or restoring an operation.
5. Verify the resulting graph, bookmarks, and working copy.

## Common repairs

| Symptom | Recovery path |
|---|---|
| Recent operation was wrong | `jj undo` |
| Lost or hidden work | Find it with `jj log -r 'all()'` |
| Need an earlier repository state | Inspect with `jj --at-op <op-id> log` or `diff`, then consider `jj op restore <op-id>` |
| Stale workspace | `jj workspace update-stale` |
| Bookmark points incorrectly | `jj bookmark set <name> -r <change-id>` |
| Local and remote bookmark disagree | `jj bookmark list --all`; fetch and resolve tracking |
| Main is stale after a merge | `jj git fetch && jj bookmark set main -r main@origin` |
| Local work needs the new main | `jj rebase -o main@origin` |
| Divergent change IDs | Inspect both commits; abandon one or assign a new change ID |
| Immutable rewrite error | Rebase the mutable change with `jj rebase -o main@origin`; do not rewrite main itself |
| Git backend out of sync | `jj git import`, then `jj git export` if required |

Conflicts are stored in commits. Edit conflicted files, verify with `jj st`, then squash the resolution into the intended change if necessary. Descendants will rebase automatically.

Prefer change IDs during recovery because they survive rewrites. Do not abandon or restore until the current graph and operation history are understood.

For operation-log forensics, use `jj op show <op-id>` plus `jj --at-op <op-id> log` or `diff`. If a repair is wrong, `jj undo` reverses the latest repository operation.
