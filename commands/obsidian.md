---
description: (Obsidian) Main gateway — auto-routes to vault mode, project mode, or shows quick actions
argument-hint: "optional: search query, note name, or workflow keyword"
---

# /obsidian — Vault Gateway

Intelligence-first entry point for Obsidian vault operations.

## Usage

```
/obsidian                          # Default: auto-context + quick actions
/obsidian morning                  # Morning planning routine
/obsidian evening                  # Evening summary
/obsidian search meeting notes     # Full-text search
/obsidian read Project Ideas       # Read a note by name
/obsidian create New Note          # Create a note
/obsidian tasks                    # Open tasks list
/obsidian health                   # Vault health audit
/obsidian weekly                   # Weekly review
```

## What it does

1. **Liveness check** — verifies Obsidian is running and CLI is enabled
2. **Location detection** — determines if CWD is inside the vault (VAULT MODE), a subfolder (PROJECT MODE), or external (EXTERNAL MODE)
3. **Auto-context** — loads project focus, intelligence reports, and today's open tasks (~600 tokens)
4. **Quick actions** — shows 5 contextual suggestions based on time of day and project state

## Workflow keywords

| Keyword | Action |
|---------|--------|
| `morning` | Populate daily note with yesterday's tasks + today's focus |
| `evening` | Summarize today's work → append to daily + weekly summary |
| `weekly` | Tags count + intelligence report + update weekly summary |
| `health` | Run vault health audit |
| `search <q>` | Full-text search |
| `read <name>` | Read note by wikilink name |
| `create <name>` | Create note with frontmatter |
| `daily <text>` | Append to today's daily note |
| `tasks` | Context-aware open tasks list |
| `project <name>` | Pin/continue a project |
| `canvas` | Canvas operations |
| `bases` | Bases queries |
| `extract <url>` | Extract clean markdown from web URL |
| `init <name>` | Initialize a new project |
| `intelligence` | Full vault intelligence scan |
| `hubs` | List top 10 hub notes |
| `orphans` | Find orphaned notes + suggest connections |
| `fix-links` | Scan broken links + suggest fixes |
| `backlinks` | Check missing bidirectional links |

If the keyword does not match, the input is treated as a search query.

## Also available

- `/obsidian-trace` — Trace idea evolution across the vault
- `/obsidian-challenge` — Stress-test a belief using vault history
- `/obsidian-connect` — Find cross-domain connections in the vault
- `/obsidian-emerge` — Surface latent ideas from the vault
