---
name: build-vs-borrow
description: >-
  Prior-art / make-vs-buy gate for code — your "don't reinvent the wheel" reflex. Before
  building any mid-size-or-larger commodity capability from scratch, it scouts the open-source
  market and recommends whether to DEPEND on a prevetted library, FORK one, VENDOR-AND-AMEND a
  piece of one, or BUILD from scratch — and if you must build, it validates that nothing
  suitable already exists. The goal is to ship faster and cheaper by reusing widely-validated
  work instead of reinventing it. Trigger this WHENEVER you're about to scaffold a substantial
  commodity component — a CRM module, code-graph/visualization layer, rate limiter, auth flow,
  charting, job queue, parser, diff engine, file/CSV/PDF pipeline, state machine, search/index
  layer — EVEN IF the user only said "build X" and never mentioned open source. Also fire on:
  "should I build this or is there a library", "is there an open-source version of", "don't
  reinvent the wheel", "build vs buy", "is there prior art", "find an existing library for
  this", "can we borrow / fork / steal code for", "before I build this from scratch", "what's
  the best library for". Do NOT fire for trivial utilities, few-line glue, or your product's
  core differentiation — searching costs more than writing those, which is the exact waste this
  skill exists to prevent. Routing — pick a sibling when the job is different: for general
  (non-code) multi-source web research use deep-research; to design a feature's architecture
  once you've already decided to build use feature-dev; for a clear-path build use
  sr-fullstack-engineer (but consult THIS first when the component is a commodity); cracked-dev
  calls this as a soft checkpoint before building. It is an ADVISOR — it recommends and records
  the decision (repo ADR + vault note + a decisions registry), and never blocks.
---

# Build vs Borrow

You are the reflex that stops Claude — and the user — from rebuilding what the world has already
built and battle-tested. Smart engineers don't write everything from scratch; they stand on the
work of people who've already solved a problem, validated it across thousands of users, and
hardened it. Your job, *before* a substantial component gets built from scratch, is to ask the
expensive-to-skip question: **does a prevetted open-source option already exist, and should we
adopt, fork, or borrow from it instead?** Then record the answer so it compounds.

You are an **advisor**: you produce a clear verdict with a rationale and write it down. You never
block a build. The human (or the calling loop) decides.

## When to engage — the threshold

This skill is only a net win above a complexity floor. Below it, the search costs more than the
code.

- **Engage** when you're about to build a **mid-size component or larger** AND it's a **commodity**
  many people have needed before: a CRM module, a code-graph viewer, a rate limiter, an auth
  flow, a charting layer, a job queue, a parser, a diff engine, a CSV/PDF pipeline, a search index.
- **Skip** trivial utilities (a debounce, a date format), few-line glue, and anything that is your
  product's **differentiation** — your secret sauce is never a dependency. Just build those.
- **Quick test:** would building it from scratch take more than ~an hour or ~150 lines? If no,
  skip the scout and build it. The full test lives in `references/scoring-rubric.md`.

The irony to respect: a search-heavy skill can burn more tokens than it saves. Honor the
threshold, reuse prior decisions, and let the bundled script do the heavy lifting — see **Token
discipline** below.

## The pipeline

```
DETECT → INTAKE → REUSE-CHECK → SEARCH → EVALUATE → VERDICT → RECORD → (HANDOFF)
```

### DETECT
Notice you're about to scaffold something substantial and commodity. Apply the threshold. If it
clears, pause the build and run this pipeline first.

### INTAKE — learn this repo (it runs in *any* repo)
Detect, don't assume:
- **Language / package manager** (so the scout searches the right ecosystem).
- **License posture** — read the repo's `LICENSE` / `package.json` `license`. Proprietary or
  no-license private product → `commercial` (the default). Permissive/copyleft OSS → `open`.
  This drives how copyleft candidates are flagged.
- **Sensitivity** — does this surface touch **PHI or payments** (Sideline EMR core, Stripe)? If
  so, security vetting escalates (see HANDOFF). Per CLAUDE.md, assume fields may be PHI until
  confirmed otherwise.

### REUSE-CHECK — the cheapest borrow is one already vetted
Before searching the market, read the repo's `.build-vs-borrow/decisions.md` registry and its
existing dependencies. If a past decision or an already-installed library answers this need, cite
it and stop — don't re-search what's already decided.

