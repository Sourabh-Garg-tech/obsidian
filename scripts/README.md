# Scripts

Utility scripts for Obsidian vault operations. Run from the repository root.

## vault-health.sh

Comprehensive vault health report — note counts, graph metrics, broken links, orphans.

```bash
# Default vault (most recently focused)
./scripts/vault-health.sh

# Specific vault
./scripts/vault-health.sh "My Vault"
```

**Prerequisites:** Obsidian must be running with CLI enabled.

## context-builder.sh

Build minimal context for a task by searching the vault, reading recent files, and loading standing instructions.

```bash
# Build context for a task
./scripts/context-builder.sh "project deadline"

# With specific vault
./scripts/context-builder.sh "project deadline" "My Vault"
```

**Prerequisites:** Obsidian must be running with CLI enabled. A `_context/` folder with `coding-standards` and `architecture-decisions` notes improves results.