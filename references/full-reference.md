---
name: obsidian
description: >
  Use this skill for ALL tasks involving Obsidian — creating, reading, editing, or deleting
  notes; managing vault folders and structure; bulk-updating frontmatter/properties; full-text
  search; tag management; wikilink and graph operations; tasks and bookmarks; daily/weekly/monthly
  notes; enabling or disabling plugins; managing themes and snippets; Obsidian Sync operations;
  Obsidian Bases queries; PKM workflows (PARA, Zettelkasten, GTD, LYT); vault health and
  hygiene; working with Obsidian Flavored Markdown, callouts, embeds, and canvas files. Trigger
  whenever the user mentions "Obsidian", "vault", "notes", ".md", "wikilinks", "frontmatter",
  "dataview", "daily notes", "second brain", "PKM", "PARA", "Zettelkasten", or any
  Obsidian-specific workflow. Always use this skill — even for simple requests like "create a
  note" — because the official CLI has critical link-safety guarantees raw file tools lack.
compatibility:
  requires: "Obsidian v1.12.7+ with CLI enabled (v1.12.7 has significantly faster CLI binary)"
  platforms: "macOS, Windows, Linux (see skills/obsidian-workflows/references/platform-setup.md)"
---

# Obsidian Skill for Claude Code

Full vault automation via the **official Obsidian CLI** (v1.12.7+, GA February 2026).
Every command routes through Obsidian's internal API: moves auto-update wikilinks, property
changes reflect in the index immediately, and plugin configs are never silently overwritten.

**Architecture: CLI as execution layer, Claude as intelligence layer.**

```
Claude (reasoning: link strategy, graph analysis, content decisions, entity extraction)
   ↓
Obsidian CLI (execution: safe CRUD, link-preserving moves, index-consistent writes)
   ↓
Obsidian vault (files, graph, index, plugins)
```

**Core rule: always use `obsidian <cmd>` over raw `mv`, `cp`, or direct `.md` file writes.
Use bash/Python only for bulk processing >500 files where CLI subprocess overhead is prohibitive.**

---

## Quick Setup

```bash
obsidian version                    # verify CLI is available
obsidian vaults                     # list known vaults
obsidian files vault="Work"         # all commands accept vault= parameter
```

If `command not found` → Obsidian Settings → General → Command line interface → Enable + Register CLI.
→ Platform-specific setup: `skills/obsidian-workflows/references/platform-setup.md`

> The CLI is a **remote control** — Obsidian must be running (or it launches automatically).

---

## Command Overview (130+ commands across 18 categories)

| Category | Key Commands |
|---|---|
| **Files** | `files`, `folders`, `file`, `read`, `create`, `append`, `prepend`, `move`, `rename`, `delete`, `open`, `random` |
| **Properties** | `properties`, `property:read`, `property:set`, `property:remove`, `aliases` |
| **Search** | `search`, `search:context` |
| **Tags** | `tags`, `tag` |
| **Tasks** | `tasks`, `task`, `tasks done`, `tasks todo`, `tasks daily`, `tasks active`, `tasks verbose` |
| **Links** | `links`, `backlinks`, `unresolved`, `orphans`, `deadends` |
| **Daily Notes** | `daily`, `daily:read`, `daily:append`, `daily:prepend`, `daily:path` |
| **Bookmarks** | `bookmarks`, `bookmark` |
| **Templates** | `templates`, `template:read`, `template:insert` |
| **Plugins** | `plugins`, `plugins:enabled`, `plugin`, `plugin:enable`, `plugin:disable`, `plugin:install`, `plugin:uninstall`, `plugin:reload` |
| **Sync** | `sync`, `sync:status`, `sync:open`, `sync:history`, `sync:read`, `sync:restore`, `sync:deleted` |
| **Themes** | `themes`, `theme`, `theme:set`, `theme:install`, `theme:uninstall` |
| **Snippets** | `snippets`, `snippets:enabled`, `snippet:enable`, `snippet:disable` |
| **Commands** | `commands`, `command`, `hotkeys`, `hotkey` |
| **Vault** | `vaults`, `vault`, `version`, `reload`, `restart`, `recents`, `outline`, `wordcount`, `diff` |
| **Developer** | `eval`, `dev:screenshot`, `dev:debug`, `dev:console`, `dev:errors`, `dev:css`, `dev:dom`, `devtools` |

