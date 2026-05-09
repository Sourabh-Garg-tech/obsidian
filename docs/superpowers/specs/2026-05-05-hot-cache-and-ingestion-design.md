# Design: Hot Cache + Ingestion Workflow

**Date:** 2026-05-05
**Approach:** Extend Root Skill + Workflows (Approach A)
**Scope:** Two related features added to the existing `obsidian` skill suite

---

## 1. Hot Cache

### Purpose
Preserve recent session context across Claude Code invocations so subsequent tasks start with background on what was just done — without re-reading `_context/active-projects` or guessing.

### Design

**Location:** `_context/session-cache.md` (leading dot, hidden from Obsidian UI but CLI-readable)

**Auto-update trigger:** After any significant write operation in the root skill:
- `create`, `append`, `move`, `property:set`, `daily:append`
- Significant = creates or modifies a note, changes project state, or records a decision

**Format (~150 tokens max):**
```markdown
---
type: session-cache
date: 2026-05-05
updated: 2026-05-05T14:23:00
tags: [system]
---

## Touch Log
- `+` [[Note Name]] (created)
- `~` [[Note Name]] (updated)
- `>` [[Note Name]] (read)

## Session Narrative
- Decision: <what was decided>
- Thread: <open thread or gap>
- Next: <next action if any>
```

**Entry rules:**
- Touch log: max 5 entries, FIFO. Only show `+` (created) and `~` (updated). `>` (read) only for notes explicitly loaded via `read` workflow or notes with `type: decision` frontmatter.
- Session narrative: max 3 bullets. Summarized by Claude after the operation completes.
- When the cache is >24h old, clear the narrative and start fresh. Keep the touch log for continuity.

**Named workflow:**
- `cache` → `obsidian read path="_context/session-cache.md"`
- `cache:clear` → `obsidian create path="_context/session-cache.md" content="---\ntype: session-cache\ndate: <today>\ntags: [system]\n---\n\n## Touch Log\n\n## Session Narrative\n" overwrite`

### Token Budget
- Hot cache read: ~80 tokens (small file, cached by CLI)
- Hot cache write: ~50 tokens overhead per significant operation
- Net impact: within existing 600-token invocation budget

---

## 2. Ingestion Workflow

### Purpose
Let users say "ingest <source>" and get a preview of generated notes before creation. Uses Claude's reasoning to extract entities, suggest cross-references, and propose a note structure — but requires human approval before writing anything.

### Design

**Named workflow:** `ingest <source>`

**Source types supported:**
- URL → delegate to `defuddle` sub-skill for markdown extraction
- File path (local `.md`, `.txt`, `.pdf`) → read with CLI, pass content to Claude
- Pasted text block → treat as raw source

**Flow:**
1. **Extract** — Get clean markdown from source
2. **Analyze** — Claude identifies: entities (named things), concepts (abstract ideas), decisions, open questions
3. **Preview** — Show user a structured preview:
   ```
   === Ingestion Preview ===
   Source: <url or file>
   Notes to create: N
   - [[Entity Name]] (entity)
   - [[Concept Name]] (concept)
   - [[Source Name]] (source index)
   Proposed tags: #tag1, #tag2
   Cross-links: [[Existing Note A]], [[Existing Note B]]
   ===
   ```
4. **Approve** — User confirms (Y) or edits ("skip Entity Name", "merge A and B")
5. **Execute** — Claude runs `obsidian create` commands for approved notes
6. **Index** — Update or create `Sources/` index note linking to new notes
7. **Log** — Append to `_context/session-cache.md` with "Ingested <source> → N notes"

**Safety gates:**
- Preview step is mandatory — no auto-creation
- User can veto individual notes in the preview
- If a note name collides with existing vault note, append `(Source)` to the title or ask user
- All notes created with `type: entity | concept | source` frontmatter for traceability

**Frontmatter for generated notes:**
```yaml
---
type: entity | concept | source
date: 2026-05-05
source: <original source URL or file>
tags: [ingested]
---
```

### Token Budget
- Extraction + analysis: ~1,500 tokens (one-time per ingestion)
- Preview display: ~200 tokens
- Execution: ~100 tokens per note
- For sources >5,000 words, Claude summarizes before entity extraction to stay within limits

---

## 3. Data Flow

```
User says: "ingest https://example.com/article"

    ↓
Skill routes to `ingest` workflow
    ↓
Check source type → URL
    ↓
Delegate to `defuddle` (sub-skill auto-load)
    ↓
Get markdown content
    ↓
Claude analyzes: entities, concepts, decisions, links
    ↓
Build preview (note titles + types + cross-links)
    ↓
Show preview to user
    ↓
User approves / vetoes / edits
    ↓
Execute approved notes: obsidian create name="..." content="..."
    ↓
Update source index note
    ↓
Update hot cache: "Ingested <source> → N notes"
```

---

## 4. Error Handling

| Scenario | Behavior |
|---|---|
| `defuddle` fails / URL unreachable | Show error, suggest saving source locally and re-running |
| Preview shows 0 extractable notes | Tell user "No entities or concepts found — maybe a listicle or reference page?" |
| Note name collision | Append `(Source)` to new note, or ask user to rename |
| User rejects entire preview | Stop, log "Ingestion cancelled" to hot cache |
| Hot cache file missing on read | Silently create empty cache, continue |
| Hot cache write fails (CLI error) | Log warning, do not block the main operation |
| Source >10,000 words | Truncate to first 5,000 + ask user if they want the rest analyzed separately |

---

## 5. Integration Points

**Files to modify:**

| File | Change |
|---|---|
| `SKILL.md` | Add `cache` and `ingest <source>` to Named Workflows table. Add hot cache auto-update to Step 2/3. |
| `obsidian-workflows/SKILL.md` | Add `ingest` to PKM workflows section. Add token budget notes for ingestion. |
| `obsidian-workflows/references/intelligence-patterns.md` | Add Pattern 14: Source Ingestion (preview → approve → execute). |
| `references/quick-reference.md` | Add `cache` and `ingest` commands to quick-ref table. |
| `scripts/context-builder.sh` | Add `--cache` flag to prepend hot cache to output. |

**No new sub-skills.** `defuddle` handles URLs. `obsidian-cli` handles creation. Everything else is Claude reasoning.

---

## 6. Testing / Validation

| Test | How |
|---|---|
| Hot cache updates after `create` | Run `obsidian create`, then `obsidian read path="_context/session-cache.md"` — expect entry |
| Hot cache clears after >24h | Set `date` in cache to yesterday, run a write op — expect narrative cleared |
| Ingestion preview shows before create | Ingest a URL, verify no `obsidian create` runs before user approval |
| Ingestion frontmatter includes `source` | Read created note, verify `source:` field matches input URL |
| Token budget stays <3,000 | Run full `ingest` + `cache` cycle, count tokens in transcript |

---

## 7. Scope Boundaries

**In scope:**
- Hot cache auto-update after CLI writes
- `cache` / `cache:clear` named workflows
- `ingest <source>` with preview → approve → execute
- Source index note updates
- Frontmatter for ingested notes

**Out of scope (future):**
- Autonomous research (`/autoresearch` style multi-round loop)
- Linting ingested notes for gaps or contradictions
- Batch ingestion (multiple sources at once)
- Import from non-markdown formats (PDF, Word)
- Cross-vault ingestion
