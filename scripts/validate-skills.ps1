# validate-skills.ps1 - Validate plugin structure, skill definitions, links, and manifests (Windows PowerShell)
# Usage: .\validate-skills.ps1 [-Fix]

param([switch]$Fix)

$ErrorCount = 0
$WarningCount = 0
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

Write-Host "=== Obsidian Skill Suite Validation ==="
Write-Host "Repo: $RepoRoot"
Write-Host ""

# 1. Check plugin structure
Write-Host "--- Plugin Structure ---"

if (-not (Test-Path (Join-Path $RepoRoot "skills"))) {
    Write-Host "  ERROR: skills/ directory missing"
    $ErrorCount++
} else {
    Write-Host "  OK: skills/ directory exists"
}

$trackedClaude = git -C $RepoRoot ls-files --error-unmatch .claude/ 2>$null
if ($trackedClaude) {
    Write-Host "  ERROR: .claude/ directory is tracked by git"
    $ErrorCount++
} else {
    Write-Host "  OK: .claude/ directory is not tracked by git"
}

if (Test-Path (Join-Path $RepoRoot "commands\README.md")) {
    Write-Host "  ERROR: commands/README.md exists"
    $ErrorCount++
} else {
    Write-Host "  OK: commands/README.md not present"
}

$pluginJson = Join-Path $RepoRoot ".claude-plugin\plugin.json"
if (-not (Test-Path $pluginJson)) {
    Write-Host "  ERROR: .claude-plugin/plugin.json missing"
    $ErrorCount++
} else {
    try {
        $null = Get-Content $pluginJson -Raw | ConvertFrom-Json
        Write-Host "  OK: .claude-plugin/plugin.json is valid JSON"
    } catch {
        Write-Host "  ERROR: .claude-plugin/plugin.json is invalid JSON"
        $ErrorCount++
    }
}

$marketplaceJson = Join-Path $RepoRoot ".claude-plugin\marketplace.json"
if (Test-Path $marketplaceJson) {
    try {
        $null = Get-Content $marketplaceJson -Raw | ConvertFrom-Json
        Write-Host "  OK: .claude-plugin/marketplace.json is valid JSON"
    } catch {
        Write-Host "  ERROR: .claude-plugin/marketplace.json is invalid JSON"
        $ErrorCount++
    }
}
Write-Host ""

# 2. Check YAML frontmatter in all SKILL.md files
Write-Host "--- YAML Frontmatter ---"
Get-ChildItem -Path (Join-Path $RepoRoot "skills\*\SKILL.md") | ForEach-Object {
    $relPath = $_.FullName.Substring($RepoRoot.Length + 1)
    $lines = Get-Content $_.FullName

    if ($lines[0] -ne "---") {
        Write-Host "  ERROR: $relPath - missing opening ---"
        $ErrorCount++
        return
    }

    $closingLine = -1
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -eq "---") {
            $closingLine = $i
            break
        }
    }

    if ($closingLine -lt 2) {
        Write-Host "  ERROR: $relPath - missing closing --- in frontmatter"
        $ErrorCount++
        return
    }

    $frontmatter = ($lines[1..($closingLine - 1)] | Out-String)
    $hasName = $frontmatter -match "(?m)^name:"
    $hasDesc = $frontmatter -match "(?m)^description:"

    if (-not $hasName) {
        Write-Host "  ERROR: $relPath - missing name field in frontmatter"
        $ErrorCount++
    }
    if (-not $hasDesc) {
        Write-Host "  ERROR: $relPath - missing description field in frontmatter"
        $ErrorCount++
    }
    if ($hasName -and $hasDesc) {
        Write-Host "  OK: $relPath"
    }
}
Write-Host ""

