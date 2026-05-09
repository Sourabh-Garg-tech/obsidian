# CLI Validation Report

Validated against Obsidian CLI v1.12.7 on Windows, test vault (911 files).
Ground truth: `obsidian help` output + live testing. Last validated: 2026-04-22.

---

## Critical: Commands That Don't Exist

These are documented in the skill but return "Command not found" or wrong behavior:

| Documented Command | Status | Replacement |
|---|---|---|
| `vault:stats` | DOESN'T EXIST | Use `vault` (shows name, path, files, folders, size) |
| `tags:rename tag="#x" to="#y"` | DOESN'T EXIST | No CLI equivalent — must use `eval` or bulk `property:set` |
| `tags:remove tag="#x" file="y"` | DOESN'T EXIST | Use `property:set` to modify tags array, or `eval` |
| `property:types` | DOESN'T EXIST | Use `properties` to list all property names |

---

## Critical: Wrong Parameter Names

| Documented Syntax | Actual Syntax | Tested? |
|---|---|---|
| `tag tag="#project"` | `tag name="project"` | YES — no `#` prefix needed |
| `plugin plugin="dataview"` | `plugin id="dataview"` | YES — confirmed |
| `plugin:enable plugin="x"` | `plugin:enable id="x"` | YES — confirmed |
| `plugin:disable plugin="x"` | `plugin:disable id="x"` | Same pattern |
| `plugin:install plugin="x"` | `plugin:install id="x"` | Same pattern |
| `plugin:uninstall plugin="x"` | `plugin:uninstall id="x"` | Same pattern |
| `snippet:enable snippet="x"` | `snippet:enable name="x"` | YES — confirmed |
| `snippet:disable snippet="x"` | `snippet:disable name="x"` | Same pattern |
| `task file="NoteName"` | `task file="NoteName" line=<n>` | YES — line= required |
| `files path="Projects/"` | `files folder="Projects/"` | YES — `folder=` is canonical (path= also works) |

---

## Wrong: format=json Not Supported Everywhere

| Command | format=json? | Notes |
|---|---|---|
| `search` | YES | Works — returns JSON array |
| `search:context` | YES | Works |
| `tags` | YES | `format=json|tsv|csv` |
| `tasks` | YES | `format=json|tsv|csv` |
| `backlinks` | YES | `format=json|tsv|csv` |
| `bookmarks` | YES | `format=json|tsv|csv` |
| `unresolved` | YES | `format=json|tsv|csv` |
| `properties` | YES | `format=yaml|json|tsv` |
| `plugins` | YES | `format=json|tsv|csv` |
| `files` | NO | Not supported — only `folder=`, `ext=`, `total` |
| `tag` | NO | Returns plain text regardless of format parameter |
| `outline` | PARTIAL | `format=tree|md|json` (not generic json) |

**Impact:** Scripts using `obsidian files format=json | jq` will fail silently.

---

## Missing: Commands Not Documented in Skill

These exist in the CLI but are absent from our skill and command-reference.md:

| Command | Description |
|---|---|
| `commands` | List available Obsidian commands |
| `command id="..."` | Execute any Obsidian command by ID |
| `hotkeys` | List hotkeys |
| `hotkey id="..."` | Get hotkey for a command |
| `open file="..."` | Open a file (with `newtab` option) |
| `random:read` | Read a random note (vs `random` which only opens) |
| `folder path="..."` | Show folder info (different from `folders`) |
| `search:open query="..."` | Open search view |
| `sync:open` | Open sync history view |
| `history:open` | Open file recovery |
| `plugins:enabled` | List enabled plugins specifically |
| `plugin:reload id="..."` | Reload a plugin (dev use) |
| `dev:cdp` | Chrome DevTools Protocol commands |
| `dev:mobile` | Toggle mobile emulation |
| `dev:console` | Show captured console messages |
| `property:set type=list|number|...` | `type=` parameter for property type coercion |

---

## Missing: Useful Flags/Params Not Documented

| Command | Missing Param | Value |
|---|---|---|
| `tasks` | `verbose` | Group by file with line numbers |
| `tasks` | `done` / `todo` | Filter by completion status |
| `tasks` | `daily` | Show tasks from daily note |
| `tasks` | `status="<char>"` | Filter by status character |
| `tasks` | `active` | Show tasks for active file |
| `tags` | `active` | Show tags for active file |
| `tags` | `file=` / `path=` | Show tags for specific file |
| `outline` | `format=md|json` | Output in markdown or JSON format |
| `backlinks` | `counts` / `total` | Include counts, return total |
| `bookmarks` | `verbose` / `total` | Include types, return count |
| `orphans` | `total` / `all` | Return count, include non-md |
| `deadends` | `total` / `all` | Return count, include non-md |
| `unresolved` | `counts` / `verbose` | Include counts, include sources |
| `recents` | `total` | Return count |
| `wordcount` | `words` / `characters` | Return specific count only |
| `vault` | `info=name|path|files|folders|size` | Return specific info |
| `files` | `ext=<extension>` | Filter by extension |
| `diff` | `filter=local|sync` | Filter by version source |
| `create` | `overwrite` / `newtab` | Overwrite existing, open in new tab |
| `daily` | `paneType=tab|split|window` | Open in specific pane |
| `daily:append` / `daily:prepend` | `inline` | Append/prepend without newline |
| `property:set` | `type=text|list|number|checkbox|date|datetime` | Explicit property type |

