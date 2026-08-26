---
name: youtube-analyze
description: |
  Analyse YouTube videos by fetching transcripts and generating structured summaries
  with key takeaways, timestamps, and knowledge extraction. Use when the user wants to:
  (1) extract insights from conference talks, webinars, or interviews, (2) create
  structured notes from technical tutorials, (3) summarise long-form video content for
  quick reference, (4) capture frameworks/methodologies from a talk, (5) build a library
  of video-sourced knowledge. Triggers: a YouTube URL with a summarise/analyse request,
  "youtube-analyze", /youtube-analyze.
---

# /youtube-analyze

Analyse YouTube videos by fetching transcripts and generating structured summaries with key takeaways, timestamps, and knowledge extraction. Creates a reference note capturing the video's core value.

## Usage

```
/youtube-analyze <youtube-url> [--depth quick|standard|deep] [--focus concepts|frameworks|actions]
```

| Parameter  | Description                                    | Required |
|------------|------------------------------------------------|----------|
| `url`      | YouTube video URL                              | Yes      |
| `--depth`  | Analysis depth (default: `standard`)           | No       |
| `--focus`  | What to emphasise in extraction (default: all) | No       |

## Instructions

### Phase 1: Fetch video information

1. **Get video metadata** — Use MCP YouTube tools if available, or WebFetch:
   - Title, channel, duration, publish date, description
   - View count and like count (if available)
2. **Get transcript** — Fetch the full transcript with timestamps
   - If MCP YouTube tools are available, use `get_timed_transcript`
   - Otherwise, use WebFetch or alternative transcript sources
3. **Assess content** — Determine the video type:
   - Conference talk, tutorial, interview, panel, demo, review

### Phase 2: Analyse content

Process the transcript to extract:

1. **Key topics** — Main subjects discussed (with timestamps)
2. **Core arguments** — The presenter's main points and thesis
3. **Frameworks and models** — Any structured frameworks introduced
4. **Concepts defined** — New terms or concepts explained
5. **Tools and technologies** — Specific tools mentioned
6. **Actionable takeaways** — Practical advice the viewer can act on
7. **Quotes** — Notable quotations worth preserving
8. **References** — Books, papers, tools, or resources mentioned

### Phase 3: Generate reference note

Create a structured reference note with the analysis, using the output format below. If the user works in an Obsidian vault (see the `obsidian-vault` skill), save it there; otherwise deliver as a markdown file.

## Output format

```markdown
---
type: Reference
title: "Reference - <Video Title>"
referenceType: youtube
created: YYYY-MM-DD
url: "<youtube-url>"
channel: "<Channel Name>"
duration: "<HH:MM:SS>"
publishDate: YYYY-MM-DD
tags: [content/youtube, domain/relevant-tag]
summary: "<One-line summary>"
---

# <Video Title>

> **Channel:** <Channel Name> | **Duration:** <HH:MM:SS> | **Published:** YYYY-MM-DD
> **URL:** <youtube-url>

## Summary

<2-3 paragraph summary of the video's core message and value>

## Key Takeaways

1. **<Takeaway 1>** — <Brief explanation>
2. **<Takeaway 2>** — <Brief explanation>
3. **<Takeaway 3>** — <Brief explanation>

## Timestamped Topics

| Timestamp | Topic        | Key Point        |
|-----------|--------------|------------------|
| 00:00     | Introduction | <What's covered> |
| 05:30     | <Topic>      | <Key point>      |

## Concepts and Frameworks

### <Framework/Concept Name>
<Description as explained in the video>

## Notable Quotes

> "<Quote>" — <Speaker> (timestamp)

## Tools and Resources Mentioned

- **<Tool/Resource>** — <Brief description and context>

## Actionable Items

- [ ] <Action the viewer can take>

## Related Notes

- [[<Related concept or note>]]
```

## Examples

- `/youtube-analyze https://www.youtube.com/watch?v=abc123 --depth deep` — deep analysis of a conference talk, all frameworks/concepts/actions
- `/youtube-analyze https://www.youtube.com/watch?v=xyz789 --depth quick` — quick summary of main steps and takeaways
- `/youtube-analyze https://www.youtube.com/watch?v=def456 --focus frameworks` — extraction focused on frameworks and models
