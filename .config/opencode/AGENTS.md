# OpenCode Global Instructions

## Filesystem Constraints

Treat root-level filesystem paths as read-only for writes on this machine. Do not create, edit, or stage scratch files under `/` or `/tmp`; keep temporary files, generated files, and command output artifacts inside the active project/workspace, using a project-local path such as `.opencode/tmp/` when a temp directory is needed.

## Neovim PR Review

When the user provides a GitHub PR URL or PR number and wants local Neovim review, use the shared helper:

```bash
python ~/.agents/skills/neovim-pr-review/scripts/prepare_pr_review.py <github-pr-url>
```

This requires a clean worktree, creates a dedicated review branch, and leaves the PR changes unstaged with `git reset --mixed` so Neovim highlights the changed files. Do not use `git reset --hard` for this workflow.

For a raw PR patch, prefer `gh pr diff <number-or-url> -R <owner/repo> --patch > pr.patch`. For public repositories, `<pr-url>.patch` and `<pr-url>.diff` also work.

## Shared Agent Skills

Shared skills live under `~/.agents/skills/<skill-name>/SKILL.md`. OpenCode skill links live under `~/.opencode/skills/` and point back to the shared skill root.

Index `~/.agents/skills/*/SKILL.md` or `~/.agents/skills/registry.json` at session start. Autoload a skill only when the user's request matches its `description`, then load bundled references, scripts, or assets lazily.
