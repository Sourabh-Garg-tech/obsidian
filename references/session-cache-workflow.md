# Session Hot Cache Workflow

Auto-updates `_context/session-cache.md` after every write operation. Provides FIFO touch log and narrative summary for session continuity.

---

## Cache Format

```markdown
---
type: session-cache
date: 2026-05-09
updated: 2026-05-09T14:23:00
tags: [system]
last-project: swing-signal-engine   # current pinned project for EXTERNAL MODE
---

## Touch Log
- `+` [[Note Name]] (created)
- `~` [[Note Name]] (updated)
- `>` [[Note Name]] (read — decision notes only)

## Session Narrative
- Decision: <summary>
- Thread: <open thread>
- Next: <next action>
```

---

## Rules

- **Touch log**: max 5 entries, FIFO. `+` = created, `~` = updated, `>` = read (decision notes only).
- **Narrative**: max 3 bullets, summarized by Claude after the operation.
- **Stale reset**: If cache is >24h old, clear narrative and start fresh.
- **last-project**: persisted across sessions. Updated when user runs `project <name>` or when EXTERNAL MODE auto-promotes to PROJECT MODE.

---

## Rebuild Script

After `create`, `append`, `move`, `property:set`, or `daily:append`, run this PowerShell script:

```powershell
$cacheRebuildScript = @'
$cache = & obsidian 'read' 'path=_context/session-cache.md'
$lines = $cache -split "`r?`n"
$touch = @()
$narrative = @()
$lastProject = ""
foreach ($l in $lines) {
    if ($l -match '^- \+') { $touch += $l }
    elseif ($l -match '^- ~') { $touch += $l }
    elseif ($l -match '^- >') { $touch += $l }
    elseif ($l -match '^- (Decision|Thread|Next):') { $narrative += $l }
    elseif ($l -match '^last-project:\s*(.+)') { $lastProject = $matches[1] }
}
$touch = @($touch | Select-Object -Last 5)
$narrative = @($narrative | Select-Object -Last 3)
$date = Get-Date -Format 'yyyy-MM-dd'
$updated = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
$touchBlock = if ($touch.Count -gt 0) { [string]::Join("`n", $touch) } else { "" }
$narrBlock = if ($narrative.Count -gt 0) { [string]::Join("`n", $narrative) } else { "" }
$lpLine = if ($lastProject) { "last-project: $lastProject" } else { "" }
$content = @"
---
type: session-cache
date: $date
updated: $updated
tags: [system]
$lpLine
---

## Touch Log
$touchBlock

## Session Narrative
$narrBlock
"@
& obsidian 'create' 'path=_context/session-cache.md' "content=$content" overwrite
'@
$tmpFile = [System.IO.Path]::GetTempFileName() + '.ps1'
Set-Content -Path $tmpFile -Value $cacheRebuildScript
& powershell -ExecutionPolicy Bypass -File $tmpFile
Remove-Item $tmpFile
```

---

## Workflows

### `cache`

```bash
obsidian read path="_context/session-cache.md"
```

### `cache:clear`

```bash
obsidian create path="_context/session-cache.md" content="---\ntype: session-cache\ndate: <today>\nupdated: <today>T00:00:00\ntags: [system]\nlast-project: <preserve-existing>\n---\n\n## Touch Log\n\n## Session Narrative\n" overwrite
```

Note: Preserve `last-project` when clearing so EXTERNAL MODE promotion continues working.
