# vault-health.ps1 — Comprehensive vault health check (Windows PowerShell)
# Prerequisites: Obsidian must be running with CLI enabled
# Usage: .\vault-health.ps1 [[-Vault] <string>] [-Help]

param(
    [string]$Vault = "",
    [switch]$Help
)

if ($Help) {
    Write-Host "Usage: .\vault-health.ps1 [[-Vault] <vault_name>]"
    Write-Host ""
    Write-Host "Comprehensive vault health check: totals, graph health, orphans, and broken links."
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Vault <name>   Optional vault name (defaults to active vault)"
    Write-Host "  -Help           Show this help message"
    exit 0
}

if (-not (Get-Command obsidian -ErrorAction SilentlyContinue)) {
    Write-Error "Error: 'obsidian' CLI not found. Ensure Obsidian is running with CLI enabled."
    exit 1
}

$VaultArg = if ($Vault) { "vault=`"$Vault`"" } else { "" }

Write-Host "=== Vault Health Report ==="
Write-Host "Run at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host ""

Write-Host "--- Totals ---"
$notesTotal = obsidian files total $VaultArg 2>$null
$tagsTotal = obsidian tags total $VaultArg 2>$null
$tasksTotal = obsidian tasks total $VaultArg 2>$null
Write-Host "Notes:    $notesTotal"
Write-Host "Tags:     $tagsTotal"
Write-Host "Tasks:    $tasksTotal"

Write-Host ""
Write-Host "--- Graph Health ---"
$brokenLinks = obsidian unresolved total $VaultArg 2>$null
$orphans = obsidian orphans total $VaultArg 2>$null
$deadends = obsidian deadends total $VaultArg 2>$null
Write-Host "Broken links:    $brokenLinks"
Write-Host "Orphans:         $orphans"
Write-Host "Dead-ends:       $deadends"

Write-Host ""
Write-Host "Top hubs (5+ backlinks):"
$hubs = obsidian eval code='app.vault.getMarkdownFiles().slice(0,500).map(f=>({name:f.basename,count:app.metadataCache.getBacklinksForFile(f).data.size})).filter(x=>x.count>=5).sort((a,b)=>b.count-a.count).slice(0,5).map(x=>x.name+": "+x.count+" backlinks")' $VaultArg 2>$null
if ($LASTEXITCODE -eq 0 -and $hubs) {
    Write-Host $hubs
} else {
    Write-Host "  (eval not available)"
}

Write-Host ""
Write-Host "--- Detailed ---"
Write-Host "Unresolved links:"
obsidian unresolved $VaultArg 2>$null | Select-Object -First 20

Write-Host ""
Write-Host "Orphan notes:"
obsidian orphans $VaultArg 2>$null | Select-Object -First 20

Write-Host ""
Write-Host "--- Done ---"