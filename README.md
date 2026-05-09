# Obsidian Skill for Claude Code

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Turn Claude Code into an intelligent vault assistant for [Obsidian](https://obsidian.md/). Create notes, search your second brain, manage tasks, and run structured PKM workflows — all through natural conversation.

**Why this exists:** Raw file tools break wikilinks, corrupt frontmatter, and overwrite plugin configs. This skill routes every operation through Obsidian's official CLI so your vault stays intact.

---

## Table of Contents

- [What You Get](#what-you-get)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Daily Workflows](#daily-workflows)
- [Vault Intelligence](#vault-intelligence)
- [Project Context (Cross-Directory)](#project-context-cross-directory)
- [Safety First](#safety-first)
- [Sub-Skills](#sub-skills)
- [Contributing](#contributing)
- [License](#license)

---

## What You Get

| Feature | What it means |
|---|---|
| **Intelligence-first context** | Auto-loads your active projects, recent decisions, and open tasks on every invocation |
| **Cross-directory awareness** | Work on projects outside your vault — the skill finds and loads the right project context automatically |
| **Session hot cache** | Tracks what you've touched this session across any directory |
| **Vault intelligence** | Auto-detects hub notes, orphaned notes, broken links, and missing backlinks |
| **Source ingestion** | Pull articles, URLs, and documents into your vault with preview-gated note creation |
| **PKM workflows** | Built-in support for PARA, Zettelkasten, GTD, and LYT methods |
| **Thinking commands** | `/trace`, `/challenge`, `/connect`, `/emerge` — reason over your vault as a knowledge graph |

---

## Installation

### Prerequisites

- [Obsidian](https://obsidian.md/) v1.12.7+ with CLI enabled
- [Claude Code](https://claude.ai/code)

Enable the Obsidian CLI: Settings → General → Command line interface → Enable + Register.

### Option 1: Claude Code Plugin (Recommended)

```bash
git clone https://github.com/Sourabh-Garg-tech/obsidian.git ~/.claude/plugins/obsidian
```

Restart Claude Code or run `/skill refresh`. The skill auto-triggers on any Obsidian-related request.

### Option 2: Standalone Skill

```bash
git clone https://github.com/Sourabh-Garg-tech/obsidian.git ~/.claude/skills/obsidian
```

Restart Claude Code or run `/skill refresh`.

---

## Quick Start

```bash
# Verify everything is connected
obsidian version
obsidian vaults

# Read a note
obsidian read file="Project Ideas"

# Search your vault
obsidian search query="deadline:2026-04-30" format=json

# Append to today's daily note
obsidian daily:append date="today" content="- [ ] Review Q2 goals"

# Update frontmatter safely
obsidian property:set file="Project Ideas" name="status" value="active"
```

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
| `hubs` | Notes with 10+ backlinks — your knowledge graph centers |
| `orphans` | Notes with zero backlinks — potential disconnects |
| `fix-links` | Broken wikilinks with suggested fixes |
| `backlinks` | Missing bidirectional connections |

---

## Project Context (Cross-Directory)

**The problem:** You're coding in `~/Work/project-a/` but your vault notes live in `~/Vault/Projects/project-a/`. Context is lost.

**The fix:** This skill detects when you're working outside the vault and automatically loads the matching project's intelligence — active decisions, open gaps, and next actions. No manual path management.

```bash
# In ~/Work/project-a/, run:
/obsidian
# Skill auto-detects project-a and loads its context
```

---

## Safety First

1. **Never `mv`/`cp`** vault files — `obsidian move` rewrites wikilinks automatically
2. **Never write raw YAML** — `property:set` writes safe frontmatter
3. **Never edit `.obsidian/*.json`** — Obsidian will overwrite your changes
4. **Dry-run bulk ops** — echo commands first, then remove `echo`
5. **Confirm vault** with `obsidian vaults` if multiple vaults are open

See [full safety reference](references/full-reference.md#safety-rules) for the complete list.

---

## Sub-Skills

| Sub-skill | Purpose |
|---|---|
| [obsidian-cli](obsidian-cli/) | CLI syntax, parameters, and command reference |
| [obsidian-markdown](obsidian-markdown/) | Wikilinks, embeds, callouts, properties, block references |
| [obsidian-bases](obsidian-bases/) | `.base` files: filters, formulas, table/card/list/map views |
| [json-canvas](json-canvas/) | `.canvas` files: nodes, edges, groups, visual layouts |
| [defuddle](defuddle/) | Extract clean markdown from web pages |
| [obsidian-workflows](obsidian-workflows/) | PKM routines, token-efficient loading, vault intelligence |
| [obsidian-vault-architect](obsidian-vault-architect/) | Vault blueprints, health audit, fix commands, scoring |

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## License

[MIT](LICENSE) — free for anyone to use, modify, and distribute.
