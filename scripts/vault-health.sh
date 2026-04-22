#!/usr/bin/env bash
# vault-health.sh — Comprehensive vault health check
# Usage: ./vault-health.sh [vault_name]

VAULT="${1:-}"
VAULT_ARG=""
if [ -n "$VAULT" ]; then
  VAULT_ARG="vault=\"$VAULT\""
fi

echo "=== Vault Health Report ==="
echo "Run at: $(date +%Y-%m-%d\ %H:%M:%S)"
echo ""

echo "--- Totals ---"
echo "Notes:    $(obsidian files total $VAULT_ARG)"
echo "Tags:     $(obsidian tags total $VAULT_ARG)"
echo "Tasks:    $(obsidian tasks total $VAULT_ARG)"

echo ""
echo "--- Graph Health ---"
echo "Broken links:    $(obsidian unresolved total $VAULT_ARG)"
echo "Orphans:         $(obsidian orphans total $VAULT_ARG)"
echo "Dead-ends:       $(obsidian deadends total $VAULT_ARG)"

echo ""
echo "--- Detailed ---"
echo "Unresolved links:"
obsidian unresolved $VAULT_ARG | head -20

echo ""
echo "Orphan notes:"
obsidian orphans $VAULT_ARG | head -20

echo ""
echo "--- Done ---"
