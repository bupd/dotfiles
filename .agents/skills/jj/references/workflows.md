# jj Workflows

## Bookmarks and new work

```bash
jj new main -m "feat: description"
jj bookmark create <feature-name> -r @
```

Create the bookmark before editing. It follows the rewritten change when `jj commit` moves that change to `@-`. Verify with `jj bookmark list`; repair with `jj bookmark set <name> -r <change-id>`.

## Amend and review

```bash
jj describe -m "better message"       # message only
jj squash                              # fold @ into @-

jj edit <change-id>                    # rewrite a pushed change
# edit files
jj new                                 # finish editing
jj git push                            # lease-protected force push
```

For an additive review commit:

```bash
jj new <bookmark-tip>
# edit files
jj commit -m "address review"
jj bookmark set <name> -r @-
jj git push -b <name>
```

## Sync

Fast-forward local main after a merge:

```bash
jj git fetch
jj bookmark set main -r main@origin
```

With local work to rebase:

```bash
jj git fetch
jj bookmark set main -r main@origin
jj rebase -o main@origin
```

Do not use `jj rebase -s main`; tracked main is normally immutable.

## Selective changes

```bash
jj commit -m "msg" file1.rs file2.rs
jj commit -m "msg" 'glob:src/**/*.rs'
jj restore --from @- file.txt
jj split 'glob:tests/**'
jj absorb
jj interdiff --from <rev1> --to <rev2>
```

## Bookmark lifecycle

```bash
jj bookmark list
jj bookmark set <name> -r <change-id>
jj bookmark delete <name>
```
