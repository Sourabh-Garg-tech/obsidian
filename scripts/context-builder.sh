#!/usr/bin/env bash
# context-builder.sh — Build minimal context for a task
# Usage: ./context-builder.sh "task description" [vault_name]

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