# 3. Check command files have frontmatter
Write-Host "--- Command Frontmatter ---"
Get-ChildItem -Path (Join-Path $RepoRoot "commands\*.md") | Where-Object { $_.Name -ne "README.md" } | ForEach-Object {
    $relPath = $_.FullName.Substring($RepoRoot.Length + 1)
    $lines = Get-Content $_.FullName

    if ($lines[0] -ne "---") {
        Write-Host "  WARN: $relPath - missing frontmatter"
        $WarningCount++
        return
    }

    $content = Get-Content $_.FullName -Raw
    if ($content -notmatch "(?m)^description:") {
        Write-Host "  WARN: $relPath - missing description in frontmatter"
        $WarningCount++
    } else {
        Write-Host "  OK: $relPath"
    }
}
Write-Host ""

# 4. Check that relative links in markdown resolve to existing files
Write-Host "--- Link Resolution ---"
$allMdFiles = @()
$allMdFiles += Get-ChildItem -Path (Join-Path $RepoRoot "skills\*\SKILL.md") -ErrorAction SilentlyContinue
$allMdFiles += Get-ChildItem -Path (Join-Path $RepoRoot "skills\*\references\*.md") -ErrorAction SilentlyContinue
$allMdFiles += Get-ChildItem -Path (Join-Path $RepoRoot "references\*.md") -ErrorAction SilentlyContinue

foreach ($mdFile in $allMdFiles) {
    if (-not (Test-Path $mdFile.FullName)) { continue }
    $relPath = $mdFile.FullName.Substring($RepoRoot.Length + 1)
    $fileDir = Split-Path $mdFile.FullName -Parent
    $content = Get-Content $mdFile.FullName -Raw

    # Find backtick-quoted .md paths using regex
    $bt = [char]96
    $patternStr = $bt + "([a-zA-Z][a-zA-Z0-9_./-]*\.md)" + $bt
    $regexMatches = [regex]::Matches($content, $patternStr)
    foreach ($m in $regexMatches) {
        $link = $m.Groups[1].Value
        if ($link -match "^https?://") { continue }
        if ($link -match "^#") { continue }
        if ($link -notmatch "^(references|skills|scripts|commands|defuddle|json)") { continue }

        $resolved = Join-Path $fileDir $link
        if (-not (Test-Path $resolved)) {
            $resolved = Join-Path $RepoRoot $link
            if (-not (Test-Path $resolved)) {
                Write-Host "  WARN: $relPath - link does not resolve: $link"
                $WarningCount++
            }
        }
    }
}
Write-Host ""

# 5. Check that CLI commands mentioned in docs exist in command-reference
Write-Host "--- Command Reference ---"
$cmdRef = Join-Path $RepoRoot "skills\obsidian-cli\references\command-reference.md"
if (-not (Test-Path $cmdRef)) {
    Write-Host "  ERROR: command-reference.md not found"
    $ErrorCount++
} else {
    $refContent = Get-Content $cmdRef -Raw
    $keyCommands = @("files", "read", "create", "append", "prepend", "move", "rename", "delete",
        "properties", "property:set", "search", "tags", "tasks", "backlinks", "unresolved",
        "orphans", "daily", "daily:read", "daily:append", "plugins", "plugin:enable", "sync",
        "vault", "recents", "outline")

    foreach ($cmd in $keyCommands) {
        $searchPattern = "obsidian $cmd"
        if ($refContent -notmatch [regex]::Escape($searchPattern)) {
            Write-Host "  WARN: Command 'obsidian $cmd' not found in command-reference.md"
            $WarningCount++
        }
    }
    Write-Host "  OK: Key commands verified in command-reference.md"
}
Write-Host ""

# Summary
Write-Host "=== Summary ==="
Write-Host "Errors:   $ErrorCount"
Write-Host "Warnings: $WarningCount"
if ($ErrorCount -gt 0) {
    Write-Host "FAIL: Fix errors before committing."
    exit 1
} elseif ($WarningCount -gt 0) {
    Write-Host "PASS with warnings. Review warnings above."
    exit 0
} else {
    Write-Host "PASS: All checks passed."
    exit 0
}