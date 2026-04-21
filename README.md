# Obsidian Skill for Claude Code

A comprehensive Claude Code skill suite for automating [Obsidian](https://obsidian.md/) vaults via the official Obsidian CLI.

## What it does

- **Vault management** — create, read, edit, move, and delete notes safely (wikilinks auto-preserved)
- **Properties & frontmatter** — get, set, and remove YAML properties without corrupting files
- **Search & intelligence** — full-text search, backlinks, unresolved links, orphans
- **Daily notes & tasks** — append to daily notes, toggle tasks, list open tasks
- **Canvas & bases** — work with `.canvas` files and `.base` filters
- **PKM workflows** — PARA, Zettelkasten, GTD, LYT method support
- **Thinking commands** — `/trace`, `/challenge`, `/connect`, `/emerge` for vault-based reasoning

## Why use this over raw file tools

Every command routes through Obsidian's internal API:
- `obsidian move` rewrites wikilinks automatically
- `property:set` writes safe YAML
- Plugin configs are never silently overwritten
- Cross-platform: macOS, Windows, Linux

## Quick start

```bash
obsidian version        # verify CLI is available
obsidian vaults         # list open vaults
obsidian read file="NoteName"
obsidian search query="keyword" format=json
```

## Sub-skills

| Skill | Purpose |
|---|---|
| `obsidian-cli` | CLI syntax and command reference |
| `obsidian-markdown` | Obsidian-flavored markdown: wikilinks, embeds, callouts |
| `obsidian-bases` | Bases `.base` files: filters, formulas, views |
| `json-canvas` | Canvas `.canvas` files: nodes, edges, groups |
| `defuddle` | Extract clean markdown from web pages |
| `obsidian-workflows` | PKM routines and vault intelligence |
| `obsidian-vault-architect` | Vault blueprints, health audit, fix commands |

## License

MIT — free for anyone to use, modify, and distribute.
