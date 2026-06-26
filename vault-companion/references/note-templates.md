# Note Templates Reference

Templates for vault notes. Load when creating or reconciling notes. Adapt freely — these are starting shapes, not rigid forms. Keep frontmatter minimal and useful.

---

## Guardrail Flag Format

When either Hard Guardrail triggers, embed the flag prominently at the top of the note, immediately under the title, so it's impossible to miss:

```markdown
> ⚠️ **COUNSEL REVIEW (Iowa) REQUIRED** before acting on this.
> Reason: [public announcement / competing-venture activity / confidentiality surface]
> This note captures intent only. Not cleared for action.
```

For Prime Directive:

```markdown
> ⏸️ **PARKED per Prime Directive.** [Venture] is deferred behind [priority].
> To unpark: [what would need to be true].
> Captured for future reference, not as a live action item.
```

---

## Decision Note

The highest-value note type. Captures a decision and — critically — the reasoning, so future-you can tell whether it still holds.

```markdown
---
type: decision
date: YYYY-MM-DD
status: decided | revisiting | superseded
tags: []
---

# Decision: [short title]

## Decision
[What was decided, in one or two sentences.]

## Why
[The reasoning. The constraints, tradeoffs, and context that drove it. This is
the part that lets you re-evaluate later when circumstances change.]

## Alternatives considered
- [Option] — [why not]

## What would change this
[The conditions under which you'd revisit. E.g., "if the upgrade cycle shortens"
or "after EMR ships."]

## Links
- Related: [[note]], [[note]]
```

---

## Session-Capture Note

For distilling a working session into durable knowledge at the end of a conversation.

```markdown
---
type: session
date: YYYY-MM-DD
tags: []
---

# Session: [topic] — YYYY-MM-DD

## What we worked on
[One-paragraph summary of the substance — not a transcript.]

## Decisions made
- [Decision] → see [[Decision: ...]] if it warrants its own note

## Open questions
- [Unresolved question — this is next session's agenda]

## Next step
[The single most important thing to do next.]

## Links
- [[related note]]
```

---

## Project Note

For an active effort with a goal and a finish line.

```markdown
---
type: project
status: active | paused | shipped | archived
goal: [the finish line, stated concretely]
tags: []
---

# Project: [name]

## Goal
[What "done" looks like. A real finish line.]

## Current state
[Where it stands now.]

## Decisions
- [[Decision: ...]]
- [[Decision: ...]]

## Open questions
- [...]

## Next actions
- [ ] [...]

## Links
- Area: [[Area: ...]]
- Related: [[...]]
```

---

## Area Note

For an ongoing responsibility with no end date.

```markdown
---
type: area
tags: []
---

# Area: [name]

## Scope
[What this area covers and why it's ongoing rather than a project.]

## Active projects under this area
- [[Project: ...]]
- [[Project: ...]]

## Standing context
[Durable facts and constraints that apply across projects in this area.]

## Links
- [[...]]
```

---

## Linking Conventions

- Use `[[wikilinks]]` for all internal references — this is what makes the graph navigable.
- Every new note links to at least one existing note. No orphans.
- Prefer linking to a specific decision or project note over a vague topic note.
- When a note supersedes another, link both ways and mark the old one `status: superseded` with a pointer to the replacement.
