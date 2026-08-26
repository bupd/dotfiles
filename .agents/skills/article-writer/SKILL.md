---
name: article-writer
description: |
  Write long-form articles and blog posts: blog posts, X (Twitter) Articles, newsletters,
  policy/market analysis, technical writeups, and their promo assets (launch tweet, thread
  version). Use when the user wants to: (1) write a blog post or article on any topic,
  (2) write an X article or long-form social post, (3) turn research, notes, or a
  conversation into a publishable article, (4) maximize engagement/reach on a piece of
  writing, (5) produce a tweet thread or launch tweet from an article. Scales from a
  single-pass draft to a multi-agent research/draft/evaluation pipeline for high-stakes
  pieces.
---

# Article Writer

Produce publishable long-form writing that is both credible and shareable: researched claims with sources, a deliberate structure, a voice that does not read as AI-generated.

## Step 0: Calibrate effort

Pick the track before writing anything:

| Track | When | Process |
|---|---|---|
| **Light** | Casual blog post, personal writeup, content already researched in conversation | Single pass: outline → draft → self-review checklist |
| **Standard** | Public-facing post the user will publish under their name | Research with sources → architecture → draft → review checklist → promo assets |
| **Heavy** | High-stakes piece: policy analysis, contrarian argument, "I want this to go viral" | Full multi-agent pipeline — read [references/deep-pipeline.md](references/deep-pipeline.md) |

If the target platform is X (Twitter) Articles, also read [references/x-platform.md](references/x-platform.md) before drafting — it has hard formatting constraints and viral structure patterns.

## Step 1: Pin the thesis

Refuse to start from a topic; demand a claim. "Why remote work is good" is a topic. "Remote-first companies outperform hybrid ones because forced written communication compounds into better decision-making" is a thesis.

Get from the user (or derive from conversation context):
- The thesis in one or two sentences
- Audience and where it will be published
- Voice: their persona, or neutral engineering-blog voice
- Any primary material (data, links, war stories) they already have

## Step 2: Research

Every factual claim needs a source the reader can check. Use web search for anything not already verified in conversation. Collect:
- Hard numbers (limits, dates, prices, percentages) with exact figures
- The strongest opposing argument — to steel-man, not to ignore
- What the current discourse already says, so the piece adds something instead of repeating it

Skip this step only on the Light track when the material came from work already done in the session.

## Step 3: Architecture

Before prose, produce:
- 3–5 title options (short noun phrase or a sharp question; no "X: Y explainer" titles)
- Section skeleton with one-line purpose per section and rough word counts
- The 2–3 data points or lines the piece is built around
- Opening and closing lines — each must work as a standalone quote/tweet

Structure heuristics:
- 1,000–1,500 words for X articles and most blog posts; 2,000+ only for essay-style pieces with narrative
- Story arc beats listicle: symptom → investigation → mechanism → fix → moral works for technical posts
- Bold/`##` subheadings for every section; tables for enumerable facts; code blocks for anything copy-pasteable
- Address the obvious objection early, not in a footnote

## Step 4: Draft

Write with real content throughout. Rules that keep it credible and human:

- **No em dashes.** Strongest AI-writing tell. Use colons, periods, or rewrite.
- **No filler phrases**: "in today's fast-paced world", "it's worth noting", "let's dive in", "game-changer".
- **Cite inline.** Link claims where they appear or with [n] markers plus a sources section.
- **Steel-man before dismantling.** State the opposing view in its strongest form first.
- **Specific beats general.** "40 jobs in one minute, double the Free-plan cap" beats "a lot of jobs quickly".
- **One idea per paragraph.** Vary sentence length; a short sentence after two long ones lands.
- **The moral is earned, not appended.** End with the sharpest one-line restatement of the thesis.

## Step 5: Review checklist

Run before delivering. Fix, don't just note:

- [ ] First line hooks — insecurity, opportunity, surprise, or concrete stakes
- [ ] Opening and closing each work standalone
- [ ] Every number/claim sourced; no orphan statistics
- [ ] Strongest counterargument addressed
- [ ] De-AI pass done — full pattern list in [references/de-ai-ify.md](references/de-ai-ify.md)
- [ ] Headings scannable: a reader skimming only headings gets the argument
- [ ] Title is a name or a question, not a caption with a colon-explainer
- [ ] Reader leaves with something actionable (a checklist, a config snippet, a rule of thumb)

For Heavy track, replace this with the evaluation panel in [references/deep-pipeline.md](references/deep-pipeline.md).

## Step 6: Deliverables

Default deliverable set (trim on Light track):
1. **The article** as a markdown file — portable to any blog engine
2. **Launch tweet** under 280 chars: hook + link slot, no hashtag spam
3. **Thread version** on request: 8–13 tweets, one idea per tweet, thesis in tweet 1, arithmetic/punchline in the last, `[blog link]` slot at the end

For posting strategy, engagement patterns, and X-specific promo formats, see [references/x-platform.md](references/x-platform.md).

## Publishing

This skill writes; it does not publish. For pushing a finished article into the X Articles editor via browser automation, use the separate `x-article-publisher` skill (handles cover image, rich-text paste, divider/table quirks).
