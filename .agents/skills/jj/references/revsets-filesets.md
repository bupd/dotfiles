# Revsets and Filesets

## Revsets

| Expression | Meaning |
|---|---|
| `@`, `@-`, `@--` | Working copy, parent, grandparent |
| `trunk()` | Mainline tip |
| `mine()` | Changes authored by the current user |
| `bookmarks()` | Local bookmark tips |
| `remote_bookmarks()` | Remote bookmark tips |
| `::x` | Ancestors of x, including x |
| `x::` | Descendants of x, including x |
| `x::y` | DAG range from x to y |
| `x..y` | `(::y) ~ (::x)` |
| `heads(x)` / `roots(x)` | Heads or roots of a set |
| `description(p)` | Description matches pattern p |
| `file(path)` | Changes modifying a path |
| `empty()` | Changes with no diff |
| `conflicts()` | Changes with unresolved conflicts |
| `present(x)` | x if it exists, otherwise empty |
| `x \| y`, `x & y`, `~x` | Union, intersection, complement |

`::` is a DAG range; `..` is set difference. They are not interchangeable.

## Filesets

| Pattern | Meaning |
|---|---|
| `file.txt` | Exact path |
| `glob:src/**/*.rs` | Glob |
| `root:path` | Path relative to repository root |
| `a \| b`, `a & b`, `~a` | Union, intersection, complement |
| `all()`, `none()` | All or no files |

Quote filesets containing operators or globs so the shell does not expand them.
