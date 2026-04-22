---
name: obsidian
description: >
  This skill should be used when the user asks to "create a note", "read a note",
  "edit a note", "search my vault", "move a note", "rename a note", "delete a note",
  "update frontmatter", "add properties", "manage tags", "find tasks",
  "check backlinks", "create a daily note", "list plugins", "change themes",
  "manage snippets", "obsidian sync", "obsidian bases", "canvas files",
  "PKM workflow", "PARA", "Zettelkasten", "GTD", "LYT", "vault health",
  "vault audit", "vault hygiene", "obsidian markdown", "wikilinks", "callouts",
  "embeds", or mentions "Obsidian", "vault", "notes", ".md", "frontmatter",
  "dataview", "daily notes", "second brain". Automates Obsidian vaults via the
  official CLI. Always use this skill over raw file tools for link-safety guarantees.
compatibility:
  requires: "Obsidian v1.12.7+ with CLI enabled (v1.12.7 has significantly faster CLI binary)"
  platforms: "macOS, Windows, Linux (see obsidian-workflows/references/platform-setup.md)"
auto-trigger:
  - "create a note"
  - "read a note"
  - "edit a note"
  - "search my vault"
  - "move a note"
  - "rename a note"
  - "delete a note"
  - "update frontmatter"
  - "add properties"
  - "manage tags"
  - "find tasks"
  - "check backlinks"
  - "create a daily note"
  - "list plugins"
  - "change themes"
  - "manage snippets"
  - "obsidian sync"
  - "obsidian bases"
  - "canvas files"
  - "PKM workflow"
  - "PARA"
  - "Zettelkasten"
  - "GTD"
  - "LYT"
  - "vault health"
  - "vault audit"
  - "vault hygiene"
  - "obsidian markdown"
  - "wikilinks"
  - "callouts"
  - "embeds"
  - "Obsidian"
  - "vault"
  - "notes"
  - ".md"
  - "frontmatter"
  - "dataview"
  - "daily notes"
  - "second brain"
---

# Obsidian Skill — Micro Core

Vault automation via the **official Obsidian CLI**. Every command routes through Obsidian's
internal API — moves auto-update wikilinks, properties reflect immediately, plugin configs
are never silently overwritten.

**Always use `obsidian <cmd>` over raw `mv`, `cp`, or direct `.md` file writes.**

→ Full command reference & examples: `references/full-reference.md`

---

## Safety Rules

1. **Never `mv`/`cp`** vault files — use `obsidian move` to preserve wikilinks
2. **Never write raw YAML** into `.md` files — use `property:set`
3. **Never edit `.obsidian/*.json`** — Obsidian will overwrite changes
4. **Dry-run bulk ops** — echo commands first, then remove `echo`
5. **Confirm vault** with `obsidian vaults` if multiple vaults open
6. **>500 files** — use Python + `python-frontmatter`, then `obsidian reload`
7. **`format=json`** only works on: `search`, `tags`, `tasks`, `backlinks`, `bookmarks`, `unresolved`, `properties`, `plugins`. **Not on `files`.**
8. **`tags:rename`/`tags:remove` don't exist** — use `property:set` or `eval`
9. **`search` unreliable on Windows** — returns empty without `path=`. Use Grep tool on vault directory as fallback: `Grep: pattern="query" path="<vault>" glob="*.md"`
10. **`backlinks file=` unreliable** — use `path=` instead: `obsidian backlinks path="Folder/Note.md"`

---

## Quick Reference

For the full command table: `references/quick-reference.md`

**`file=` vs `path=`:** `file=` resolves by wikilink name (no extension). `path=` is exact from vault root.

---

## Token-Efficient Context Loading

Search first, read only what is needed. Target: under 3,000 tokens of vault context per task.

```
User task → Search (2–5 notes) → Read those notes → Process → Write back
```

→ Deep dive: `obsidian-workflows/references/token-efficiency.md`

---

## OFM Quick Reference

```markdown
[[Note Name]]          wikilink
[[Note|Display]]       aliased link
![[Note Name]]         embed
> [!note] Title        callout
#tag-name              tag
- [ ] task             checkbox
```

→ Full syntax: `references/ofm-syntax.md`

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `command not found` | Re-enable CLI in Settings; restart terminal |
| Empty output / hangs | Obsidian not running; start it first |
| Windows: silent failures | Normal terminal only (not admin) |
| Wrong vault | Pass `vault="Name"` explicitly |

→ Platform setup: `obsidian-workflows/references/platform-setup.md`

---

## Thinking Commands

Slash commands that use the vault as context for reasoning, not file management. Copy from `commands/` to the vault's `.claude/commands/`.

| Command | Input | What it does |
|---|---|---|
| `/trace <topic>` | concept or project name | Timeline of how thinking evolved on this topic |
| `/challenge <belief>` | stated belief or plan | Vault-sourced counterarguments and past patterns |
| `/connect <A, B>` | two domains | Non-obvious connections between seemingly unrelated topics |
| `/emerge` | none | Latent ideas the vault implies but hasn't stated |

All commands read the vault only — they never write to it. See `commands/` for prompt templates.

---

## Reference Files

### Top-Level References

| File | When to read |
|---|---|
| `references/full-reference.md` | Complete command overview + all examples (loads this skill's full content) |
| `references/frontmatter-schema.md` | Property schemas, normalization, Dataview patterns |
| `references/ofm-syntax.md` | Callouts, embeds, canvas, Dataview, Templater |
| `references/advanced-operations.md` | Merge/split notes, normalize vault, PKM method detection |
| `references/daily-workflows.md` | CLI wrapper, auto-context builder, daily note intelligence |
| `obsidian-workflows/references/intelligence-patterns.md` | Auto-linking, hub detection, orphan triage, domain-to-code intelligence, decision trails, custom eval queries |
| `references/cli-validation-report.md` | CLI validation findings against v1.12.7 |
| `references/quick-reference.md` | Essential command table for daily use |
| `obsidian-workflows/references/project-onboarding.md` | Project scaffolding, `vault-project-init` workflow, 3-folder structure |

### Scripts

| Script | Purpose |
|---|---|
| `scripts/vault-health.sh` | Run comprehensive vault health metrics (orphans, broken links, totals) |
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