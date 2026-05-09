# Design: Vault Intelligence & Auto-Linking (v1.3)

**Date:** 2026-05-09
**Approach:** Extend Root Skill + obsidian-workflows (Approach A)
**Scope:** Four automated intelligence features for vault health and connectivity

---

## 1. Hub Detection

### Purpose
Identify highly-connected notes (hubs) so new notes can automatically link to them, strengthening the knowledge graph.

### Design

**Trigger:** After any `create`, `ingest`, or `append` that adds content with wikilinks.

**Method:**
- Use `obsidian eval` to query files with backlink count >= 10
- Or: `obsidian backlinks` on a candidate note (expensive, use sparingly)

**Output:** Hub list stored in `_context/session-cache.md` under `## Hub Index`

**Format:**
```markdown
## Hub Index
- [[Active Projects]] — 12 backlinks (updated 2026-05-09)
- [[Domain Principles]] — 8 backlinks (updated 2026-05-09)
```

**Auto-suggest during ingestion:**
When creating a new note, check if its title/content contains words matching hub titles. If so: "Link to hub [[Active Projects]]?"

---

## 2. Orphan Triage

### Purpose
Find orphaned notes (0 backlinks) and suggest where they belong or who they should connect to.

### Design

**Trigger:** Manual via `/obsidian orphans` or auto-run during `health` workflow.

**Method:**
1. `obsidian orphans` → list of orphaned notes
2. For each orphan, extract key words from title and first paragraph
3. `obsidian search` for related content (fuzzy match on title words)
4. Rank matches by shared words
5. Present top 3 suggestions per orphan

**Output:** Orphan triage report
```
=== Orphan Triage ===
- [[Old Draft Note]] → Suggest: move to Archive/ or link from [[Active Projects]]
- [[Random Idea]] → Suggest: connect to [[Project Ideas]]
===
```

**Action:** User can approve move, approve backlink, or skip.

---

## 3. Broken Link Auto-Fix

### Purpose
When `obsidian unresolved` finds broken wikilinks, suggest the closest matching existing note.

### Design

**Trigger:** Manual via `/obsidian fix-links` or auto-run during `health` workflow.

**Method:**
1. `obsidian unresolved` → list of broken link texts
2. For each broken link text, run `obsidian search query="<text>" path="." limit=5`
3. If exact match exists → suggest rename/replace
4. If partial match exists → suggest "Did you mean [[Partial Match]]?"
5. If no match → suggest creating the note or removing the link

**Safety Gate:** Never auto-fix. Always preview suggestions before executing.

**Output:**
```
=== Broken Link Fixes ===
- [[Old Project Name]] not found → Did you mean [[Active Projects]]? (Y/N/create new)
- [[Misspelled Note]] not found → Did you mean [[Correct Note]]? (Y/N/skip)
===
```

---

## 4. Missing Backlinks (Bidirectional Linking)

### Purpose
Ensure links are bidirectional where appropriate. If Note A links to Note B, Note B should ideally link back.

### Design

**Trigger:** After `create` or `ingest` generates notes with cross-links.

**Method:**
1. For each newly created note, extract its outgoing links (`obsidian links`)
2. For each target note, check if it links back (`obsidian backlinks`)
3. If one-way link detected → suggest appending "See Also" section

**Safety Gate:** Only suggest for notes in the same "domain" (e.g., both under Projects/, or both Concepts/). Skip daily notes and archive.

**Output:**
```
=== Missing Backlinks ===
- [[Concept A]] links to [[Concept B]], but [[Concept B]] doesn't link back.
  Suggest: Append "See Also: [[Concept A]]" to [[Concept B]]? (Y/N)
===
```

---

## Integration Points

### Session Cache
All intelligence findings append to `_context/session-cache.md` under `## Intelligence Findings`.

```markdown
## Intelligence Findings
- Hub: [[Active Projects]] (12 backlinks)
- Orphan: [[Old Draft Note]] → suggest Archive/
- Broken link: [[Old Name]] → [[New Name]]
- Missing backlink: [[Concept B]] should link to [[Concept A]]
```

### Named Workflows
Add to Named Workflows table:

| Keyword | What runs |
|---------|-----------|
| `intelligence` | Run hub detection + orphan triage + broken link scan + missing backlinks |
| `hubs` | List top 10 hub notes by backlink count |
| `orphans` | Find orphaned notes and suggest connections |
| `fix-links` | Scan unresolved links and suggest fixes |
| `backlinks` | Check for missing bidirectional links |

### Auto-Run Rules
- After `ingest` → auto-run hub detection + missing backlinks on new notes
- After `create` with wikilinks → check if targets are hubs, suggest connections
- During `health` → include orphan count and broken link count in report

---

## Token Budget

| Feature | Tokens |
|---------|--------|
| Hub detection | ~100 (eval query) |
| Orphan triage | ~50 per orphan (search + rank) |
| Broken link fix | ~50 per broken link (search + suggest) |
| Missing backlinks | ~50 per new note (links + backlinks check) |

**Batch size:** Process max 10 items per operation to stay under 1,000 tokens.

---

## Testing Plan

| Test | How |
|---|---|
| Hub detection finds real hubs | Create note with 10 backlinks, run `/obsidian hubs` |
| Orphan triage suggests correctly | Create orphan with title matching existing note, run `/obsidian orphans` |
| Broken link fix suggests match | Create note with `[[Typo Note]]`, run `/obsidian fix-links` |
| Missing backlinks detected | Create Note A linking to Note B, verify Note B flagged |
| Session cache updated | After intelligence run, read `_context/session-cache.md` |

---

## Files to Modify

| File | Changes |
|------|---------|
| `SKILL.md` | Add intelligence workflows to Named Workflows, add auto-run rules |
| `obsidian-workflows/SKILL.md` | Add vault intelligence section with hub/orphan/link patterns |
| `obsidian-workflows/references/intelligence-patterns.md` | Add Patterns 15-18 |
| `references/quick-reference.md` | Add `intelligence`, `hubs`, `orphans`, `fix-links`, `backlinks` entries |
| `scripts/vault-health.sh` | Add orphan count and broken link count to health report |

---

## Success Criteria

- `/obsidian intelligence` runs without errors and produces actionable findings
- Hub detection correctly identifies notes with 10+ backlinks
- Orphan triage suggests relevant connections for 80%+ of orphans
- Broken link fix suggests correct match for 90%+ of typos
- Missing backlink detection only suggests for same-domain notes
- All findings logged to session cache

---

## Self-Review

1. **Spec coverage:** All 4 features described with trigger, method, output, and safety gates
2. **No placeholders:** No TBDs, all workflows have concrete commands
3. **Type consistency:** `obsidian eval` for hubs, `obsidian search` for orphans/links, `obsidian unresolved` for broken links
4. **Integration:** Features connect to existing cache, health, and ingestion workflows
