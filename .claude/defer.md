# Defer Skill

Solves: Capture interesting ideas/articles/code without breaking focus. Process them asynchronously later.

The problem you're solving: When deep in work, you find something interesting. You either derail yourself to think about it OR ignore it and lose it. Defer handles this.

## When to Use This Skill

Use when you encounter:
- Interesting article/thread mid-work
- Code pattern or library you don't understand yet
- GitHub issue/PR worth exploring later
- Blog post on unfamiliar topic
- Tweet/discussion sparking ideas
- Any "interesting but not urgent" capture

## How to Implement in Your Workflow

### Quick Capture (5 seconds)
1. Highlight or copy the text
2. Create a file in `_deferred/` folder with:
   - Capture date + time
   - Source (URL, context)
   - Raw text/link
   - Why you captured it (1-2 words)

Example:
```markdown
---
captured: 2026-01-17T23:30
source: https://github.com/...
why: understanding-openid
---

# [Raw text or link here]

## Context
Where did you find it? What were you doing?
```

### Async Processing
- **Daily:** 10 min slot for reviewing `_deferred/` captures
- **AI help:** Use Claude to explain unfamiliar concepts
- **Action:** Move to relevant workflow/project OR archive

### Daily Digest
Instead of email, log to `_memories.md`:
- Learnings from captured items
- Links to save
- Patterns noticed

## Implementation Details

### Folder Structure
```
_deferred/
├── YYYY-MM-DD-captures.md (batch by day)
├── processed/ (archive after review)
```

### Processing Queue
Each morning: 10 min review
1. Open `_deferred/YYYY-MM-DD-captures.md`
2. For each capture:
   - Read + understand
   - Ask Claude: "Explain this concept" or "Why does this matter?"
   - Move insight to relevant note in vault
   - Move file to `processed/`
3. Log patterns to `_memories.md`

## Example Workflow

**During deep work (2 sec):**
```
[Find interesting article on Kubernetes RBAC]
→ Copy link + 1 sentence why
→ Create file in _deferred/2026-01-17-captures.md
→ Back to work (never left focus)
```

**Next morning (10 min):**
```
[Review _deferred/2026-01-17-captures.md]
→ Read: "Why is RBAC important for multi-tenant clusters?"
→ Ask Claude: "Explain Kubernetes RBAC in 3 sentences"
→ Add insight to Work/kubernetes-patterns.md
→ Delete capture, move on
```

## Rules
- Capture takes <5 seconds max
- Processing happens async (next morning)
- Never let captures pile up >3 days
- Archive processed captures weekly
- Add learnings to `_memories.md`

## Machine Goal Alignment
Defer helps you:
- Stay in flow during deep work (important for 666 PRs goal)
- Capture learning opportunities without derailing
- Build knowledge without context switching
- Review async = respects energy patterns (dead zone recovery)

## Tags
#defer #workflow #focus #learning
