---
name: diagramming
description: |
  Generate and review architecture diagrams. Use when the user wants to: (1) create
  architecture diagrams — C4 context/container/component, system landscape maps, data
  flow, AWS infrastructure, integration patterns — as PNGs via the Python `diagrams`
  library, (2) generate text-based C4 diagrams (Mermaid C4, flowchart-with-C4-styling,
  or PlantUML) that render in Git/Obsidian, (3) analyse or review an existing diagram
  image (architecture diagram, flowchart, technical drawing) for correctness, clarity,
  and gaps. Triggers: "diagram", "C4", "architecture diagram", "visualize the system",
  "review this diagram", /diagram, /c4-diagram, /diagram-review.
---

# Diagramming

Three workflows, each fully documented in its own reference. Load only the one matching the task:

| Task | Reference |
|---|---|
| Generate diagram **PNGs** with the Python `diagrams` library — C4, system landscape, data flow, AWS infra | [references/diagram.md](references/diagram.md) |
| Generate **text-based C4 diagrams** (Mermaid C4 / flowchart LR with C4 styling / PlantUML) — Git-friendly, renders inline in Obsidian | [references/c4-diagram.md](references/c4-diagram.md) |
| **Review/analyse an existing diagram image** with vision sub-agents | [references/diagram-review.md](references/diagram-review.md) |

## Choosing between the two generators

- Need a rendered image artifact (docs site, slide, PNG attachment) → `diagrams` library workflow (diagram.md)
- Need diffable source that lives in a repo or vault → text-based C4 workflow (c4-diagram.md)

## Portability note

The references originate from an Obsidian-vault setup: mentions of "System note frontmatter" (`c4:` blocks), vault paths like `Attachments/`, and specific system names (ODIE, AMOS) are that vault's conventions. Adapt to the current project: source the same structured data from wherever the project keeps architecture facts (design docs, README, code), and write outputs to the project's docs/assets location. Frontmatter in the reference files (`context: fork`, `model: opus`) is from the original author's harness — ignore it.

## Prerequisites

- PNG workflow: Python 3 with the `diagrams` package plus Graphviz installed
- PlantUML output: a PlantUML renderer if a rendered image is needed (Mermaid needs nothing extra)
