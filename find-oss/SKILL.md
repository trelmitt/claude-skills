---
name: find-oss
description: >-
  Active open-source scout-and-adopt — your "someone has already built this; find me the best one
  and show me how to drop it in" reflex. Use this WHENEVER the build-or-borrow decision is already
  made in favor of BORROW and you want the single best existing open-source implementation of a
  specific thing surfaced, vetted, and turned into a concrete adoption plan (which files to touch,
  depend-vs-vendor-vs-fork, install/copy command, adapter shape, a verification step). Fire on:
  "find me the best open-source X", "is there an existing library/repo I can use for X", "who has
  already built X open source", "find an open-source version of X I can copy into this project",
  "what's the best OSS package/library for X", "I want to add an existing library for X", "search
  GitHub for the best X", "I've decided not to build X — what existing thing can I adopt", "find
  something I can drop in for X", "has someone open-sourced X I can steal/borrow", "grab an
  existing X and wire it in". This skill ASSUMES borrow is already chosen — it finds the best
  option and hands you an integration plan; it does not re-litigate whether to build. Do NOT fire
  for trivial utilities or few-line glue (a debounce, a slug, a date-format helper) — writing it is
  cheaper than scouting, the exact waste this skill exists to avoid. And do NOT fire merely because
  a query NAMES an existing open-source library — fixing a bug in a React component, debugging an
  Express route, or comparing lodash vs ramda is not a request to find or adopt one; fire only when
  the ask is to surface and wire in a NEW dependency. Routing —
  defer to a sibling when the job is actually different: if the user has NOT yet decided whether to
  build or borrow ("should I build this or is there a library", "before I build this from scratch",
  weighing scaffolding a commodity from scratch), that is build-vs-borrow — it returns a
  build-or-borrow VERDICT; THIS returns the
  best pick + integration plan (the two share the same oss_scout.py engine and scoring rubric). For
  a cited research REPORT comparing tools with no near-term intent to adopt, use deep-research. Once
  you have the plan and want the code written, hand to sr-fullstack-engineer. Records only a
  lightweight one-line pointer to the decisions registry when one already exists; never blocks.
---

# Find OSS

You are the active-borrow reflex: the user has already decided they'd rather adopt existing
open-source work than build it, and they want you to go find the *single best* thing that already
exists and hand them a plan to drop it in. Your job is to answer, concretely: **"Who has already
built this well, and exactly how do I adopt it into this repo?"**

This is the pull-side twin of `build-vs-borrow`. That skill decides *whether* to build or borrow and
returns a four-way verdict. You start one step later — borrow is assumed — and you go one step
further into the repo: you produce an **integration plan**, not just a verdict. You share its search
engine (`oss_scout.py`) and its scoring rubric, so the two never drift on how candidates are judged.

You are an **advisor and planner**, not an implementer: you find, judge, pick, and plan. You stop
before writing integration code — that hands to the user (or `sr-fullstack-engineer`). You never
block.

## One-line challenge before you search (house style)

If the thing they want to borrow looks like their product's **core differentiation** — the secret
sauce, framed with possessive/product-core language ("our ranking engine", "our matching logic") —
say so in one line: *"Heads up — this reads like your differentiation, where borrowing usually
serves you less than owning it. Want me to search anyway?"* Then respect the answer. This is a
flag, not a gate — the user decided to borrow; you're just making sure it was deliberate.

One floor, same as `build-vs-borrow`: don't scout **trivial glue** (a debounce, a slug, a
date-format helper — anything cheaper to write than to search for). If the ask is few-line glue,
just write it and say so; the scout only earns its tokens on a real subsystem.

## The pipeline

```
INTAKE → SEARCH → EVALUATE → PICK → ADOPT-STYLE → PLAN → (POINTER)
```

### Locate the shared engine
This skill reuses `build-vs-borrow`'s search engine and rubric — it does not ship its own (single
source of truth, no drift). Find them, in order:
1. Sibling in the same skills tree: `<this-skill-dir>/../build-vs-borrow/scripts/oss_scout.py`
   (skills sync together, so the sibling travels alongside this one).
2. Local absolute: `~/.claude/skills/build-vs-borrow/scripts/oss_scout.py`.

If neither exists (build-vs-borrow not installed here), **degrade** — don't fail: run the search
directly with `gh search repos "<query>" --sort stars --limit 8 --json ...` (plus the ecosystem
registry via `npm search --json <query>` / `cargo search <query> --limit 20` if relevant, for
deterministic output), and judge by the same signals below. Note the degradation to the user so
they know Scorecard/license flags weren't auto-pulled.

### INTAKE — learn this repo (runs in *any* repo)
Detect, don't assume — the same intake `build-vs-borrow` uses, kept light:
- **Language / package manager** → so the scout searches the right ecosystem.
- **License posture** → read `LICENSE` / `package.json` `license`. Proprietary/no-license private
  product → `commercial` (default, copyleft is hazardous). Permissive/copyleft OSS → `open`.
- **Sensitivity** → does this surface touch **PHI or payments** (per CLAUDE.md, assume fields may be
  PHI until confirmed)? If so, security vetting escalates before you recommend adoption (see PLAN).
- **The integration target** → *where* in this repo does the borrowed thing plug in? What's the
  call site, the existing pattern it must match, the data shape it consumes/returns? This is what
  makes your plan concrete instead of generic — read the actual call site, don't guess.

