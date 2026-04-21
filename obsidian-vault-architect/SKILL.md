---
name: obsidian-vault-architect
description: >
  This skill should be used when the user asks to "vault audit", "vault health",
  "vault structure", "vault efficiency", "fix vault", "vault blueprint",
  "vault architect", "vault score", "vault check", "improve vault",
  "clean vault", "vault hygiene", "score my vault", or "vault setup".
  Audits vault structure, frontmatter, link graph, token efficiency, and naming
  conventions against the ideal 3-tier blueprint. Produces a health scorecard
  (A-F grade) with prioritized fix commands.
compatibility:
  requires: "Obsidian v1.12.7+ with CLI enabled"
  platforms: "macOS, Windows, Linux (see obsidian-workflows/references/platform-setup.md)"
---

# Vault Architect — Micro Core

Audit vault health against the 3-tier token-efficiency model. Produces a scorecard with
prioritized fix commands.

**Always use `obsidian <cmd>` for vault operations — never raw file writes.**

→ Blueprint: `references/vault-blueprint.md`
→ Frontmatter rules: `references/frontmatter-schema.md`
→ Scoring formula: `references/scoring-rubric.md`

---

## Audit Flow

Run these commands in order. Collect all output before scoring.

```bash
# 1. Confirm vault
obsidian vaults

# 2. Map folder structure
obsidian folders

# 3. Count files per folder (skip if vault >500 files — use sampling)
obsidian files

# 4. Check frontmatter (sample up to 20 notes)
obsidian files | head -20 | while read p; do
  obsidian properties path="$p"
done

# 5. Unresolved links
obsidian unresolved

# 6. Orphan notes
obsidian orphans

# 7. Dead-end notes
obsidian deadends

# 8. Tag distribution
obsidian tags sort=count counts

# 9. Hub detection (backlinks on most-linked notes)
obsidian backlinks file="<most-linked-note>"

# 10. Naming convention scan
obsidian files | grep -E ' |[A-Z]' | grep -v '^[0-9]{4}-[0-9]{2}-[0-9]{2}'
```

For step 4, if the vault has >500 files, sample 20 random notes instead of checking all.
For step 10, Windows users: use PowerShell `Select-String` or Grep tool instead of bash grep.

---

## Scoring

Calculate each category score per `references/scoring-rubric.md`:

| Category | Weight | Key checks |
|---|---|---|
| Folder Structure | 25% | Required folders exist, no stray root files |
| Frontmatter | 25% | Required properties present, no invalid names |
| Link Graph | 20% | Low unresolved, low orphans, no hub overload |
| Token Efficiency | 20% | _context/ exists and sized right, _summaries/ exists |
| Naming | 10% | kebab-case, YYYY-MM-DD dailies, no spaces |

**Overall** = round(Folder x 0.25 + Frontmatter x 0.25 + Link x 0.20 + Token x 0.20 + Naming x 0.10)

Letter grade: A (90-100), B (75-89), C (60-74), D (40-59), F (0-39)

---

## Output Format

After collecting audit data and calculating scores, present:

```markdown
## Vault Health Scorecard — <vault-name>

Overall: <grade> (<score>/100)

| Category         | Score | Issues |
|------------------|-------|--------|
| Folder Structure | XX    | <brief> |
| Frontmatter      | XX    | <brief> |
| Link Graph       | XX    | <brief> |
| Token Efficiency | XX    | <brief> |
| Naming           | XX    | <brief> |

### Priority Fixes
1. [Category] <issue> — `<fix command>`
...

### Quick Wins (single command)
...

### Bulk Operations (Python script)
...
```

Sort priority fixes by impact: (category weight x points lost) descending.

---

## Fix Principles

1. **Never auto-execute** fixes — present all commands for user review
2. **Group by effort** — quick wins (single command) vs. bulk operations (Python script)
3. **Dry-run bulk ops** — show commands with `echo` prefix for fixes affecting >5 notes
4. **Re-audit** — user can re-run this skill after fixes to verify improvements

### Quick Wins (single `obsidian` command)

```bash
# Missing folder
mkdir _context && obsidian reload

# Missing property on one note
obsidian property:set file="NoteName" name="tags" value='["untagged"]'

# Rename a file with spaces
obsidian rename file="Note Name" name="note-name"

# Connect an orphan
obsidian append file="OrphanNote" content="\nRelated: [[HubNote]]"

# Move stray root file
obsidian move file="StrayNote" to="Inbox/"
```

### Bulk Operations (Python + python-frontmatter)

For fixes affecting >5 notes, generate a Python script (see `references/frontmatter-schema.md`
for the bulk fix template). After running the script, execute `obsidian reload`.

---

## Vault Setup

If the vault is empty or newly created, offer to scaffold the ideal structure:

```bash
# Create required folders
mkdir _context _summaries Projects Archive "Daily Notes" Inbox Templates

# Create _context/ seed files
obsidian create name="coding-standards" content="# Coding Standards\n\n<!-- Fill in your standards -->"
obsidian create name="architecture" content="# Architecture (Current State)\n\n<!-- Keep under 300 words -->"
obsidian create name="agent-instructions" content="# Agent Instructions\n\n<!-- Standing instructions for AI -->"
obsidian create name="glossary" content="# Glossary\n\n<!-- Domain terms -->"
obsidian create name="current-sprint" content="# Current Sprint\n\n<!-- What's in focus this week -->"

# Move seed files into _context/
obsidian move file="coding-standards" to="_context/"
obsidian move file="architecture" to="_context/"
obsidian move file="agent-instructions" to="_context/"
obsidian move file="glossary" to="_context/"
obsidian move file="current-sprint" to="_context/"

# Create _summaries/ seed files
WEEK=$(date +%Y-W%V)
obsidian create name="decisions-log" content="# Decisions Log\n\n<!-- Append-only -->"
obsidian create name="week-$WEEK" content="# Week $WEEK Summary\n\n<!-- Daily 1-liners -->"
obsidian move file="decisions-log" to="_summaries/"
obsidian move file="week-$WEEK" to="_summaries/"
```

---

## Reference Files

| File | When to read |
|---|---|
| `references/vault-blueprint.md` | Full folder hierarchy, naming rules, tier assignments, anti-patterns |
| `references/frontmatter-schema.md` | Required properties, type validation, invalid property names, bulk fix script |
| `references/scoring-rubric.md` | Exact scoring formulas, weightings, output template |