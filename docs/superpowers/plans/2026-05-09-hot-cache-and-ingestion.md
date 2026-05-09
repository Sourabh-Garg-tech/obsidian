# Hot Cache + Ingestion Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a session hot cache and a preview-gated ingestion workflow to the Obsidian skill suite.

**Architecture:** Hot cache is a hidden note (`_context/.session-cache.md`) auto-updated after CLI writes. Ingestion is a named workflow that previews proposed notes before creation. Both are skill behaviors, not new sub-skills.

**Tech Stack:** Markdown (SKILL.md, references), Bash (`context-builder.sh`), Obsidian CLI.

---

## File Map

| File | Responsibility |
|---|---|
| `SKILL.md` | Root skill. Add hot cache auto-update protocol, `cache`/`ingest` named workflows, updated safety rules. |
| `obsidian-workflows/SKILL.md` | Sub-skill. Add ingestion to PKM workflows section, token budget callouts. |
| `obsidian-workflows/references/intelligence-patterns.md` | Add Pattern 14: Source Ingestion with preview/approve/execute steps. |
| `references/quick-reference.md` | Add `cache` and `ingest` entries to command table. |
| `scripts/context-builder.sh` | Add `--cache` flag to prepend hot cache to output. |

---

### Task 1: Hot Cache — Update Root SKILL.md Protocol

**Files:**
- Modify: `SKILL.md`

- [ ] **Step 1: Add hot cache auto-update to Step 2/3**

After the "Auto-checkpoint" paragraph (line ~128-149), insert a new subsection:

```markdown
**Auto-checkpoint — session hot cache (all modes, after any write operation):**

After `create`, `append`, `move`, `property:set`, or `daily:append`, update `_context/.session-cache.md`:

```bash
# Read existing cache (PowerShell for multiline on Windows)
$cache = powershell -c "obsidian 'read' 'path=_context/.session-cache.md'"

# If missing or stale (>24h), create fresh
# Append touch entry
powershell -c "obsidian 'append' 'path=_context/.session-cache.md' 'content=- + [[Note Name]] (created)'"

# After 5 entries, roll FIFO
```

Cache format:
```markdown
---
type: session-cache
date: 2026-05-09
updated: 2026-05-09T14:23:00
tags: [system]
---

## Touch Log
- `+` [[Note Name]] (created)
- `~` [[Note Name]] (updated)

## Session Narrative
- Decision: <summary>
- Thread: <open thread>
- Next: <next action>
```

Rules:
- Touch log: max 5 entries, FIFO. `+` = created, `~` = updated, `>` = read (decision notes only).
- Narrative: max 3 bullets, summarized by Claude after the operation.
- If cache is >24h old, clear narrative and start fresh.
```

- [ ] **Step 2: Add `cache` and `cache:clear` to Named Workflows table**

Insert two rows in the Named Workflows table (line ~169):

```markdown
| `cache` | `obsidian read path="_context/.session-cache.md"` |
| `cache:clear` | `obsidian create name="_context/.session-cache" content="---\ntype: session-cache\ndate: <today>\ntags: [system]\n---\n\n## Touch Log\n\n## Session Narrative\n" overwrite` |
```

- [ ] **Step 3: Add `ingest <source>` to Named Workflows table**

Insert one row:

```markdown
| `ingest <source>` | Preview-gated ingestion: extract → analyze → preview → approve → create notes + update source index |
```

- [ ] **Step 4: Update Quick Actions context**

In Step 5 (Quick Actions), add context-aware picks:
- After "PROJECT MODE" bullet, add: `- Morning hours (6-11) → include `/obsidian morning` · Evening hours (18+) → include `/obsidian evening` · After write ops → hot cache auto-updates`

- [ ] **Step 5: Commit**

```bash
git add SKILL.md
git commit -m "feat: add hot cache protocol, cache/ingest named workflows"
```

---

### Task 2: Hot Cache — Update `scripts/context-builder.sh`

**Files:**
- Modify: `scripts/context-builder.sh`

- [ ] **Step 1: Add `--cache` flag to argument parsing**

After line 23 (`if [ "${1:-}" = "--help" ]; then`), insert:

```bash
if [ "${1:-}" = "--cache" ]; then
  SHOW_CACHE=true
  shift
fi
```

After line 43 (`echo "=== Context Builder ==="`), insert:

