# PKM Workflows

Operational routines for common PKM tasks.

---

## Morning Planning

```bash
# Review today's note and outstanding tasks
obsidian daily:read
obsidian tasks daily todo
obsidian recents

# Check for urgent items
obsidian search query="tag:#urgent" format=json
obsidian orphans | head -5        # notes needing integration
```

---

## Weekly Review

```bash
# Vault health snapshot
obsidian unresolved              # broken links to fix
obsidian orphans                 # unlinked notes
obsidian tags sort=count counts   # most used tags
obsidian files total              # total note count

# Review projects
obsidian search query="tag:#project" format=json
obsidian tasks done               # completed tasks

# Check sync status (if using Sync)
obsidian sync:status
```

---

## GTD Inbox Processing

```bash
# List inbox contents
obsidian files folder="Inbox/"
obsidian tasks folder="Inbox/" todo

# For each item, decide: Do, Delegate, Defer, or Archive
# Move processed items to appropriate folder
obsidian move file="InboxItem" to="Projects/"
obsidian move file="ReferenceItem" to="Archive/"
obsidian move file="SomedayItem" to="Someday Maybe/"
```

---

## Vault Hygiene Check

```bash
# Count issues
obsidian unresolved total         # broken links count
obsidian orphans total            # orphaned notes count
obsidian deadends total           # notes with no outgoing links

# List the issues
obsidian unresolved verbose       # broken links with source files
obsidian orphans                  # notes needing connections
obsidian deadends                  # notes with no outgoing links

# Fix: link orphans to relevant notes, resolve broken links
obsidian search query="topic" format=json  # find related notes
```

---

## PKM Method Conventions

When working with a vault, detect the organizational method from folder structure:

| Folders detected | Likely method | Key principle |
|---|---|---|
| `Projects/`, `Areas/`, `Resources/`, `Archive/` | PARA | Actionability-based |
| `01 Fleeting/`, `02 Literature/`, `03 Permanent/` | Zettelkasten | Idea atomicity |
| `MOC/`, `Map of Content` files | LYT/Linking | Bottom-up emergence |
| `Inbox/`, `Next Actions/`, `Someday/` | GTD | Task-oriented |

Frame suggestions in the user's existing framework. Don't impose a different method.

---

## Tag Renaming (Bulk)

`tags:rename` does NOT exist. To bulk-rename a tag:

```bash
# Search for notes with the old tag
obsidian search query="tag:#oldname" format=json

# For each note, update the tags property
# Note: property:set replaces the entire tags array, so read first
obsidian property:read file="Note" name="tags"
# Then set with old tag replaced
obsidian property:set file="Note" name="tags" value='["newname", "other"]'
```

For large vaults (>500 notes), use a Python script with `python-frontmatter` library,
then run `obsidian reload` to reindex.