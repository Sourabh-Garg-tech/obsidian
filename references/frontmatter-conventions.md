# Obsidian Frontmatter Schema Conventions

Use when setting up a new vault schema or bulk-normalizing properties.

---

## Core Fields

```yaml
---
title: "Human-readable note title"
aliases:
  - "alternate name"
  - "abbreviation"
tags:
  - project
  - active
created: 2026-04-15
modified: 2026-04-19
---
```

**Rules:**
- `tags` — array, no `#` prefix (the `#` is implicit in frontmatter)
- `created` / `modified` — ISO date `YYYY-MM-DD` or datetime `YYYY-MM-DDTHH:MM`
- `aliases` — array; Obsidian uses these for wikilink matching

---

## Status & Workflow

```yaml
status: "draft"          # draft | active | review | done | archived | someday
priority: 1              # 1 (high) / 2 (medium) / 3 (low)
due: 2026-05-01
completed: 2026-04-19
effort: "M"              # XS / S / M / L / XL
```

---

## Classification (PARA / LYT / GTD)

```yaml
# PARA method
type: "project"           # project | area | resource | archive

# Areas of responsibility
area: "health"            # health | finance | career | learning | relationships

# LYT (Linking Your Thinking)
note_type: "evergreen"    # fleeting | literature | evergreen | moc | structure

# GTD contexts
context: "@computer"      # @computer | @phone | @home | @errands | @office
energy: "high"            # high | medium | low
```

---

## Reference & Source

```yaml
source: "https://example.com"
author: "Author Name"
published: 2026-01-10
isbn: "978-0-000-00000-0"
type: "book"              # book | article | video | podcast | paper
rating: 4                 # 1-5
```

---

## Relationships

```yaml
project: "[[ProjectAlpha]]"
related:
  - "[[NoteA]]"
  - "[[NoteB]]"
parent: "[[ParentNote]]"
up: "[[MOC - Topic]]"         # LYT: up-link to structure note
```

---

## Dataview-Compatible Patterns

Dataview parses specific types for querying:

```yaml
# Dates → parsed as date objects for comparison
date: 2026-04-15
due: 2026-05-01

# Booleans → not quoted
published: true
archived: false

# Numbers → not quoted, used in math/sorting
rating: 4
word_count: 1250
sprint: 12

# Wikilinks in arrays → Dataview recognizes [[link]] inside arrays
people:
  - "[[Alice]]"
  - "[[Bob]]"
blockers:
  - "[[Issue-47]]"
```

---

## Normalizing Properties via CLI

```bash
# Rename a property across all notes
obsidian files | while read note; do
  old_val=$(obsidian property:read file="$note" name="old_field" 2>/dev/null)
  if [ -n "$old_val" ]; then
    obsidian property:set    file="$note" name="new_field" value="$old_val"
    obsidian property:remove file="$note" name="old_field"
  fi
done

# Ensure all Project notes have a status
obsidian files folder="Projects/" | while read note; do
  existing=$(obsidian property:read file="$note" name="status" 2>/dev/null)
  [ -z "$existing" ] && obsidian property:set file="$note" name="status" value="active"
done

# Audit: list all unique property keys in vault
obsidian files | while read path; do
  obsidian properties path="$path" 2>/dev/null | grep "^[a-z]" | cut -d: -f1
done | sort -u

# Find notes missing required fields
obsidian files folder="Projects/" | while read note; do
  status=$(obsidian property:read file="$note" name="status" 2>/dev/null)
  [ -z "$status" ] && echo "MISSING status: $note"
done
```

---

## Anti-Patterns to Avoid

- **No `#` in frontmatter tags** — use `project` not `#project`
- **No spaces in tag names** — use `project-alpha` or `projectAlpha`
- **Don't mix `date` and `created`** — pick one and normalize vault-wide
- **Don't use deeply nested YAML objects** — Dataview handles flat structures better
- **Don't store wikilinks as bare strings** — use `"[[Note]]"` format so Obsidian resolves them
- **Don't hardcode full paths in links** — use note names, not `Folder/Note.md`
