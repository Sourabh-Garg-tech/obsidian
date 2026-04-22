# Obsidian Skill — Presentation Redesign

**Date:** 2026-04-22  
**Scope:** Documentation and repository presentation  
**Goal:** Make the repo public-ready for three audiences: Claude Code users, Obsidian users, and developers.

---

## Current State

- README rewritten with hero, badges, 3-audience table, sub-skill links, safety rules
- `LICENSE` file added (MIT)
- `CONTRIBUTING.md` added
- GitHub templates added (bug report, feature request, PR template)
- Sub-skills have `README.md` files for GitHub browsing
- CLAUDE.md added for Claude Code instructions
- Repo metadata topics still need manual addition via GitHub UI

## Target State

### 1. README.md (rewritten)

**Structure:**
1. Hero — title, emoji, badges (MIT, last commit), one-line hook
2. What is this? — 2-sentence pitch
3. Who is this for? — 3-column layout (Claude Code users, Obsidian users, developers)
4. Prerequisites — Obsidian CLI setup link
5. Installation — skill install steps for Claude Code
6. Quick start — 3 copy-pasteable examples
7. Sub-skills — emoji table with one-liners and links
8. Safety rules — why `obsidian` CLI beats raw file tools
9. Contributing — link to CONTRIBUTING.md
10. License — MIT with link to LICENSE file

**Tone:** Professional, enthusiastic, accessible to non-technical users.

### 2. New files

| File | Purpose |
|---|---|
| `LICENSE` | Full MIT license text |
| `CONTRIBUTING.md` | How to report bugs, suggest features, submit PRs |
| `.github/PULL_REQUEST_TEMPLATE.md` | Standard PR checklist |
| `.github/ISSUE_TEMPLATE/bug_report.md` | Bug report template |
| `.github/ISSUE_TEMPLATE/feature_request.md` | Feature request template |

### 3. Sub-skill READMEs

Each sub-skill folder gets a `README.md` with:
- One-line description
- Link to `SKILL.md`
- Link to any references

Folders: `obsidian-cli`, `obsidian-markdown`, `obsidian-bases`, `json-canvas`, `obsidian-workflows`, `obsidian-vault-architect`, `defuddle`

### 4. GitHub repo metadata

Topics to add: `claude-code`, `obsidian`, `obsidian-md`, `pkm`, `cli`, `skill`, `automation`, `second-brain`

### 5. Commit

Single commit: `docs: professional README, contributing guide, issue templates, and sub-skill READMEs`

---

## Out of scope

- GitHub Pages / documentation site
- Social preview image
- CI/CD workflows
- npm/packaging
- Badges requiring external services (coverage, etc.)

---

## Self-review

- **Placeholder scan:** No TBDs or TODOs. All sections are concrete.
- **Internal consistency:** README links to files that will exist (`LICENSE`, `CONTRIBUTING.md`). Sub-skill READMEs link to existing `SKILL.md` files.
- **Scope check:** This is a single docs pass. No code changes. Well-bounded.
- **Ambiguity check:** "Professional" is subjective but the concrete structure above removes ambiguity.