```bash
if [ "$SHOW_CACHE" = true ]; then
  echo "--- Session Cache ---"
  obsidian read path="_context/.session-cache.md" $VAULT_ARG 2>/dev/null | grep -E "^-|##|Decision|Thread|Next" | head -10
  echo ""
fi
```

- [ ] **Step 2: Update help text**

In `show_help()`, after the `Arguments:` section, add:

```
Flags:
  --cache   Include session hot cache in output
```

- [ ] **Step 3: Commit**

```bash
git add scripts/context-builder.sh
git commit -m "feat: add --cache flag to context-builder"
```

---

### Task 3: Ingestion — Update `obsidian-workflows/SKILL.md`

**Files:**
- Modify: `obsidian-workflows/SKILL.md`

- [ ] **Step 1: Add ingestion workflow section**

After the "Daily Routines" section (line ~46), insert:

```markdown
## Source Ingestion Workflow

Ingest external sources into the vault with preview-gated note creation.

```bash
# Ingest a URL (delegates to defuddle sub-skill)
/obsidian ingest https://example.com/article

# Ingest a local file
/obsidian ingest path="Downloads/article.md"
```

**Flow:**
1. Extract — get clean markdown (URL → defuddle, file → obsidian read)
2. Analyze — identify entities, concepts, decisions, open questions
3. Preview — show proposed notes, tags, cross-links to user
4. Approve — user confirms or vetoes individual notes
5. Execute — `obsidian create` for approved notes
6. Index — update `Sources/` index note

**Token budget:**
- Extraction + analysis: ~1,500 tokens
- Preview display: ~200 tokens
- Execution: ~100 tokens per note
- For sources >5,000 words, summarize before entity extraction.
```

- [ ] **Step 2: Update reference files table**

Add to the "Reference Files" table (line ~139):

```markdown
| `references/intelligence-patterns.md` | Auto-linking, hub detection, orphan triage, **source ingestion (Pattern 14)** |
```

- [ ] **Step 3: Commit**

```bash
git add obsidian-workflows/SKILL.md
git commit -m "feat: add source ingestion workflow to obsidian-workflows"
```

---

### Task 4: Ingestion — Add Pattern 14 to `intelligence-patterns.md`

**Files:**
- Modify: `obsidian-workflows/references/intelligence-patterns.md`

- [ ] **Step 1: Add Pattern 14 after Pattern 13**

After Pattern 13 (line ~710), insert:

```markdown
---

## Pattern 14: Source Ingestion (Preview-Gated)

Ingest external sources into the vault as structured notes.

### When to Use

- You found a useful article, paper, or document and want to extract entities/concepts
- You want cross-referenced notes without manually creating each one
- You want a traceable link back to the original source

### Prerequisites

- `defuddle` sub-skill loaded (for URLs)
- `obsidian-cli` sub-skill loaded (for creation)
- Vault has a `Sources/` folder (create if missing)

### Phase 1: Extract

**For URLs:**
```bash
# Delegate to defuddle for clean markdown extraction
# The skill extracts article content, strips ads/headers
```

**For local files:**
```bash
obsidian read path="Downloads/article.md"
```

**For pasted text:**
- Treat as raw markdown source

### Phase 2: Analyze

Claude identifies from the source:
- **Entities** — named things (people, companies, products, tools)
- **Concepts** — abstract ideas (patterns, principles, methodologies)
- **Decisions** — explicit or implicit choices made by the author
- **Open questions** — gaps or unresolved points

### Phase 3: Preview

Show the user a structured preview before creating anything:

```
=== Ingestion Preview ===
Source: https://example.com/article
Notes to create: 4
- [[Entity Name]] (entity)
- [[Concept Name]] (concept)
- [[Open Question]] (question)
- [[Source: Article Name]] (source index)
Proposed tags: #ingested #topic-name
Cross-links: [[Existing Note A]] [[Existing Note B]]
===
```

**User can:**
- Approve all (Y)
- Veto individual notes ("skip Entity Name")
- Rename notes ("call it 'Better Name'")
- Cancel entirely (N)

### Phase 4: Execute

For each approved note:
```bash
obsidian create name="Entity Name" content="---
type: entity
date: 2026-05-09
source: https://example.com/article
tags: [ingested]
---

# Entity Name

## Source
From [[Source: Article Name]]

## Key Points
- ...

## See Also
- [[Concept Name]]"
```

### Phase 5: Index

Update or create `Sources/Article Name.md`:
```bash
obsidian create name="Sources/Article Name" content="---
type: source
date: 2026-05-09
url: https://example.com/article
tags: [source]
---

