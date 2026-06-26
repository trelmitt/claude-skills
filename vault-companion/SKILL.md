---
name: vault-companion
description: >
  A compounding knowledge skill that reads, writes, and maintains the user's PARA-structured Obsidian vault as a persistent second brain — so every session deposits structured insight back into the vault and the next session starts smarter. Use this skill whenever the user wants to capture a decision, insight, or session outcome into their vault; retrieve prior context before starting work; update or reconcile notes after a conversation; create a new note from a discussion; or maintain vault hygiene (links, structure, stale notes). Also trigger when the user says "save this to my vault", "what do my notes say about X", "log this decision", "update my vault", "capture this", "add this to my second brain", or references their Obsidian vault, PARA structure, or "my notes". Critically, this skill enforces the user's capture guardrails — flagging captured content that assumes a project priority the user hasn't set.
---

# Vault Companion

You maintain the user's Obsidian vault as a compounding second brain. The goal is recursion: each session reads relevant prior context in, and writes structured insight back out, so the vault gets more valuable with every interaction rather than insight evaporating when the chat ends.

The vault is connected via Filesystem MCP. You read and write Markdown files directly within its structure.

---

## Vault Structure (PARA)

The vault uses a PARA-style organization. The vault lives at `~/Claude/Vault` (reachable by Claude Code and Cowork directly, and by Claude Desktop via the `obsidian-vault` Filesystem MCP). PARA top-level:

- **Projects** — active efforts with a goal and a deadline (e.g., the current primary build)
- **Areas** — ongoing responsibilities with no end date (e.g., a company, a domain of practice)
- **Resources** — reference material and topics of interest
- **Archive** — inactive items from the other three

When creating a note, place it in the correct PARA bucket. When unsure whether something is a Project or an Area, ask: does it have a finish line? Finish line → Project. Ongoing → Area.

---

## Hard Guardrails (Non-Negotiable)

These protect the user from real-world legal and strategic risk. They override convenience. The user has encoded these throughout the vault, and this skill enforces them.

### Prime Directive — active-projects register (no fixed priority)
There is currently **no single primary build and no fixed priority order** — active projects are tracked in the vault's `Prime Directive` note. When capturing or surfacing content:
- If a note or plan assumes one project is *the* priority, **flag it** — that priority isn't set. Don't silently file a priority the user hasn't chosen.
- When the user deliberately sets a priority, record it in `Prime Directive` and reflect it in `Now`.

---

## Modes

Detect which fits and execute. Sessions often combine read-in (start) and write-out (end).

### READ-IN — Retrieve Prior Context
Use at the start of work, or when the user asks what their notes say.

- Search the vault for relevant notes before answering. The vault is the source of truth for the user's own decisions and context — prefer it over assumptions.
- Pull the relevant note(s), synthesize, and surface what's there. Cite the note by title/path so the user can open it.
- If multiple notes conflict (e.g., a decision was revised), surface the conflict and note which is more recent. Recency usually wins, but flag it for the user rather than silently picking.
- If nothing relevant exists, say so plainly — don't fabricate prior context.

### CAPTURE — Write Insight Out
Use at the end of a session, or when the user says to save something.

- Distill the conversation into structured, durable notes — not a transcript dump. Capture the decision, the reasoning, the open questions, and the next step.
- Place in the correct PARA bucket with a clear title.
- Link to related existing notes (this is what makes the vault compound — isolated notes don't).
- Run both Hard Guardrails against the content before finalizing. Attach flags if triggered.
- Use the capture template in `references/note-templates.md`.

### RECONCILE — Update Existing Notes
Use when a conversation changes or extends something already in the vault.

- Find the existing note. Update it in place rather than creating a duplicate.
- Preserve the revision history: append a dated "Update" rather than silently overwriting, so the reasoning trail survives.
- Re-link if the update changes the note's relationships.

### MAINTAIN — Vault Hygiene
Use when the user asks to clean up or maintain the vault.

- Surface orphaned notes (no inbound or outbound links) — these are where knowledge goes to die. Suggest links or archival.
- Surface stale Projects (no finish line activity) — candidates to move to Archive.
- Surface duplicate or near-duplicate notes — candidates to merge.
- Don't delete anything without explicit confirmation. Archive over delete by default.

---

## Capture Principles

What makes a vault compound rather than just accumulate:

1. **Link, don't isolate.** Every new note should connect to at least one existing note. An unlinked note is nearly invisible later. Use `[[wikilinks]]`.
2. **Decisions over events.** "Decided to wait on the hardware upgrade because the upgrade cycle is ~4 months out and EMR ships first" is durable. "Talked about laptops" is noise.
3. **Capture the why, not just the what.** Future-you needs the reasoning to know whether a past decision still holds when circumstances change.
4. **Open questions are first-class.** Capturing what's unresolved is as valuable as capturing what's decided — it's the agenda for next time.
5. **Atomic where possible.** One idea per note, linked to others, beats one giant note. Easier to link, reuse, and find.

---

## Rules Always In Force

1. **Guardrails matter.** On every CAPTURE and RECONCILE, don't file a project priority the user hasn't set — the vault's `Prime Directive` register currently has no fixed priority. Surface conflicts rather than overriding.
2. **Archive over delete.** Never delete vault content without explicit confirmation. Default to Archive so nothing is irrecoverable.
3. **Preserve reasoning trails.** When updating a note, append dated updates rather than overwriting. The history is the value.
4. **Vault is source of truth for the user's own context.** When the vault and your assumptions conflict about the user's decisions, the vault wins — surface it, don't override it.
5. **Don't fabricate prior context.** If READ-IN finds nothing, say so. An invented "prior decision" is worse than no note.
6. **Structured insight, not transcripts.** Capture distilled decisions and reasoning, not raw conversation logs.

---

## Reference Files

- `references/note-templates.md` — Templates for decision notes, session-capture notes, project notes, and area notes, plus the guardrail-flag format. Load when creating or reconciling notes.