---

## Official CLI Page vs Skill

The official https://obsidian.md/cli page documents only ~18 commands. The CLI actually has 80+.
Our skill documents 130+ commands — some of which don't exist (vault:stats, tags:rename, tags:remove, property:types).

---

## Recommended Fixes (Priority Order)

### P0 — Commands that will fail at runtime
1. Replace `vault:stats` with `vault` everywhere
2. Replace `tag tag=` with `tag name=` everywhere
3. Replace `plugin plugin=` with `plugin id=` everywhere (and all plugin: subcommands)
4. Replace `snippet:enable snippet=` with `snippet:enable name=` everywhere
5. Remove `tags:rename` and `tags:remove` — document alternatives via `eval` or `property:set`
6. Remove `property:types` — not a real command
7. Fix `task file="NoteName"` — document that `line=` is required
8. Remove `files format=json` — not supported, fix all scripts using it

### P1 — Commands that will produce wrong results
9. Replace `files path=` with `files folder=` (path= works but folder= is canonical)
10. Document that `format=json` only works on specific commands (see table above)
11. Fix `outline` to show `format=tree|md|json` options

### P2 — Missing commands that add real value
12. Add `commands` / `command id=` — powerful for executing any Obsidian action
13. Add `tasks verbose` / `tasks done` / `tasks todo` / `tasks daily` flags
14. Add `property:set type=` parameter
15. Add `open` command with `newtab`
16. Add `random:read` command
17. Add `plugin:reload id=` for dev use
18. Add `vault info=name|path|files|folders|size` alternatives

---

## Additional Findings (from background agent)

### Developer commands: `selector=` not `file=`
The official CLI uses `selector=` (CSS selector) for `dev:css` and `dev:dom`, not `file=`:
- `obsidian dev:css selector=".workspace"` (NOT `dev:css file="NoteName"`)
- `obsidian dev:dom selector=".nav"` (NOT `dev:dom file="NoteName"`)
- `obsidian dev:screenshot path="shot.png"` (saves to file path, not note)

### `eval` syntax
Both syntaxes appear to work: positional `obsidian eval "expression"` and named `obsidian eval code="expression"`.

### Property search syntax
Official docs: `obsidian search query="status::active"` (double colon)
Our skill: `obsidian search query="[status:done]"` (Dataview-style brackets + single colon)
Both may work — needs testing.

### `vault=` parameter position
Changelog says `vault=` "must be the first argument." Our skill shows it at the end. May work either way but canonical position is first.

### Version note
CLI v1.12.7 introduced a new dedicated CLI binary that is "significantly faster." ~~Our skill states v1.12.4+ compatibility — should update to recommend v1.12.7+.~~ **(Fixed: All SKILL.md files and references updated to v1.12.7+.)**

### `silent` parameter deprecated
`open` replaced `silent` in v1.12.2. Our command-reference.md still shows `obsidian append ... silent` — should use `open` instead. **(Fixed: command-reference.md now uses `open`.)**

---

## 2026-04-22 Validation Update

Re-tested against v1.12.7 on Windows (911-file vault). Key findings:

### Windows Git Bash: colon commands fail (exit code 127)

Commands with `:` in the name fail in Git Bash on Windows because `:` is interpreted as a path separator:

- `property:read`, `property:set`, `property:remove`
- `daily:read`, `daily:append`, `daily:prepend`, `daily:path`
- `plugin:enable`, `plugin:disable`, `plugin:install`, `plugin:uninstall`, `plugin:reload`
- `snippet:enable`, `snippet:disable`
- `base:create`, `base:query`, `base:views`
- `history:list`, `history:open`, `history:read`, `history:restore`
- `theme:set`, `theme:install`, `theme:uninstall`
- `template:insert`, `template:read`
- `tab:open`
- `search:context`, `search:open`
- `sync:status`, `sync:open`, `sync:history`, `sync:read`, `sync:restore`, `sync:deleted`
- `dev:debug`, `dev:console`, `dev:errors`, `dev:css`, `dev:dom`, `dev:cdp`, `dev:mobile`, `dev:screenshot`
- `workspace:save`, `workspace:load`, `workspace:delete`

**Workaround:** Run `cmd /c "obsidian property:read ..."` or use PowerShell.

### `tag name=` does not accept `#` prefix

Using `name="#project"` returns empty results. Use `name="project"` without the hash.
**(Fixed in all docs.)**

### `tag` does not support `format=json`

The `tag` command ignores the `format=json` parameter and returns plain text regardless.
**(Added to format=json warning in safety rules.)**

### `links file=` unreliable on Windows

Same issue as `backlinks file=` — use `path=` instead.
**(Added to safety rule 10.)**

### `search` without `path=` is inconsistent on Windows

Returns results for some queries (e.g., "vault") but empty for others (e.g., "test", "trading") without `path=`. Always use `path=` on Windows.

### `commands` returns empty

`obsidian commands` returns empty output, but `obsidian command id="..."` works. Likely requires specific conditions.

### `unresolved` returns empty

May indicate no unresolved links in the test vault, or a Windows-specific issue.