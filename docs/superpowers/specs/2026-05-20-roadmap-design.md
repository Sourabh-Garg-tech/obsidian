---
name: roadmap-design
description: Design spec for the Obsidian skill suite ROADMAP.md and future development plan
---

# Roadmap Design Spec

**Date:** 2026-05-20
**Scope:** v1.3.x through v1.4+ future development planning
**Approach:** Single ROADMAP.md file, version-phased, checkbox format

## Decisions

1. **Format:** Single ROADMAP.md in repo root — serves as both internal planning and public signal
2. **Structure:** Version-phased sections (v1.3.x, v1.4, Future Ideas, Completed)
3. **Item format:** Checkbox items with optional GitHub issue links
4. **No dates** — versions only, avoids stale date promises
5. **Completed section** — archive of done work at bottom for visibility
6. **Scope:** Balanced — quality/testing, documentation, small features, community

## v1.3.x — Quality & Polish

### Quality & Testing
- Add CHANGELOG.md — track versions with dates, changes, links
- Skill validation CI — GitHub Action running validate-skills scripts on push
- Automated reference link validation across skill files
- CLI smoke test script (scripts/test-cli.sh/.ps1)

### Documentation
- Expand CONTRIBUTING.md — PR process, commit conventions, how to add a sub-skill
- Add .github/ISSUE_TEMPLATE/config.yml
- Add docs/architecture.md — architecture diagram and data flow
- Fix remaining cross-references in skill files

### Features (small)
- Document obsidian rename in full-reference.md command table
- Expand Obsidian Sync command examples
- Add obsidian diff and obsidian wordcount to quick-reference
- Document search path= Windows workaround more prominently

### Community
- Add good first issue labels to appropriate items
- Add GitHub topics/description for discoverability

## v1.4 — Next Features

- Obsidian Bases deeper integration — template .base files for common patterns
- Canvas editing workflow — guided canvas creation via /obsidian canvas
- Multi-vault support improvements — vault switcher, per-vault config
- Session cache v2 — auto-detect stale project context
- Smarter intelligence patterns — auto-suggest backlinks during note creation

## Future Ideas

- Obsidian Web Clipper integration — ingest from browser extension
- Obsidian Sync conflict resolution workflow
- Template library — pre-built note templates for each PKM method
- MCP server mode — expose vault as MCP server for other AI tools
- Plugin contribution pipeline — community sub-skill submissions
- Voice note transcription → vault ingestion pipeline

## Completed (as of v1.3.0)

- All 7 sub-skills, 5 slash commands, 6 scripts (3x .sh + 3x .ps1)
- Windows PowerShell script equivalents
- PKM workflow templates (PARA, Zettelkasten, GTD, LYT)
- Vault intelligence patterns (hubs, orphans, fix-links, backlinks)
- Session hot cache
- Thinking commands (trace, challenge, connect, emerge)
- Source ingestion workflow
- GitHub Actions for traffic stats
- README architecture diagram and demo section