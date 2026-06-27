# Claude skills — source of truth

My personal Claude Code skills. **This folder is the source of truth** — edit skills here, then run
`bash ~/.claude/sync-skills.sh` to propagate changes to both distribution routes. `~/.claude/skills`
is machine-local (no account sync), so skills travel via one of:

## Route A — dotfiles (short names)
Clone this repo into `~/.claude/skills` on another machine; skills load with their short names
(`/cracked-dev`, `/skill-forge`, …).
```bash
git clone https://github.com/trelmitt/claude-skills.git ~/.claude/skills
git -C ~/.claude/skills pull      # update later
```

## Route B — trevor-skills plugin (namespaced)
The same skills are mirrored into the `trevor-skills` plugin in the `trelmitt-tools` marketplace
(commit-SHA versioned → auto-updates on every sync).
```bash
/plugin marketplace add trelmitt/claude-dev-loop-marketplace
/plugin install trevor-skills@trelmitt-tools
/plugin update trevor-skills@trelmitt-tools     # update later (skills are /trevor-skills:<name>)
```

## Universal updates
Edit a skill here → run `bash ~/.claude/sync-skills.sh` → it pushes **both** Route A and Route B in one go.

## Excluded (never synced)
- `*.local.md` — confidential business/legal context that skills load at runtime (e.g.
  `shadow-board-advisor/references/user-context.local.md`); kept **local-only** by `.gitignore`
  (Route A) and the rsync `--exclude` (Route B). The skills themselves — including
  `shadow-board-advisor` — now sync; only their `*.local.md` context files are held back.
