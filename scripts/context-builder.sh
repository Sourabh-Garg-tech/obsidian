#!/usr/bin/env bash
set -euo pipefail
# context-builder.sh — Build minimal context for a task
# Prerequisites: Obsidian must be running with CLI enabled
# Usage: ./context-builder.sh [--help] "task description" [vault_name]

show_help() {
  cat <<EOF
Usage: $(basename "$0") [--help] [--cache] "task description" [vault_name]

Build minimal context for a task by searching notes, recents, and standing instructions.

Options:
  --help    Show this help message and exit

Arguments:
  task_description   Description of the task to find context for
  vault_name         Optional vault name (defaults to the active vault)

Flags:
  --cache   Include session hot cache in output
EOF
  exit 0
}

SHOW_CACHE=false

if [ "${1:-}" = "--help" ]; then
  show_help
fi

if [ "${1:-}" = "--cache" ]; then
  SHOW_CACHE=true
  shift
fi

if ! command -v obsidian &>/dev/null; then
  echo "Error: 'obsidian' CLI not found. Ensure Obsidian is running with CLI enabled." >&2
  exit 1
fi

if [ -z "${1:-}" ]; then
  echo "Usage: $0 [--help] [--cache] \"task description\" [vault_name]" >&2
  exit 1
fi

TASK="$1"
VAULT="${2:-}"
VAULT_ARG=""
if [ -n "$VAULT" ]; then
  VAULT_ARG="vault=\"$VAULT\""
fi

if [ -z "$TASK" ]; then
  echo "Usage: $0 [--help] [--cache] \"task description\" [vault_name]"
  exit 1
fi

echo "=== Context Builder ==="
echo "Task: $TASK"
echo ""

if [ "$SHOW_CACHE" = true ]; then
  echo "--- Session Cache ---"
  obsidian read path="_context/session-cache.md" $VAULT_ARG 2>/dev/null | grep -E "^-|##|Decision|Thread|Next" | head -10
  echo ""
fi

echo "--- Relevant Notes ---"
# Try obsidian search first, fall back to grep if results are empty (search is unreliable on Windows)
SEARCH_RESULTS=$(obsidian search query="$TASK" $VAULT_ARG path="." limit=5 2>/dev/null)
if [ -z "$SEARCH_RESULTS" ]; then
  echo "(obsidian search returned no results — using file search fallback)"
  # Find vault root for grep fallback
  VAULT_PATH=$(obsidian vault $VAULT_ARG 2>/dev/null | head -1)
  if [ -n "$VAULT_PATH" ] && [ -d "$VAULT_PATH" ]; then
    grep -r -l -i --include="*.md" "$TASK" "$VAULT_PATH" 2>/dev/null | head -5
  fi
else
  echo "$SEARCH_RESULTS"
fi

echo ""
echo "--- Recently Touched ---"
obsidian recents $VAULT_ARG | head -5

echo ""
echo "--- Standing Instructions ---"
obsidian read file="_context/coding-standards" $VAULT_ARG 2>/dev/null | head -20
obsidian read file="_context/architecture" $VAULT_ARG 2>/dev/null | head -20

echo ""
echo "--- Today's Focus ---"
# Note: grep -E may not be available on Windows natively — use PowerShell Select-String as fallback
if command -v grep &>/dev/null; then
  obsidian daily:read $VAULT_ARG 2>/dev/null | grep -E "^- \[.\]|##" | head -10
else
  obsidian daily:read $VAULT_ARG 2>/dev/null | head -10
fi