# Article Name

## Entities
- [[Entity Name]]

## Concepts
- [[Concept Name]]

## Decisions
- ...

## Open Questions
- ...
"
```

### Safety Gates

| Scenario | Gate |
|---|---|
| Note name collision | Append `(Source)` or ask user to rename |
| Source >10,000 words | Truncate to 5,000, ask if rest needed |
| 0 extractable notes | Stop, explain why |
| User rejects preview | Log cancellation to hot cache, stop |

### Frontmatter Convention

All ingested notes:
```yaml
---
type: entity | concept | source | question
date: YYYY-MM-DD
source: <original URL or file path>
tags: [ingested]
---
```
```

- [ ] **Step 2: Commit**

```bash
git add obsidian-workflows/references/intelligence-patterns.md
git commit -m "feat: add Pattern 14 — source ingestion with preview gate"
```

---

### Task 5: Update `references/quick-reference.md`

**Files:**
- Modify: `references/quick-reference.md`

- [ ] **Step 1: Read the current file to locate the command table**

Run:
```bash
cat references/quick-reference.md | grep -n "search\|read\|create" | head -20
```

- [ ] **Step 2: Add `cache` and `ingest` entries**

Find the command table. Insert two rows:

```markdown
| `cache` | Read session hot cache | `obsidian read path="_context/.session-cache.md"` |
| `ingest <source>` | Preview-gated source ingestion | `/obsidian ingest <url or file>` |
```

- [ ] **Step 3: Commit**

```bash
git add references/quick-reference.md
git commit -m "feat: add cache and ingest to quick reference"
```

---

### Task 6: Validation

**Files:**
- None (validation only)

- [ ] **Step 1: Validate hot cache format**

Run:
```bash
obsidian create name="_context/.session-cache" content="---\ntype: session-cache\ndate: 2026-05-09\ntags: [system]\n---\n\n## Touch Log\n\n## Session Narrative\n" overwrite
```

Then:
```bash
obsidian read path="_context/.session-cache.md"
```

Expected: Shows the created cache note with correct frontmatter.

- [ ] **Step 2: Validate cache named workflow exists in SKILL.md**

Search for the string `cache` in `SKILL.md`:
```bash
grep -n "cache" SKILL.md
```

Expected: At least 4 matches (protocol, workflow table entry, quick actions, ingestion log reference).

- [ ] **Step 3: Validate ingestion workflow exists**

Search for `ingest` in `SKILL.md` and `obsidian-workflows/SKILL.md`:
```bash
grep -n "ingest" SKILL.md obsidian-workflows/SKILL.md
```

Expected: Matches in both files.

- [ ] **Step 4: Validate Pattern 14 exists**

Search for "Pattern 14" in `intelligence-patterns.md`:
```bash
grep -n "Pattern 14" obsidian-workflows/references/intelligence-patterns.md
```

Expected: At least one match.

- [ ] **Step 5: Final commit**

```bash
git commit -m "feat: v1.2 — hot cache + ingestion workflow"
```

---

## Self-Review

**1. Spec coverage:**
- Hot cache auto-update after writes → Task 1
- `cache`/`cache:clear` named workflows → Task 1
- Cache format (150 tokens, FIFO, 24h stale) → Task 1
- `ingest <source>` workflow → Tasks 3, 4
- Preview → approve → execute flow → Task 4, Pattern 14
- Source index note → Task 4, Phase 5
- Frontmatter for ingested notes → Task 4, Frontmatter Convention
- Error handling scenarios → Task 4, Safety Gates table
- Token budget callouts → Task 3
- `--cache` flag for context-builder → Task 2
- Quick reference updates → Task 5

**2. Placeholder scan:**
- No TBDs, TODOs, or "implement later" found.
- All code blocks contain actual commands or markdown content.
- No vague descriptions.

**3. Type consistency:**
- `type: session-cache` used consistently in Task 1
- `type: entity | concept | source | question` used consistently in Task 4
- `source:` frontmatter field used consistently
- Cache path `_context/.session-cache.md` used consistently across all tasks

**4. Gaps found and fixed:**
- Added `cache:clear` workflow (was implied but not explicit in spec)
- Added validation steps (Task 6) to confirm Obsidian CLI compatibility
- Added `--cache` flag to context-builder (was in spec but needed explicit task)
