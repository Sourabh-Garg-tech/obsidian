# Vault Intelligence Workflows

Automated vault health and connectivity features. Run manually via named workflows or auto-run after ingestion/note creation.

---

## Workflows

### `intelligence`

Full scan combining all four checks below. Run in order:

```bash
obsidian eval code='app.vault.getMarkdownFiles().map(f=>({name:f.basename,count:app.metadataCache.getBacklinksForFile(f).data.size})).filter(x=>x.count>=10).sort((a,b)=>b.count-a.count).slice(0,10).map(x=>x.name+": "+x.count+" backlinks")'
obsidian orphans
obsidian unresolved
# Compare links vs backlinks for each hub
```

### `hubs`

List top 10 hub notes by backlink count:

```bash
obsidian eval code='app.vault.getMarkdownFiles().map(f=>({name:f.basename,count:app.metadataCache.getBacklinksForFile(f).data.size})).filter(x=>x.count>=10).sort((a,b)=>b.count-a.count).slice(0,10).map(x=>x.name+": "+x.count+" backlinks")'
```

Hubs are knowledge graph centers — new notes should likely connect to them.

### `orphans`

Find notes with 0 backlinks and suggest:
- A parent note to link from
- A folder to move to
- Archive if stale

```bash
obsidian orphans
```

### `fix-links`

Scan unresolved links and suggest closest matching existing note:

```bash
obsidian unresolved
# For each broken link, run: obsidian search query="<broken-link-name>" path="." limit=5
```

### `backlinks`

Check for missing bidirectional links. When Note A links to Note B, suggest adding a reverse link if both are in the same domain:

```bash
# For each note with outgoing links
obsidian links path="Folder/Note.md"
# Compare with
obsidian backlinks path="Folder/Note.md"
# Suggest reverse links where backlink count < outgoing link count
```

---

## Auto-Run Rules

| Trigger | Action |
|---------|--------|
| After `ingest` | Hub detection on new notes + missing backlinks check |
| After `create` with wikilinks | Check if linked notes are hubs |
| During `health` | Include orphan count and broken link count |

---

## Metrics in `scripts/vault-health.sh`

The health script includes vault intelligence in its report:

```bash
echo "Broken links:    $(obsidian unresolved total $VAULT_ARG)"
echo "Orphans:         $(obsidian orphans total $VAULT_ARG)"
echo "Dead-ends:       $(obsidian deadends total $VAULT_ARG)"
```

→ See `obsidian-workflows/references/intelligence-patterns.md` for Patterns 15-18
