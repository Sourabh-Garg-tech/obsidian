---
name: obsidian-cli
description: >
  This skill should be used when the user asks to "interact with Obsidian vault",
  "manage obsidian notes", "search vault content", "obsidian command line",
  "obsidian CLI", "vault operations", "obsidian plugin development",
  "obsidian theme development", "reload plugin", "run JavaScript in obsidian",
  "capture obsidian errors", "obsidian screenshot", "inspect obsidian DOM",
  or mentions any obsidian command-line operation.
---

# Obsidian CLI

Use the `obsidian` CLI to interact with a running Obsidian instance. Requires Obsidian to be open.

## Command reference

Run `obsidian help` to see all available commands. This is always up to date.
Full docs: https://help.obsidian.md/cli

→ Detailed command reference: `references/command-reference.md`

## Syntax

**Parameters** take a value with `=`. Quote values with spaces:

```bash
obsidian create name="My Note" content="Hello world"
```

**Flags** are boolean switches with no value:

```bash
obsidian create name="My Note" open overwrite
```

For multiline content use `\n` for newline and `\t` for tab.

## File targeting

Many commands accept `file` or `path` to target a file. Without either, the active file is used.

- `file=<name>` — resolves like a wikilink (name only, no path or extension needed)
- `path=<path>` — exact path from vault root, e.g. `folder/note.md`

## Vault targeting

Commands target the most recently focused vault by default. Use `vault=<name>` as the first parameter to target a specific vault:

```bash
obsidian vault="My Vault" search query="test"
```

## Common patterns

```bash
obsidian read file="My Note"
obsidian create name="New Note" content="# Hello" template="Template"
obsidian append file="My Note" content="New line"
obsidian search query="search term" limit=10
obsidian daily:read
obsidian daily:append content="- [ ] New task"
obsidian property:set name="status" value="done" file="My Note"
obsidian tasks daily todo
obsidian tags sort=count counts
obsidian backlinks file="My Note"
```

Use `--copy` on any command to copy output to clipboard.
Use `total` on list commands to get a count.

## Safety rules

1. **Never `mv`/`cp` vault files** — use `obsidian move` to preserve wikilinks
2. **Never write raw YAML** into `.md` files — use `property:set` to avoid index corruption
3. **Never edit `.obsidian/*.json`** — Obsidian will overwrite changes
4. **Dry-run bulk ops** — echo commands first, then remove `echo`
5. **Confirm vault** with `obsidian vaults` if multiple vaults open
6. **>500 files** — use Python + `python-frontmatter`, then `obsidian reload`

## Plugin development

### Develop/test cycle

1. **Reload** the plugin: `obsidian plugin:reload id=my-plugin`
2. **Check for errors**: `obsidian dev:errors`
3. **Verify visually**: `obsidian dev:screenshot path=screenshot.png`
4. **Check console**: `obsidian dev:console level=error`

### Additional developer commands

```bash
obsidian eval code="app.vault.getFiles().length"
obsidian dev:css selector=".workspace-leaf" prop=background-color
obsidian dev:mobile on
```

Run `obsidian help` to see additional developer commands.

## Tips

1. **`property:set` stores list values as strings** — `value="tag1, tag2"` writes a literal string, not a YAML array. Edit frontmatter directly or use `eval` for proper arrays.
2. **`template:insert` inserts into the active file only** — no `file=` or `path=` param. Use `create template=` to create a file from a template.
3. **`eval` requires single-line JS** — write multiline scripts to a temp file and use command substitution:
   ```bash
   cat > /tmp/obs.js << 'JS'
   var files = app.vault.getMarkdownFiles();
   files.length;
   JS
   obsidian eval code="$(cat /tmp/obs.js)"
   ```
4. **`files` does not support `format=json`** — use `search format=json` for structured output.
5. **`daily:prepend` inserts after frontmatter**, not at byte 0.
6. **Windows**: Must run from normal terminal (not admin). Git Bash needs a wrapper script — see command-reference.md.
7. **Linux headless**: Use `.deb` (not snap), run under xvfb, set `PrivateTmp=false` for systemd.