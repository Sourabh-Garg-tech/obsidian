#!/usr/bin/env bash
set -euo pipefail
# context-builder.sh — Build minimal context for a task
# Prerequisites: Obsidian must be running with CLI enabled
# Usage: ./context-builder.sh [--help] "task description" [vault_name]

show_help() {
  cat <<EOF
Usage: $(basename "$0") [--help] "task description" [vault_name]

Build minimal context for a task by searching notes, recents, and standing instructions.

Options:
  --help    Show this help message and exit

Arguments:
  task_description   Description of the task to find context for
  vault_name         Optional vault name (defaults to the active vault)
EOF
  exit 0
}

if [ "${1:-}" = "--help" ]; then
  show_help
fi

if ! command -v obsidian &>/dev/null; then
  echo "Error: 'obsidian' CLI not found. Ensure Obsidian is running with CLI enabled." >&2
  exit 1
fi

TASK="$1"
VAULT="${2:-}"
VAULT_ARG=""
if [ -n "$VAULT" ]; then
  VAULT_ARG="vault=\"$VAULT\""
fi

if [ -z "$TASK" ]; then
  echo "Usage: $0 \"task description\" [vault_name]"
  exit 1
fi

echo "=== Context Builder ==="
echo "Task: $TASK"
echo ""

echo "--- Relevant Notes ---"
# Note: 'obsidian search' is unreliable on Windows without path= — use path= for targeted queries
obsidian search query="$TASK" $VAULT_ARG limit=5

echo ""
echo "--- Recently Touched ---"
obsidian recents $VAULT_ARG | head -5

echo ""
echo "--- Standing Instructions ---"
obsidian read file="_context/coding-standards" $VAULT_ARG 2>/dev/null | head -20
obsidian read file="_context/architecture-decisions" $VAULT_ARG 2>/dev/null | head -20

echo ""
echo "--- Today's Focus ---"
obsidian daily:read $VAULT_ARG 2>/dev/null | grep -E "^-\ \[.\]|##" | head -10
