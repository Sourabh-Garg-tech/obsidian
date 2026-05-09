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

### Step 1: Liveness Check

Run `obsidian version` silently. If it fails:
- Tell the user: "Obsidian is not running or CLI is not enabled. Start Obsidian and enable CLI in Settings > General > Command line interface."
- STOP. Do not run any further commands.

### Step 2: Detect Location & Time

1. Run `obsidian vaults` to get the vault path
2. Compare CWD to vault path to determine mode:
   - **CWD is vault root** → **VAULT MODE**
   - **CWD is a subfolder within vault** → **PROJECT MODE** (subfolder name = project)
   - **CWD is outside vault** → check `last-project` in session cache, or match CWD basename to a vault project folder → **PROJECT MODE (external)**. If no match → **EXTERNAL MODE**.
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

**VAULT / EXTERNAL MODE:**

```bash
obsidian read file="_context/active-projects"             # P1: project focus + next action
obsidian eval code='app.vault.getMarkdownFiles().filter(f=>f.path.startsWith("Intelligence/")).map(f=>f.basename).slice(0,10)'  # P2: intelligence reports
obsidian daily:read 2>/dev/null | grep -E "^- \[ \]" | head -3  # P3: today's open tasks
```

**PROJECT MODE (vault or external):**

```bash
obsidian read file="<project>/_context/active-projects"    # project next action (skip if missing)
obsidian eval code='app.vault.getMarkdownFiles().filter(f=>f.path.startsWith("<project>/Intelligence/")).map(f=>f.basename).slice(0,3)'  # latest decisions/gaps
obsidian daily:read 2>/dev/null | grep -E "^- \[ \]" | head -3  # today's open tasks
```

If `<project>/Intelligence/` does not exist → suggest `vault-project-init`.

**EXTERNAL → PROJECT promotion logic:**

1. Read `last-project` from `_context/session-cache.md`
2. If set → ask: "Continue with `<last-project>`?"
3. If not set → search vault for a folder matching CWD basename: `obsidian search query="path:<cwd-basename>" path="." limit=1`
4. If match found → treat as PROJECT MODE, set `last-project` in cache
5. If no match → stay in EXTERNAL MODE, show generic vault context

→ Auto-context details, checkpoints, and time-aware behavior: `references/named-workflows.md`
→ Session hot cache: `references/session-cache-workflow.md`
→ Source ingestion: `references/ingestion-workflow.md`
→ Vault intelligence: `references/vault-intelligence-workflow.md`

### Step 4: Named Workflows

| Keyword | What runs |
|---------|-----------|
| `morning` | Populate daily note with yesterday's tasks + today's focus |
| `evening` | Summarize today's work → append to daily + weekly summary |
| `weekly` | Tags count + intelligence report + update weekly summary |
| `health` | Run `scripts/vault-health.sh`, delegate to `obsidian-vault-architect` |
| `search <q>` | Full-text search with JSON fallback |
| `read <name>` | Read note by wikilink name |
| `create <name>` | Create note with frontmatter |
| `daily <text>` | Append to today's daily note |
| `tasks` | Context-aware open tasks list |
| `project <name>` | Search Projects/ folder, or pin/continue a project when in EXTERNAL MODE |
| `canvas` | Auto-load `json-canvas` sub-skill |
| `bases` | Auto-load `obsidian-bases` sub-skill |
| `extract <url>` | Auto-load `defuddle` sub-skill |
| `init <name>` | Run `vault-project-init` workflow |
| `checkpoint <summary>` | Log checkpoint to project daily note |
| `cache` | Read session hot cache |
| `cache:clear` | Reset session cache |
| `ingest <source>` | Preview-gated source ingestion |
| `intelligence` | Full vault intelligence scan |
| `hubs` | List top 10 hub notes |
| `orphans` | Find orphaned notes + suggest connections |
| `fix-links` | Scan broken links + suggest fixes |
| `backlinks` | Check missing bidirectional links |

If keyword does not match any workflow, treat as search query.

→ Detailed workflow instructions: `references/named-workflows.md`

### Step 5: Quick Actions

Show 5 contextual suggestions adapted to mode, time, and project state.

- PROJECT MODE → tasks, checkpoint, read, search, init
- VAULT MODE → morning/evening, tasks, search, project, read
- EXTERNAL MODE → morning, search, read, project, tasks
- Morning (6-11) → include `/obsidian morning`
- Evening (18+) → include `/obsidian evening`
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
| `obsidian-cli` | CLI syntax, command parameters, debugging CLI failures, dev commands |
| `obsidian-markdown` | Writing/editing OFM: wikilinks, embeds, callouts, properties |
| `obsidian-bases` | Creating/editing .base files, filters, formulas, table/card/list/map views |
| `json-canvas` | Creating/editing .canvas files, nodes, edges, groups, visual layouts |
| `defuddle` | Extracting clean markdown from web URLs, converting web pages |
| `obsidian-workflows` | PKM routines (GTD, PARA, Zettelkasten), intelligence patterns, auto-linking, hub detection |
| `obsidian-vault-architect` | Vault health audit, scoring, fix commands, vault blueprint, frontmatter normalization |

**Avoid double-loading:** Do not load a sub-skill if the parent skill already has sufficient knowledge.

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
9. **`search` unreliable on Windows** — returns empty without `path=`. Use Grep tool as fallback
10. **`backlinks file=` and `links file=` unreliable** — use `path=` instead
11. **Windows colon commands** — see `obsidian-workflows/references/platform-setup.md`

---

## Reference Files

| File | When to read |
|---|---|
| `references/quick-reference.md` | Essential command table for daily use |
| `references/full-reference.md` | Complete command overview + all examples |
| `references/named-workflows.md` | Detailed workflow instructions, auto-context, checkpoints |
| `references/session-cache-workflow.md` | Hot cache rebuild script and rules |
| `references/ingestion-workflow.md` | Source ingestion 6-step flow |
| `references/vault-intelligence-workflow.md` | Hubs, orphans, broken links, missing backlinks |
| `obsidian-workflows/references/token-efficiency.md` | RAG-lite patterns, context budgets |
| `obsidian-workflows/references/intelligence-patterns.md` | Auto-linking, hub detection, decision trails |
| `obsidian-workflows/references/platform-setup.md` | Windows, Linux, multi-vault setup |
| `obsidian-workflows/references/project-onboarding.md` | Project scaffolding, `vault-project-init` |

### Scripts

| Script | Purpose |
|---|---|
| `scripts/vault-health.sh` | Comprehensive vault health metrics |
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
