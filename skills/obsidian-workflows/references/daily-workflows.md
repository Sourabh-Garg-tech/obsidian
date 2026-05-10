# Daily Workflows — CLI Wrapper & Daily Note Intelligence

Practical scripts for daily Obsidian routines. Adapt vault names and folder paths to
match your setup.

---

## `obs` — Recommended CLI Wrapper

For frequent use, create a thin wrapper that sets your vault path and common defaults.
Place at `~/bin/obs` and `chmod +x ~/bin/obs`:

```bash
#!/usr/bin/env bash
# obs — Obsidian CLI wrapper with default vault
# Usage: obs <command> [args...]

VAULT="${OBS_VAULT:-MyVault}"   # set OBS_VAULT env var or change default here

# Health check shortcut: obs health
if [[ "$1" == "health" ]]; then
  echo "=== Vault Health: $VAULT ==="
  echo "Notes:    $(obsidian files vault="$VAULT" | wc -l)"
  echo "Orphans:  $(obsidian orphans vault="$VAULT" | wc -l)"
  echo "Broken:   $(obsidian unresolved vault="$VAULT" | wc -l)"
  echo "Tasks:    $(obsidian tasks vault="$VAULT" | wc -l)"
  echo "Tags:     $(obsidian tags vault="$VAULT" | wc -l)"
  exit 0
fi

# Pass everything else through with default vault
exec obsidian "$@" vault="$VAULT"
```

Usage:
```bash
export OBS_VAULT="MyVault"
obs health
obs search query="TODO"
obs daily:append date="today" content="\n- [ ] new task"
obs orphans
```

---

## Auto-Context Builder

A helper that builds a lean context package for any task. See also
`obsidian-workflows/references/token-efficiency.md` for the full context-loading strategy.

```bash
#!/usr/bin/env bash
# obs-context — Build minimal context for a task
# Usage: obs-context "implement rate limiting for the API"
TASK="$1"
VAULT="${OBS_VAULT:-MyVault}"

echo "=== Relevant Notes (search) ==="
obsidian search query="$TASK" vault="$VAULT" limit=5

echo "=== Recently Touched ==="
obsidian recents vault="$VAULT" | head -5

echo "=== Standing Instructions ==="
obsidian read file="_context/coding-standards"        vault="$VAULT" 2>/dev/null | head -30
obsidian read file="_context/architecture-decisions"  vault="$VAULT" 2>/dev/null | head -20

echo "=== Today's Focus ==="
obsidian daily:read date="today" vault="$VAULT" 2>/dev/null | grep -E "ONE Big Thing|Focus|##"
```

---

## Daily Note Intelligence

### Auto-summarize a week of daily notes

```bash
for i in 0 1 2 3 4 5 6; do
  echo "=== $(date -d "-$i days" +%Y-%m-%d) ==="
  obsidian daily:read date="-$i" 2>/dev/null | grep -E "^- \[.\]|##"
done
# → Pass to Claude: "Summarize this week's work and extract recurring themes"
```

### Extract all tasks from past 7 daily notes

```bash
for i in 1 2 3 4 5 6 7; do
  obsidian daily:read date="-$i" 2>/dev/null
done | grep "^- \[" | sort | uniq
```

### Morning briefing

```bash
echo "=== Today: $(date +%Y-%m-%d) ==="
echo "--- Open tasks from yesterday ---"
obsidian daily:read date="-1" 2>/dev/null | grep "^- \[ \]"

echo "--- Active projects ---"
obsidian search query="[status:active]" path="Projects/" | head -10

echo "--- Notes modified this week ---"
obsidian recents | head -10
```

### Evening summary

```bash
today_note=$(obsidian daily:read date="today" 2>/dev/null)
echo "$today_note" | grep -E "^- \[.\]|^##"
# → Pass to Claude: "Summarize today's work in 3 bullet points and identify blockers"
```