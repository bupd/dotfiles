---
name: taskfile
description: Comprehensive reference and best practices for Task/Taskfile.dev (taskfile.dev). Use when creating, editing, or working with Taskfiles (task runner/build tool). Covers all Taskfile features from official documentation plus real-world examples - variables (string, bool, int, array, map), dependencies, includes, loops, matrix builds, status checks, platform-specific tasks, wildcards, watching files, CLI flags, configuration, environment variables, and advanced patterns from production usage.
---

# Taskfile

Complete reference for Task (taskfile.dev) - modern task runner and build tool.

## Overview

Task is a task runner / build tool that aims to be simpler and easier to use than GNU Make. This skill provides complete official documentation, production-proven patterns, and ready-to-use templates.

## When to Use

- Creating new Taskfiles for projects
- Implementing advanced features (loops, matrix, wildcards, conditions)
- Optimizing task dependencies and caching
- Working with multi-platform builds or monorepos
- Setting up includes and modular task composition
- Configuring Task CLI, environment, config files
- Debugging and troubleshooting Taskfiles

## Quick Reference

### Basic Structure

```yaml
version: '3'

vars:
  APP: myapp

tasks:
  default:
    cmds:
      - task: build
  
  build:
    desc: Build the application
    sources: ['**/*.go']
    generates: ['./{{.APP}}']
    cmds:
      - go build -o {{.APP}}
```

## Available References

Load these for comprehensive official documentation:

### Core Documentation (15 files, 135KB)

**Main Guides:**
- **references/guide.md** (52KB) - Complete usage guide with all features
- **references/schema.md** (14KB) - Full schema specification
- **references/templating.md** (16KB) - Template functions, special variables

**Configuration & CLI:**
- **references/cli.md** - Complete CLI reference (commands, flags, exit codes)
- **references/config.md** - Configuration files (.taskrc.yml)
- **references/environment.md** - Environment variables (TASK_*)

**Additional:**
- **references/any-variables.md** - Modern variable types (v3.37+)
- **references/getting-started.md** - Quick start tutorial
- **references/installation.md** - All installation methods
- **references/styleguide.md** - Official conventions
- **references/faq.md** - FAQ
- **references/integrations.md** - VS Code, JSON schema
- **references/taskfile-versions.md** - Versioning
- **references/package.md** - Go package API

## Templates

Ready-to-use Taskfiles in **assets/templates/**:

### Basic Templates
- **basic.yml** - Minimal starter Taskfile
- **go-project.yml** - Go with lint, test, build, docker, multi-platform
- **docker-compose.yml** - Docker services management
- **frontend.yml** - Node.js/Frontend (npm, dev, build, test, watch)

### Advanced Templates
- **monorepo.yml** - Multi-service monorepo with wildcards
- **ci-patterns.yml** - CI/CD integration (GitHub Actions format)
- **advanced-patterns.yml** - Wildcards, maps, refs, loops, run control, defer
- **includes-patterns.yml** - Modular organization, nested includes, monorepo
- **testing-debugging.yml** - Status, preconditions, testing, debugging, watch

## Core Features Summary

### 1. Variables and Templating

```yaml
vars:
  STRING: 'hello'
  BOOL: true
  INT: 42
  ARRAY: [1, 2, 3]
  MAP:
    map: { host: localhost, port: 5432 }
  DYNAMIC:
    sh: git rev-parse HEAD
  REF:
    ref: .OTHER_VAR  # Pass by reference
```

### 2. Task Dependencies

```yaml
tasks:
  deploy:
    deps: [build, test]  # parallel
  
  sequence:
    cmds:
      - task: first
      - task: second  # sequential
```

### 3. Loops (5 types)

```yaml
tasks:
  # Static list
  greet:
    cmds:
      - for: [alice, bob]
        cmd: echo "Hello {{.ITEM}}"
  
  # Matrix (cross-product)
  build-matrix:
    cmds:
      - for:
          matrix:
            OS: [linux, darwin, windows]
            ARCH: [amd64, arm64]
        cmd: echo "{{.ITEM.OS}}/{{.ITEM.ARCH}}"
  
  # Variable
  process:
    vars:
      FILES: 'a.txt,b.txt'
    cmds:
      - for: { var: FILES, split: ',' }
        cmd: cat {{.ITEM}}
  
  # Sources
  convert:
    sources: ['*.png']
    cmds:
      - for: sources
        cmd: convert {{.ITEM}} {{.ITEM}}.jpg
  
  # Dynamic (command output)
  clean:
    vars:
      OLD_FILES: {sh: find . -mtime +30}
    cmds:
      - for: { var: OLD_FILES }
        cmd: rm {{.ITEM}}
```

### 4. Wildcards

```yaml
tasks:
  # Match: task start:api
  start:*:
    vars:
      SERVICE: '{{index .MATCH 0}}'
    cmds:
      - docker-compose up -d {{.SERVICE}}
  
  # Match: task deploy:staging:api
  deploy:*:*:
    vars:
      ENV: '{{index .MATCH 0}}'
      SERVICE: '{{index .MATCH 1}}'
    cmds:
      - ./deploy.sh {{.ENV}} {{.SERVICE}}
```

### 5. Conditional Execution

```yaml
tasks:
  build:
    # File-based
    sources: ['**/*.go']
    generates: ['./app']
    
    # Programmatic
    status:
      - test -f ./app
    
    # Prerequisites
    preconditions:
      - sh: test -n "$API_KEY"
        msg: "API_KEY required"