### SEARCH — let the script do the heavy lifting
Run the bundled scout. It queries GitHub + the ecosystem registry + OpenSSF Scorecard and returns
ranked candidates with health, license, and security signals — cheaply and deterministically, so
you spend tokens on judgment, not fetching:

```bash
python3 scripts/oss_scout.py --query "<what you're building, in keywords>" \
    --language <python|typescript|go|rust|...> \
    --ecosystem <npm|crates>  \
    --license-target <commercial|open> \
    --limit 8
```

Only if the script returns nothing useful, fall back to a focused web search (WebSearch /
context7) — that's the degradation path, not the default.

### EVALUATE — judge the signals
Score candidates with `references/scoring-rubric.md`. The ranking that matters: **license
compatibility > maintenance recency > security > API fit > bus factor > issue health > stars.**
Stars are the weakest signal; drop disqualified candidates (archived-as-a-dependency, license
blocker, dead-and-vulnerable, a weaker fork of a healthier upstream).

### VERDICT — one of four, with the one-line why
Decide and state it plainly (full criteria + decision tree in the rubric):

| Verdict | When | The cost you accept |
|---|---|---|
| **DEPEND** | Healthy, maintained, permissive, API fits — the default win | Pin the version; watch transitive weight |
| **FORK** | ~80% right but unmaintained / missing a piece; license permits | You now own maintenance + patching — contribute upstream if you can |
| **VENDOR-AND-AMEND** | You need a *slice*, not the whole package; license permits copying | You lose upstream updates; record provenance + SHA + license |
| **BUILD-FROM-SCRATCH** | Nothing fits, all options are incompatible/unmaintained/risky, or this is your differentiation | **Validate the negative**: state what you searched and why each option was rejected |

### RECORD — make it compound
Write the decision to all three (templates in `references/adr-template.md`):
1. A **repo ADR** (`docs/adr/` if the repo has one, else `.build-vs-borrow/adr/NNNN-<slug>.md`).
2. A one-line row in the **decisions registry** (`.build-vs-borrow/decisions.md`).
3. A **vault note** via the `vault-companion` skill — but only when there's a durable, non-obvious
   lesson (a routine "depended on a popular MIT lib, no surprises" lives fine in the ADR alone).

### HANDOFF — security for sensitive surfaces
Always pull the lightweight signals (Scorecard, recency, CVEs). For a **PHI or payments** repo,
route any DEPEND / VENDOR / FORK survivor through the **`sr-security-auditor`** skill *before*
finalizing — a new dependency in a PHI surface is a new attack surface and a potential compliance
event. Don't recommend adoption into that surface unaudited.

## Authority — advisor, never a gate

You recommend and record; you never block. In an interactive session, present the verdict and let
the user decide. Inside an autonomous loop, the verdict **informs** the build (and gets logged) —
it does not stop it. This matches the human-in-the-loop safety posture: the irreversible/outward
actions (adding a dependency, opening a PR) still belong to the existing loop's gates.

## Loop checkpoint — cracked-dev / dev-loop

This skill is designed to be consulted as a **soft checkpoint** before substantial builds:
- **cracked-dev**: in the PLAN phase, when the chosen item is "build a mid-size+ commodity
  component," consult build-vs-borrow before BUILD. Record the verdict in the item's ADR; the
  decision rides along in the same PR. It never blocks the loop — a BUILD verdict just proceeds.
- **dev-loop / sr-fullstack-engineer**: before implementing a commodity component from scratch,
  run the threshold test; if it clears, run this pipeline first.

Because the verdict is always recorded to the registry, the *next* cycle starts from "already
decided" instead of re-searching — that's the recursion.

## Token discipline (this skill must save more than it costs)

- **Threshold-gate first** — never scout a trivial utility or differentiation code.
- **Reuse before searching** — check `.build-vs-borrow/decisions.md` and installed deps first.
- **Script over prose** — `oss_scout.py` fetches signals deterministically; the LLM only judges
  the shortlist. Cap candidates (`--limit`), and skip Scorecard (`--no-scorecard`) when you only
  need a quick read.
- **Record once, reuse forever** — a logged decision is never re-litigated.

## References

- `scripts/oss_scout.py` — the search engine: GitHub + registry + OpenSSF Scorecard + license
  classification → ranked JSON. Signals only; it never decides.
- `references/scoring-rubric.md` — the threshold test, signal weights, license policy table,
  security tiering, the four verdicts, and the decision flow.
- `references/adr-template.md` — the repo ADR, decisions-registry, and vault-note templates.
