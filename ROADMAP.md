# Obsidian Skill Suite — Roadmap

## v1.3 Status (Current)

v1.3 adds vault intelligence (hubs, orphans, broken links, missing backlinks) with 4 new patterns and auto-run rules. The skill suite has 7 sub-skills, 4 thinking commands, 3 utility scripts, full reference documentation, and CLI validation against v1.12.7. Presentation materials (README, CONTRIBUTING, LICENSE, issue/PR templates) are in place.

### v1.0 Release (Complete)

- [x] Commit all uncommitted changes and push to origin
- [x] Set GitHub repo topics
- [x] Fix P0 bug: `files format=json` in intelligence-patterns.md
- [x] Fix broken links in full-reference.md (11 links)
- [x] Fix broken link in obsidian-workflows/SKILL.md
- [x] Fix ambiguous reference in obsidian-cli/SKILL.md
- [x] Update stale v1.12.4+ to v1.12.7+ in full-reference.md
- [x] Add safety rules 9-10 to full-reference.md
- [x] Update cli-validation-report.md silent→open fix note

### v1.1 Release (Complete)

- [x] Add `plugin.json` for Claude Code registration
- [x] Add `obsidian` Bash permissions to settings
- [x] Add P2 CLI commands (`open`, `commands`/`command`, `hotkeys`, `vault info=`, `tasks done/todo/daily/verbose/active/status=`, `property:set type=`) to docs
- [x] Add missing auto-trigger phrases (`open note`, `backlinks`, `create canvas`, `metadata`, `sync history`, `run command`)
- [x] Add sub-skill cross-references (workflows ↔ vault-architect, workflows ↔ obsidian-cli)
- [x] Add error handling to scripts (CLI check, `--help`, `set -euo pipefail`, Windows fallback)
- [x] Add `compatibility:` frontmatter to all sub-skill SKILL.md files
- [x] Archive `docs/plan.md` and `docs/design.md` to `docs/archive/`
- [x] Add README.md to `references/`, `scripts/`, and `commands/` directories
- [x] Create `CHANGELOG.md`
- [x] Create validation script (`scripts/validate-skills.sh`)
- [x] Fix `project-onboarding.md` link in `intelligence-patterns.md`
- [x] Update SKILL.md quick reference with P2 commands

---

### v1.2 Release (Complete)

- [x] **Session Hot Cache** — `_context/session-cache.md` auto-updates after writes
- [x] **Source Ingestion Workflow** — `ingest <source>` with preview-gated note creation
- [x] **Pattern 14** — Source Ingestion in `intelligence-patterns.md`
- [x] `--cache` flag for `scripts/context-builder.sh`
- [x] Design spec and implementation plan for v1.2

### v1.3 Release (Complete)

- [x] **Vault Intelligence & Auto-Linking**
  - [x] `intelligence`, `hubs`, `orphans`, `fix-links`, `backlinks` named workflows
  - [x] Patterns 15-18 (Hub Detection, Orphan Triage, Broken Link Fix, Missing Backlinks)
  - [x] Vault Intelligence section in `obsidian-workflows/SKILL.md`
  - [x] Vault Intelligence commands in `references/quick-reference.md`
  - [x] Vault Intelligence metrics in `scripts/vault-health.sh`
- [x] Auto-run rules for intelligence after `ingest` and `create`
- [x] Design spec and implementation plan for v1.3

---

## v1.4 (Future)

| Item | Description | Priority |
|---|---|---|
| Defuddle references | Add a `references/` directory to `defuddle/` for consistency | P4 |
| Dataview query guide | Add Dataview query examples to `obsidian-markdown/references/` | P2 |
| Canvas generation patterns | Add programmatic canvas creation patterns to `json-canvas/` | P2 |
| Multi-vault guide | Add multi-vault management guide to `obsidian-workflows/` | P3 |
| Integration tests | Create CLI command integration test suite | P3 |

---

## v2.0 (Future)

- Interactive vault onboarding via `/obsidian init` command
- Dataview query generation skill
- Canvas auto-layout generation
- Multi-vault management workflows
- Obsidian Sync conflict resolution patterns