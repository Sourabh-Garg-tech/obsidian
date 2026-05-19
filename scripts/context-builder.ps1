# context-builder.ps1 - Build minimal context for a task (Windows PowerShell)
# Prerequisites: Obsidian must be running with CLI enabled
# Usage: .\context-builder.ps1 -Task "task description" [[-Vault] <string>] [-Cache] [-Help]

param(
    [string]$Task = "",
    [string]$Vault = "",
    [switch]$Cache,
    [switch]$Help
)

if ($Help) {
    Write-Host "Usage: .\context-builder.ps1 -Task `"task description`" [-Vault <name>] [-Cache]"
    Write-Host ""
    Write-Host "Build minimal context for a task by searching notes, recents, and standing instructions."
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Task     Task description to find context for (required)"
    Write-Host "  -Vault    Optional vault name (defaults to active vault)"
    Write-Host "  -Cache    Include session hot cache in output"
    Write-Host "  -Help     Show this help message"
    exit 0
}

if (-not $Task) {
    Write-Error "Error: -Task is required. Use -Help for usage."
    exit 1
}

if (-not (Get-Command obsidian -ErrorAction SilentlyContinue)) {
    Write-Error "Error: obsidian CLI not found. Ensure Obsidian is running with CLI enabled."
    exit 1
}

$VaultArg = if ($Vault) { "vault=`"$Vault`"" } else { "" }

Write-Host "=== Context Builder ==="
Write-Host "Task: $Task"
Write-Host ""

if ($Cache) {
    Write-Host "--- Session Cache ---"
    $cacheContent = obsidian read path="_context/session-cache.md" $VaultArg 2>$null
    if ($cacheContent) {
        $cacheContent | Select-String -Pattern "^-|##|Decision|Thread|Next" | Select-Object -First 10
    }
    Write-Host ""
}

Write-Host "--- Relevant Notes ---"
# Try obsidian search first; fall back to file search if results are empty
# (search is unreliable on Windows without path=)
$searchResults = obsidian search query="$Task" $VaultArg path="." limit=5 2>$null
$hasResults = $false
if ($searchResults) {
    $trimmed = $searchResults.ToString().Trim()
    if ($trimmed.Length -gt 0) {
        $hasResults = $true
    }
}

if (-not $hasResults) {
    Write-Host "(obsidian search returned no results -- using file search fallback)"
    $vaultPath = obsidian vault $VaultArg 2>$null | Select-Object -First 1
    if ($vaultPath -and (Test-Path $vaultPath)) {
        Get-ChildItem -Path $vaultPath -Filter "*.md" -Recurse |
            Select-String -Pattern $Task -SimpleMatch |
            Select-Object -First 5 |
            ForEach-Object { $_.Path }
    }
} else {
    Write-Host $searchResults
}

Write-Host ""
Write-Host "--- Recently Touched ---"
obsidian recents $VaultArg 2>$null | Select-Object -First 5

Write-Host ""
Write-Host "--- Standing Instructions ---"
$standards = obsidian read file="_context/coding-standards" $VaultArg 2>$null
if ($standards) { $standards | Select-Object -First 20 }
$arch = obsidian read file="_context/architecture" $VaultArg 2>$null
if ($arch) { $arch | Select-Object -First 20 }

Write-Host ""
Write-Host "--- Today's Focus ---"
$daily = obsidian daily:read $VaultArg 2>$null
if ($daily) {
    $daily | Select-String -Pattern "^- \[.\]|##" | Select-Object -First 10
}