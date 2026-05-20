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

## Integration & Friction Audit (2026-05-20)

Full audit found 21 issues across 3 priority levels:

### P0 — Broken Functionality (4 items)
1. Missing workflow keywords in commands/obsidian.md — checkpoint, cache, cache:clear, ingest
2. Thinking commands never load the obsidian skill — no liveness check, no safety rules
3. Health workflow hardcodes .sh, not .ps1 — Windows health audits fail
4. 5 of 6 scripts are dead code — never invoked by any workflow

### P1 — Friction & Inconsistency (8 items)
1. property:set array examples lack warnings — writes strings not YAML arrays
2. Hardcoded powershell -c in cross-platform workflows — macOS/Linux breaks
3. Intelligence workflows use N+1 subprocess pattern — should use single eval calls
4. 58% of safety rules are CLI workarounds, not safety guidance
5. 3 sub-skills have no keyword-driven load trigger
6. project-onboarding.md uses raw cp — violates safety rule #1
7. .sh and .ps1 scripts produce different results — diverged logic
8. Dry-run pattern is manual echo trick — should use preview-gated confirmation

### P2 — Missing Coverage (9 items)
1. No CHANGELOG.md
2. No CI for skill validation
3. CONTRIBUTING.md needs expansion
4. No issue template config
5. No architecture doc
6. Missing command coverage (rename, diff, wordcount in quick-reference)
7. Sparse Sync/Publish/History/Workspace examples
8. Windows Git Bash wrapper is always manual
9. No GitHub topics/description

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