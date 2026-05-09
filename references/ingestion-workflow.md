# Source Ingestion Workflow

Ingest external sources into the vault with preview-gated note creation.

---

## Flow

```text
# Ingest a URL
/obsidian ingest https://example.com/article

# Ingest a local file
/obsidian ingest path="Downloads/article.md"
```

**Steps:**

1. **Extract** — get clean markdown (URL → defuddle sub-skill, file → obsidian read)
2. **Analyze** — identify entities, concepts, decisions, open questions
3. **Preview** — show proposed notes, tags, cross-links to user
4. **Approve** — user confirms or vetoes individual notes
5. **Execute** — `obsidian create` for approved notes
6. **Index** — update `Sources/` index note with `source:` frontmatter

---

## Token Budget

| Phase | Tokens |
|---|---|
| Extraction + analysis | ~1,500 |
| Preview display | ~200 |
| Execution | ~100 per note |

For sources >5,000 words, summarize before entity extraction.

---

## Auto-Run After Ingest

After successful ingestion:

1. Run hub detection on newly created notes
2. Check for missing backlinks between new notes and existing vault
3. Update `Sources/` index note

→ See `obsidian-workflows/references/intelligence-patterns.md` for Pattern 14: Source Ingestion