```

### 6. Includes

```yaml
includes:
  docker: ./docker/Taskfile.yml
  
  backend:
    taskfile: ./backend
    dir: ./backend
    vars: { SERVICE: api }
    optional: false
    flatten: false
    internal: false
    aliases: [api]
```

### 7. Run Control

```yaml
run: when_changed  # Global

tasks:
  expensive-setup:
    run: once  # Only once even if called multiple
  
  deploy:*:
    run: once  # Per wildcard match
```

### 8. Defer Cleanup

```yaml
tasks:
  test:
    cmds:
      - mkdir tmp
      - defer: rm -rf tmp
      - exit 1  # Cleanup still runs
```

## CLI Quick Reference

Key commands (full reference in **references/cli.md**):

```bash
task [tasks...]              # Run tasks
task --list                  # List tasks
task --list-all              # All tasks (including no desc)
task --summary <task>        # Task details
task --watch <task>          # Watch for changes
task --parallel <tasks>      # Parallel execution
task --force <task>          # Force run (ignore up-to-date)
task --dry <task>            # Dry run
task --status <task>         # Check if up-to-date
task --init                  # Create new Taskfile
```

## Configuration Hierarchy

Task configuration priority (highest last):
1. Environment variables (TASK_*)
2. Config files (.taskrc.yml)
3. Command-line flags

See **references/config.md** and **references/environment.md**.

## Decision Framework

**Choose `sources`/`generates` when:**
- Building/compiling code
- File content matters
- Need automatic change detection

**Choose `status` when:**
- Remote state checks
- Complex multi-condition validation
- Non-file-based checks

**Choose `method: timestamp` when:**
- Fast builds more important than accuracy
- File content changes rarely

**Choose `method: checksum` when:**
- Accuracy critical
- Content changes matter

## Key Patterns

### Monorepo Service Management

```yaml
tasks:
  start:*:
    vars:
      SERVICE: '{{index .MATCH 0}}'
    dir: 'services/{{.SERVICE}}'
    cmds:
      - docker-compose up -d
```

### Environment-Specific Deploys

```yaml
tasks:
  deploy:
    requires:
      vars:
        - name: ENV
          enum: [dev, staging, prod]
    dotenv: ['.env.{{.ENV}}']
    cmds:
      - ./deploy.sh {{.ENV}}
```

### Watch Mode Development

```yaml
tasks:
  dev:
    watch: true
    sources: ['**/*.go']
    cmds:
      - go run ./cmd/server
```

### Complex Data Structures

```yaml
tasks:
  deploy:
    vars:
      CONFIG:
        map:
          database: { host: localhost, port: 5432 }
      JSON_DATA:
        ref: 'fromJson .JSON_STRING'
```

## Best Practices

From **references/styleguide.md**:

1. **Use `desc` for all public tasks**
2. **Kebab-case for task names** (not snake_case)
3. **UPPERCASE for variables**
4. **Set `method: timestamp`** for faster builds (if appropriate)
5. **Use `run: once`** for expensive setup
6. **Add `preconditions`** for environment validation
7. **Use defer** for guaranteed cleanup
8. **Prefer external scripts** for complex multi-line logic
9. **Use wildcards** for dynamic task matching
10. **Keep includes modular** for better organization

## Template Selection Guide

**Basic project:** `basic.yml`  
**Go application:** `go-project.yml`  
**Docker services:** `docker-compose.yml`  
**Frontend/Node:** `frontend.yml`  
**Multiple services:** `monorepo.yml`  
**CI/CD pipeline:** `ci-patterns.yml`  
**Advanced features:** `advanced-patterns.yml`  
**Modular structure:** `includes-patterns.yml`  
**Testing/debugging:** `testing-debugging.yml`

For complete feature documentation, load the appropriate reference file.