→ Full parameter/flag reference: `skills/obsidian-cli/references/command-reference.md`

---

## File Operations

```bash
# List & Navigate
obsidian files                              # all notes in vault
obsidian files folder="Projects/"          # filter by folder
obsidian folders                            # tree of all folders
obsidian file file="NoteName"              # metadata: size, created, modified

# Read
obsidian read file="Folder/NoteName"       # by wikilink name (no extension needed)
obsidian read path="Folder/Note.md"        # by exact path from vault root

# Create
obsidian create name="Folder/NoteName" content="# Heading\n\nBody text"
obsidian create name="ReadingLog/Book" template="BookNote"

# Edit
obsidian append  file="NoteName" content="\n## New Section\n- item"
obsidian prepend file="NoteName" content="Status: done\n"

# Move / Rename / Delete
obsidian move   file="Inbox/Draft" to="Projects/"   # auto-rewrites ALL wikilinks
obsidian rename file="OldName"     name="NewName"
obsidian delete file="NoteName"                      # sends to system trash

# Open in Obsidian
obsidian open   file="NoteName"                       # open note in Obsidian
obsidian open   file="NoteName" newtab                # open in new tab
```

**`file=` vs `path=`:** Use `file=` (wikilink resolution, no extension) in most cases.
Use `path=Folder/Note.md` only when notes share names or precision is required.

---

## Properties / Frontmatter

```bash
obsidian properties file="NoteName"                           # view all properties
obsidian property:read file="NoteName" name="status"         # read one property
obsidian property:set  file="NoteName" name="status" value="done"
obsidian property:set  file="NoteName" name="tags"  value='["project","active"]'
obsidian property:set  file="NoteName" name="status" value="active" type=list
obsidian property:remove file="NoteName" name="deprecated"
obsidian aliases file="NoteName"
```

**`type=` options:** `text`, `list`, `number`, `checkbox`, `date`, `datetime`

→ Frontmatter schema conventions: `skills/obsidian-vault-architect/references/frontmatter-schema.md`

---

## Search

```bash
obsidian search query="meeting notes"                # full-text search
obsidian search query="tag:#project" path="Work/"   # tag + folder filter
obsidian search query="[status:done]"               # property filter (Dataview-style)
obsidian search query="TODO" limit=20               # limit results
obsidian search:context query="TODO" lines=3        # show surrounding lines
```

---

## Tags

```bash
obsidian tags                                        # all tags with counts
obsidian tags sort=count                             # sort by frequency
obsidian tag name="project"                         # notes with this tag (no # prefix)
# Note: tags:rename and tags:remove do NOT exist. Use property:set or eval for bulk tag changes.
```

---

## Tasks

```bash
# List tasks
obsidian tasks                                       # all tasks (done + todo)
obsidian tasks done                                  # completed only
obsidian tasks todo                                  # incomplete only
obsidian tasks daily                                 # from daily note
obsidian tasks active                                # tasks in active file
obsidian tasks path="Projects/"                      # tasks in a folder
obsidian tasks 'status="?"'                          # filter by status character
obsidian tasks verbose                               # grouped by file with line numbers
obsidian tasks total                                 # return count
obsidian tasks format=json|tsv|csv                   # output format

# Single task
obsidian task file="NoteName" line=5                 # task info on specific line
obsidian task file="NoteName" line=5 toggle          # toggle done/undone
obsidian task file="NoteName" line=5 done            # mark as done [x]
obsidian task file="NoteName" line=5 todo            # mark as todo [ ]
obsidian task daily line=3 toggle                    # toggle in daily note
obsidian task ref="note.md:8" toggle                 # by reference (path:line)
```

