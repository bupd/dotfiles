---
name: neovim-pr-review
description: Prepare GitHub pull requests for local Neovim code review by checking out the PR, uncommitting its changes, and leaving all PR edits unstaged in the working tree. Use when the user provides a GitHub PR URL or PR number and wants to review highlighted file changes in Neovim, inspect a raw PR patch/diff, or turn a PR into local unstaged changes without committing anything.
---

# Neovim PR Review

## Workflow

Use the helper script for checkout/reset operations instead of rewriting the git sequence manually. It has guardrails for dirty worktrees, PR URL parsing, base branch fetching, and branch collisions.

From inside the target repository, run:

```bash
python ~/.agents/skills/neovim-pr-review/scripts/prepare_pr_review.py <github-pr-url>
```

The script will:

1. Require a clean worktree before doing anything.
2. Resolve PR metadata with `gh pr view`.
3. Fetch `refs/pull/<number>/head` and the PR base branch from the matching GitHub remote.
4. Create a new local review branch from the PR head.
5. Reset that branch back to the merge-base with `git reset --mixed`, leaving the PR changes unstaged.

After it finishes, open Neovim normally:

```bash
nvim .
```

Git signs, file explorers, and `git status` integrations should now show the PR's files as ordinary unstaged changes.

## Raw Patch

To get the entire PR as a raw patch:

```bash
gh pr diff 109 -R container-registry/8gcr --patch > pr-109.patch
```

For public repositories, appending `.patch` or `.diff` to the PR URL also works:

```bash
curl -L https://github.com/container-registry/8gcr/pull/109.patch > pr-109.patch
curl -L https://github.com/container-registry/8gcr/pull/109.diff > pr-109.diff
```

Prefer `gh pr diff` for private repositories because it uses the existing GitHub CLI authentication.

## Safety Rules

- Do not run the checkout/reset workflow with local edits present; stash or commit them first.
- Do not use `git reset --hard` for this workflow.
- Do not force-update an existing review branch unless the user explicitly asks.
- If the repository remote does not match the PR's base repository, stop and ask which remote to use.

## Helper

The bundled helper is `scripts/prepare_pr_review.py`. Read or patch it only when the user needs different behavior, such as a custom branch name or support for a non-GitHub host.
