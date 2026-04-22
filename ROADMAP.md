# Obsidian Skill Suite — Roadmap

## v1.0 Status (Current)

The skill suite is feature-complete with 7 sub-skills, 4 thinking commands, 2 utility scripts, full reference documentation, and CLI validation against v1.12.7. Presentation materials (README, CONTRIBUTING, LICENSE, issue/PR templates) are in place.

### Remaining Before v1.0 Release

- [ ] Commit all uncommitted changes and push to origin
- [ ] Set GitHub repo topics: `claude-code`, `obsidian`, `obsidian-md`, `pkm`, `cli`, `skill`, `automation`, `second-brain`
- [ ] Fix P0 bug: `files format=json` in intelligence-patterns.md — **DONE**
- [ ] Fix broken links in full-reference.md — **DONE**
- [ ] Fix broken link in obsidian-workflows/SKILL.md — **DONE**
- [ ] Fix ambiguous reference in obsidian-cli/SKILL.md — **DONE**
- [ ] Update stale v1.12.4+ to v1.12.7+ in full-reference.md — **DONE**
- [ ] Add safety rules 9-10 to full-reference.md — **DONE**
- [ ] Update cli-validation-report.md silent→open fix note — **DONE**

---

## v1.1 (Next Release)

### P1 — Release Blockers

| Item | Description | Effort |
|---|---|---|
| Plugin registration | Add `plugin.json` or document skill discovery mechanism for Claude Code | 1-2 hr |
| Bash permissions | Add `obsidian` command permissions to `.claude/settings.local.json` so the skill works after clone | 15 min |

### P2 — High Impact

| Item | Description | Effort |
|---|---|---|
| P2 commands | Add `open`, `commands`/`command`, `hotkeys`, `vault info=`, `tasks done/todo/daily/verbose/active/status=`, `property:set type=` to full-reference.md and SKILL.md quick reference | 1-2 hr |
| Auto-trigger phrases | Add missing triggers: `open note`, `run command`, `create canvas`, `backlinks`, `metadata`, `sync history` | 20 min |
| Sub-skill cross-references | Add "when to delegate" guidance between sub-skills (workflows ↔ vault-architect) | 30 min |
| Script error handling | Add CLI availability check, Windows fallback for `search`, `--help` flag, `set -euo pipefail` to vault-health.sh and context-builder.sh | 1 hr |

### P3 — Polish

| Item | Description | Effort |
|---|---|---|
| Validation script | Create a script that checks: YAML frontmatter parses, relative links resolve, commands match command-reference | 2-3 hr |
| Compatibility frontmatter | Add `compatibility:` block to the 5 sub-skill SKILL.md files that lack it | 15 min |
| Archive docs/ | Move `docs/plan.md` and `docs/design.md` to `docs/archive/` or remove — they're implementation artifacts | 5 min |
| Directory READMEs | Add README.md to `references/`, `scripts/`, and `commands/` directories | 30 min |
| CHANGELOG.md | Create a changelog tracking v1.0 release | 30 min |

### P4 — Nice to Have

| Item | Description | Effort |
|---|---|---|
| Commands README | Add `commands/README.md` with install instructions for thinking commands | 15 min |
| Defuddle references | Add a `references/` directory to `defuddle/` for consistency with other sub-skills | 30 min |
| GitHub topics | Set repo topics via GitHub UI | 5 min |

---

## v2.0 (Future)

- Interactive vault onboarding via `/obsidian init` command
- Dataview query generation skill
- Canvas auto-layout generation
- Multi-vault management workflows
- Obsidian Sync conflict resolution patterns