---
name: aur-maintain
description: >
  Diagnose and fix problems in bupd/aur (Prasanth's AUR package repo, submodule-per-package
  layout). Use when asked to check on, fix, or update AUR packages, or investigate why
  automated update PRs there aren't merging.
---

Repo: `~/code/aur` (github.com/bupd/aur), one git submodule per package, each submodule's
own remote is `aur.archlinux.org`. `.nvchecker.toml`/`nvchecker.log` track upstream
versions; `check_updates.yml` opens a daily automated PR per outdated package.

## HARD RULE — never push to aur.archlinux.org

Prep and commit locally, push to `origin` (GitHub) only. AUR publishes are irreversible
and user-facing — that push stays Prasanth's, always. If push commands are the deliverable,
print them for him to run, don't execute them.

## Diagnosis order

1. `gh pr list` / `gh run list` on bupd/aur — check whether automated update PRs are
   actually getting validated. Known failure mode (found 2026-09-22): `check_updates.yml`
   opens PRs using the default `GITHUB_TOKEN` via `peter-evans/create-pull-request` — GitHub
   refuses to let `GITHUB_TOKEN`-triggered pushes start further `pull_request` workflow
   runs, so `Validate PKGBUILDs` silently never fires on bot PRs (shows `action_required`/0
   jobs). A PAT-secret fix (`secrets.PAT_TOKEN || secrets.GITHUB_TOKEN`) exists as a prepped
   no-op PR (#661), but Prasanth DECLINED adding that secret (2026-09-22) — he re-runs/
   approves the stuck checks manually himself when needed. Don't re-ask for a PAT_TOKEN
   secret.
2. Per package: diff `.SRCINFO` against `PKGBUILD` (`makepkg --printsrcinfo`) — flag drift.
3. Check nvchecker: is the tracked version current vs upstream releases.
4. Submodule HEAD vs its `aur.archlinux.org` remote HEAD (`git ls-remote`) — confirms
   what's actually live vs what's only committed locally.
5. Smoke-test a source fetch (`makepkg -o`) on anything touched — catches broken
   PKGBUILD/source URLs without a full build.

## Fixing a version bump

Standard shape per package: bump the submodule pointer, `makepkg --printsrcinfo >
.SRCINFO`, commit both, branch name `local-update-<pkg>-<version>`. Keep branches on
`master`/ff-only after merge — don't leave stale update branches lying around.

## Report back

Status file `herdr-cc/tasks/aurfix-status.md` (harbor repo). Separate root-cause findings
(CI/workflow problems) from per-package version-bump prep — they're independent issues.
List exactly which packages are prepped-and-ready-to-push vs which need his input first
(e.g. a newer upstream version showed up mid-diagnosis — don't silently re-chase it,
ask). Never merge or close the automated PRs yourself.
