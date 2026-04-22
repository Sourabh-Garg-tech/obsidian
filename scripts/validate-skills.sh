#!/usr/bin/env bash
# validate-skills.sh — Validate skill definitions, links, and command references
# Usage: ./scripts/validate-skills.sh [--fix]
#   --fix  Attempt to fix common issues (currently: none auto-fixed)

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

# 1. Check YAML frontmatter in all SKILL.md files
echo "--- YAML Frontmatter ---"
for skill_file in "$REPO_ROOT"/SKILL.md "$REPO_ROOT"/*/SKILL.md; do
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

# 2. Check that relative links in markdown resolve to existing files
echo "--- Link Resolution ---"
for md_file in "$REPO_ROOT"/SKILL.md "$REPO_ROOT"/*/SKILL.md "$REPO_ROOT"/references/*.md "$REPO_ROOT"/*/references/*.md; do
  if [[ ! -f "$md_file" ]]; then
    continue
  fi
  rel_path="${md_file#$REPO_ROOT/}"
  file_dir="$(dirname "$md_file")"

  # Find backtick-quoted paths (used for reference file pointers)
  # Use sed instead of grep -P for Windows compatibility
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
  # Only check paths that look like real references (start with known prefixes or contain /)
  # Skip placeholder examples like "folder/note.md"
  done < <(sed -n 's/.*`\([a-zA-Z][a-zA-Z0-9_./-]*\.md\)`.*/\1/p' "$md_file" | grep -E '^(references|obsidian|scripts|commands|defuddle|json)' | sort -u 2>/dev/null || true)
done
echo ""

# 3. Check that CLI commands mentioned in docs exist in command-reference
echo "--- Command Reference ---"
CMD_REF="$REPO_ROOT/obsidian-cli/references/command-reference.md"
if [[ ! -f "$CMD_REF" ]]; then
  echo "  ERROR: command-reference.md not found at $CMD_REF"
  ((ERRORS++))
else
  # Extract command names from command-reference (sed instead of grep -P for portability)
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

# 4. Check compatibility frontmatter
echo "--- Compatibility Frontmatter ---"
for skill_file in "$REPO_ROOT"/SKILL.md "$REPO_ROOT"/*/SKILL.md; do
  if [[ ! -f "$skill_file" ]]; then
    continue
  fi
  rel_path="${skill_file#$REPO_ROOT/}"

  if grep -q "^compatibility:" "$skill_file"; then
    echo "  OK: $rel_path — has compatibility field"
  else
    echo "  WARN: $rel_path — missing compatibility field"
    ((WARNINGS++))
  fi
done
echo ""

# 5. Check that sub-skill directories have README.md
echo "--- Sub-skill READMEs ---"
for skill_dir in "$REPO_ROOT"/*/; do
  skill_name="$(basename "$skill_dir")"
  # Skip non-skill directories
  if [[ ! -f "$skill_dir/SKILL.md" ]]; then
    continue
  fi
  if [[ -f "$skill_dir/README.md" ]]; then
    echo "  OK: $skill_name/README.md"
  else
    echo "  WARN: $skill_name/ — missing README.md"
    ((WARNINGS++))
  fi
done
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