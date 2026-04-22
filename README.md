# Obsidian Skill for Claude Code

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Claude Code skill suite for automating [Obsidian](https://obsidian.md/) vaults via the official Obsidian CLI.

Every command routes through Obsidian's internal API — so moves auto-rewrite wikilinks, properties reflect immediately, and plugin configs are never silently overwritten.

## What is this?

This skill turns Claude Code into an intelligent vault assistant. Create notes, update properties, search across your entire second brain, toggle tasks, and run structured PKM workflows — all through natural conversation. No raw file manipulation, no broken links, no YAML corruption.

## Who is this for?

| Claude Code users | Obsidian users | Developers |
|---|---|---|
| Install one skill and control your vault with natural language. | Automate repetitive vault tasks without leaving your editor. | Extend the skill suite with new sub-skills or CLI commands. |

## Prerequisites

- Obsidian v1.12.7+ with CLI enabled ([setup guide](obsidian-workflows/references/platform-setup.md))
- Claude Code (this is a Claude Code skill)

## Installation

1. Clone this repo into your Claude Code skills directory:
   ```bash
   git clone https://github.com/Sourabh-Garg-tech/obsidian.git ~/.claude/skills/obsidian
   ```
2. Restart Claude Code or run `/skill refresh`
3. The skill auto-triggers on any Obsidian-related request

## Quick start

```bash
# Verify CLI is available
obsidian version
obsidian vaults

# Read a note
obsidian read file="Project Ideas"

# Search your vault
obsidian search query="deadline:2026-04-30" format=json

# Append to today's daily note
obsidian daily:append date="today" content="- [ ] Review Q2 goals"

# Update frontmatter
obsidian property:set file="Project Ideas" name="status" value="active"
```

## Sub-skills

| Sub-skill | What it does |
|---|---|
| [obsidian-cli](obsidian-cli/) | CLI syntax, parameters, and command reference |
| [obsidian-markdown](obsidian-markdown/) | Obsidian-flavored markdown: wikilinks, embeds, callouts, properties |
| [obsidian-bases](obsidian-bases/) | Bases `.base` files: filters, formulas, views |
| [json-canvas](json-canvas/) | Canvas `.canvas` files: nodes, edges, groups |
| [defuddle](defuddle/) | Extract clean markdown from web pages |
| [obsidian-workflows](obsidian-workflows/) | PKM routines, token-efficient loading, vault intelligence |
| [obsidian-vault-architect](obsidian-vault-architect/) | Vault blueprints, health audit, fix commands |

## Why this over raw file tools

| Raw file tools | Obsidian CLI (this skill) |
|---|---|
| `mv` breaks wikilinks | `obsidian move` rewrites all links automatically |
| Writing YAML by hand corrupts frontmatter | `property:set` writes safe YAML |
| Editing `.obsidian/*.json` gets overwritten | Plugin configs managed through the API |
| No cross-platform guarantees | Works on macOS, Windows, Linux |

## Safety rules

1. **Never `mv`/`cp`** vault files — use `obsidian move` to preserve wikilinks
2. **Never write raw YAML** into `.md` files — use `property:set`
3. **Never edit `.obsidian/*.json`** — Obsidian will overwrite changes
4. **Dry-run bulk ops** — echo commands first, then remove `echo`
5. **Confirm vault** with `obsidian vaults` if multiple vaults open
6. **>500 files** — use Python + `python-frontmatter`, then `obsidian reload`

See [full safety reference](references/full-reference.md#safety-rules).

## Thinking commands

Four slash commands that use the vault as context for reasoning — not file management. Copy from `commands/` to your vault's `.claude/commands/`.

| Command | Input | What it does |
|---|---|---|
| `/trace <topic>` | concept or project name | Timeline of how thinking evolved on this topic |
| `/challenge <belief>` | stated belief or plan | Vault-sourced counterarguments and past patterns |
| `/connect <A, B>` | two domains | Non-obvious connections between seemingly unrelated topics |
| `/emerge` | none | Latent ideas the vault implies but hasn't stated |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE) — free for anyone to use, modify, and distribute.