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
  platforms: "macOS, Windows, Linux (see references/platform-setup.md)"
---

# Obsidian Skill for Claude Code

Full vault automation via the **official Obsidian CLI** (v1.12.4+, GA February 2026).
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
→ Platform-specific setup: `references/platform-setup.md`

> The CLI is a **remote control** — Obsidian must be running (or it launches automatically).

---

## Command Overview (130+ commands across 18 categories)

| Category | Key Commands |
|---|---|
| **Files** | `files`, `folders`, `file`, `read`, `create`, `append`, `prepend`, `move`, `rename`, `delete`, `random` |
| **Properties** | `properties`, `property:read`, `property:set`, `property:remove`, `aliases` |
| **Search** | `search`, `search:context` |
| **Tags** | `tags`, `tag` |
| **Tasks** | `tasks`, `task` |
| **Links** | `links`, `backlinks`, `unresolved`, `orphans`, `deadends` |
| **Daily Notes** | `daily`, `daily:read`, `daily:append`, `daily:prepend`, `daily:path` |
| **Bookmarks** | `bookmarks`, `bookmark` |
| **Templates** | `templates`, `template:read`, `template:insert` |
| **Plugins** | `plugins`, `plugins:enabled`, `plugin`, `plugin:enable`, `plugin:disable`, `plugin:install`, `plugin:uninstall`, `plugin:reload` |
| **Sync** | `sync`, `sync:status`, `sync:history`, `sync:read`, `sync:restore`, `sync:deleted` |
| **Themes** | `themes`, `theme`, `theme:set`, `theme:install`, `theme:uninstall` |
| **Snippets** | `snippets`, `snippets:enabled`, `snippet:enable`, `snippet:disable` |
| **Commands** | `commands`, `command` |
| **Vault** | `vaults`, `vault`, `version`, `reload`, `restart`, `recents`, `outline`, `wordcount`, `diff` |
| **Developer** | `eval`, `dev:screenshot`, `dev:debug`, `dev:console`, `dev:errors`, `dev:css`, `dev:dom`, `devtools` |

→ Full parameter/flag reference: `references/command-reference.md`

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
obsidian property:remove file="NoteName" name="deprecated"
obsidian aliases file="NoteName"
```

→ Frontmatter schema conventions: `references/frontmatter-schema.md`

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
obsidian tag name="#project"                        # notes with this tag
# Note: tags:rename and tags:remove do NOT exist. Use property:set or eval for bulk tag changes.
```

---

## Tasks

```bash
obsidian tasks                                       # all open tasks in vault
obsidian tasks path="Projects/"                      # tasks in a folder
obsidian task file="NoteName" line=5                # task on specific line
obsidian task file="NoteName" line=5 toggle          # toggle a task done/undone
```

---

## Links & Graph Health

```bash
obsidian links     file="NoteName"   # outgoing wikilinks
obsidian backlinks file="NoteName"   # incoming wikilinks
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
obsidian sync                             # trigger manual sync
obsidian sync:history file="NoteName"    # version history of a note
obsidian sync:restore file="NoteName" version=3

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

→ Full command details: `references/command-reference.md`

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
`references/token-efficiency.md`

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

→ Full OFM syntax (callouts, embeds, canvas, Dataview, Templater): `references/ofm-syntax.md`

---

## Safety Rules

1. **Never use `mv` or `cp`** on vault files — use `obsidian move` to preserve wikilinks.
2. **Never write raw YAML** into `.md` files — use `property:set` to avoid index corruption.
3. **Never edit `.obsidian/*.json`** plugin configs directly — Obsidian will overwrite changes.
4. **Dry-run destructive bulk ops** by echoing commands first, then removing `echo`.
5. **Confirm the vault** with `obsidian vaults` if the user has multiple vaults open.
6. **For >500 files**, use Python with `python-frontmatter` lib, then run `obsidian reload` to reindex.
7. **Not all commands support `format=json`** — only `search`, `tags`, `tasks`, `backlinks`, `bookmarks`, `unresolved`, `properties`, `plugins`. `files` does NOT support JSON output.
8. **`tags:rename` and `tags:remove` don't exist** — use `property:set` on individual notes or `eval` for bulk tag changes.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `command not found` | Re-enable CLI in Obsidian Settings; restart terminal |
| Empty output / hangs | Obsidian is not running; start it first |
| Windows: silent failures | Use a normal terminal (not admin/elevated) |
| Wrong vault targeted | Pass `vault="VaultName"` explicitly |

→ Platform-specific setup: `references/platform-setup.md`

---

## Reference Files

| File | When to read |
|---|---|
| `references/command-reference.md` | Need a specific flag, obscure command, or JSON output format |
| `references/frontmatter-schema.md` | Setting up or normalizing vault property schemas |
| `references/ofm-syntax.md` | Writing Obsidian Flavored Markdown (callouts, embeds, canvas, Dataview) |
| `references/platform-setup.md` | Windows, Linux headless/systemd, or multi-vault PATH setup |
| `references/intelligence-patterns.md` | Auto-linking engine, hub detection, orphan triage, refactor recipes, self-improvement loop |
| `references/token-efficiency.md` | Vault structure for token savings, RAG-lite patterns, context budget templates |
| `references/pkm-workflows.md` | Morning planning, weekly review, vault hygiene, GTD inbox processing, graph analysis |
| `references/advanced-operations.md` | Merge/split notes, normalize messy vault, PKM method detection |
| `references/daily-workflows.md` | CLI wrapper script, auto-context builder, daily note intelligence |