# Obsidian Skill for Claude Code

[![Version](https://img.shields.io/badge/version-1.3.0-blue)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Obsidian](https://img.shields.io/badge/Obsidian-v1.12.7+-8b5cf6?logo=obsidian)](https://obsidian.md/)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Skill-1e3a5f)](https://claude.ai/code)

> Turn Claude Code into an intelligent vault assistant for [Obsidian](https://obsidian.md/).
> Create notes, search your second brain, manage tasks, and run structured PKM workflows -- all through natural conversation.

**Why this exists:** Raw file tools break wikilinks, corrupt frontmatter, and overwrite plugin configs. This skill routes every operation through Obsidian's official CLI so your vault stays intact.

---

## Architecture

```
User Request ("search my vault for meeting notes")
        |
        v
+---------------------+     +---------------------+     +---------------------+
|   Claude (skill)    | --> |   Obsidian CLI      | --> |   Obsidian Vault    |
| - reasoning         |     | - safe CRUD         |     | - files             |
| - link strategy     |     | - wikilink rewrite  |     | - graph             |
| - context loading   |     | - index sync        |     | - plugins           |
+---------------------+     +---------------------+     +---------------------+
```

**The rule:** Always use `obsidian <cmd>` over raw `mv`, `cp`, or direct `.md` writes.

---

## What You Get

| Feature | What it means |
|---|---|
| **Intelligence-first context** | Auto-loads your active projects, recent decisions, and open tasks on every invocation |
| **Cross-directory awareness** | Work on projects outside your vault -- the skill finds and loads the right project context automatically |
| **Session hot cache** | Tracks what you've touched this session across any directory |
| **Vault intelligence** | Auto-detects hub notes, orphaned notes, broken links, and missing backlinks |
| **Source ingestion** | Pull articles, URLs, and documents into your vault with preview-gated note creation |
| **PKM workflows** | Built-in support for PARA, Zettelkasten, GTD, and LYT methods |
| **Thinking commands** | `/obsidian`, `/obsidian-trace`, `/obsidian-challenge`, `/obsidian-connect`, `/obsidian-emerge` |

---

## Demo

### Natural language vault operations

```
> search my vault for meeting notes

Found 3 notes:
  - Meeting Notes/2026-04-15 Sprint Review
  - Meeting Notes/2026-04-22 Architecture Decision
  - Projects/Website Redesign/Stakeholder Meeting

> read "Architecture Decision"

# Architecture Decision

Date: 2026-04-22
Attendees: Alice, Bob, Carol

## Decision
Migrate from REST to GraphQL...

> create note "GraphQL Migration Plan" with status active

Created: Projects/Website Redesign/GraphQL Migration Plan
Properties: status=active, tags=["project","backend"]
```

### Morning routine

```
> /obsidian morning

Good morning. Here's your context:

Projects: 3 active
  - Website Redesign (2 open tasks)
  - Q2 Planning (1 decision pending)
  - Infrastructure Audit (on hold)

Yesterday's incomplete tasks:
  - [ ] Review PR #42 (Website Redesign)
  - [ ] Draft stakeholder update (Q2 Planning)

Today's focus: Website Redesign (2 tasks, 1 due today)
```

### Vault intelligence

```
> /obsidian health

Vault Health Scorecard -- Work Vault
Overall: B (78/100)

| Category         | Score | Issues                           |
|------------------|-------|----------------------------------|
| Folder Structure | 85    | Missing _summaries/ folder       |
| Frontmatter      | 70    | 12 notes missing tags property   |
| Link Graph       | 80    | 3 broken links, 7 orphans        |
| Token Efficiency | 75    | _context/ exists but oversized   |
| Naming           | 90    | 2 files with spaces              |

Priority fix: Add tags to 12 notes -- `obsidian property:set file="Note" name="tags" value='["untagged"]'`
```

---

## Installation

### Prerequisites

- [Obsidian](https://obsidian.md/) v1.12.7+ with CLI enabled
- [Claude Code](https://claude.ai/code)

Enable the Obsidian CLI: Settings -> General -> Command line interface -> Enable + Register.

### Option A: Manual Clone (Recommended -- Works Everywhere)

**macOS / Linux:**
```bash
git clone https://github.com/Sourabh-Garg-tech/obsidian.git "$HOME/.claude/plugins/obsidian"
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/Sourabh-Garg-tech/obsidian.git "$env:USERPROFILE\.claude\plugins\obsidian"
```

> **Note:** On Windows, do **not** use `~` -- git creates a literal `~` folder instead of expanding it.

Then run `/reload-plugins`. The manifest auto-registers:
- **8 skills**: main `obsidian` + 7 sub-skills
- **5 commands**: `/obsidian` gateway + 4 thinking commands
- **Auto-trigger**: any message mentioning Obsidian, vaults, notes, or PKM

### Option B: Claude Code "Add Marketplace"

```bash
/plugin install
```

1. In the Claude Code plugin menu, select **Add Marketplace**
2. Enter: `https://github.com/Sourabh-Garg-tech/obsidian`
3. Choose **Install**

> **Note:** This requires Claude Code v2.1.139+ and a working SSH `known_hosts` for `github.com`. If it fails, use **Option A** instead.

---

## Quick Start

```bash
# Verify CLI connection
obsidian version
obsidian vaults

# Read and search
obsidian read file="Project Ideas"
obsidian search query="deadline:2026-04-30" format=json

# Daily notes and tasks
obsidian daily:append date="today" content="- [ ] Review Q2 goals"
obsidian tasks todo

# Safe frontmatter updates
obsidian property:set file="Project Ideas" name="status" value="active"

# Move with wikilink preservation
obsidian move file="Draft" to="Published/"
```

---

## Commands

| Command | Input | What it does |
|---|---|---|
| `/obsidian` | Optional keyword | Main gateway -- auto-routes to vault mode, project mode, or quick actions |
| `/obsidian-trace <topic>` | Concept or project | Timeline of how thinking evolved |
| `/obsidian-challenge <belief>` | Stated belief or plan | Vault-sourced counterarguments |
| `/obsidian-connect <A, B>` | Two domains | Non-obvious connections |
| `/obsidian-emerge` | None | Latent ideas the vault implies |

---

## Daily Workflows

Run these with `/obsidian <workflow>`:

| Workflow | When to use |
|---|---|
| `morning` | Populate daily note with yesterday's incomplete tasks + today's focus |
| `evening` | Summarize accomplishments, append to daily and weekly notes |
| `weekly` | Tag analysis + intelligence report + update weekly summary |
| `tasks` | See open tasks from your current project or daily note |
| `search <query>` | Full-text search across the vault |
| `health` | Full vault health report with scoring |

---

## Vault Intelligence

Automated vault health that runs after ingestion and note creation:

| Check | What it finds |
|---|---|
| `intelligence` | Full scan: hubs + orphans + broken links + missing backlinks |
| `hubs` | Notes with 10+ backlinks -- your knowledge graph centers |
| `orphans` | Notes with zero backlinks -- potential disconnects |
| `fix-links` | Broken wikilinks with suggested fixes |
| `backlinks` | Missing bidirectional connections |

---

## Project Context (Cross-Directory)

**The problem:** You're coding in `~/Work/project-a/` but your vault notes live in `~/Vault/Projects/project-a/`. Context is lost.

**The fix:** This skill detects when you're working outside the vault and automatically loads the matching project's intelligence -- active decisions, open gaps, and next actions. No manual path management.

```bash
# In ~/Work/project-a/, run:
/obsidian
# Skill auto-detects project-a and loads its context
```

---

## Safety Rules

1. **Never `mv`/`cp`** vault files -- `obsidian move` rewrites wikilinks automatically
2. **Never write raw YAML** -- `property:set` writes safe frontmatter
3. **Never edit `.obsidian/*.json`** -- Obsidian will overwrite your changes
4. **Dry-run bulk ops** -- echo commands first, then remove `echo`
5. **Confirm vault** with `obsidian vaults` if multiple vaults are open
6. **Windows:** `search` may return empty without `path=` -- use `path="Folder/"`
7. **Backlinks:** use `path="Folder/Note.md"` instead of `file="Note"`

See [full safety reference](references/full-reference.md) for the complete list.

---

## Sub-Skills

| Sub-skill | Purpose |
|---|---|
| [obsidian-cli](skills/obsidian-cli/) | CLI syntax, parameters, and command reference |
| [obsidian-markdown](skills/obsidian-markdown/) | Wikilinks, embeds, callouts, properties, block references |
| [obsidian-bases](skills/obsidian-bases/) | `.base` files: filters, formulas, table/card/list/map views |
| [json-canvas](skills/json-canvas/) | `.canvas` files: nodes, edges, groups, visual layouts |
| [defuddle](skills/defuddle/) | Extract clean markdown from web pages |
| [obsidian-workflows](skills/obsidian-workflows/) | PKM routines, token-efficient loading, vault intelligence |
| [obsidian-vault-architect](skills/obsidian-vault-architect/) | Vault blueprints, health audit, fix commands, scoring |

---

## Contributing

Pull requests welcome. Use `docs:`, `feat:`, or `fix:` prefix for commits.

---

## License

[MIT](LICENSE) -- free for anyone to use, modify, and distribute.
