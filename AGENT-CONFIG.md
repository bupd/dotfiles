# Agent Configuration Management

Centralized AI agent rules for Claude Code, Codex, and OpenCode. All config files live in this dotfiles repo and are stowed to `$HOME`.

## Directory Layout

```
dotfiles/
├── .agents/                          # Shared rules (source of truth)
│   ├── AGENTS.md                     # Global instructions (source of truth)
│   ├── harbor-worktree-rules.md      # Harbor multi-remote push safety
│   ├── git-signoff.md                # DCO sign-off identity
│   └── skills/                       # Shared skill source of truth
├── .claude/
│   └── CLAUDE.md → ../.agents/AGENTS.md  # Symlink to canonical file
└── .codex/
    ├── AGENTS.md → ../.agents/AGENTS.md  # Symlink to canonical file
    └── skills/ → ../.agents/skills/*     # Symlinks for Codex skill discovery
└── .config/opencode/
    ├── AGENTS.md                         # OpenCode-specific global instructions
    └── skills/ → ../../.agents/skills/*  # Symlinks for OpenCode skill discovery
```

## What each agent reads

| Agent       | Global config                  | Project config     |
|-------------|--------------------------------|--------------------|
| Claude Code | `~/.claude/CLAUDE.md`          | `./CLAUDE.md`      |
| Codex       | `~/.codex/AGENTS.md`           | `.codex/AGENTS.md` |
| OpenCode    | _(none)_                       | `./AGENTS.md`      |

Claude Code and Codex read from the same canonical file (`~/.agents/AGENTS.md`) via symlinks. Edit once, both agents see the change. OpenCode uses `~/.config/opencode/AGENTS.md` for OpenCode-specific global behavior and links skills from `~/.opencode/skills/`.

OpenCode also reads `AGENTS.md` from the project root. For harbor worktrees, symlink it:
```bash
ln -s ~/.agents/AGENTS.md ~/code/OSS/harbor/<worktree>/AGENTS.md
```

## Stowing

The dotfiles repo uses symlinks via stow. Only instruction files are tracked — never caches, sessions, auth tokens, or history.

### First-time setup

```bash
# Back up existing files (if not yet stowed)
mkdir -p ~/agent-config-backup/.agents ~/agent-config-backup/.claude ~/agent-config-backup/.codex
cp ~/.agents/*.md ~/agent-config-backup/.agents/
cp -r ~/.agents/skills ~/agent-config-backup/.agents/
cp ~/.claude/CLAUDE.md ~/agent-config-backup/.claude/
cp ~/.codex/AGENTS.md ~/agent-config-backup/.codex/

# Remove originals so stow can create symlinks
rm ~/.agents/AGENTS.md ~/.agents/git-signoff.md ~/.agents/harbor-worktree-rules.md ~/.agents/README.md
rm -rf ~/.agents/skills
rm ~/.claude/CLAUDE.md
rm ~/.codex/AGENTS.md

# Stow from dotfiles
cd ~/dotfiles
stow -t ~ .
```

### After editing rules

Edit `~/dotfiles/.agents/AGENTS.md` — changes propagate automatically via symlinks to both `.claude/CLAUDE.md` and `.codex/AGENTS.md`. Update `~/dotfiles/.config/opencode/AGENTS.md` when OpenCode-specific guidance changes.

## Skills

The canonical skill root is `~/.agents/skills`. Tool-specific skill directories should contain symlinks back to that root rather than duplicate skill content.

Every shared skill must have:

- `~/.agents/skills/<skill-name>/SKILL.md`
- A matching entry in `~/.agents/skills/registry.json`
- A symlink in `~/.codex/skills/<skill-name>`
- A symlink in `~/.opencode/skills/<skill-name>`

## Adding a new rule for all agents

1. Write the rule in `dotfiles/.agents/<rule-name>.md`
2. Add a summary to `dotfiles/.agents/AGENTS.md` (automatically visible to Claude Code and Codex via symlinks)
3. Stow if not already linked
4. Commit to dotfiles repo

## What NOT to track

These live in `~/.claude/` and `~/.codex/` but must not be committed:

- `auth.json`, `.credentials.json` — secrets
- `history.jsonl`, `sessions/` — conversation history
- `cache/`, `backups/`, `downloads/` — ephemeral data
- `settings.json`, `settings.local.json` — machine-specific
- `*.sqlite` — local state databases
