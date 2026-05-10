# Frontmatter Schema — Audit Reference

Required and optional frontmatter properties for vault health audits. This reference defines what the audit checks for and how to fix violations.

---

## Required Properties (All Notes)

Every `.md` file in the vault must have these properties in its frontmatter:

| Property | Type | Example | Audit Fix |
|---|---|---|---|
| `tags` | list | `["project", "auth"]` | Add `tags: ["untagged"]` if missing |
| `created` | date | `2026-04-21` | Add `created: <today>` if missing |
| `updated` | date | `2026-04-21` | Add `updated: <today>` if missing |

### Type Validation Rules

| Property | Valid format | Invalid examples |
|---|---|---|
| `tags` | YAML list `["a", "b"]` | String `"a, b"`, bare `tag` (singular) |
| `created` | `YYYY-MM-DD` or `YYYY-MM-DDTHH:MM` | `April 21`, `21/04/2026` |
| `updated` | `YYYY-MM-DD` or `YYYY-MM-DDTHH:MM` | `April 21`, `21/04/2026` |

---

## Required Properties Per Note Type

### `_context/` notes

| Property | Required | Value |
|---|---|---|
| `type` | Yes | `context` |
| `updated` | Yes | ISO date |

### `_summaries/` notes

| Property | Required | Value |
|---|---|---|
| `type` | Yes | `summary` |
| `updated` | Yes | ISO date |

### `Projects/**/README.md`

| Property | Required | Value |
|---|---|---|
| `type` | Yes | `project` |
| `status` | Yes | `active`, `paused`, or `done` |
| `tags` | Yes | list |
| `created` | Yes | ISO date |
| `updated` | Yes | ISO date |

### `Daily Notes/` notes

| Property | Required | Value |
|---|---|---|
| `type` | Yes | `daily` |

### `Inbox/` notes

| Property | Required | Value |
|---|---|---|
| `type` | Yes | `inbox` |

---

## Invalid Properties to Flag

These are common mistakes that the audit should catch:

| Invalid property | Correct form | Why |
|---|---|---|
| `alias` | `aliases` | Obsidian expects plural list |
| `tag` | `tags` | Obsidian expects plural list |
| `date` | `created` or `updated` | Ambiguous — be explicit |
| `Date` | `created` | Inconsistent capitalization |
| `title` (in frontmatter) | Often redundant with filename | Only flag if it differs from wikilink name |

---

## Audit Check Commands

```bash
# Find notes missing frontmatter entirely
obsidian files | while read p; do
  obsidian properties path="$p" 2>/dev/null || echo "NO-FRONTMATTER: $p"
done

# Find notes missing 'tags' property
obsidian files | while read p; do
  tags=$(obsidian property:read path="$p" name="tags" 2>/dev/null)
  [ -z "$tags" ] && echo "MISSING-TAGS: $p"
done

# Find notes with invalid property names
obsidian files | while read p; do
  obsidian properties path="$p" 2>/dev/null | grep -E "^(alias|tag|date|Date):" && echo "INVALID-PROP: $p"
done
```

---

## Bulk Fix Script

For vaults with more than 5 notes missing properties, use a Python script instead of individual `property:set` calls:

```python
#!/usr/bin/env python3
"""Add missing frontmatter properties to vault notes."""
import frontmatter
import glob
import datetime

today = datetime.date.today().isoformat()
vault_path = "."  # run from vault root

for path in glob.glob(f"{vault_path}/**/*.md", recursive=True):
    post = frontmatter.load(path)

    # Add missing tags
    if "tags" not in post:
        post["tags"] = ["untagged"]

    # Add missing created
    if "created" not in post:
        post["created"] = today

    # Add missing updated
    if "updated" not in post:
        post["updated"] = today

    # Fix singular 'tag' → 'tags'
    if "tag" in post and "tags" not in post:
        val = post["tag"]
        post["tags"] = [val] if isinstance(val, str) else val
        del post["tag"]

    # Fix singular 'alias' → 'aliases'
    if "alias" in post and "aliases" not in post:
        val = post["alias"]
        post["aliases"] = [val] if isinstance(val, str) else val
        del post["alias"]

    # Fix 'date' → 'created'
    if "date" in post and "created" not in post:
        post["created"] = post["date"]
        del post["date"]

    # Fix 'Date' → 'created'
    if "Date" in post and "created" not in post:
        post["created"] = post["Date"]
        del post["Date"]

    with open(path, "w") as f:
        frontmatter.dump(post, f)
```

After running: `obsidian reload`