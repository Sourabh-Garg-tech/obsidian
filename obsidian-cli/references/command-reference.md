# Obsidian CLI — Full Command Reference

Complete reference for all official Obsidian CLI commands (v1.12.7+).

**Syntax**: `obsidian [vault] <command> [subcommand] [key=value ...] [flags]`

All parameters use `key=value` syntax. Quote values containing spaces: `content="hello world"`.
Use `--copy` on any command to copy output to clipboard.

---

## Table of Contents

1. [Files](#files)
2. [Daily Notes](#daily-notes)
3. [Search](#search)
4. [Properties](#properties)
5. [Tags](#tags)
6. [Tasks](#tasks)
7. [Links](#links)
8. [Bookmarks](#bookmarks)
9. [Templates](#templates)
10. [Plugins](#plugins)
11. [Sync](#sync)
12. [Publish](#publish)
13. [Themes](#themes)
14. [CSS Snippets](#css-snippets)
15. [Commands & Hotkeys](#commands--hotkeys)
16. [Obsidian Bases](#obsidian-bases)
17. [History](#history)
18. [Workspace & Tabs](#workspace--tabs)
19. [Diff](#diff)
20. [Developer](#developer)
21. [Vault & System](#vault--system)
22. [Other](#other)

---

## Files

### `read`

Read file contents (default: active file).

```bash
obsidian read file="My Note"
obsidian read path="folder/note.md"
obsidian read                   # active file
```

### `create`

Create or overwrite a file.

```bash
obsidian create name="New Note" content="# Title\n\nBody text"
obsidian create path="folder/note" content="# Title"    # path omits .md
obsidian create name="Meeting" template="Meeting Template"
obsidian create name="Note" content="text" open overwrite
obsidian create name="Note" newtab               # open in new tab
```

### `append`

Append content to a file (default: active file).

```bash
obsidian append file="My Note" content="New paragraph"
obsidian append path="folder/note.md" content="text" inline  # no newline
```

### `prepend`

Prepend content after frontmatter (default: active file).

```bash
obsidian prepend file="My Note" content="Status: done\n"
obsidian prepend path="folder/note.md" content="text" inline  # no newline
```

### `move`

Move or rename a file. Automatically updates internal links.

```bash
obsidian move file="Draft" to="Archive/"
obsidian move path="old/note.md" to="new/note.md"
```

### `rename`

Rename a file (extension preserved if omitted). Automatically updates internal links.

```bash
obsidian rename file="OldName" name="NewName"
```

### `delete`

Delete a file (default: system trash).

```bash
obsidian delete file="My Note"
obsidian delete path="folder/note.md" permanent  # bypass trash
```

### `open`

Open a file.

```bash
obsidian open file="My Note"
obsidian open file="My Note" newtab
```

### `files`

List all files in the vault.

```bash
obsidian files                       # all files
obsidian files folder="Projects/"    # filter by folder
obsidian files ext=md                # filter by extension
obsidian files total                  # return count only
```

Note: `format=json` is NOT supported on `files`. Use `search format=json` for structured output.

### `folders`

List all folders in the vault.

```bash
obsidian folders                     # full folder tree
obsidian folders folder="Projects/"  # filter by parent
obsidian folders total                # return count
```

### `folder`

Show folder info.

```bash
obsidian folder path="Projects/"                   # full info
obsidian folder path="Projects/" info=files         # file count only
obsidian folder path="Projects/" info=folders       # subfolder count
obsidian folder path="Projects/" info=size          # total size
```

### `file`

Show file metadata (default: active file).

```bash
obsidian file file="My Note"
# Output: path, name, extension, size (bytes), created (ms), modified (ms)
```

### `random`

Open a random note.

```bash
obsidian random                       # any note
obsidian random folder="Archive/"     # limit to folder
obsidian random newtab                 # open in new tab
```

### `random:read`

Read a random note (includes path, doesn't open it).

```bash
obsidian random:read
obsidian random:read folder="Projects/"
```

---

## Daily Notes

Requires Daily Notes core plugin enabled.

### `daily`

Open today's daily note.

```bash
obsidian daily                              # open today's note
obsidian daily paneType=tab                 # open in new tab
obsidian daily paneType=split              # open in split
obsidian daily paneType=window              # open in new window
```

### `daily:path`

Get daily note path. Returns the expected path even if the file hasn't been created yet.

```bash
obsidian daily:path
```

### `daily:read`

Read daily note contents.

```bash
obsidian daily:read                         # today
```

### `daily:append`

Append content to daily note.

```bash
obsidian daily:append content="- [ ] New task"
obsidian daily:append content="text" inline  # no newline
obsidian daily:append content="text" open     # open after adding
obsidian daily:append content="text" paneType=tab
```

### `daily:prepend`

Prepend content to daily note (after frontmatter).

```bash
obsidian daily:prepend content="## Morning Notes\n"
obsidian daily:prepend content="text" inline
obsidian daily:prepend content="text" open
obsidian daily:prepend content="text" paneType=tab
```

---

## Search

### `search`

Full-text search across the vault.

```bash
obsidian search query="search text"
obsidian search query="text" path="folder"       # scope to folder
obsidian search query="text" limit=10            # limit results
obsidian search query="text" format=json          # JSON output
obsidian search query="text" case                  # case-sensitive
obsidian search query="text" total                 # return match count
```

### `search:context`

Search with matching line context. Returns grep-style `path:line: text` output.

```bash
obsidian search:context query="TODO"
obsidian search:context query="TODO" path="folder"
obsidian search:context query="TODO" limit=10
obsidian search:context query="TODO" format=json
obsidian search:context query="TODO" case
```

### `search:open`

Open search view in Obsidian UI.

```bash
obsidian search:open query="initial query"
```

---

## Properties

### `properties`

List properties in the vault, or for a specific file.

```bash
obsidian properties                            # all properties in vault
obsidian properties file="My Note"             # properties for a file
obsidian properties path="folder/note.md"      # by path
obsidian properties name="status"             # specific property count
obsidian properties active                      # properties for active file
obsidian properties sort=count                  # sort by count
obsidian properties counts                      # include occurrence counts
obsidian properties total                       # return property count
obsidian properties format=yaml|json|tsv       # output format
```

### `property:read`

Read a single property value.

```bash
obsidian property:read file="My Note" name="status"
obsidian property:read path="folder/note.md" name="status"
```

### `property:set`

Set a property on a file (default: active file).

```bash
obsidian property:set name="status" value="done" file="My Note"
obsidian property:set name="priority" value=1 file="My Note"
obsidian property:set name="published" value=true file="My Note"
obsidian property:set name="due" value="2026-05-01" file="My Note"
obsidian property:set name="tags" value='["a","b"]' file="My Note"
obsidian property:set name="status" value="active" type=list file="My Note"
```

Types: `type=text|list|number|checkbox|date|datetime`

> **Important:** `property:set` always stores `value=` as a string. Passing `value="[a, b]"` writes the literal string `[a, b]`, not a YAML array. For true array-typed properties, edit the note's frontmatter directly or use `eval` with the Obsidian API.

### `property:remove`

Remove a property from a file.

```bash
obsidian property:remove file="My Note" name="deprecated_field"
```

### `aliases`

List aliases in the vault, or for a specific file.

```bash
obsidian aliases file="My Note"
obsidian aliases active                       # for active file
obsidian aliases total                         # return alias count
obsidian aliases verbose                       # include file paths
```

---

## Tags

### `tags`

List tags in the vault.

```bash
obsidian tags                                  # all tags
obsidian tags sort=count                        # sort by frequency
obsidian tags counts                             # include tag counts
obsidian tags file="My Note"                    # tags for a file
obsidian tags active                             # tags for active file
obsidian tags total                              # return tag count
obsidian tags format=json|tsv|csv               # output format
```

### `tag`

Get tag info.

```bash
obsidian tag name="project"                    # notes with this tag (no # prefix)
obsidian tag name="project" total              # return count only
obsidian tag name="project" verbose            # include file list
```

> **Note:** `tags:rename` and `tags:remove` do NOT exist. Use `property:set` or `eval` for bulk tag changes.

---

## Tasks

### `tasks`

List tasks in the vault.

```bash
obsidian tasks                                  # all tasks (done + todo)
obsidian tasks all                               # same as above
obsidian tasks done                              # completed only
obsidian tasks todo                              # incomplete only
obsidian tasks daily                              # from daily note
obsidian tasks file="My Note"                    # tasks in a file
obsidian tasks path="folder/"                    # tasks in a folder
obsidian tasks 'status="?"'                     # filter by status character
obsidian tasks active                             # tasks in active file
obsidian tasks verbose                            # grouped by file with line numbers
obsidian tasks total                              # return count
obsidian tasks format=json|tsv|csv               # output format
```

### `task`

Show or update a single task.

```bash
obsidian task file="My Note" line=5             # show task info
obsidian task path="note.md" line=5 toggle      # toggle done/undone
obsidian task file="My Note" line=5 done        # mark as done [x]
obsidian task file="My Note" line=5 todo        # mark as todo [ ]
obsidian task daily line=3 toggle               # toggle in daily note
obsidian task file="My Note" line=8 'status="-"'  # set status character
obsidian task ref="note.md:8" toggle            # by reference (path:line)
```

---

## Links

```bash
obsidian backlinks path="My Note.md"              # incoming links (use path=, not file=)
obsidian backlinks path="My Note.md" counts        # include link counts
obsidian backlinks path="My Note.md" total         # return count
obsidian backlinks path="My Note.md" format=json|tsv|csv

obsidian links path="My Note.md"                  # outgoing links (use path=)
obsidian links path="My Note.md" total

obsidian unresolved                             # all broken links
obsidian unresolved total
obsidian unresolved counts                      # include link counts
obsidian unresolved verbose                     # include source files
obsidian unresolved format=json|tsv|csv

obsidian orphans                                # notes with no incoming links
obsidian orphans total

obsidian deadends                               # notes with no outgoing links
obsidian deadends total
```

---

## Bookmarks

### `bookmarks`

List bookmarks.

```bash
obsidian bookmarks                              # list all
obsidian bookmarks total                        # return count
obsidian bookmarks verbose                      # include bookmark types
obsidian bookmarks format=json|tsv|csv
```

### `bookmark`

Add a bookmark.

```bash
obsidian bookmark file="folder/note.md"                          # bookmark a file
obsidian bookmark file="note.md" subpath="#Heading"              # bookmark a heading
obsidian bookmark folder="projects"                              # bookmark a folder
obsidian bookmark search="query text" title="My Search"          # bookmark a search
obsidian bookmark url="https://example.com" title="Link"         # bookmark a URL
```

---

## Templates

### `templates`

List available templates.

```bash
obsidian templates
obsidian templates total
```

### `template:read`

Read template content.

```bash
obsidian template:read name="Meeting"
obsidian template:read name="Meeting" resolve title="My Note"   # resolve {{date}}, {{time}}, {{title}}
```

### `template:insert`

Insert template into the **currently active file** in the Obsidian UI.

```bash
obsidian template:insert name="Meeting"
```

> **Note:** `template:insert` has no `file=` or `path=` parameter. It inserts into whichever file is active in the Obsidian UI. If no file is open, it returns an error. To create a file from a template, use `obsidian create name="..." template="..."` instead.

---

## Plugins

### `plugins`

List installed plugins.

```bash
obsidian plugins                                # all plugins + enabled state
obsidian plugins filter=core|community          # filter by type
obsidian plugins versions                       # include version numbers
obsidian plugins format=json|tsv|csv
```

### `plugins:enabled`

List enabled plugins only.

```bash
obsidian plugins:enabled
obsidian plugins:enabled filter=core|community
obsidian plugins:enabled versions
obsidian plugins:enabled format=json|tsv|csv
```

### `plugins:restrict`

Toggle or check restricted mode.

```bash
obsidian plugins:restrict                       # show status
obsidian plugins:restrict on                    # enable (disables community plugins)
obsidian plugins:restrict off                   # disable
```

### `plugin`

Get plugin info.

```bash
obsidian plugin id="dataview"                   # info: version, description
```

### `plugin:enable` / `plugin:disable`

```bash
obsidian plugin:enable id="dataview"
obsidian plugin:disable id="dataview"
obsidian plugin:enable id="canvas" filter=core
```

### `plugin:install` / `plugin:uninstall`

```bash
obsidian plugin:install id="templater-obsidian"
obsidian plugin:install id="dataview" enable    # install and enable
obsidian plugin:uninstall id="old-plugin"
```

### `plugin:reload`

Reload a plugin (for developers).

```bash
obsidian plugin:reload id="my-plugin"
```

---

## Sync

Requires Obsidian Sync subscription.

### `sync`

Pause or resume sync.

```bash
obsidian sync                                   # show status summary
obsidian sync on                                # resume
obsidian sync off                               # pause
```

### `sync:status`

Show sync status and usage.

```bash
obsidian sync:status
```

### `sync:history`

List sync version history for a file.

```bash
obsidian sync:history file="My Note"
obsidian sync:history total
```

### `sync:read` / `sync:restore`

Read or restore a sync version.

```bash
obsidian sync:read file="My Note" version=3
obsidian sync:restore file="My Note" version=3
```

### `sync:open`

Open sync history in UI.

```bash
obsidian sync:open file="My Note"
```

### `sync:deleted`

List deleted files in sync.

```bash
obsidian sync:deleted
obsidian sync:deleted total
```

---

## Publish

Requires Obsidian Publish.

### `publish:site`

Show publish site info (slug, URL).

```bash
obsidian publish:site
```

### `publish:list`

List published files.

```bash
obsidian publish:list
obsidian publish:list total
```

### `publish:status`

List publish changes.

```bash
obsidian publish:status
obsidian publish:status total
obsidian publish:status new         # show new files only
obsidian publish:status changed     # show changed files only
obsidian publish:status deleted     # show deleted files only
```

### `publish:add` / `publish:remove` / `publish:open`

```bash
obsidian publish:add file="My Note"              # publish a file
obsidian publish:add changed                     # publish all changed files
obsidian publish:remove file="My Note"           # unpublish a file
obsidian publish:open file="My Note"              # open on published site
```

---

## Themes

### `themes`

```bash
obsidian themes                           # list installed themes
obsidian themes versions                  # include version numbers
```

### `theme`

Show active theme or get info.

```bash
obsidian theme                            # current theme info
obsidian theme name="Minimal"             # details about a theme
```

### `theme:set`

Set active theme.

```bash
obsidian theme:set name="Minimal"         # switch theme
obsidian theme:set name=""                # switch to default
```

### `theme:install` / `theme:uninstall`

```bash
obsidian theme:install name="Minimal"
obsidian theme:install name="Minimal" enable  # install and activate
obsidian theme:uninstall name="Minimal"
```

---

## CSS Snippets

```bash
obsidian snippets                          # list all CSS snippets
obsidian snippets:enabled                  # list enabled snippets
obsidian snippet:enable name="my-style"
obsidian snippet:disable name="my-style"
```

---

## Commands & Hotkeys

### `commands`

List available command IDs.

```bash
obsidian commands
obsidian commands filter="app:"           # filter by ID prefix
```

### `command`

Execute an Obsidian command by ID.

```bash
obsidian command id="app:reload"
obsidian command id="editor:toggle-bold"
```

### `hotkeys`

List hotkeys for all commands.

```bash
obsidian hotkeys
obsidian hotkeys total
obsidian hotkeys verbose                   # show if custom or default
obsidian hotkeys format=json|tsv|csv
```

### `hotkey`

Get hotkey for a command.

```bash
obsidian hotkey id="app:open-settings"
obsidian hotkey id="app:open-settings" verbose
```

---

## Obsidian Bases

### `bases`

List all .base files.

```bash
obsidian bases
```

### `base:views`

List views in a base file.

```bash
obsidian base:views file="Tasks"
obsidian base:views path="folder/Tasks.base"
```

### `base:create`

Create a new item in a base.

```bash
obsidian base:create file="Tasks" name="New Item"
obsidian base:create file="Tasks" name="Item" content="text" open
obsidian base:create path="folder/Tasks.base" view="Open" name="Item" newtab
```

### `base:query`

Query a base and return results.

```bash
obsidian base:query file="Tasks"
obsidian base:query file="Tasks" view="Open Tasks"
obsidian base:query file="Tasks" format=json|csv|tsv|md|paths
obsidian base:query path="folder/Tasks.base" view="Kanban" format=csv
```

---

## History

File version history (File Recovery core plugin).

### `history`

List versions of a file.

```bash
obsidian history file="My Note"
obsidian history path="folder/note.md"
```

### `history:list`

List all files with local history.

```bash
obsidian history:list
```

### `history:read`

Read a local history version.

```bash
obsidian history:read file="My Note"
obsidian history:read file="My Note" version=3      # specific version
```

### `history:restore`

Restore a local history version.

```bash
obsidian history:restore file="My Note" version=3
```

### `history:open`

Open file recovery UI.

```bash
obsidian history:open file="My Note"
```

---

## Workspace & Tabs

### `workspace`

Show workspace tree.

```bash
obsidian workspace
obsidian workspace ids                        # include item IDs
```

### `workspaces`

List saved workspaces.

```bash
obsidian workspaces
obsidian workspaces total
```

### `workspace:save` / `workspace:load` / `workspace:delete`

```bash
obsidian workspace:save name="Focus Mode"
obsidian workspace:load name="Focus Mode"
obsidian workspace:delete name="Focus Mode"
```

### `tabs`

List open tabs.

```bash
obsidian tabs
obsidian tabs ids                             # include tab IDs
```

### `tab:open`

Open a new tab.

```bash
obsidian tab:open file="My Note"
obsidian tab:open view="graph"
obsidian tab:open group=123 file="note.md"
```

---

## Diff

Compare versions from local File recovery and Sync.

```bash
obsidian diff                                  # versions of active file
obsidian diff file="My Note"
obsidian diff file="My Note" from=1             # latest vs current
obsidian diff file="My Note" from=2 to=1       # compare two versions
obsidian diff file="My Note" filter=local      # local versions only
obsidian diff file="My Note" filter=sync       # sync versions only
```

---

## Developer

### `eval`

Execute JavaScript and return result.

```bash
obsidian eval code="app.vault.getFiles().length"
obsidian eval code="app.vault.getMarkdownFiles().map(f => f.path).join('\n')"
```

> **Multiline scripts:** Write to a temp file and use command substitution:
> ```bash
> cat > /tmp/obs.js << 'JS'
> var files = app.vault.getMarkdownFiles();
> files.length;
> JS
> obsidian eval code="$(cat /tmp/obs.js)"
> ```

### `devtools`

Toggle Electron DevTools panel.

```bash
obsidian devtools
```

### `dev:debug`

Attach/detach Chrome DevTools Protocol debugger.

```bash
obsidian dev:debug on                          # attach
obsidian dev:debug off                         # detach
```

### `dev:console`

Show captured console messages.

```bash
obsidian dev:console limit=20                  # last 20 messages
obsidian dev:console level=error               # filter by level
obsidian dev:console clear                     # clear buffer
```

> **Note:** `dev:console` requires `dev:debug on` first.

### `dev:errors`

Show captured JavaScript errors.

```bash
obsidian dev:errors
obsidian dev:errors clear
```

### `dev:screenshot`

Take a screenshot (returns base64 PNG).

```bash
obsidian dev:screenshot path="folder/screenshot.png"  # vault-relative path
```

### `dev:css`

Inspect CSS with source locations.

```bash
obsidian dev:css selector=".workspace-leaf"
obsidian dev:css selector=".workspace-leaf" prop=background-color
```

### `dev:dom`

Query DOM elements.

```bash
obsidian dev:dom selector=".view-content"             # outerHTML of first match
obsidian dev:dom selector=".view-content" all         # all matches
obsidian dev:dom selector=".view-content" text       # text content
obsidian dev:dom selector=".view-content" total       # count
obsidian dev:dom selector=".view-content" attr=class  # attribute value
obsidian dev:dom selector=".view-content" css=color    # CSS property
```

### `dev:cdp`

Run a Chrome DevTools Protocol command.

```bash
obsidian dev:cdp method="Runtime.evaluate" params='{"expression":"1+1"}'
```

### `dev:mobile`

Toggle mobile emulation.

```bash
obsidian dev:mobile on
obsidian dev:mobile off
```

---

## Vault & System

### `vault`

Show vault info.

```bash
obsidian vault                                # full info
obsidian vault info=name                      # specific info (name|path|files|folders|size)
```

### `vaults`

List known vaults.

```bash
obsidian vaults
obsidian vaults total
obsidian vaults verbose                        # include vault paths
```

### `version`

Show Obsidian version.

```bash
obsidian version
```

### `reload` / `restart`

```bash
obsidian reload                               # reload vault (Ctrl+R equivalent)
obsidian restart                               # full restart
```

### `recents`

List recently opened files.

```bash
obsidian recents
obsidian recents total
```

---

## Other

### `outline`

Show heading structure of a file.

```bash
obsidian outline file="My Note"
obsidian outline path="folder/note.md"
obsidian outline format=tree|md|json           # output format
obsidian outline total                          # return heading count
```

### `wordcount`

Count words and characters.

```bash
obsidian wordcount file="My Note"
obsidian wordcount path="folder/note.md"
obsidian wordcount words                        # word count only
obsidian wordcount characters                   # character count only
```

### `web`

Open URL in web viewer.

```bash
obsidian web url="https://example.com"
obsidian web url="https://example.com" newtab
```

### `unique`

Create a unique note (Zettelkasten-style).

```bash
obsidian unique name="Note Name" content="text"
obsidian unique name="Note" open
obsidian unique name="Note" paneType=tab
```

---

## Multi-Vault Usage

Pass the vault name as the first parameter:

```bash
obsidian vault="My Vault" daily:read
obsidian vault="Work" search query="meeting"
```

> **Compatibility note:** On some environments, `obsidian vault="Name" command` returns
> `Error: Command "Name" not found`. If this occurs, omit the vault name — the CLI targets
> the most recently active vault.

---

## Exit Codes

| Code | Meaning |
|---|---|
| 0 | Success |
| 1 | Note or resource not found |
| 2 | Vault not found / Obsidian not running |
| 3 | Invalid parameters |
| 4 | Operation failed (e.g., destination already exists) |

---

## Output Formats

| Format | Description | Best for |
|---|---|---|
| `text` | Plain text (default) | Piping to grep/awk/sed |
| `json` | JSON array or object | Processing with jq, AI agents |
| `csv` | Comma-separated values | Spreadsheet import |
| `tsv` | Tab-separated values | Shell parsing with cut/awk |
| `yaml` | YAML output | Config-style processing |
| `md` | Markdown table | Embedding results in notes |
| `paths` | One path per line | Batch file operations |
| `tree` | Tree view | Visual hierarchy |

Not all formats are supported by every command. Use `text` or `json` when in doubt.

---

## Headless / Server Setup (Linux)

1. Install the `.deb` package (not snap — snap confinement breaks IPC)
2. Install and start xvfb: `Xvfb :5 -screen 0 1920x1080x24 &`
3. Start Obsidian: `DISPLAY=:5 obsidian &`
4. Run CLI: `DISPLAY=:5 obsidian daily:read`
5. Filter stderr: `2>/dev/null` (GPU warnings are harmless)

**Systemd**: Ensure `PrivateTmp=false` so IPC socket is accessible.

---

## Platform Troubleshooting

| Problem | Cause | Fix |
|---|---|---|
| Empty output / hangs | Obsidian not running | Start Obsidian first |
| Command not found | CLI not in PATH | Re-enable CLI in Settings; restart terminal |
| Windows: silent failures | Admin terminal | Use normal-privilege terminal |
| Windows: exit 127 on colon+params | Missing `Obsidian.com` | Reinstall from obsidian.md/download |
| Windows: exit 127 in Git Bash | Resolves to `.exe` not `.com` | Create wrapper: `~/bin/obsidian` → `/c/path/to/Obsidian.com "$@"` |
| Wrong vault | Multi-vault ambiguity | Pass `vault="Name"` explicitly |
| Linux: IPC not found | systemd `PrivateTmp=true` | Set `PrivateTmp=false` |
| Linux: snap issues | Snap confinement | Use `.deb` package |
| `property:set` list is a string | CLI stores value as-is | Edit frontmatter directly or use `eval` |