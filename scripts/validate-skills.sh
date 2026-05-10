#!/usr/bin/env bash
# validate-skills.sh — Validate plugin structure, skill definitions, links, and manifests
# Usage: ./scripts/validate-skills.sh [--fix]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FIX_MODE=false
ERRORS=0
WARNINGS=0

if [[ "${1:-}" == "--fix" ]]; then
  FIX_MODE=true
fi

echo "=== Obsidian Skill Suite Validation ==="
echo "Repo: $REPO_ROOT"
echo ""

# 1. Check plugin structure
echo "--- Plugin Structure ---"

# 1a. Check skills/ directory exists
if [[ ! -d "$REPO_ROOT/skills" ]]; then
  echo "  ERROR: skills/ directory missing — Claude Code will not discover any skills"
  ((ERRORS++))
else
  echo "  OK: skills/ directory exists"
fi

# 1b. Check .claude/ directory is not tracked by git (triggers bug #44120)
if git -C "$REPO_ROOT" ls-files --error-unmatch .claude/ 2>/dev/null | grep -q .; then
  echo "  ERROR: .claude/ directory is tracked by git — this breaks skill discovery"
  ((ERRORS++))
else
  echo "  OK: .claude/ directory is not tracked by git"
fi

# 1c. Check commands/ has no README.md
if [[ -f "$REPO_ROOT/commands/README.md" ]]; then
  echo "  ERROR: commands/README.md exists — Claude Code registers it as /obsidian:README"
  ((ERRORS++))
else
  echo "  OK: commands/README.md not present"
fi

# 1d. Check plugin.json exists and is valid JSON
if [[ ! -f "$REPO_ROOT/.claude-plugin/plugin.json" ]]; then
  echo "  ERROR: .claude-plugin/plugin.json missing"
  ((ERRORS++))
else
  if python3 -c "import json,sys; f=open(sys.argv[1]); json.load(f)" "$REPO_ROOT/.claude-plugin/plugin.json" 2>/dev/null; then
    echo "  OK: .claude-plugin/plugin.json is valid JSON"
  else
    echo "  ERROR: .claude-plugin/plugin.json is invalid JSON"
    ((ERRORS++))
  fi
fi

# 1e. Check marketplace.json exists and is valid JSON
if [[ -f "$REPO_ROOT/.claude-plugin/marketplace.json" ]]; then
  if python3 -c "import json,sys; f=open(sys.argv[1]); json.load(f)" "$REPO_ROOT/.claude-plugin/marketplace.json" 2>/dev/null; then
    echo "  OK: .claude-plugin/marketplace.json is valid JSON"
  else
    echo "  ERROR: .claude-plugin/marketplace.json is invalid JSON"
    ((ERRORS++))
  fi
fi
echo ""

