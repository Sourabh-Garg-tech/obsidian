---
name: obsidian
description: >
  Intelligence-first skill for Obsidian vault automation. When invoked, loads
  project context, intelligence reports, and active tasks — then presents an
  actionable briefing, not a data dump. Detects invocation context (vault root,
  project folder, or external) and adapts. Auto-populates daily notes on first
  invocation. Always use this skill over raw file tools for link-safety.
compatibility:
  requires: "Obsidian v1.12.7+ with CLI enabled (v1.12.7 has significantly faster CLI binary)"
  platforms: "macOS, Windows, Linux (see obsidian-workflows/references/platform-setup.md)"
auto-trigger:
  - "create a note"
  - "read a note"
  - "edit a note"
  - "open a note"
  - "search my vault"
  - "move a note"
  - "rename a note"
  - "delete a note"
  - "update frontmatter"
  - "add properties"
  - "manage tags"
  - "find tasks"
  - "check backlinks"
  - "backlinks"
  - "create a daily note"
  - "list plugins"
  - "change themes"
  - "manage snippets"
  - "obsidian sync"
  - "sync history"
  - "obsidian bases"
  - "canvas files"
  - "create canvas"
  - "PKM workflow"
  - "PARA"
  - "Zettelkasten"
  - "GTD"
  - "LYT"
  - "obsidian markdown"
  - "wikilinks"
  - "callouts"
  - "embeds"
  - "metadata"
  - "run command"
  - "Obsidian"
  - "vault"
  - "vault health"
  - "vault audit"
  - "vault hygiene"
  - "notes"
  - ".md"
  - "frontmatter"
  - "dataview"
  - "daily notes"
  - "second brain"
---

# Obsidian Skill — Intelligence-First

Vault automation via the **official Obsidian CLI**. Every command routes through Obsidian's
internal API — moves auto-update wikilinks, properties reflect immediately, plugin configs
are never silently overwritten.

**Always use `obsidian <cmd>` over raw `mv`, `cp`, or direct `.md` file writes.**

---

## Invocation Protocol

When `/obsidian` is invoked (or this skill auto-triggers), follow this sequence:

### Step 1: Liveness Check
Run `obsidian version` silently. If it fails:
- Tell the user: "Obsidian is not running or CLI is not enabled. Start Obsidian and enable CLI in Settings > General > Command line interface."
- STOP. Do not run any further commands.

### Step 2: Detect Location & Time

1. Run `obsidian vaults` to get the vault path
2. Compare CWD to vault path to determine mode:
   - **CWD is vault root** → **VAULT MODE**
   - **CWD is a subfolder within vault** → **PROJECT MODE** (subfolder name = project)
   - **CWD is outside vault** → **EXTERNAL MODE**
3. Detect time of day:
   - **Morning (6-11)** → auto-populate daily note with yesterday's tasks + today's focus
   - **Afternoon (12-17)** → focus on current work, active project context
   - **Evening (18+)** → offer to summarize today's work
4. Classify invocation:
   - **No arguments** → Default Auto-Context (Step 3), then Quick Actions (Step 5)
   - **Named workflow keyword** → run that workflow (Step 4)
   - **Other arguments** → handle as task, check Sub-Skill Auto-Loading table first

### Step 3: Intelligence-First Auto-Context

Load highest-signal content first. **Token budget: ~600 tokens.** Every line must be actionable.

**VAULT / EXTERNAL MODE (CWD = vault root or outside vault):**

```bash
obsidian read file="_context/active-projects"             # P1: project focus + next action
obsidian eval code='app.vault.getMarkdownFiles().filter(f=>f.path.startsWith("Intelligence/")).map(f=>f.basename).slice(0,10)'  # P2: intelligence reports
obsidian daily:read 2>/dev/null | grep -E "^- \[ \]" | head -3  # P3: today's open tasks
```

**PROJECT MODE (CWD = project subfolder in vault):**

```bash
obsidian read file="<project>/_context/active-projects"    # project next action (skip if missing)
obsidian eval code='app.vault.getMarkdownFiles().filter(f=>f.path.startsWith("<project>/Intelligence/")).map(f=>f.basename).slice(0,3)'  # latest decisions/gaps
obsidian daily:read 2>/dev/null | grep -E "^- \[ \]" | head -3  # today's open tasks
```

