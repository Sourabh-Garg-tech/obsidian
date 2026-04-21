# Scoring Rubric — Audit Reference

Scoring rules for each vault health audit category. All scores are integers 0-100. The overall score is a weighted average.

---

## Category Weights

| Category | Weight |
|---|---|
| Folder Structure | 25% |
| Frontmatter | 25% |
| Link Graph | 20% |
| Token Efficiency | 20% |
| Naming | 10% |

**Overall score** = round(Folder x 0.25 + Frontmatter x 0.25 + Link x 0.20 + Token x 0.20 + Naming x 0.10)

---

## Letter Grades

| Grade | Score Range |
|---|---|
| A | 90-100 |
| B | 75-89 |
| C | 60-74 |
| D | 40-59 |
| F | 0-39 |

---

## 1. Folder Structure (25%)

### Checks

| Check | Method | Points |
|---|---|---|
| `_context/` exists | `obsidian folders` includes `_context` | +25 |
| `_summaries/` exists | `obsidian folders` includes `_summaries` | +20 |
| `Projects/` exists | `obsidian folders` includes `Projects` | +15 |
| `Archive/` exists | `obsidian folders` includes `Archive` | +10 |
| `Daily Notes/` exists | `obsidian folders` includes `Daily Notes` | +10 |
| `Inbox/` exists | `obsidian folders` includes `Inbox` | +10 |
| No stray `.md` files at vault root | `obsidian files` root has no `.md` except `README.md` | +10 |

### Scoring Formula

```
folder_score = sum(earned_points)
```

Max: 100. Each check is independent. Missing `_context/` is the heaviest penalty (-25 points).

### Fix Commands

```bash
# Create missing folders
mkdir _context && obsidian reload
mkdir _summaries && obsidian reload

# Move stray root files
obsidian move file="StrayNote" to="Inbox/"
```

---

## 2. Frontmatter (25%)

### Checks

| Check | Method | Points |
|---|---|---|
| `% notes with tags` | `property:read` on each file | Up to 40 |
| `% notes with created` | `property:read` on each file | Up to 25 |
| `% notes with updated` | `property:read` on each file | Up to 20 |
| No invalid property names | Check for `alias`, `tag`, `date`, `Date` | Up to 15 |

### Scoring Formula

```
tags_score      = (% notes with tags) x 40
created_score   = (% notes with created) x 25
updated_score   = (% notes with updated) x 20
invalid_deduction = (count of invalid props / total notes) x 15
frontmatter_score = max(0, tags_score + created_score + updated_score - invalid_deduction)
```

Max: 100.

### Fix Commands

```bash
# Single note fix
obsidian property:set file="NoteName" name="tags" value='["untagged"]'
obsidian property:set file="NoteName" name="created" value="2026-04-21"

# Bulk fix (>5 notes): use Python script from references/frontmatter-schema.md
```

---

## 3. Link Graph (20%)

### Checks

| Check | Method | Points |
|---|---|---|
| Unresolved links % | `obsidian unresolved` count / total links | Up to 40 |
| Orphan notes % | `obsidian orphans` count / total notes | Up to 30 |
| Dead-end notes % | `obsidian deadends` count / total notes | Up to 20 |
| Hub overload | Notes with >50 backlinks | Up to 10 |

### Scoring Formula

```
unresolved_pct = (unresolved_count / total_notes) x 100
orphan_pct = (orphan_count / total_notes) x 100
deadend_pct = (deadend_count / total_notes) x 100

unresolved_score = 40 x max(0, 1 - (unresolved_pct / 10))   # 0% = 40, 10%+ = 0
orphan_score = 30 x max(0, 1 - (orphan_pct / 20))           # 0% = 30, 20%+ = 0
deadend_score = 20 x max(0, 1 - (deadend_pct / 30))        # 0% = 20, 30%+ = 0
hub_score = 10 if no hubs with >50 backlinks else 0

link_score = unresolved_score + orphan_score + deadend_score + hub_score
```

Max: 100. Score 0 = >10% unresolved or >20% orphans. Score 100 = <2% unresolved, <5% orphans, no hub overload.

### Fix Commands

