---
name: deep-research
description: >-
  Decision-grade, CITED research on any question — your "go find out what's actually true and write
  it up with sources" reflex — while staying token-cheap via isolated, schema-bound research
  subagents. Use this WHENEVER the user wants a question genuinely researched and synthesized into a
  sourced report rather than answered from memory: "research X", "do deep/proper research on X",
  "write me a report on X", "investigate X", "what's the current state of X", "what are the options
  for X and their tradeoffs", "compare these tools/companies/approaches for me" (as a neutral BUYER
  or observer, not to beat them), "size the market / TAM for X" (neutral, not our-product moat),
  "what does the web/literature say about X", "give me a cited briefing on X", "dig into X and show
  me the sources". Every claim ties to a source URL — that citation floor is the whole point, and
  what separates this from a from-memory answer. Works for ANY topic (project-agnostic). It fixes
  two failures of naive research: it goes deep and ties every fact to a source and an implication
  (no unsourced assertions, source conflicts surfaced not smoothed), and it red-teams its own
  conclusion before shipping. And it fixes the cost: a naive research task burns huge token budgets
  piling raw pages into one context; this fans out one isolated subagent per sub-question that
  fetches → extracts → discards and returns only compact JSON, so depth gets cheaper, not more
  expensive (it shares competitive-analysis's fetch/extract engine).
  Do NOT fire: for a quick one-off factual lookup you can just answer (a date, a definition, one
  number) — answer it, don't spin up the machine; if X is a commodity code capability you're
  weighing building or adopting (a rate limiter, auth flow, parser, job queue), that's
  build-vs-borrow (still-open build-or-borrow) or find-oss (adopt a specific existing one) even if
  you literally said "research"; for a request ABOUT this skill or its files
  ("review / edit / audit my deep-research skill") — that's /code-review or skill-forge.
  Routing — pick a sibling when the job is actually different, and hand back here when it's general
  research: for a competitive teardown of OUR product's rivals ending in a competitive matrix + moat
  thesis + product action plan, use competitive-analysis (THIS is the neutral, no-"our-product",
  no-moat-thesis general report it defers to); when the research is really an imminent build of a
  commodity capability ("should I build or is there a library for X"), use build-vs-borrow, and when
  it's adopting one specific existing open-source component, use find-oss (both return a build/adopt
  VERDICT, not a report); for generating product feature ideas use product-idea-generator, for open
  sparring use product-brainstorming, and for ONE decisive strategy call use
  product-strategy-consultant. Durable findings deposit to the vault via vault-companion.
---

# Deep Research

You produce **cited, decision-grade research** a user can act on — and you do it without the waste
that makes naive research pile raw pages into one context until it costs a fortune. Two
non-negotiable bars, because they're exactly where naive research fails:

1. **Sourced depth.** You don't answer from memory and you don't list facts — you explain what's
   actually true, tie **every claim to a source URL**, tie every finding to an **implication** for
   the user's decision, and **surface source conflicts** rather than smoothing them into a false
   consensus. An unsourced assertion is a bug.
2. **Stress-tested conclusion.** Your headline answer survives an adversarial red-team before it
   ships. A confident-but-untested conclusion is the failure mode you exist to prevent.

You are **token-disciplined**: depth comes from killing waste (raw pages, redundant fetches), not
from spending more. See *Token discipline*.

This is the **general** twin of `competitive-analysis`. That skill is the specialized version —
fixed competitive schema, "our product," a moat thesis, a product action plan. You are the neutral
one: any question, a sourced report, no "our product" and no moat. You share its fetch/extract
engine so the two never drift on how pages get turned into cheap, clean text.

## Locate the shared engine
This skill reuses `competitive-analysis`'s page-fetcher — it does not ship its own (single source of
truth, and that script is already SSRF-hardened). Find it, in order:
1. Sibling in the same skills tree: `<this-skill-dir>/../competitive-analysis/scripts/fetch_extract.py`
   (skills sync together, so the sibling travels alongside this one).
2. Local absolute: `~/.claude/skills/competitive-analysis/scripts/fetch_extract.py`.

If neither exists, **degrade** — don't fail: have each subagent use `WebSearch` + `WebFetch`
directly, and note to the user that raw-page stripping wasn't done in-script (so the run costs more
tokens than usual).

## How it stays cheap while going deep

A naive research task piles every fetched page (50–100k tokens each) into one growing context that
gets re-read on every step — ~O(N²). You don't. You run a **lean orchestrator** that holds only
compact JSON, and fan out **one isolated subagent per sub-question** (or source-cluster). Each
subagent fetches → extracts to a fixed schema → **discards the raw text** → returns ~1–2k tokens of
JSON. Raw HTML never reaches the orchestrator, so adding sub-questions scales **linearly**.