# 2. Check YAML frontmatter in all SKILL.md files
echo "--- YAML Frontmatter ---"
for skill_file in "$REPO_ROOT"/skills/*/SKILL.md; do
  if [[ ! -f "$skill_file" ]]; then
    continue
  fi
  rel_path="${skill_file#$REPO_ROOT/}"

  # Check that frontmatter starts with --- and ends with ---
  first_line=$(head -1 "$skill_file")
  if [[ "$first_line" != "---" ]]; then
    echo "  ERROR: $rel_path — missing opening ---"
    ((ERRORS++))
    continue
  fi

  # Find closing ---
  closing_line=$(grep -n "^---$" "$skill_file" | tail -1 | cut -d: -f1)
  if [[ -z "$closing_line" ]] || [[ "$closing_line" -lt 3 ]]; then
    echo "  ERROR: $rel_path — missing closing --- in frontmatter"
    ((ERRORS++))
    continue
  fi

  # Extract and validate YAML fields
  frontmatter=$(sed -n "2,$((closing_line - 1))p" "$skill_file")

  # Check name field
  if ! echo "$frontmatter" | grep -q "^name:"; then
    echo "  ERROR: $rel_path — missing 'name' field in frontmatter"
    ((ERRORS++))
  fi

  # Check description field
  if ! echo "$frontmatter" | grep -q "^description:"; then
    echo "  ERROR: $rel_path — missing 'description' field in frontmatter"
    ((ERRORS++))
  fi

  echo "  OK: $rel_path"
done
echo ""

# 3. Check command files have frontmatter
echo "--- Command Frontmatter ---"
for cmd_file in "$REPO_ROOT"/commands/*.md; do
  if [[ ! -f "$cmd_file" ]]; then
    continue
  fi
  rel_path="${cmd_file#$REPO_ROOT/}"

  # Skip README (shouldn't exist, but just in case)
  if [[ "$(basename "$cmd_file")" == "README.md" ]]; then
    continue
  fi

  # Check frontmatter
  first_line=$(head -1 "$cmd_file")
  if [[ "$first_line" != "---" ]]; then
    echo "  WARN: $rel_path — missing frontmatter (commands need description for /help)"
    ((WARNINGS++))
    continue
  fi

  # Check description field
  if ! grep -q "^description:" "$cmd_file"; then
    echo "  WARN: $rel_path — missing 'description' in frontmatter"
    ((WARNINGS++))
  else
    echo "  OK: $rel_path"
  fi
done
echo ""

# 4. Check that relative links in markdown resolve to existing files
echo "--- Link Resolution ---"
for md_file in "$REPO_ROOT"/skills/*/SKILL.md "$REPO_ROOT"/skills/*/references/*.md "$REPO_ROOT"/references/*.md; do
  if [[ ! -f "$md_file" ]]; then
    continue
  fi
  rel_path="${md_file#$REPO_ROOT/}"
  file_dir="$(dirname "$md_file")"

  # Find backtick-quoted paths
  while IFS= read -r link; do
    # Skip URLs (http/https)
    if [[ "$link" =~ ^https?:// ]]; then
      continue
    fi
    # Skip anchor-only links
    if [[ "$link" =~ ^# ]]; then
      continue
    fi

    # Resolve path relative to the file's directory
    resolved="$file_dir/$link"
    if [[ ! -f "$resolved" ]]; then
      # Try from repo root
      resolved="$REPO_ROOT/$link"
      if [[ ! -f "$resolved" ]]; then
        echo "  WARN: $rel_path — link does not resolve: $link"
        ((WARNINGS++))
      fi
    fi
  # Only check paths that look like real references
  done < <(sed -n 's/.*`\([a-zA-Z][a-zA-Z0-9_./-]*\.md\)`.*/\1/p' "$md_file" | grep -E '^(references|skills|scripts|commands|defuddle|json)' | sort -u 2>/dev/null || true)
done
echo ""

# 5. Check that CLI commands mentioned in docs exist in command-reference
echo "--- Command Reference ---"
CMD_REF="$REPO_ROOT/skills/obsidian-cli/references/command-reference.md"
if [[ ! -f "$CMD_REF" ]]; then
  echo "  ERROR: command-reference.md not found at $CMD_REF"
  ((ERRORS++))
else
  # Extract command names from command-reference
  declared_commands=$(sed -n 's/.*obsidian \([a-z][a-z:]*\).*/\1/p' "$CMD_REF" | sort -u)

  # Check key commands exist
  for cmd in files read create append prepend move rename delete properties "property:set" search tags tasks backlinks unresolved orphans daily "daily:read" "daily:append" plugins "plugin:enable" sync vault recents outline; do
    if ! echo "$declared_commands" | grep -q "^${cmd}$"; then
      echo "  WARN: Command 'obsidian $cmd' not found in command-reference.md"
      ((WARNINGS++))
    fi
  done
  echo "  OK: Key commands verified in command-reference.md"
fi
echo ""

# Summary
echo "=== Summary ==="
echo "Errors:   $ERRORS"
echo "Warnings: $WARNINGS"
if [[ $ERRORS -gt 0 ]]; then
  echo "FAIL: Fix errors before committing."
  exit 1
elif [[ $WARNINGS -gt 0 ]]; then
  echo "PASS with warnings. Review warnings above."
  exit 0
else
  echo "PASS: All checks passed."
  exit 0
fi