### SEARCH — let the script do the heavy lifting
Run the scout (found above). It queries GitHub + the ecosystem registry + OpenSSF Scorecard and
returns candidates with health, license, and security signals — deterministically, so you spend
tokens on judgment, not fetching.

```bash
python3 <path>/oss_scout.py --query "<what you want, in keywords>" \
    --language <python|typescript|go|rust|...> \
    --ecosystem <npm|crates> \
    --license-target <commercial|open> \
    --limit 8
```

Registry confirmation covers **npm and crates** only; for PyPI/Go rely on GitHub signals. GitHub
results come back **star-ordered** (the weakest signal) — re-rank in EVALUATE.

### EVALUATE — judge for *adoption fit*, not just health
Re-rank with `build-vs-borrow`'s `references/scoring-rubric.md`, but weight for a decided borrow:
**API/stack fit for THIS repo's call site** first, then **license compatibility → maintenance
recency → security (Scorecard/CVEs) → bus factor → issue health → stars.** The whole point of
having read the call site in INTAKE is that "best" means *best for where this plugs in*, not
most-starred in the abstract. Drop disqualified candidates (archived-as-a-dependency, license
blocker for a commercial repo, dead-and-vulnerable, a weaker fork of a healthier upstream — the
script flags these in `signal_notes`).

Any candidate with `license_class: unknown` needs a manual LICENSE check before you recommend it —
GitHub reports `NOASSERTION` for many real GPL/SSPL projects, which can mask viral copyleft.

### PICK — one winner, one runner-up, the why
Be opinionated (house style: no wishy-washy shortlist dumps). Name **one** recommended option with a
one-paragraph why (fit + health + license), and **one** runner-up in case the user knows something
you don't (a constraint, a past bad experience). If two are genuinely co-equal, say so and give the
tiebreaker. If nothing clears the bar, go to the *nothing-good* path below.

### ADOPT-STYLE — depend / vendor-and-amend / fork (context decides)
Recommend *how* to take it, using `build-vs-borrow`'s criteria minus the BUILD option (borrow is
already chosen):

| Style | When | The cost you accept |
|---|---|---|
| **DEPEND** | Healthy, maintained, permissive, the whole package fits — the default win | Pin the version; watch transitive weight |
| **VENDOR-AND-AMEND** | You need a *piece*, not the whole thing; license permits copying; you want it "copied into this project" | You lose upstream updates; record provenance + source URL + commit SHA + license |
| **FORK** | ~80% right but unmaintained or missing a piece; license permits | You now own maintenance/patching — contribute upstream if you can |

Let the repo's reality drive it: a small self-contained utility you want *in the tree* → vendor; a
maintained package that fits clean → depend; a stale-but-close project → fork. State the one you
recommend and why, in a line.

### PLAN — the deliverable (an artifact)
Produce a concrete **integration plan** as a markdown artifact (structure in
`references/integration-plan-template.md`). It must be specific to *this repo's call site*, not a
generic README paraphrase:
- **What & why** — the pick, the adopt-style, one-line rationale.
- **Install / vendor command** — the exact `npm install …` / `cargo add …` / `pip install …`, or
  for vendor: which files/dirs to copy, to where, and the provenance line to record.
- **Wire-up** — the specific files to create/touch in this repo, the adapter/wrapper shape that
  matches the existing pattern you read in INTAKE, config/env needed.
- **Verification step** — the one runnable check that proves the integration works (a call through
  the real path, a test, a script). Never leave the borrow unverified.
- **Rollback** — how to back it out cleanly if it doesn't pan out.
- **Watch-outs** — license obligations (attribution, NOTICE file), transitive-dep weight, any
  Scorecard/CVE flags, and — for a **PHI/payments** surface — a note to route the pick through
  `sr-security-auditor` *before* adoption (a new dependency there is a new attack surface).

Present the plan; hand code-writing to the user or `sr-fullstack-engineer`.

### POINTER — record only if it's cheap (lightweight)
If the repo already has a `.build-vs-borrow/decisions.md` registry, append **one line**: what was
adopted, source URL, adopt-style, license. If there's no registry, record nothing — don't create
ceremony this skill's whole point is to avoid. No ADR, no vault note (that's build-vs-borrow's job
when a *decision* was weighed; here the decision was already made).

## Nothing good found — the honest fallback
If the search turns up nothing that clears the bar (all stale, all wrong-license, all wrong-shape,
or the space is genuinely empty), say so plainly and don't force a bad pick. Give the closest one
with its disqualifier, and note that building may now be the right call — hand to `build-vs-borrow`
for the formal build-or-borrow verdict, or to `sr-fullstack-engineer` if the user just wants to
build it. A truthful "nothing good exists" is a valid, valuable result.

## Token discipline (this skill must save more than it costs)
- **Script over prose** — `oss_scout.py` fetches signals deterministically; you only judge the
  shortlist. Cap candidates (`--limit`), add `--no-scorecard` for a quick read.
- **Read the call site once** — the concrete plan comes from reading where it plugs in, not from
  re-searching. One good read beats three vague searches.
- **Don't re-search a settled borrow** — if `.build-vs-borrow/decisions.md` already answers this,
  cite it and stop.

## References
- `references/integration-plan-template.md` — the structure of the integration-plan artifact.
- `../build-vs-borrow/scripts/oss_scout.py` — the shared search engine (signals only; re-rank).
- `../build-vs-borrow/references/scoring-rubric.md` — the shared signal weights, license policy
  table, and security tiering. Same rubric both skills judge by, so verdicts never drift.
