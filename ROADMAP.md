# Roadmap

Planned development for the Obsidian Skill Suite. Items are phased by version. Checkmarks track progress.

## v1.3.x — Quality & Polish

### P0 — Broken Functionality

- [ ] **Add missing workflow keywords to `commands/obsidian.md`** — `checkpoint`, `cache`, `cache:clear`, `ingest` exist in named-workflows.md but not in the slash command file. Users typing these get search fallback instead of the workflow.
- [ ] **Add liveness check and skill loading to thinking commands** — `/obsidian-trace`, `/obsidian-challenge`, `/obsidian-connect`, `/obsidian-emerge` use `obsidian <cmd>` directly without loading the main skill. No liveness check, no safety rules, no Windows workarounds.
- [ ] **Fix health workflow for Windows** — `health` workflow hardcodes `scripts/vault-health.sh`. Add platform detection to call `.ps1` on Windows. Same for `vault-health.sh` references in SKILL.md and named-workflows.md.
- [ ] **Remove or integrate dead scripts** — `context-builder.sh/.ps1` and `validate-skills.sh/.ps1` are listed as available but never invoked by any workflow. Either integrate them into workflows or remove them from the reference table.

### P1 — Friction & Inconsistency

- [ ] **Add `property:set` array warning to all examples** — 6+ files show `value='["a","b"]'` without warning that this writes a string, not a YAML array. Add `type=list` or frontmatter-edit note to every example.
- [ ] **Remove hardcoded `powershell -c` from cross-platform workflows** — named-workflows.md bakes Windows-only `powershell -c "obsidian 'daily:read'..."` into universal workflow code. Replace with platform-detecting patterns.
- [ ] **Consolidate intelligence workflows to use single `eval` calls** — `intelligence` scan runs 3+ sequential CLI calls when one `eval` could return all data. Backlinks check is per-note. fix-links is N+1. Use batch `eval` patterns from intelligence-patterns.md Pattern 6.
- [ ] **Separate safety rules from CLI workarounds** — Rules 6-11 are workarounds for missing features/bugs, not safety guidance. Move to a "Known Limitations" section. Keep only rules 1-5 and 12 in Safety Rules.
- [ ] **Add sub-skill delegation triggers** — `obsidian-cli`, `obsidian-markdown`, and `obsidian-workflows` have auto-load conditions but no keyword delegates to them. Add explicit triggers: CLI debugging → `obsidian-cli`, markdown writing → `obsidian-markdown`, PKM routines → `obsidian-workflows`.
- [ ] **Fix `project-onboarding.md` raw `cp` violation** — Init workflow uses `cp` to copy docs into vault, violating safety rule #1. Replace with `obsidian create` commands.
- [ ] **Align `.sh` and `.ps1` script logic** — `vault-health.sh` uses `.slice(0,1000)` for hub detection; `.ps1` uses `.slice(0,500)`. Fallback logic differs. Standardize both to same parameters.
- [ ] **Add structured dry-run for bulk operations** — Replace manual `echo` pattern with preview-gated confirmation (same pattern as ingestion workflow). Present commands for user review, then execute after approval.

### P2 — Missing Coverage & Docs

- [ ] **Add CHANGELOG.md** — track versions with dates, changes, commit links
- [ ] **Skill validation CI** — GitHub Action running `validate-skills.sh/.ps1` on push
- [ ] **Expand CONTRIBUTING.md** — PR process, commit conventions, how to add a sub-skill
- [ ] **Add `.github/ISSUE_TEMPLATE/config.yml`** — issue template chooser
- [ ] **Add `docs/architecture.md`** — architecture diagram and data flow
- [ ] **Document `obsidian rename`, `diff`, `wordcount` in quick-reference** — present in command-reference but not in quick-reference
- [ ] **Cover 38 unused CLI commands in skill docs** — 38 commands from command-reference.md are never referenced in any skill/workflow file. Entire unused categories: Bookmarks (2), Publish (6), History (5), Workspace & Tabs (7). Partial gaps: Bases (`base:views`, `base:create`), CSS Snippets (`snippets`, `snippets:enabled`, `snippet:disable`), Developer (`devtools`, `dev:debug`, `dev:dom`, `dev:cdp`). Also unused: `folder`, `random`, `random:read`, `daily:prepend`, `search:open`, `template:read`, `plugins:restrict`, `plugin:disable`, `plugin:uninstall`, `theme`, `theme:install`, `theme:uninstall`, `web`, `unique`
- [ ] **Add `search path=` Windows workaround to README** — currently only in SKILL.md safety rules
- [ ] **Add setup script for Windows Git Bash wrapper** — auto-detect and create `~/bin/obsidian` wrapper
- [ ] **Add GitHub topics/description** for discoverability
- [ ] **Create `scripts/setup-windows.ps1`** — auto-provision Git Bash wrapper and verify CLI connectivity

## v1.4 — Next Features

- [ ] Bases scaffolding workflow — prompt-to-.base templates for common patterns (task tracker, reading list, daily notes index)
- [ ] Canvas editing workflow — guided canvas creation via `/obsidian canvas` with layout presets
- [ ] Session cache v2 — add eval-based health checks, concurrent-safe writes, sub-day staleness
- [ ] Smarter intelligence patterns — auto-suggest backlinks during note creation
- [ ] Multi-vault support improvements — vault switcher, per-vault configuration
- [ ] Health workflow hand-off protocol — define delegation from main skill to vault-architect sub-skill
- [ ] Reference file auto-loading — add explicit "read X reference when Y happens" triggers for quick-reference, full-reference, token-efficiency, platform-setup

## Future Ideas

Unversioned and aspirational. Promote to a version when scoped.

- Obsidian Web Clipper integration — ingest from browser extension
- Obsidian Sync conflict resolution workflow
- Template library — pre-built note templates for each PKM method
- MCP server mode — expose vault as MCP server for other AI tools
- Plugin contribution pipeline — community sub-skill submissions
- Voice note transcription → vault ingestion pipeline
- Defuddle integration hardening — explicit Skill tool delegation from ingestion workflow
- Batch eval patterns — single-call vault operations that currently require N+1 subprocess calls

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

## Audit Log

**2026-05-20 — Integration & Friction Audit**

Found 21 issues across 3 priority levels:
- P0 (4): Missing workflow keywords, dead scripts, Windows health failure, thinking commands lack skill loading
- P1 (8): Array bug examples, hardcoded PowerShell, N+1 calls, safety/workaround conflation, sub-skill triggers, cp violation, script drift, manual dry-run
- P2 (9→10): Changelog, CI, CONTRIBUTING, architecture docs, command coverage gaps (38 unused CLI commands), Windows setup, discoverability