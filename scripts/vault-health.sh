#!/usr/bin/env bash
set -euo pipefail
# vault-health.sh — Comprehensive vault health check
# Prerequisites: Obsidian must be running with CLI enabled
# Usage: ./vault-health.sh [--help] [vault_name]

show_help() {
  cat <<EOF
Usage: $(basename "$0") [--help] [vault_name]

Comprehensive vault health check: totals, graph health, orphans, and broken links.

Options:
  --help    Show this help message and exit

Arguments:
  vault_name   Optional vault name (defaults to the active vault)
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
echo "--- Vault Intelligence ---"
echo "Orphan count:    $(obsidian orphans $VAULT_ARG | wc -l)"
echo "Broken links:    $(obsidian unresolved $VAULT_ARG | wc -l)"

# Optional: list top 5 hubs (notes with 5+ backlinks)
echo ""
echo "Top hubs (5+ backlinks):"
obsidian eval code='app.vault.getMarkdownFiles().map(f=>({name:f.basename,count:app.metadataCache.getBacklinksForFile(f).data.size})).filter(x=>x.count>=5).sort((a,b)=>b.count-a.count).slice(0,5).map(x=>x.name+": "+x.count+" backlinks")' $VAULT_ARG 2>/dev/null || echo "  (eval not available)"

echo ""
echo "--- Detailed ---"
echo "Unresolved links:"
obsidian unresolved $VAULT_ARG | head -20

echo ""
echo "Orphan notes:"
obsidian orphans $VAULT_ARG | head -20

echo ""
echo "--- Done ---"
