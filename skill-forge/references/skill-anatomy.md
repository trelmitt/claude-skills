# Skill Anatomy Reference

Detailed guide to skill structure, writing patterns, and the build-vs-grab decision. Load when drafting or restructuring a skill.

---

## Anatomy of a Skill

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter (name, description — both required)
│   └── Markdown instructions (the body)
└── Bundled Resources (optional)
    ├── scripts/    — executable code for deterministic/repeated tasks
    ├── references/ — docs loaded into context only as needed
    └── assets/     — files used in output (templates, icons, fonts)
```

---

## Progressive Disclosure — The Three Levels

1. **Metadata** (name + description) — always in context, ~100 tokens. This is what Claude scans to decide relevance.
2. **SKILL.md body** — loads when the skill triggers. Keep under ~500 lines.
3. **Bundled resources** — load only when referenced. Effectively unlimited. Scripts can execute without loading their full text into context.

The discipline: don't put in the body what belongs in a reference. A bloated body wastes context on every trigger. Push depth down a level and point to it clearly.

When a skill spans multiple domains/frameworks, organize references by variant so only the relevant one loads:
```
cloud-deploy/
├── SKILL.md          (workflow + which-variant selection)
└── references/
    ├── aws.md
    ├── gcp.md
    └── azure.md
```

For any reference over ~300 lines, include a table of contents at the top.

---

## Frontmatter

```yaml
---
name: skill-name
description: >
  What it does AND when to trigger it. This is the primary triggering
  mechanism. List concrete phrases and contexts. Lean slightly pushy —
  Claude under-triggers skills. Put ALL "when to use" logic here, not in
  the body.
---
```

**The description is the highest-leverage text in the whole skill.** It alone determines triggering. A perfect body with a weak description never fires.

---

## Writing Patterns

**Imperative voice.** "State assumptions explicitly" not "the skill should state assumptions."

**Defining output formats:**
```markdown
## Report structure
Use this exact template:
# [Title]
## Summary
## Findings
## Recommendations
```

**Examples (Input/Output):**
```markdown
## Commit message format
Input: Added user authentication with JWT tokens
Output: feat(auth): implement JWT-based authentication
```

**Explain the why.** Today's Claude has strong theory of mind. "Snapshot before editing so you have a baseline to roll back to" beats "ALWAYS SNAPSHOT FIRST." Reserve hard rules for genuine safety/correctness constraints. Stacked ALL-CAPS MUSTs are a yellow flag — they often mean the instruction wasn't explained well enough to be understood.

**Theory of mind over rote rules.** Given a good harness and the reasoning behind a request, Claude goes beyond literal instructions and makes things happen. Write for that.

---

## Build vs. Grab Decision Framework

When a workflow needs a skill, decide whether to build custom or grab a public one.

**Grab a public skill when:**
- A battle-tested option exists (high stars, active maintenance, positive real-world feedback)
- It doesn't need the user's specific guardrails or conventions
- The value is in capability, not in matching house style
- Examples: document-format skills, web-scraping/research tools, framework-specific best-practice packs

**Build custom when:**
- The skill must respect specific constraints a generic one can't know (compliance rules, sequencing directives, private conventions, vault structure)
- House style ("challenge before recommending", specific output structure) is core to the value
- It's a thin personalized wrapper around the user's own repeated workflow
- The skill needs to carry private project context

**Security gate on any grab:**
Public agent-skill packages have a meaningful rate of critical flaws (~13% in one Feb 2026 audit). Skills can execute arbitrary code in Claude's environment. So:
- Recommend only from the official source repo — never a fork or mirror
- Skill files are short and human-readable; recommend the user inspect before installing
- Be specific about the exact repo path so the user isn't guessing

---

## The Hybrid Move

Often the best answer is grab-then-customize: take a validated public skill as the base, then layer in the user's guardrails. Example: take a popular behavioral-rules file, but integrate only the core rules surgically into the user's existing setup rather than pasting the whole thing — because advisory context files lose compliance once they grow too long and important rules get drowned in noise.

---

## Common Anti-Patterns to Avoid When Building

- **Body bloat** — content that belongs in `references/` stuffed into `SKILL.md`, taxing every trigger.
- **Weak description** — vague triggering language so the skill under-fires. The most common reason a good skill goes unused.
- **Overfitting** — tuning a skill to pass its test cases rather than to generalize across the million prompts it'll actually see.
- **Rigid MUST-stacking** — piling absolute commands instead of explaining the why; the model fights these and wastes steps.
- **Reinvented scripts** — making every invocation rewrite the same helper instead of bundling it once in `scripts/`.
- **Silent overlap** — a new skill whose triggers collide with an existing one, so neither fires reliably.
