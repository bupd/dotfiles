#!/usr/bin/env python3
"""Prepare a GitHub PR as unstaged working-tree changes for Neovim review."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
import time
from pathlib import Path
from urllib.parse import urlparse


def run(args: list[str], cwd: Path | None = None, check: bool = True) -> str:
    proc = subprocess.run(
        args,
        cwd=cwd,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if check and proc.returncode != 0:
        message = [f"command failed: {' '.join(args)}"]
        if proc.stdout.strip():
            message.append(proc.stdout.strip())
        if proc.stderr.strip():
            message.append(proc.stderr.strip())
        raise SystemExit("\n".join(message))
    return proc.stdout.strip()


def parse_pr(value: str, repo: str | None) -> tuple[str, str, str]:
    value = value.strip()
    parsed = urlparse(value)
    if parsed.netloc.endswith("github.com"):
        parts = [part for part in parsed.path.split("/") if part]
        if len(parts) >= 4 and parts[2] == "pull" and parts[3].isdigit():
            return parts[0], parts[1], parts[3]

    match = re.fullmatch(r"([^/\s]+)/([^#\s]+)#(\d+)", value)
    if match:
        return match.group(1), match.group(2), match.group(3)

    if value.isdigit() and repo:
        owner, name = repo.split("/", 1)
        return owner, name, value

    raise SystemExit(
        "pass a GitHub PR URL, owner/repo#number, or --repo owner/repo with a PR number"
    )


def normalize_github_remote(url: str) -> str | None:
    patterns = [
        r"github\.com[:/]([^/]+)/([^/]+?)(?:\.git)?$",
        r"https://github\.com/([^/]+)/([^/]+?)(?:\.git)?$",
        r"ssh://git@github\.com/([^/]+)/([^/]+?)(?:\.git)?$",
    ]
    for pattern in patterns:
        match = re.search(pattern, url)
        if match:
            return f"{match.group(1)}/{match.group(2)}".lower()
    return None


def find_remote(root: Path, owner: str, repo: str) -> str:
    target = f"{owner}/{repo}".lower()
    remotes = run(["git", "remote"], cwd=root).splitlines()
    matches: list[str] = []
    seen: list[str] = []
    for remote in remotes:
        url = run(["git", "remote", "get-url", remote], cwd=root, check=False)
        normalized = normalize_github_remote(url)
        if normalized:
            seen.append(f"{remote}={normalized}")
        if normalized == target:
            matches.append(remote)

    if len(matches) == 1:
        return matches[0]
    if len(matches) > 1:
        raise SystemExit(f"multiple remotes match {target}: {', '.join(matches)}")

    details = f"; saw {', '.join(seen)}" if seen else ""
    raise SystemExit(f"no git remote matches GitHub repository {target}{details}")


def ensure_clean(root: Path) -> None:
    status = run(
        ["git", "status", "--porcelain=v1", "--untracked-files=all"],
        cwd=root,
    )
    if status:
        raise SystemExit(
            "worktree is not clean; stash or commit local changes before preparing a PR review\n"
            + status
        )


def branch_exists(root: Path, branch: str) -> bool:
    proc = subprocess.run(
        ["git", "show-ref", "--verify", "--quiet", f"refs/heads/{branch}"],
        cwd=root,
    )
    return proc.returncode == 0


def validate_branch(root: Path, branch: str) -> None:
    run(["git", "check-ref-format", "--branch", branch], cwd=root)
    if branch_exists(root, branch):
        raise SystemExit(f"local branch already exists: {branch}")


def pr_metadata(owner: str, repo: str, number: str) -> dict[str, object]:
    url = f"https://github.com/{owner}/{repo}/pull/{number}"
    output = run(
        [
            "gh",
            "pr",
            "view",
            url,
            "--json",
            "baseRefName,headRefName,number,title,url",
        ]
    )
    return json.loads(output)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Prepare a GitHub PR as unstaged changes for Neovim review."
    )
    parser.add_argument("pr", help="GitHub PR URL, owner/repo#number, or PR number with --repo")
    parser.add_argument("--repo", help="owner/repo, required when passing only a PR number")
    parser.add_argument("--branch", help="local review branch to create")
    args = parser.parse_args()

    owner, repo, number = parse_pr(args.pr, args.repo)
    root = Path(run(["git", "rev-parse", "--show-toplevel"])).resolve()
    ensure_clean(root)

    metadata = pr_metadata(owner, repo, number)
    base = str(metadata["baseRefName"])
    remote = find_remote(root, owner, repo)
    branch = args.branch or f"review-pr-{number}-{time.strftime('%Y%m%d-%H%M%S')}"
    validate_branch(root, branch)

    pr_ref = f"refs/remotes/{remote}/pull/{number}/head"
    base_ref = f"refs/remotes/{remote}/{base}"

    run(
        ["git", "fetch", "--no-tags", remote, f"+refs/pull/{number}/head:{pr_ref}"],
        cwd=root,
    )
    run(
        ["git", "fetch", "--no-tags", remote, f"+refs/heads/{base}:{base_ref}"],
        cwd=root,
    )
    run(["git", "switch", "--create", branch, pr_ref], cwd=root)
    merge_base = run(["git", "merge-base", "HEAD", base_ref], cwd=root)
    run(["git", "reset", "--mixed", merge_base], cwd=root)

    status = run(["git", "status", "--short"], cwd=root)
    short_base = run(["git", "rev-parse", "--short", merge_base], cwd=root)

    print(f"Prepared PR #{metadata['number']}: {metadata['title']}")
    print(f"URL: {metadata['url']}")
    print(f"Repository: {owner}/{repo}")
    print(f"Branch: {branch}")
    print(f"Base: {base} at merge-base {short_base}")
    print("\nUnstaged changes:")
    print(status or "(none)")
    print("\nOpen with: nvim .")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit("interrupted")
