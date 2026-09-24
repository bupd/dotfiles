---
name: smart-goals
description: "Rewrite any goal or task into SMART form (specific, measurable, achievable, relevant, time-bound) before it is written down, then create it on Prasanth's Notion task board with notiontask, falling back to the Obsidian vault when Notion credentials are missing. Use when he says add a task, create a goal, track this, put this on my board, remind me to, new OKR, log this as a todo, set a goal for Q4, or whenever an agent is about to record a goal, objective, milestone, or todo anywhere."
---

# SMART Goals

Any goal or task that is about to be written somewhere durable goes through the SMART pass first. Durable means Notion, the Obsidian vault, an issue tracker, a calendar event, a handoff note. The pass produces corrected wording, then the task gets created.

Order of work:

1. Decide whether this is a goal at all. If it is not, skip the skill.
2. Run the five checks and rewrite until each one passes.
3. Assemble the goal statement.
4. Create it in Notion with `notiontask create`.
5. If Notion is unreachable or unconfigured, write it into the vault and say so out loud.

## When not to use this

Skip the whole skill for:

- Shell steps and one-off commands inside work already running.
- Sub-steps of a task that is already tracked. The parent task is the SMART one; its checklist items are not.
- Anything that lives and dies inside one session, including scratch notes, TODO comments in a diff under review, and the internal plan an agent keeps for itself.
- Questions and lookups. "What is on my board" is a read, not a goal.

Test: if nobody will go looking for this item tomorrow, it does not belong on the board.

## The five checks

Each check has a rejection rule. Fix the wording yourself where context allows it; ask only for facts that are genuinely not in the conversation.

### S: Specific

Reject a bare verb of direction. "Improve X", "reduce Y", "increase Z", "look into W" say which way a number should move and nothing about what gets done. Replace with an action verb that names the work: write, implement, migrate, upgrade, reconcile, review, publish, ship, file, evaluate, transition.

Also name who is on the hook when it is not Prasanth alone, and name the artifact. "Clean up CI" is not specific; "delete the four dead workflow files in harbor/.github/workflows" is.

### M: Measurable

Reject anything with no number, no count, and no yes/no finish condition. Ask what data says this is done, then put that data in the title. Counts, rates, money, page numbers, PR numbers, and a named deliverable all qualify. "Faster builds" is not measurable; "CI wall time under 8 minutes on the main branch" is.

Qualitative goals survive if the evidence is named. "Reviewer approves the draft" is a finish condition. "Feels better" is not.

### A: Achievable

Reject scope that the calendar cannot hold. Check the stated deadline against what else is already committed that week before accepting. If the goal needs a skill, an access token, or someone else's sign-off that does not exist yet, either cut the scope or split the blocker into its own task and link them.

This is the check that should change the goal most often. Cutting four platforms to three, or six PRs to two, is the normal outcome here.

### R: Relevant

Reject anything that does not connect to current priorities. Say which one, in the goal's own words: a 2026 goal (666 upstream PRs, one post a day, one stream a week, one LinkedIn post a week), an Eisenhower Q1 item, a work commitment, health, family. The priority order is work, then health, then family.

If no connection exists, do not quietly file it. Say so and offer the backlog instead.

### T: Time-bound

Reject an undated task. Pull the date from context first: a meeting on the calendar, a sprint end, a release, "by Friday", "before the call". Only ask when context gives nothing. Anything longer than about two weeks also needs a midpoint milestone, otherwise it silently slips until the deadline.

"Ongoing" is a legitimate answer for recurring duties, and it still needs a review date and a rate ("reconcile the month's expenses by the 15th, every month").

## Assembling the statement

Fill this in, then compress to a title plus fields:

> [Action verb] [what, with the artifact named] to [measurable result] by [date]. [Who else is involved] does [their part]. This matters because [the priority it serves].

The Notion title carries the verb, the object, the number, and the date. Everything else goes into properties or the note body. Keep the title under about 80 characters so the board stays readable.

Example of the rewrite in full:

- Raw: "track my upstream PR count"
- Rejected on M and T: no number, no date.
- SMART: "Open 12 upstream PRs on harbor by 2026-10-31 (2026 goal: 666 upstream PRs), 3 merged per week, midpoint check 2026-10-15."

## Creating the task in Notion

