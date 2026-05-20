# Roadmap

Planned development for the Obsidian Skill Suite. Items are phased by version. Checkmarks track progress.

## v1.3.x — Quality & Polish

### Quality & Testing

- [ ] Add `CHANGELOG.md` — track versions with dates, changes, commit links
- [ ] Skill validation CI — GitHub Action running `validate-skills.sh/.ps1` on push
- [ ] Automated reference link validation across skill files
- [ ] Add `scripts/test-cli.sh` and `scripts/test-cli.ps1` — smoke test Obsidian CLI connectivity and core commands

### Documentation

- [ ] Expand `CONTRIBUTING.md` — PR process, commit conventions, how to add a sub-skill
- [ ] Add `.github/ISSUE_TEMPLATE/config.yml` — issue template chooser
- [ ] Add `docs/architecture.md` — architecture diagram and data flow
- [ ] Fix remaining cross-references in skill files

### Features (small)

- [ ] Document `obsidian rename` in full-reference.md command table
- [ ] Expand Obsidian Sync command examples in full-reference.md
- [ ] Add `obsidian diff` and `obsidian wordcount` to quick-reference
- [ ] Document `search path=` Windows workaround more prominently in README

### Community

- [ ] Add `good first issue` labels to appropriate GitHub issues
- [ ] Add GitHub repository topics/description for discoverability

## v1.4 — Next Features

- [ ] Obsidian Bases deeper integration — template .base files for common patterns (task tracker, reading list, daily notes index)
- [ ] Canvas editing workflow — guided canvas creation via `/obsidian canvas` with layout presets
- [ ] Multi-vault support improvements — vault switcher, per-vault configuration
- [ ] Session cache v2 — auto-detect stale project context and prompt refresh
- [ ] Smarter intelligence patterns — auto-suggest backlinks during note creation

## Future Ideas

Unversioned and aspirational. Promote to a version when scoped.

- Obsidian Web Clipper integration — ingest from browser extension
- Obsidian Sync conflict resolution workflow
- Template library — pre-built note templates for each PKM method
- MCP server mode — expose vault as MCP server for other AI tools
- Plugin contribution pipeline — allow community sub-skill submissions
- Voice note transcription → vault ingestion pipeline

## Completed

- [x] All 7 sub-skills, 5 slash commands, 6 utility scripts
- [x] Windows PowerShell script equivalents for all shell scripts
- [x] PKM workflow templates (PARA, Zettelkasten, GTD, LYT)
- [x] Vault intelligence patterns (hubs, orphans, fix-links, backlinks)
- [x] Session hot cache for cross-session continuity
- [x] Thinking commands (trace, challenge, connect, emerge)
- [x] Source ingestion workflow
- [x] GitHub Actions for traffic stats
- [x] README architecture diagram and demo section
- [x] Plugin auto-discovery support