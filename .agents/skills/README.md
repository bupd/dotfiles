# Shared Skills

This directory is the shared skill root for OpenCode, Codex, Claude-compatible agents, and custom agent tooling.

## Discovery

- Canonical source: `~/.agents/skills/<skill-name>/SKILL.md`
- Metadata: YAML frontmatter `name` and `description`
- Autoload rule: match the user's task to a skill description, then load only that skill's `SKILL.md`
- Bundled resources: load referenced files from the same skill directory only when needed
- Machine-readable manifest: `~/.agents/skills/registry.json`

## Matt Pocock Skills

Installed from `mattpocock/skills`:

- `obsidian-vault` - Search, create, and organize Obsidian notes.
- `edit-article` - Restructure and tighten article drafts.
- `caveman` - Ultra-compressed communication mode.
- `handoff` - Produce handoff notes for another agent.
- `write-a-skill` - Create new agent skills.
- `diagnose` - Disciplined debugging and regression diagnosis.
- `grill-with-docs` - Stress-test plans against docs, domain language, and ADRs.
- `triage` - Triage issues through project workflow states.
- `improve-codebase-architecture` - Find architecture and refactoring opportunities.
- `setup-matt-pocock-skills` - Configure repos for the engineering skill set.
- `tdd` - Use red-green-refactor development.
- `to-issues` - Break plans into implementation issues.
- `to-prd` - Turn conversation context into a PRD.
- `zoom-out` - Explain code at a higher abstraction level.
- `prototype` - Build throwaway prototypes for logic or UI questions.
