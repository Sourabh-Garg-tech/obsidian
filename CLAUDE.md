# Obsidian Skill Suite — Claude Code Instructions

## Project Overview

This is a Claude Code skill suite for automating Obsidian vaults via the official Obsidian CLI (v1.12.7+). It consists of a main skill (`skills/obsidian/SKILL.md`) with 7 sub-skills, 5 commands, and tiered reference files.

## Architecture

- **`.claude-plugin/plugin.json`** — plugin manifest for Claude Code registration
- **Main skill** — `skills/obsidian/SKILL.md`, auto-triggers on Obsidian-related requests (~7KB)
- **Sub-skills** — `obsidian-cli`, `obsidian-markdown`, `obsidian-bases`, `json-canvas`, `defuddle`, `obsidian-workflows`, `obsidian-vault-architect`
- **References/** — on-demand reference files loaded only when needed (token-efficient)
- **Commands/** — `/obsidian` gateway + `/obsidian-trace`, `/obsidian-challenge`, `/obsidian-connect`, `/obsidian-emerge`
- **Scripts/** — utility scripts (`vault-health.sh`, `context-builder.sh`)

## Key Principles

1. **CLI-first, always** — Never use raw `mv`, `cp`, or direct `.md` writes. Every vault operation goes through `obsidian <cmd>`.
2. **Token-efficient** — Sub-skills and references are loaded on-demand, not upfront. Target under 3,000 tokens per task.
3. **Safety rules** — See SKILL.md for the 11 safety rules. Critical ones: never edit `.obsidian/*.json`, never write raw YAML, use `path=` for backlinks.
4. **Windows compatibility** — `search` is unreliable on Windows without `path=`. Use Grep tool as fallback.

## File Conventions

- Skill definitions: `SKILL.md` in each sub-skill directory
- Reference files: `references/` subdirectory within each sub-skill
- Markdown: 100-character line wrap
- Links: relative paths only
- Commit messages: `docs:`, `feat:`, or `fix:` prefix

## Validation

- All CLI commands were validated against Obsidian v1.12.7 on Windows (2091-file vault)
- Validation report: `references/cli-validation-report.md`
- Known bugs documented in SKILL.md safety rules (items 7-10)

## Git Workflow

- Main branch: `master`
- Commit convention: conventional commits (`docs:`, `feat:`, `fix:`)
- All changes are documentation (markdown only) — no code to test