```bash
# List unresolved links
obsidian unresolved

# List orphans
obsidian orphans

# List dead ends
obsidian deadends

# Connect an orphan
obsidian append file="OrphanNote" content="\nRelated: [[HubNote]]"

# Move truly orphaned reference to archive
obsidian move file="OrphanNote" to="Archive/"
```

---

## 4. Token Efficiency (20%)

### Checks

| Check | Method | Points |
|---|---|---|
| `_context/` exists and has files | `obsidian folders` + file count | Up to 30 |
| `_context/` total size <400 tokens | Read all _context/ files, estimate tokens | Up to 25 |
| `_summaries/` exists and has files | `obsidian folders` + file count | Up to 25 |
| Weekly summaries exist | `obsidian files` in _summaries matching `week-*` | Up to 20 |

### Scoring Formula

```
context_exists = 30 if _context/ exists and has >=1 file else 0
context_size = 25 if estimated _context/ tokens < 400 else max(0, 25 - (tokens - 400) / 40)
summaries_exist = 25 if _summaries/ exists and has >=1 file else 0
weekly_exist = 20 if _summaries/ has >=1 week-* file else 0

token_score = context_exists + context_size + summaries_exist + weekly_exist
```

Max: 100.

### Estimating Tokens

```bash
total_chars=0
for note in coding-standards architecture agent-instructions glossary current-sprint; do
  chars=$(obsidian read file="$note" 2>/dev/null | wc -c)
  total_chars=$((total_chars + chars))
done
tokens=$((total_chars / 4))
echo "Estimated _context/ tokens: $tokens"
```

### Fix Commands

```bash
# Create _context/ structure
mkdir _context && obsidian reload
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

# Create _summaries/ structure
mkdir _summaries && obsidian reload
obsidian create name="decisions-log" content="# Decisions Log\n\n<!-- Append-only -->"
WEEK=$(date +%Y-W%V)
obsidian create name="week-$WEEK" content="# Week $WEEK Summary\n\n<!-- Daily 1-liners -->"
obsidian move file="decisions-log" to="_summaries/"
obsidian move file="week-$WEEK" to="_summaries/"
```

---

## 5. Naming (10%)

### Checks

| Check | Method | Points |
|---|---|---|
| `% files in kebab-case` | Grep for spaces, uppercase, underscores in filenames | Up to 50 |
| `% daily notes in YYYY-MM-DD format` | Check `Daily Notes/` filenames | Up to 30 |
| No spaces in filenames | `obsidian files` contains no names with spaces | Up to 20 |

### Scoring Formula

```
kebab_pct = (files in kebab-case / total files) x 100
daily_pct = (daily notes matching YYYY-MM-DD / total daily notes) x 100
spaces_deduction = 20 if any file has spaces else 0

naming_score = max(0, (kebab_pct / 100 x 50) + (daily_pct / 100 x 30) + (20 - spaces_deduction))
```

Max: 100.

### Fix Commands

```bash
# Rename a single file (preserves wikilinks)
obsidian rename file="Note Name" name="note-name"

# Bulk rename (>5 files): dry-run first
obsidian files | while read f; do
  new=$(echo "$f" | tr '[:upper:]' '[:lower:]' | tr ' _' '-')
  [ "$f" != "$new" ] && echo "obsidian rename file=\"$f\" name=\"$new\""
done
# Review output, then remove echo prefix to execute
```

---

## Scorecard Output Template

```markdown
## Vault Health Scorecard — <vault-name>

Overall: <grade> (<score>/100)

| Category         | Score | Issues |
|------------------|-------|--------|
| Folder Structure | XX    | <brief summary> |
| Frontmatter      | XX    | <brief summary> |
| Link Graph       | XX    | <brief summary> |
| Token Efficiency | XX    | <brief summary> |
| Naming           | XX    | <brief summary> |

### Priority Fixes
1. [Category] <issue> — `<fix command>`
2. [Category] <issue> — `<fix command>`
...

### Quick Wins (single command)
1. ...
2. ...

### Bulk Operations (Python script required)
1. <issue> — see `references/frontmatter-schema.md` for script
```

Priority is sorted by: (category weight x points available) descending. Fix the category with the most impact first.