---

## Links & Graph Health

```bash
obsidian links     path="NoteName.md"  # outgoing wikilinks (use path=, not file=)
obsidian backlinks path="NoteName.md"   # incoming wikilinks (use path=, not file=)
obsidian unresolved                  # all broken/unresolved links in vault
obsidian orphans                     # notes with no links at all
obsidian deadends                    # notes with no outgoing links
```

---

## Daily Notes

```bash
obsidian daily                                      # open/create today's note
obsidian daily date="2026-04-15"                   # specific date
obsidian daily:read  date="yesterday"
obsidian daily:append date="today" content="\n- [ ] Review PR"
obsidian daily:path date="today"                   # print path to daily note
```

Date formats: `today`, `yesterday`, `YYYY-MM-DD`, `+1` (tomorrow), `-3` (3 days ago)

---

## Plugins, Sync, Bases, Themes, Templates

```bash
# Plugins
obsidian plugins                          # list all plugins + enabled state
obsidian plugins:enabled                  # list only enabled plugins
obsidian plugin:enable  id="dataview"
obsidian plugin:install id="templater-obsidian"
obsidian plugin:reload id="my-plugin"    # reload plugin (dev use)

# Sync (Obsidian Sync subscribers)
obsidian sync                             # show status / trigger sync
obsidian sync on                          # resume sync
obsidian sync off                         # pause sync
obsidian sync:status                       # detailed sync status & usage
obsidian sync:open file="NoteName"         # open sync history in UI
obsidian sync:history file="NoteName"     # version history of a note
obsidian sync:read file="NoteName" version=3   # read a sync version
obsidian sync:restore file="NoteName" version=3
obsidian sync:deleted                     # list deleted files in sync

# Templates
obsidian templates                        # list available templates
obsidian template:insert file="NewNote" name="MeetingNote"

# Bases
obsidian bases                            # list all .base files
obsidian base:query base="Tasks" view="Open Tasks"

# Themes / Snippets
obsidian themes                           # list installed themes
obsidian theme:set theme="Minimal"
obsidian snippet:enable name="my-snippet"
```

→ Full command details: `skills/obsidian-cli/references/command-reference.md`

---

## Commands & Hotkeys

```bash
obsidian commands                                    # list available command IDs
obsidian commands filter="app:"                     # filter by ID prefix
obsidian command id="app:reload"                    # execute an Obsidian command
obsidian command id="editor:toggle-bold"
obsidian hotkeys                                    # list hotkeys for all commands
obsidian hotkeys total                              # return count
obsidian hotkeys verbose                            # show if custom or default
obsidian hotkey  id="app:open-settings"             # hotkey for a command
obsidian hotkey  id="app:open-settings" verbose
```

---

## Vault & System

```bash
obsidian vault                                      # full vault info
obsidian vault info=name                            # vault name only
obsidian vault info=path                            # vault path only
obsidian vault info=files                           # file count only
obsidian vault info=folders                         # folder count only
obsidian vault info=size                            # vault size only
obsidian vaults                                     # list known vaults
obsidian vaults total                               # vault count
obsidian vaults verbose                             # include vault paths
obsidian version                                    # Obsidian version
obsidian reload                                    # reload vault
obsidian restart                                   # full restart
obsidian recents                                   # recently opened files
obsidian recents total                              # count only
```

---

## Token-Efficient Context Loading

Obsidian's biggest value for AI workflows is **selective retrieval** — loading only the 2-5
notes relevant to the current task rather than pasting everything.

| Approach | Tokens per task |
|---|---|
| Raw prompting (repeat everything) | 10k – 50k |
| Obsidian, naive (dump whole vault) | same or worse |
| Obsidian + selective retrieval | 3k – 10k |
| Obsidian + retrieval + summaries | **500 – 3k** |

**The anti-pattern:** pasting entire vault content into a prompt. That wastes tokens and
defeats the purpose. Obsidian is external memory — reference it, do not dump it.

### Context Loading Workflow

