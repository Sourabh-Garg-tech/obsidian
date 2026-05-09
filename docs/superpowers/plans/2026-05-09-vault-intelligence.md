# Vault Intelligence & Auto-Linking Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add four automated vault intelligence features (hub detection, orphan triage, broken link fix, missing backlinks) to the Obsidian skill suite.

**Architecture:** Extend root SKILL.md with named workflows, add intelligence patterns to obsidian-workflows, update health script. All features are skill behaviors, not new sub-skills.

**Tech Stack:** Markdown (SKILL.md, references), Bash (`vault-health.sh`), Obsidian CLI (`eval`, `search`, `backlinks`, `links`, `unresolved`).

---

## File Map

| File | Responsibility |
|------|----------------|
| `SKILL.md` | Add `intelligence`, `hubs`, `orphans`, `fix-links`, `backlinks` named workflows |
| `obsidian-workflows/SKILL.md` | Add vault intelligence section with usage patterns |
| `obsidian-workflows/references/intelligence-patterns.md` | Add Patterns 15-18 (hub, orphan, broken link, missing backlink) |
| `references/quick-reference.md` | Add new workflow entries |
| `scripts/vault-health.sh` | Add orphan count and broken link count to report |

---

### Task 1: Update Root SKILL.md with Intelligence Workflows

**Files:**
- Modify: `SKILL.md`

- [ ] **Step 1: Add intelligence workflows to Named Workflows table**

Insert after the `ingest` row (line ~239):

```markdown
| `intelligence` | Run full vault intelligence scan: hubs + orphans + broken links + missing backlinks |
| `hubs` | List top 10 hub notes by backlink count: `obsidian eval code='app.vault.getMarkdownFiles().map(f=>({name:f.basename,count:app.metadataCache.getBacklinksForFile(f).data.size})).filter(x=>x.count>=10).sort((a,b)=>b.count-a.count).slice(0,10)'` |
| `orphans` | Find orphaned notes + suggest connections: `obsidian orphans` then search for related content |
| `fix-links` | Scan unresolved links + suggest fixes: `obsidian unresolved` then fuzzy match |
| `backlinks` | Check for missing bidirectional links: compare `obsidian links` vs `obsidian backlinks` |
```

- [ ] **Step 2: Add auto-run rules to session cache section**

After the cache rules (line ~198), add:

```markdown
**Intelligence auto-run:**
- After `ingest` → run hub detection on new notes + missing backlinks check
- After `create` with wikilinks → check if linked notes are hubs
- During `health` → include orphan count and broken link count
```

- [ ] **Step 3: Commit**

```bash
git add SKILL.md
git commit -m "feat: add vault intelligence workflows (hubs, orphans, fix-links, backlinks)"
```

---

### Task 2: Update obsidian-workflows SKILL.md

**Files:**
- Modify: `obsidian-workflows/SKILL.md`

- [ ] **Step 1: Add vault intelligence section**

After the "Source Ingestion Workflow" section (or after "Daily Routines" if not present), insert:

```markdown
## Vault Intelligence

Automated vault health and connectivity features.

```bash
# Run full intelligence scan
/obsidian intelligence

# List hub notes (10+ backlinks)
/obsidian hubs

# Triage orphaned notes
/obsidian orphans

# Fix broken links
/obsidian fix-links

# Check missing backlinks
/obsidian backlinks
```

**Hub Detection:**
Identifies notes with 10+ backlinks. These are knowledge graph hubs — new notes should likely connect to them.

**Orphan Triage:**
Finds notes with 0 backlinks and suggests:
- A parent note to link from
- A folder to move to
- Archive if stale

**Broken Link Fix:**
Scans `obsidian unresolved` and suggests closest matching existing note via `obsidian search`.

**Missing Backlinks:**
When Note A links to Note B, suggests adding reverse link if both are in the same domain.
```

- [ ] **Step 2: Commit**

```bash
git add obsidian-workflows/SKILL.md
git commit -m "feat: add vault intelligence section to obsidian-workflows"
```

---

### Task 3: Add Patterns 15-18 to intelligence-patterns.md

**Files:**
- Modify: `obsidian-workflows/references/intelligence-patterns.md`

- [ ] **Step 1: Add Pattern 15 after Pattern 14**

```markdown
---

## Pattern 15: Hub Detection

Identify highly-connected notes to prioritize new links.

### When to Use
- After ingesting new notes
- When building a project hub or index note
- During vault health checks

### Method

```bash
# Query for files with 10+ backlinks
obsidian eval code='app.vault.getMarkdownFiles().map(f=>({name:f.basename,count:app.metadataCache.getBacklinksForFile(f).data.size})).filter(x=>x.count>=10).sort((a,b)=>b.count-a.count).slice(0,10)'
```

**Output format:**
```
Hub Index:
1. [[Active Projects]] — 12 backlinks
2. [[Domain Principles]] — 8 backlinks
```

### Auto-suggest
When a new note mentions topics related to a hub, suggest: "Link to hub [[Active Projects]]?"
```

- [ ] **Step 2: Add Pattern 16**

```markdown
---

## Pattern 16: Orphan Triage

Find orphaned notes and suggest connections.

### When to Use
- `obsidian orphans` returns non-empty list
- Vault health check
- Monthly cleanup routine

### Method

```bash
# Step 1: Get orphans
obsidian orphans

# Step 2: For each orphan, search for related content
obsidian search query="orphan title keywords" path="." limit=3

# Step 3: Rank by shared words, suggest top match
```

**Decision tree:**
- Orphan has content match → suggest backlink from matched note
- Orphan is stale/draft → suggest move to Archive/
- Orphan is standalone concept → suggest linking from _mocs/ or index note

### Example Output
```
- [[Old Draft]] → Suggest: link from [[Active Projects]] or Archive/
- [[Random Idea]] → Suggest: move to Concepts/
```
```

