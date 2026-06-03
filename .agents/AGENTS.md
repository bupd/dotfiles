# Global Agent Instructions

## Git Sign-off

When creating commits with DCO sign-off (`git commit -s`), always use:

```
Signed-off-by: Prasanth Baskar <bupdprasanth@gmail.com>
```

Never hardcode or guess the sign-off email. Always use `bupdprasanth@gmail.com`.

## Harbor Worktree Push Rules

See `~/.agents/harbor-worktree-rules.md` for full details. Summary:

**CRITICAL: Wrong remote = private code leaked to public repos.**

Harbor (`~/code/OSS/harbor/`) is a bare repo with worktrees named `{remote}-{description}`. The prefix before the first `-` IS the push target remote. Derive: `basename "$PWD" | cut -d'-' -f1`

- `8gcr-*` → `8gcr` (**PRIVATE**) | `next-*` → `next` (**PRIVATE**) | `bupd-*` → `bupd` (fork) | `upstream-*` → `upstream` (**PUBLIC**) | `glab-*` → `glab` (**PRIVATE**)

1. ONLY push to the remote matching the directory prefix.
2. NEVER push `8gcr` or `next` code to `upstream`.
3. When unsure, ask. Confirm remote + branch before force-push.

## Neovim PR Review

When the user provides a GitHub PR URL or PR number and wants local Neovim review, use the `neovim-pr-review` skill or run:

```bash
python ~/.agents/skills/neovim-pr-review/scripts/prepare_pr_review.py <github-pr-url>
```

This workflow requires a clean worktree, creates a dedicated review branch, and leaves the PR changes unstaged with `git reset --mixed` so Neovim highlights the changed files. Do not use `git reset --hard` for this workflow.

For a raw PR patch, prefer GitHub CLI auth:

```bash
gh pr diff <number-or-url> -R <owner/repo> --patch > pr.patch
```

For public repositories, `<pr-url>.patch` and `<pr-url>.diff` also work.

## Shared Agent Skills

Shared skills live under `~/.agents/skills/<skill-name>/SKILL.md`. Each skill uses YAML frontmatter with `name` and `description`; optional references, scripts, and assets live beside that `SKILL.md`.

Agents that support skills should index `~/.agents/skills/*/SKILL.md` at session start and autoload a skill when the user's request matches its description. Load only the matching `SKILL.md` first, then load bundled files referenced by that skill as needed.

For Codex, OpenCode, Claude-compatible agents, or custom tools without native skill indexing, use `~/.agents/skills/README.md` and `~/.agents/skills/registry.json` as discovery aids. Do not load every skill body by default.
