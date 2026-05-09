# Changelog

All notable changes to the Obsidian Skill Suite are documented here.

## v1.2.0 (2026-05-09)

### Added

- **Session Hot Cache** — `_context/session-cache.md` auto-updates after `create`, `append`, `move`, `property:set`, `daily:append`
  - `cache` named workflow to read session state
  - `cache:clear` named workflow to reset
  - FIFO touch log (5 entries), narrative summary (3 bullets), 24h stale auto-reset
- **Source Ingestion Workflow** — `ingest <source>` with preview-gated note creation
  - 6-step flow: Extract → Analyze → Preview → Approve → Execute → Index
  - Supports URLs (via `defuddle` sub-skill), local files, pasted text
  - Auto-generates entity, concept, source, and question notes with traceable `source:` frontmatter
  - Source index note updated automatically
- **Pattern 14: Source Ingestion (Preview-Gated)** in `intelligence-patterns.md`
- `--cache` flag for `scripts/context-builder.sh` to include session hot cache in output
- Design spec (`docs/superpowers/specs/`) and implementation plan (`docs/superpowers/plans/`)

### Fixed

- Pre-existing session fixes: settings permissions, CLI tips, tag/links examples, validation report updates
- `tag` does not support `format=json` — documented in CLI skill tips
- `tag name=` takes name without `#` prefix — fixed all examples
- `backlinks file=` and `links file=` unreliable — use `path=` instead
- Colon commands fail in Git Bash on Windows — documented workaround
- CLI validation report updated to 911-file vault count and last validated date

## v1.0.0 (2026-04-22)

### Added

- Root SKILL.md with 30+ auto-trigger phrases and micro-core architecture
- 7 sub-skills: obsidian-cli, obsidian-markdown, obsidian-bases, json-canvas, defuddle, obsidian-workflows, obsidian-vault-architect
- 4 thinking commands: `/trace`, `/challenge`, `/connect`, `/emerge`
- 21 reference files across sub-skills
- CLI validation report against Obsidian v1.12.7 on Windows (2091-file vault)
- Utility scripts: `vault-health.sh` and `context-builder.sh`
- `references/quick-reference.md` — essential command cheat sheet
- `obsidian-workflows/references/project-onboarding.md` — vault-project-init workflow
- Intelligence Patterns 12 (Bootstrap Project Intelligence) and 13 (Project Initiate Workflow)
- Intelligence Folder Scope (Global vs Project) documentation
- `.claude-plugin/plugin.json` for Claude Code skill registration
- `compatibility:` frontmatter on all sub-skill SKILL.md files
- README.md in `commands/`, `references/`, and `scripts/` directories
- ROADMAP.md for release planning
- MIT License, CONTRIBUTING.md, GitHub issue/PR templates

### Fixed

- P0: `obsidian files format=json` in intelligence-patterns.md — replaced with valid alternatives
- 11 broken internal links in `references/full-reference.md` (paths were root-relative from inside `references/`)
- Broken link in `obsidian-workflows/SKILL.md` (command-reference.md)
- Ambiguous reference in `obsidian-cli/SKILL.md` (missing `references/` prefix)
- Stale v1.12.4+ compatibility updated to v1.12.7+ in full-reference.md
- Missing safety rules 9-10 (Windows search, backlinks path=) added to full-reference.md
- Stale note about `silent` parameter marked as resolved in cli-validation-report.md

### Changed

- Root SKILL.md description expanded from 1 line to 14-line auto-trigger list
- Token-efficiency reference updated with Intelligence/_index loading step
- Root SKILL.md Quick Reference replaced with pointer to `references/quick-reference.md`