```
User task
   ↓
Search vault for relevant notes (2–5 max)
   ↓
Load only those notes into context
   ↓
Send to model with task
   ↓
Write result back to vault
```

**Token budget target:** aim for under 3,000 tokens of loaded context per task.

→ Deep dive on vault structure for token savings, RAG-lite patterns, context budget templates:
`skills/obsidian-workflows/references/token-efficiency.md`

---

## Obsidian Flavored Markdown Quick Reference

```markdown
[[Note Name]]                    # wikilink
[[Note Name|Display Text]]       # aliased link
[[Note Name#Heading]]            # link to heading
![[Note Name]]                   # embed note

> [!note] Title                  # callout
> Content

#tag-name                        # tag (no spaces)
- [ ] Open task                  # task checkbox
- [x] Completed task
```

→ Full OFM syntax (callouts, embeds, canvas, Dataview, Templater): `obsidian-markdown/SKILL.md`

---

## Safety Rules

1. **Never use `mv` or `cp`** on vault files — use `obsidian move` to preserve wikilinks.
2. **Never write raw YAML** into `.md` files — use `property:set` to avoid index corruption.
3. **Never edit `.obsidian/*.json`** plugin configs directly — Obsidian will overwrite changes.
4. **Dry-run destructive bulk ops** by echoing commands first, then removing `echo`.
5. **Confirm the vault** with `obsidian vaults` if the user has multiple vaults open.
6. **For >500 files**, use Python with `python-frontmatter` lib, then run `obsidian reload` to reindex.
7. **Not all commands support `format=json`** — only `search`, `tags`, `tasks`, `backlinks`, `bookmarks`, `unresolved`, `properties`, `plugins`. `files` and `tag` do NOT support JSON output.
8. **`tags:rename` and `tags:remove` don't exist** — use `property:set` on individual notes or `eval` for bulk tag changes.
9. **`search` unreliable on Windows** — returns empty without `path=`. Use Grep tool on vault directory as fallback.
10. **`backlinks file=` and `links file=` unreliable** — use `path=` instead: `obsidian backlinks path="Folder/Note.md"`
11. **Colon commands may fail in Git Bash on Windows** — `property:*`, `daily:*`, `plugin:*`, `base:*`, `history:*`, `theme:*`, `template:*`, `tab:*` return exit code 127. Use `cmd /c "obsidian property:read ..."` or PowerShell.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `command not found` | Re-enable CLI in Obsidian Settings; restart terminal |
| Empty output / hangs | Obsidian is not running; start it first |
| Windows: silent failures | Use a normal terminal (not admin/elevated) |
| Wrong vault targeted | Pass `vault="VaultName"` explicitly |

→ Platform-specific setup: `skills/obsidian-workflows/references/platform-setup.md`

---

## Reference Files

| File | When to read |
|---|---|
| `skills/obsidian-cli/references/command-reference.md` | Need a specific flag, obscure command, or JSON output format |
| `skills/obsidian-vault-architect/references/frontmatter-schema.md` | Setting up or normalizing vault property schemas |
| `obsidian-markdown/SKILL.md` | Writing Obsidian Flavored Markdown (callouts, embeds, canvas, Dataview) |
| `skills/obsidian-workflows/references/platform-setup.md` | Windows, Linux headless/systemd, or multi-vault PATH setup |
| `skills/obsidian-workflows/references/intelligence-patterns.md` | Auto-linking engine, hub detection, orphan triage, refactor recipes, self-improvement loop |
| `skills/obsidian-workflows/references/token-efficiency.md` | Vault structure for token savings, RAG-lite patterns, context budget templates |
| `skills/obsidian-workflows/references/pkm-workflows.md` | Morning planning, weekly review, vault hygiene, GTD inbox processing, graph analysis |
| `skills/obsidian-vault-architect/references/vault-operations.md` | Merge/split notes, normalize messy vault, PKM method detection |
| `skills/obsidian-workflows/references/daily-workflows.md` | CLI wrapper script, auto-context builder, daily note intelligence |