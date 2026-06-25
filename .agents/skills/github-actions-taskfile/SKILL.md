---
name: github-actions-taskfile
description: GitHub Actions CI/CD best practices for .github/workflows/*.yml, workflow_call, release, deploy, test, build, and pipeline automation. Use when writing, reviewing, or fixing GitHub Actions workflows. Enforce thin workflows: GitHub Actions only orchestrates checkout, setup, auth, cache, artifacts, env, and calls Taskfile tasks; real pipeline logic belongs in Taskfile.yml or specific Taskfile.*.yml files. Load taskfile skill when creating or editing those tasks.
---

## GitHub Actions Taskfile

Goal: Actions = caller. Taskfile = pipeline.

## Core Rules

- Keep `.github/workflows/*.yml` thin.
- Put build/test/lint/package/release/deploy logic in `Taskfile.yml` or `Taskfile.*.yml`.
- Load `taskfile` skill before creating or changing Taskfiles.
- Prefer `task ci`, `task lint`, `task test`, `task build`, `task release`, `task deploy` over inline shell.
- Inline shell allowed only for GitHub wiring: checkout, tool install, auth, cache, artifacts, env, permissions, concurrency.
- No copied pipeline scripts inside workflow YAML.
- Fail loud. No `|| true` unless expected failure is documented in task name or comment.

## Standard Layout

Prefer root Taskfile with includes:

```yaml
version: '3'

includes:
  ci: ./Taskfile.ci.yml
  release: ./Taskfile.release.yml
  deploy: ./Taskfile.deploy.yml

tasks:
  ci:
    cmds:
      - task: ci:default
```

Workflow calls stable public tasks:

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: arduino/setup-task@v2
  - run: task ci
```

## Workflow Checklist

- `permissions:` set least privilege. Default to `contents: read`.
- `concurrency:` set for PR/branch workflows.
- `timeout-minutes:` set on every job.
- `workflow_dispatch` for manual deploy/release when useful.
- `workflow_call` for reusable org/repo workflows.
- Pin third-party actions to trusted major tags at minimum; use full SHA for high-risk/security-sensitive workflows.
- Avoid `pull_request_target`; if required, never checkout untrusted PR code with write token/secrets.
- Prefer OIDC for cloud deploys. Avoid long-lived cloud secrets.
- Use environments for deploy approval/secrets.
- Upload artifacts only when useful; set retention.
- Cache dependencies via setup actions or `actions/cache`; cache keys include lockfiles.
- Validate with `actionlint` when available.

## Good Thin CI

```yaml
name: CI

on:
  pull_request:
  push:
    branches: [main]

permissions:
  contents: read

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  ci:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v4
      - uses: arduino/setup-task@v2
      - run: task ci
```

## Good Thin Release

```yaml
name: Release

on:
  push:
    tags: ['v*']
  workflow_dispatch:

permissions:
  contents: write
  id-token: write

jobs:
  release:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    environment: release
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: arduino/setup-task@v2
      - run: task release
```

## Taskfile Boundaries

Move to Taskfile:

- package manager commands
- tests/lint/typecheck/build
- Docker build/push commands
- versioning/changelog/release commands
- deploy scripts
- smoke tests
- matrix target logic when reusable locally

Keep in Actions:

- events/triggers
- job matrix
- runner OS/image
- permissions/OIDC
- environment approvals
- caches/artifacts
- GitHub token wiring

## Review Smells

- Long `run: |` blocks.
- Workflow differs from local dev command.
- CI logic duplicated across workflows.
- Secrets used in PR workflows.
- Missing `permissions`, `timeout-minutes`, or `concurrency`.
- `pull_request_target` with checkout of PR head.
- Deployment without `environment` or OIDC.
- Cache key ignores lockfile.
- Workflow green but local `task ci` fails.

## Verification

Run what exists:

```bash
task --list
task ci
actionlint
```

If `actionlint` missing, say not run. Do not claim workflow valid without command output.
