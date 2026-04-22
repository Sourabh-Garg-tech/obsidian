# Quick Reference

Essential Obsidian CLI commands for daily use.

---

```bash
obsidian version                                          # verify CLI
obsidian vaults                                           # list vaults

# Read / Search
obsidian read file="NoteName"                             # read note (wikilink name)
obsidian read path="Folder/Note.md"                      # read by exact path
obsidian search query="keyword"                          # full-text search
obsidian search query="tag:#project"                     # tag search
obsidian search query="keyword" format=json               # JSON output

# Create / Edit
obsidian create name="NoteName" content="# Title"         # create note
obsidian create name="NoteName" template="Template"      # from template
obsidian append  file="NoteName" content="\n- item"      # append content
obsidian prepend file="NoteName" content="text\n"        # prepend after frontmatter

# Move / Delete
obsidian move   file="Draft" to="Archive/"               # auto-rewrites wikilinks
obsidian rename file="Old" name="New"                    # rename + update links
obsidian delete file="NoteName"                           # to system trash

# Properties
obsidian properties file="NoteName"                       # view all
obsidian property:read  file="Note" name="status"         # read one
obsidian property:set   file="Note" name="status" value="done"
obsidian property:set   file="Note" name="tags" value='["a","b"]'
obsidian property:remove file="Note" name="deprecated"

# Daily Notes
obsidian daily                                            # open today's note
obsidian daily:append date="today" content="- [ ] task"   # add to today
obsidian daily:read  date="yesterday"                      # read yesterday

# Tags / Tasks / Links
obsidian tags                                             # all tags
obsidian tag name="#project"                              # notes with tag (use name=)
obsidian tasks                                            # all open tasks
obsidian task file="Note" line=5 toggle                   # toggle task (line= required)
obsidian backlinks path="Folder/Note.md"               # incoming links (use path=, not file=)
obsidian unresolved                                       # broken links
obsidian orphans                                          # unlinked notes

# Plugins / Themes
obsidian plugins                                          # list plugins
obsidian plugin:enable id="dataview"                      # use id= (not plugin=)
obsidian snippet:enable name="style"                     # use name= (not snippet=)

# Vault
obsidian vault                                            # vault info
obsidian recents                                          # recently opened
obsidian outline file="NoteName"                          # heading structure
```

**`file=` vs `path=`:** `file=` resolves by wikilink name (no extension). `path=` is exact from vault root.
