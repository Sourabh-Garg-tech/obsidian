# Advanced Operations — Vault Refactoring

Bulk operations that restructure or normalize vault content. These combine CLI execution
with Claude's reasoning for decisions that can't be scripted mechanically.

> **Scaling note:** Scripts that loop `obsidian` per-note are fine under ~500 files.
> For larger vaults, use Python with `python-frontmatter` then run `obsidian reload`.

---

## Normalize a Messy Vault

### Step 1: Audit schema inconsistencies

```bash
obsidian files | while read p; do
  obsidian properties path="$p" 2>/dev/null | grep "^[a-z]" | cut -d: -f1
done | sort | uniq -c | sort -rn | head -30
# → Shows which property keys exist and how common they are
```

### Step 2: Rename inconsistent fields

```bash
# Example: "Date" → "created"
obsidian files | while read note; do
  val=$(obsidian property:read file="$note" name="Date" 2>/dev/null)
  if [ -n "$val" ]; then
    obsidian property:set    file="$note" name="created" value="$val"
    obsidian property:remove file="$note" name="Date"
  fi
done
```

### Step 3: Rename tags across vault

Note: `tags:rename` does NOT exist in the CLI. Use property:set loops or eval instead:
```bash
# Rename a tag by updating the tags property on each note that has it
obsidian search query="tag:#Todo" | while read note; do
  obsidian property:set file="$note" name="tags" value='["task"]'
done
```

---

## Merge Duplicate Notes

For content merging decisions, see also `references/intelligence-patterns.md` Pattern 3.

```bash
# Read both notes, combine content, create merged note, then delete originals
content_a=$(obsidian read file="NoteA")
content_b=$(obsidian read file="NoteB")
# → Claude merges content, deduplicates, writes merged version
obsidian create name="Folder/MergedNote" content="$merged_content"
obsidian delete file="NoteA"
obsidian delete file="NoteB"
```

---

## Split a Large Note

```bash
# Read a long note, identify natural split points (H2 headings)
obsidian outline file="LargeNote"
# → Claude identifies which sections should become standalone notes
# → For each section: obsidian create, then replace section with embed ![[NewNote]]
obsidian create name="Folder/Section1" content="$section1_content"
# Update parent note to embed the new file
obsidian append file="LargeNote" content="\n![[Section1]]"
```

---

## PKM Method Detection

Detect which PKM method the user's vault follows, then operate accordingly:

```bash
folders=$(obsidian folders)

if echo "$folders" | grep -qiE "^Projects|^Areas|^Resources|^Archive"; then
  echo "PARA detected"
elif echo "$folders" | grep -qiE "^Fleeting|^Literature|^Permanent|^Evergreen"; then
  echo "Zettelkasten detected"
elif echo "$folders" | grep -qiE "^MOC|^Atlas|^Cards|^Sources"; then
  echo "LYT detected"
else
  echo "Custom structure"
fi
```

Claude adjusts filing decisions based on detected method:
- **PARA**: new note → Projects/, Areas/, Resources/, or Archive/
- **Zettelkasten**: new note → Fleeting/ initially, promote to Permanent/ when mature
- **LYT**: new note → Cards/, link to relevant MOC