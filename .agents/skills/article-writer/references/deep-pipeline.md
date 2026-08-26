# Deep Pipeline: Multi-Agent Article Production

For high-stakes pieces: policy analysis, contrarian arguments, anything the user explicitly wants to maximize reach and defensibility on. Token-expensive; confirm the piece warrants it. Pause for user feedback between phases.

## Required input

Before Phase 1, get from the user:
1. Identity and positioning goals (who they are publishing as)
2. Thesis — a falsifiable claim, not a topic
3. Initial thinking: key arguments, data they already trust
4. Pre-existing research (optional)
5. Tone and audience preferences

Good thesis example: "Remote-first companies will outperform hybrid ones over the next decade, not because remote is inherently better, but because it forces written communication culture, which compounds into better decision-making."
Too weak: "I want to write about why remote work is good."

## Phase 1: Deep research (3 parallel agents)

- **Agent 1A — Discourse & sentiment**: map what is already being said, by whom, and where the audience's emotional center is
- **Agent 1B — Data & precedent**: hard numbers, studies, historical analogies, with URLs
- **Agent 1C — Platform & viral strategy**: what formats/hooks are currently working for this topic and audience

Agents must return structured, sourced data. Vague summaries = re-run with narrower prompts or ask the user for primary sources.

## Phase 2: Architecture

- 5–10 title options
- Structural skeleton with per-section word counts
- Key data points to feature
- Tone calibration against the user's positioning

## Phase 3: Multi-draft generation (4 parallel agents)

Each writes a complete draft of the same architecture in a genuinely different voice:

- **Draft A — The Analyst**: data-first, measured
- **Draft B — The Contrarian**: punchy, provocative
- **Draft C — The Bridge Builder**: empathetic, constructive
- **Draft D — The Storyteller**: narrative-driven

If drafts converge into one voice, the constraints are too tight; relax tone instructions and re-run.

## Phase 4: Expert evaluation panel

5 evaluator agents score all drafts 1–10 with line-level feedback:
virality/hook strength, analytical rigor, credibility/sourcing, voice authenticity, structural clarity.
Panel ends with a synthesis recommendation: which draft leads, which elements to graft from others.

## Phase 5: Synthesis & iteration

- Build a hybrid from the best elements per the panel's recommendation
- Re-run the panel; iterate 2–3 rounds until all scores ≥ 7
- If scores plateau below 7 after 3 rounds: stop, present the best version with the panel's remaining concerns, let the user decide

## Final deliverables

1. Final article (markdown file)
2. Launch tweet (<280 chars)
3. Posting strategy: TLDR self-reply, 4–5 follow-ups over 48h, 3–4 prepared rebuttals

## Quality standards (enforced at every phase)

- Every claim: inline [n] citation with source URL
- No em dashes
- Steel-man opposing arguments before dismantling
- Bold subheadings every section
- 1,000–1,500 words target
- Opening and closing work as standalone tweets

## Failure modes

- **Surface-level research**: topic too niche for search. Ask user for primary sources, re-run Phase 1.
- **Identical drafts**: relax constraints, re-run Phase 3.
- **Score plateau < 7**: stop iterating, ship best + concerns.
- **Context filling**: save every phase's output to files; resume from files in a fresh session starting at Phase 3.

Save all intermediate versions to files — users often want earlier phrasing back.
