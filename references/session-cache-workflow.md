# Session Hot Cache Workflow

Auto-updates `_context/session-cache.md` after write operations. Provides a lightweight touch log for session continuity.

---

## Cache Format

```markdown
---
type: session-cache
date: 2026-05-09
tags: [system]
last-project: swing-signal-engine
---

- 2026-05-09T14:23 + Note Name (created)
- 2026-05-09T14:15 ~ Note Name (updated)
- 2026-05-09T13:00 > Decision Note (read)
- Decision: Migrated to GraphQL
- Next: Review PR #42
```

---

## Rules

- **Touch log**: max 10 entries, FIFO. `+` = created, `~` = updated, `>` = read (decision notes only).
- **Narrative**: max 3 lines at the bottom, prefixed with `Decision:`, `Thread:`, or `Next:`.
- **Stale reset**: If cache `date` is not today, clear all entries (preserve `last-project`).
- **last-project**: persisted across resets. Updated when user runs `project <name>` or EXTERNAL MODE auto-promotes.
- **Concurrent sessions**: Each Claude Code session appends entries. If two sessions write simultaneously, the last writer wins — this is acceptable since the cache is advisory, not authoritative. For critical state, use Obsidian notes (the source of truth) rather than the cache.

---

## Updating the Cache

After `create`, `append`, `move`, `property:set`, or `daily:append`, append a single line:

```bash
obsidian append path="_context/session-cache.md" content="- $(date +%Y-%m-%dT%H:%M) <symbol> <note-name> (<action>)"
```

That's it. No rebuild script needed. The cache is append-only — entries accumulate until stale reset clears them.

If the cache has more than 10 touch entries, trim to the last 10:

```bash
# Read cache, keep last 10 touch lines, rewrite
obsidian read path="_context/session-cache.md"
# Then recreate with trimmed content
obsidian create path="_context/session-cache.md" content="<trimmed>" overwrite
```

---

## Workflows

### `cache`

```bash
obsidian read path="_context/session-cache.md"
```

### `cache:clear`

```bash
obsidian create path="_context/session-cache.md" content="---
type: session-cache
date: <today>
tags: [system]
last-project: <preserve-existing>
---

" overwrite
```

Note: Preserve `last-project` when clearing so EXTERNAL MODE promotion continues working.