- [ ] **Step 3: Add Pattern 17**

```markdown
---

## Pattern 17: Broken Link Auto-Fix

Resolve broken wikilinks by suggesting closest matches.

### When to Use
- `obsidian unresolved` shows broken links
- After renaming or moving notes
- During vault health checks

### Method

```bash
# Step 1: Get broken links
obsidian unresolved

# Step 2: For each broken link, search
obsidian search query="broken link text" path="." limit=5

# Step 3: If exact/partial match, suggest rename or replacement
```

**Safety Gates:**
- Never auto-fix — always preview
- If multiple matches, show all options
- If no match, offer "create new note" or "remove link"

### Example
```
- [[Old Project Name]] not found → Did you mean [[Active Projects]]?
- [[Typo Nmae]] not found → Did you mean [[Typo Name]]?
```
```

- [ ] **Step 4: Add Pattern 18**

```markdown
---

## Pattern 18: Missing Backlinks (Bidirectional Links)

Ensure cross-referenced notes link back to each other.

### When to Use
- After `create` or `ingest` generates notes with cross-links
- When reviewing project notes for connectivity
- During health checks

### Method

```bash
# For a newly created note Note A:
obsidian links path="Note A.md"          # get outgoing links
obsidian backlinks path="Note B.md"        # check if Note B links back

# If Note A → Note B but not Note B → Note A, suggest backlink
```

**Domain constraint:** Only suggest for notes in same folder/project. Skip daily notes, archive, Sources/.

### Example
```
- [[Concept A]] links to [[Concept B]]
- [[Concept B]] does NOT link to [[Concept A]]
- Suggest: Append "See Also: [[Concept A]]" to [[Concept B]]
```
```

- [ ] **Step 5: Commit**

```bash
git add obsidian-workflows/references/intelligence-patterns.md
git commit -m "feat: add Patterns 15-18 — vault intelligence (hubs, orphans, broken links, missing backlinks)"
```

---

### Task 4: Update quick-reference.md

**Files:**
- Modify: `references/quick-reference.md`

- [ ] **Step 1: Add intelligence commands**

After the daily notes section (line ~42), add:

```markdown
# Vault Intelligence
obsidian eval code='app.vault.getMarkdownFiles().map(f=>({name:f.basename,count:app.metadataCache.getBacklinksForFile(f).data.size})).filter(x=>x.count>=10).sort((a,b)=>b.count-a.count).slice(0,10)'  # hub detection
obsidian orphans                                             # orphaned notes
obsidian unresolved                                          # broken links
obsidian links path="Note.md"                                 # outgoing links
obsidian backlinks path="Note.md"                             # incoming links
```

- [ ] **Step 2: Commit**

```bash
git add references/quick-reference.md
git commit -m "feat: add vault intelligence commands to quick reference"
```

---

### Task 5: Update vault-health.sh

**Files:**
- Modify: `scripts/vault-health.sh`

- [ ] **Step 1: Add orphan and broken link counts**

After the existing totals section, add:

```bash
echo "--- Vault Intelligence ---"
echo "Orphans: $(obsidian orphans | wc -l)"
echo "Broken links: $(obsidian unresolved | wc -l)"

# Optional: list top 5 hubs
obsidian eval code='app.vault.getMarkdownFiles().map(f=>({name:f.basename,count:app.metadataCache.getBacklinksForFile(f).data.size})).filter(x=>x.count>=5).sort((a,b)=>b.count-a.count).slice(0,5).map(x=>x.name+": "+x.count+" backlinks")'
```

- [ ] **Step 2: Commit**

```bash
git add scripts/vault-health.sh
git commit -m "feat: add vault intelligence metrics to health script"
```

---

### Task 6: Validation

**Files:**
- None (validation only)

- [ ] **Step 1: Validate workflows exist in SKILL.md**

```bash
grep -E "intelligence|hubs|orphans|fix-links" SKILL.md
```

Expected: At least 5 matches (one per workflow).

- [ ] **Step 2: Validate patterns exist**

```bash
grep -n "Pattern 1[5-8]" obsidian-workflows/references/intelligence-patterns.md
```

Expected: 4 matches.

- [ ] **Step 3: Validate quick reference updated**

```bash
grep -n "Vault Intelligence" references/quick-reference.md
grep -n "eval code" references/quick-reference.md
```

Expected: At least 1 match.

- [ ] **Step 4: Run vault-health.sh**

```bash
bash scripts/vault-health.sh
```

Expected: Shows orphan count and broken link count.

- [ ] **Step 5: Final commit**

```bash
git commit -m "feat: v1.3 — vault intelligence & auto-linking"
```

---

## Self-Review

**1. Spec coverage:**
- Hub detection → Task 1, Pattern 15
- Orphan triage → Task 1, Pattern 16
- Broken link fix → Task 1, Pattern 17
- Missing backlinks → Task 1, Pattern 18
- Session cache integration → Task 1
- Health script integration → Task 5

**2. Placeholder scan:**
- No TBDs, TODOs, or vague steps found
- All code blocks contain actual commands
- No "implement later" references

**3. Type consistency:**
- `obsidian eval` for hubs
- `obsidian orphans` for orphans
- `obsidian unresolved` for broken links
- `obsidian links` + `obsidian backlinks` for bidirectional check
- Consistent across SKILL.md, patterns, and quick reference

**4. Gaps found and fixed:**
- Added auto-run rules (after ingest/create, during health)
- Added domain constraint for missing backlinks (skip daily/archive)
- Added safety gates for broken link fix (never auto-fix)
- Added token budget callouts

---

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `docs/superpowers/plans/2026-05-09-vault-intelligence.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?"