If `<project>/Intelligence/` does not exist → suggest `vault-project-init`.
If Intelligence reports exist → show most recent title + date (1 line).

**Time-aware behavior:**

- **Morning (6-11):** If today's daily note is empty/placeholder, auto-populate it:
  ```bash
  # Read yesterday's incomplete tasks (PowerShell for Windows colon commands)
  powershell -c "obsidian 'daily:read' 'date=-1'" 2>/dev/null | grep "^\- \[ \]" | head -5
  # Append to today's note (PowerShell for multiline content)
  powershell -c "obsidian 'daily:append' 'content=- [ ] <yesterday incomplete tasks>'"
  powershell -c "obsidian 'daily:append' 'content=
## Focus
<next action from active-projects>'"
  ```
- **Evening (18+):** Show "Run `/obsidian evening` to summarize today's work."

**Auto-checkpoint — project daily notes (PROJECT MODE, after significant actions):**

When a write operation completes in PROJECT MODE (create, append, property:set, move), check if the action is a **significant checkpoint**:
- A decision was recorded
- Project status or phase changed
- A new intelligence report was created
- Multiple notes were created/updated in sequence

If checkpoint → auto-generate/update a project daily note:
```bash
# Create or append to <project>/Intelligence/daily/YYYY-MM-DD.md
# Use PowerShell for reliable multiline append on Windows
powershell -c "obsidian 'append' 'path=<project>/Intelligence/daily/$(date +%Y-%m-%d).md' 'content=
## <checkpoint summary>
- What was done
- Decision: <if any>
- Next: <what follows>'"
```

If `<project>/Intelligence/daily/` doesn't exist → create it with `obsidian create`.
Show: "Checkpoint logged → <project>/Intelligence/daily/YYYY-MM-DD.md"

**Auto-checkpoint — session hot cache (all modes, after any write operation):**

After `create`, `append`, `move`, `property:set`, or `daily:append`, update `_context/.session-cache.md`:

```bash
# Read existing cache (PowerShell for multiline on Windows)
cache=$(powershell -c "obsidian 'read' 'path=_context/.session-cache.md'")

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

**Summary format (intelligence briefing):**

```
## Obsidian [<MODE>] — <date>