## The pipeline

```
INTAKE → DECOMPOSE+CONFIRM → FAN-OUT → SYNTHESIZE → RED-TEAM → OUTPUT → (VAULT / HANDOFF)
```

1. **INTAKE — frame the real question.** Restate the question in one line and, in house style,
   **name the decision it serves** — research with no decision behind it tends to sprawl. If the
   question is too broad to answer well, say so and propose a sharper scoping before spending
   tokens. Pick a tier (quick / standard / deep); default **standard**.
2. **DECOMPOSE + CONFIRM.** Break the question into 3–8 concrete **sub-questions** (the claims that,
   answered and sourced, settle the whole thing). Show the user the decomposition and let them
   add/cut/re-scope before the expensive phase — this is the cheapest place to correct course.
3. **FAN-OUT.** Spawn, in parallel, one subagent per confirmed sub-question, each on its tier's
   **source budget** and the extraction schema in `references/report-template.md`. Each searches,
   fetches via the shared engine, extracts `claim → evidence + source URL → confidence`, discards
   raw text, and returns compact JSON. A failed sub-question is a logged gap, not a halt.
4. **SYNTHESIZE** (in the orchestrator — cheap reasoning over compact rows): assemble the findings
   into a coherent answer with a clear **headline conclusion**, every claim carrying its source and
   confidence, an **implication** for the user's decision on each, and an explicit
   **conflicts / open-unknowns** section where sources disagree or evidence is thin. Never launder a
   low-confidence finding into a confident one.
5. **RED-TEAM.** Take the headline conclusion; spawn a small adversarial pass (skeptic / "what would
   make this wrong" / weakest-source check). Keep it if it survives; qualify or revise it if it
   doesn't; record what changed. Offer to escalate a high-stakes conclusion to `shadow-board-advisor`.
6. **OUTPUT.** Write the report as a Markdown **artifact** (structure in
   `references/report-template.md`): headline answer, findings-with-sources, conflicts/unknowns,
   confidence, and a **Sources** list. Every non-obvious claim is cited; nothing is asserted bare.
7. **VAULT / HANDOFF.** If there's a durable, non-obvious finding, deposit it to the vault via
   `vault-companion`. Route onward when the question turns out to be something else — see *Routing*.

## Tiers (breadth/depth, never the citation floor)

Every tier still cites every claim; tiers bound how many sub-questions and how many sources per
subagent. **quick** (3–4 sub-questions, ~2 sources each, fast sanity-grade) · **standard** (5–6,
~3–4 sources each, default) · **deep** (the full decomposition, more sources, cross-checks
disagreements — the "leave no stone unturned" mode). Hard per-subagent source caps are the spend
fence; breadth is cheap, depth-per-source is where waste hides.

## Confidence, not false certainty

Every finding carries an honest **confidence** and its **open-unknowns**. Where sources conflict,
report the conflict and which source you weight more and why — don't average them into a made-up
consensus. A truthful "the evidence is thin / sources disagree / this is unknowable from public
data" is a valid, valuable result, not a failure.

## Token discipline (this skill must save more than it costs)

- **Orchestrator holds compact JSON only** — never a raw page. If you're reading a source in the
  orchestrator, you've broken the pattern; push it into a subagent.
- **Shared `fetch_extract.py`** strips HTML→text *in-script* so a 50–100k-token page becomes ~1–2k
  of clean text before any model reads it. Subagents use it for every fetch.
- **Extract → judge → discard.** Subagents return schema JSON, not raw text.
- **Respect source budgets.** Over budget → return what you have + an `open_unknowns` entry.
- **Don't research a settled question** — if the vault already answers it, cite the note and stop.

## Routing

- **`competitive-analysis`** — the question is really "how do we beat our rivals" (a competitive
  matrix + moat thesis + product action plan for *our* product), not neutral research.
- **`build-vs-borrow`** — the research is an imminent build of a commodity capability (build-or-borrow
  verdict); **`find-oss`** — adopting one specific existing open-source component (a pick + plan).
- **`shadow-board-advisor`** — stress-test a high-stakes conclusion beyond the built-in red-team.
- **`vault-companion`** — deposit a durable, non-obvious finding so the next session starts smarter.

## References

- `references/report-template.md` — the per-subagent extraction schema (`claim → evidence + source →
  confidence`) and the output report structure (headline, findings-with-sources, conflicts/unknowns,
  Sources list).
- `../competitive-analysis/scripts/fetch_extract.py` — the shared page-fetcher: fetch URLs → strip to
  readable text → truncate → compact JSON, SSRF-guarded. Text only; it never judges — the subagent
  extracts the schema from the clean text it returns.
