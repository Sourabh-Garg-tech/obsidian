# Changelog

All notable changes to the Obsidian Skill Suite are documented here.

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