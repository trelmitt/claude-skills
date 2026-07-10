#!/usr/bin/env bash
# lint-skills.sh <skills-dir> — shared skill-library lint, used by CI in
# claude-skills and claude-dev-loop-marketplace and callable locally.
#
# Hard failures (exit 1):
#   - a skill dir without SKILL.md
#   - frontmatter `name:` missing or != directory name (the SCRAMBLE guard)
#   - frontmatter `description:` missing
#   - description longer than 1200 chars — the always-loaded token tax; the
#     whole library was compressed under this budget, and this gate is the
#     ratchet that keeps bloat from silently returning
#   - any *.local.md present (confidential context must never be committed/synced)
# Warnings (exit 0):
#   - description longer than 1100 chars (approaching the budget)
# Length is measured on the PARSED description value (folded lines joined,
# indentation stripped) — that's what actually loads into context.
set -uo pipefail

DIR="${1:?usage: lint-skills.sh <skills-dir>}"
WARN_AT=1100
FAIL_AT=1200
fail=0

for d in "$DIR"/*/; do
  [ -d "$d" ] || continue
  s="$(basename "$d")"
  f="$d/SKILL.md"
  if [ ! -f "$f" ]; then echo "✗ $s: no SKILL.md"; fail=1; continue; fi

  name=$(awk -F': *' '/^name:/{gsub(/["'\'' ]/,"",$2); print $2; exit}' "$f")
  if [ -z "$name" ]; then echo "✗ $s: no 'name:' in frontmatter"; fail=1
  elif [ "$name" != "$s" ]; then echo "✗ $s: SCRAMBLE — frontmatter name '$name' != dir"; fail=1; fi

  # description: may be single- or multi-line (until the next frontmatter key or ---)
  desc=$(awk '/^---/{c++; next} c==1 && /^description:/{f=1; sub(/^description: */,""); print; next}
              c==1 && f && /^[a-zA-Z_-]+:/{exit} c==1 && f{print} c>1{exit}' "$f")
  if [ -z "$desc" ]; then echo "✗ $s: no 'description:' in frontmatter"; fail=1
  else
    # normalize to the parsed value: strip per-line indentation, join with single spaces
    norm=$(printf '%s\n' "$desc" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | tr '\n' ' ' | sed 's/ $//')
    len=$(printf '%s' "$norm" | wc -c | tr -d ' ')
    if [ "$len" -gt "$FAIL_AT" ]; then echo "✗ $s: description ${len} chars (> ${FAIL_AT}) — over the always-loaded budget"; fail=1
    elif [ "$len" -gt "$WARN_AT" ]; then echo "⚠ $s: description ${len} chars (> ${WARN_AT}) — approaching the ${FAIL_AT} budget"
    fi
  fi
done

locals=$(find "$DIR" -name '*.local.md' 2>/dev/null)
if [ -n "$locals" ]; then
  echo "✗ confidential *.local.md files present:"; echo "$locals" | sed 's/^/    /'; fail=1
fi

[ "$fail" -eq 0 ] && echo "✓ skill lint passed for $DIR"
exit "$fail"