The write path is `notiontask`, a Python CLI on the official Notion API. It is not on `PATH`; call it by absolute path.

```bash
/var/home/bupd/obsidian/donna/bin/notiontask --help
```

Never write Notion API calls by hand and never use `notcrawl` for this. `notcrawl` is the archive crawler: it syncs the workspace into SQLite and renders markdown, and it has no command that creates a page. Verified from `notcrawl --help` on 0.6.3.

Read the live schema before the first write of a session, because property names and the allowed status values come from the database, not from this file:

```bash
/var/home/bupd/obsidian/donna/bin/notiontask props
```

Then create:

```bash
/var/home/bupd/obsidian/donna/bin/notiontask create \
  "Open 12 upstream PRs on harbor by 2026-10-31 (2026 goal: 666)" \
  --set "Status=Backlog" \
  --set "Due=2026-10-31"
```

Flags that exist, read from the source at `/var/home/bupd/obsidian/donna/bin/notiontask`:

- `create "Title" [--set "Property=value" ...]` creates a page in the task database and prints the new page id and URL.
- `update <page-id-or-url> --set "Property=value" ...` edits fields.
- `status <page-id-or-url> "In Progress"` is the shortcut for `--set Status=`.
- `list [--status S] [--assignee NAME] [--limit N]`, `get <page-id-or-url>`, `search <query> [--limit N]`, `props`.

Value types are derived from the live schema, so a date takes an ISO date or the literal `today`, a multi-select takes a comma-separated string, and people are matched by workspace display name. An unknown property name fails with the list of valid names rather than guessing, so a failed `--set` is a signal to run `props`, not to retry with a different guess.

`Status` and `Due` above are placeholders. Substitute whatever `props` prints. Not verified against the live board, because the credentials below are missing.

## Credentials are missing right now

Checked on 2026-09-29:

- `~/.notcrawl/env` has a `NOTION_TOKEN=` line with an empty value.
- `NOTION_TASKS_DB` is absent from that file entirely.
- Neither is exported in the shell environment.

Every `notiontask` command that touches the API therefore fails immediately with `notiontask: no NOTION_TASKS_DB set in ~/.notcrawl/env`. This is confirmed by running `props` and `list`.

The fix, once an internal integration exists at notion.so/my-integrations with insert and update content capability, and the task database has been shared with it through the page's Connections menu:

```bash
printf 'NOTION_TOKEN=ntn_xxx\nNOTION_TASKS_DB=<task-db-id-or-url>\n' > ~/.notcrawl/env && chmod 600 ~/.notcrawl/env
```

Minting the token requires workspace Member access; a Guest account cannot do it. Never paste a token into a skill file, a commit, or a chat reply.

When a `notiontask` command fails, say which of the two values is missing and use the fallback. Do not retry silently and do not report the task as created.

## Vault fallback

With Notion unavailable, the SMART goal still gets written. It goes into `/var/home/bupd/obsidian`, following that vault's CLAUDE.md:

- Notes go at the root. Do not create folders.
- Use `##` headers. Never `**bold**` as a heading.
- Wikilinks are the organizing structure.
- Dated work items go in `private/YYYY-MM-DD.md`, and notes under `private/` carry no wikilinks.

Put a standalone goal at the root as `TOPIC-YYYY-MM-DD.md`, add it to `_eisenhower.md` under the right quadrant, and append a line to today's `private/YYYY-MM-DD.md`. Keep the same SMART wording in all three places so nothing has to be reconciled later when the Notion sync starts working.

Root note shape:

```markdown
---
created: 2026-09-29T14:05
updated: 2026-09-29T14:05
---

## Goal
Open 12 upstream PRs on harbor by 2026-10-31.

## Measure
12 PRs opened, 3 merged per week. Source: gh pr list --author bupd.

## Why
2026 goal of 666 upstream PRs.

## Dates
Start 2026-09-29, midpoint check 2026-10-15, deadline 2026-10-31.

## Status
Pending Notion sync. Move to the board once NOTION_TASKS_DB is set.
```

Mark it pending sync so a later pass can push these into Notion in a batch.

## Reference

[references/goal-writing.md](references/goal-writing.md) holds the source material: the specific-verb list, the data types that count as measurement, the scoping rules for how many goals to keep, and worked examples for ongoing duties, project work, and development goals. Load it when a goal resists the checks above, or when several goals are being set in one sitting.
