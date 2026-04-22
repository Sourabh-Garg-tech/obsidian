---
name: obsidian-workflows
description: >
  This skill should be used when the user asks to "morning planning", "weekly review",
  "GTD inbox processing", "vault health check", "auto-linking", "hub detection",
  "orphan triage", "token efficiency", "PKM workflow", "PARA method",
  "Zettelkasten workflow", "GTD workflow", "vault hygiene", "graph analysis",
  "obsidian daily routine", or mentions PKM, PARA, Zettelkasten, GTD, LYT,
  morning routine, weekly review, vault hygiene, token efficiency, or graph analysis.
compatibility:
  requires: "Obsidian v1.12.7+ with CLI enabled"
  platforms: "macOS, Windows, Linux (see references/platform-setup.md)"
---

# Obsidian Workflows

Operational PKM routines and intelligence patterns that combine the Obsidian CLI with
Claude's reasoning. Uses CLI as execution layer, Claude as intelligence layer.

→ CLI command reference: See the `obsidian-cli` skill and `obsidian-cli/references/command-reference.md`
→ Markdown syntax: See the `obsidian-markdown` skill

---

## Token-Efficient Context Loading

Obsidian's biggest value for AI workflows is **selective retrieval** — loading only the 2-5
notes relevant to the current task rather than pasting everything.

| Approach | Tokens per task |
|---|---|
| Raw prompting (repeat everything) | 10k - 50k |
| Obsidian, naive (dump whole vault) | same or worse |
| Obsidian + selective retrieval | 3k - 10k |
| Obsidian + retrieval + summaries | **500 - 3k** |

**The anti-pattern:** pasting entire vault content into a prompt. Obsidian is external
memory — reference it, do not dump it.

→ Deep dive: `references/token-efficiency.md`

---

## Daily Routines

```bash
# Morning briefing
obsidian daily:read                              # read today's note
obsidian tasks daily todo                        # open tasks from today
obsidian recents                                 # recently opened files

# Add entry to daily note
obsidian daily:append content="## $(date '+%H:%M') — Status Update
- Completed: feature branch merge
- Next: code review for PR #42"

# Evening summary
obsidian tasks daily done                        # completed tasks today
obsidian daily:append content="## End of Day
- Accomplished: $(obsidian tasks daily done | wc -l) tasks"
```

---

## Weekly Review

```bash
# Vault health
obsidian unresolved                              # broken links to fix
obsidian orphans                                 # unlinked notes
obsidian tags sort=count counts                  # most used tags
obsidian files total                             # total note count

# Project review
obsidian search query="tag:#project" format=json # find all projects
# **Windows:** `search` may return empty without `path=`. Include `path="Folder/"` or use Grep tool on vault directory as fallback.
obsidian tasks done                              # completed this week
```

---

## GTD Inbox Processing

```bash
# Process inbox
obsidian files folder="Inbox/"                   # list inbox items
obsidian tasks folder="Inbox/" todo              # incomplete tasks in inbox

# After processing, move to appropriate folder
obsidian move file="InboxItem" to="Projects/"
obsidian move file="ReferenceItem" to="Archive/"
```

---

## Intelligence Patterns

Automated analysis patterns that combine CLI data-gathering with Claude's reasoning.

→ Full patterns: `references/intelligence-patterns.md`

---

## PKM Method Detection

Detect the user's organizational method from vault structure:

| Folders detected | Likely method |
|---|---|
| `Projects/`, `Areas/`, `Resources/`, `Archive/` | PARA |
| `01 Fleeting/`, `02 Literature/`, `03 Permanent/` | Zettelkasten |
| `MOC/`, `Map of Content` files | LYT/Linking |
| `Inbox/`, `Next Actions/`, `Someday/` | GTD |

Use this to frame suggestions in the user's existing framework.

---

## Platform Notes

- **Windows**: Must use normal terminal (not admin). Git Bash/MSYS2 need a wrapper script.
- **Linux headless**: Use `.deb` (not snap), run under xvfb, `PrivateTmp=false` for systemd.
- **Multi-vault**: Use `vault="Name"` if multiple vaults open.

→ Full platform setup: `references/platform-setup.md`

---

## Reference Files

| File | When to read |
|---|---|
| `references/token-efficiency.md` | Vault structure for token savings, RAG-lite patterns, context budgets |
| `references/intelligence-patterns.md` | Auto-linking, hub detection, orphan triage, refactor recipes |
| `references/pkm-workflows.md` | Morning planning, weekly review, GTD inbox, vault hygiene |
| `references/platform-setup.md` | Windows, Linux headless/systemd, multi-vault setup |