**Focus:** <active project> — <phase/milestone> (P<#>)
**Next:** <next action from active-projects>
**Decision:** <latest decision + date> (find via eval: files with "decision" in path)
**Gaps:** <domain gap count> (PROJECT MODE only)
**Tasks:** <today's open tasks from daily note>
**Checkpoint:** <project daily note updated> (PROJECT MODE, only if checkpoint fired)
```

Every line is actionable. Skip lines with no content. Never waste tokens on empty slots.

### Step 4: Named Workflows

| Keyword | What runs |
|---------|-----------|
| `morning` | Populate daily note with yesterday's tasks + today's focus from `_context/active-projects` |
| `evening` | Read today's daily note → summarize accomplishments → append to daily note + `_summaries/week-YYYY-WWW.md` + update project daily note if in PROJECT MODE |
| `weekly` | `obsidian tags sort=count counts` + intelligence report summary + update `_summaries/week-YYYY-WWW.md` |
| `health` | Run `scripts/vault-health.sh` (full report), delegate to `obsidian-vault-architect` for scoring |
| `search <q>` | `obsidian search query="<q>" path="." format=json limit=10 2>/dev/null || obsidian search query="<q>" path="." limit=10` |
| `read <name>` | `obsidian read file="<name>"` |
| `create <name>` | `obsidian create name="<name>" content="---\ntype: note\ncreated: <date>\ntags: []\n---\n\n# <name>\n"` |
| `daily <text>` | `obsidian daily:append content="<text>"` |
| `tasks` | PROJECT MODE: `obsidian read file="<project>/_context/active-projects"` then extract next actions · VAULT/EXTERNAL: `obsidian daily:read | grep "^\- \[ \]" | head -5` |
| `project <name>` | `obsidian search query="<name>" path="Projects/" format=json limit=10` |
| `canvas` | Auto-load `json-canvas` sub-skill |
| `bases` | Auto-load `obsidian-bases` sub-skill |
| `extract <url>` | Auto-load `defuddle` sub-skill |
| `init <name>` | Run `vault-project-init` workflow (see project-onboarding.md) |
| `checkpoint <summary>` | Manually log a checkpoint to project daily note: `<project>/Intelligence/daily/YYYY-MM-DD.md` |
| `cache` | `obsidian read path="_context/.session-cache.md"` |
| `cache:clear` | `obsidian create name="_context/.session-cache.md" content="---\ntype: session-cache\ndate: <today>\nupdated: <today>T00:00:00\ntags: [system]\n---\n\n## Touch Log\n\n## Session Narrative\n" overwrite` |
| `ingest <source>` | Preview-gated ingestion: extract → analyze → preview → approve → create notes + update source index |

If the keyword does not match any named workflow, treat it as a search query:
`obsidian search query="<input>" path="." format=json limit=10 2>/dev/null || obsidian search query="<input>" path="." limit=10`

### Step 5: Quick Actions

Show 5 contextual suggestions adapted to mode, time, and project state.

Context-aware picks:
- PROJECT MODE → tasks, checkpoint, read, search, init
- VAULT MODE → morning/evening, tasks, search, project, read
- EXTERNAL MODE → morning, search, read, project, tasks
- Morning hours (6-11) → include `/obsidian morning`
- Evening hours (18+) → include `/obsidian evening`
- After write ops → hot cache auto-updates

Example output:
```
Try: /obsidian morning · search <q> · read <name> · tasks · project <name>
```

---

## Sub-Skill Auto-Loading

When the user's task matches these conditions, auto-invoke the sub-skill BEFORE processing.
Use the Skill tool with the sub-skill name.

| Sub-skill | Auto-load when task involves |
|-----------|------------------------------|
| `obsidian-cli` | CLI syntax questions, command parameters, "how do I use obsidian <cmd>", debugging CLI failures, dev commands |
| `obsidian-markdown` | Writing/editing OFM: wikilinks, embeds, callouts, properties, block references, comments |
| `obsidian-bases` | Creating/editing .base files, filters, formulas, table/card/list/map views |
| `json-canvas` | Creating/editing .canvas files, nodes, edges, groups, visual layouts |
| `defuddle` | Extracting clean markdown from web URLs, converting web pages |
| `obsidian-workflows` | PKM routines (GTD, PARA, Zettelkasten), intelligence patterns, auto-linking, hub detection |
| `obsidian-vault-architect` | Vault health audit, scoring, fix commands, vault blueprint, frontmatter normalization |

**Avoid double-loading:** Do not load a sub-skill if the parent skill already has sufficient knowledge for the task. Example: "read a note" needs only the parent's CLI knowledge — skip `obsidian-cli`.

---

## Safety Rules

1. **Never `mv`/`cp`** vault files — use `obsidian move` to preserve wikilinks
2. **Never write raw YAML** into `.md` files — use `property:set`
3. **Never edit `.obsidian/*.json`** — Obsidian will overwrite changes
4. **Dry-run bulk ops** — echo commands first, then remove `echo`
5. **Confirm vault** with `obsidian vaults` if multiple vaults open
6. **>500 files** — use Python + `python-frontmatter`, then `obsidian reload`
7. **`format=json`** only works on: `search`, `tags`, `tasks`, `backlinks`, `bookmarks`, `unresolved`, `properties`, `plugins`. **Not on `files` or `tag`.**
8. **`tags:rename`/`tags:remove` don't exist** — use `property:set` or `eval`
9. **`search` unreliable on Windows** — returns empty without `path=`. Use Grep tool on vault directory as fallback: `Grep: pattern="query" path="<vault>" glob="*.md"`
10. **`backlinks file=` and `links file=` unreliable** — use `path=` instead: `obsidian backlinks path="Folder/Note.md"`
11. **Windows colon commands** — see Windows-Specific Constraints below

---

## Windows-Specific Constraints

- `property:*` and `search:*` colon commands fail in Git Bash (exit 127). Use PowerShell:
  `powershell -c "obsidian property:read name='type' path='Note.md'"`
- `obsidian search` needs `path=` on Windows or returns empty
- `daily:*`, `plugins:*`, `sync:*`, `history:*`, `dev:*` work fine in Git Bash
- `tasks format=json` may return empty on Windows — use `tasks | grep "^\- \[ \]" | head -5` for items
- Run from normal terminal (not admin) on Windows

---

## Quick Reference

For the full command table: `references/quick-reference.md`

**`file=` vs `path=`:** `file=` resolves by wikilink name (no extension). `path=` is exact from vault root.

---

## Token-Efficient Context Loading

Load highest-signal content first. Target: under 600 tokens per invocation, 3,000 per task.

```
Invocation: _context/active-projects (150) + Intelligence (100) + daily tasks (50)
Task:       Search (2–5 notes) → Read those notes → Process → Write back
```

→ Deep dive: `obsidian-workflows/references/token-efficiency.md`

---

## OFM Quick Reference

```markdown
[[Note Name]]          wikilink
[[Note|Display]]       aliased link
![[Note Name]]         embed
> [!note] Title        callout
#tag-name              tag
- [ ] task             checkbox
```

→ Full syntax: `references/ofm-syntax.md`

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `command not found` | Re-enable CLI in Settings; restart terminal |
| Empty output / hangs | Obsidian not running; start it first |
| Windows: silent failures | Normal terminal only (not admin) |
| Wrong vault | Pass `vault="Name"` explicitly |
| `tasks format=json` empty | Windows — use `tasks | grep "^\- \[ \]" | head -5` |
| `eval` returns empty | O(n²) scaling limit on large vaults — reduce slice size |

→ Platform setup: `obsidian-workflows/references/platform-setup.md`

---

## Thinking Commands

Slash commands that use the vault as context for reasoning, not file management. Copy from `commands/` to the vault's `.claude/commands/`.

| Command | Input | What it does |
|---|---|---|
| `/trace <topic>` | concept or project name | Timeline of how thinking evolved on this topic |
| `/challenge <belief>` | stated belief or plan | Vault-sourced counterarguments and past patterns |
| `/connect <A, B>` | two domains | Non-obvious connections between seemingly unrelated topics |
| `/emerge` | none | Latent ideas the vault implies but hasn't stated |

All commands read the vault only — they never write to it. See `commands/` for prompt templates.

---

## Reference Files

### Top-Level References

| File | When to read |
|---|---|
| `references/full-reference.md` | Complete command overview + all examples (loads this skill's full content) |
| `references/frontmatter-schema.md` | Property schemas, normalization, Dataview patterns |
| `references/ofm-syntax.md` | Callouts, embeds, canvas, Dataview, Templater |
| `references/advanced-operations.md` | Merge/split notes, normalize vault, PKM method detection |
| `references/daily-workflows.md` | CLI wrapper, auto-context builder, daily note intelligence |
| `obsidian-workflows/references/intelligence-patterns.md` | Auto-linking, hub detection, orphan triage, domain-to-code intelligence, decision trails, custom eval queries |
| `references/cli-validation-report.md` | CLI validation findings against v1.12.7 |
| `references/quick-reference.md` | Essential command table for daily use |
| `obsidian-workflows/references/project-onboarding.md` | Project scaffolding, `vault-project-init` workflow, 3-folder structure |

### Scripts

| Script | Purpose |
|---|---|
| `scripts/vault-health.sh` | Run comprehensive vault health metrics (orphans, broken links, totals) |
| `scripts/context-builder.sh` | Build minimal context for a task from vault |

### Sub-Skills

| Sub-skill | When to use |
|---|---|
| `obsidian-cli/SKILL.md` | CLI syntax, parameters, command reference |
| `obsidian-markdown/SKILL.md` | OFM syntax: wikilinks, embeds, callouts, properties |
| `obsidian-bases/SKILL.md` | Bases .base files: filters, formulas, views |
| `json-canvas/SKILL.md` | Canvas .canvas files: nodes, edges, groups |
| `defuddle/SKILL.md` | Extract clean markdown from web pages |
| `obsidian-workflows/SKILL.md` | PKM routines, token-efficient loading, vault intelligence |
| `obsidian-vault-architect/SKILL.md` | Vault blueprint, health audit, fix commands |