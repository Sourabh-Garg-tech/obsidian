# Presentation Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the `obsidian` skill repository public-ready with professional README, license, contributing guide, issue/PR templates, and sub-skill READMEs.

**Architecture:** Pure documentation pass — no code changes. New markdown files added; existing `README.md` rewritten; GitHub templates created in `.github/`.

**Tech Stack:** Markdown, GitHub-flavored markdown, Git CLI.

---

### Task 1: Add MIT LICENSE file

**Files:**
- Create: `LICENSE`

- [x] **Step 1: Write LICENSE**

```text
MIT License

Copyright (c) 2026 Sourabh Garg

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [x] **Step 2: Commit** ✅ (committed as cab15b8)

---

### Task 2: Add CONTRIBUTING.md

**Files:**
- Create: `CONTRIBUTING.md`

- [x] **Step 1: Write CONTRIBUTING.md** ✅

```markdown
# Contributing to Obsidian Skill

Thanks for your interest in making this skill better.

## Reporting bugs

Open an issue and use the Bug Report template. Include:
- Obsidian version
- Claude Code version
- Exact command that failed
- Expected vs actual behavior

## Suggesting features

Open an issue and use the Feature Request template. Describe:
- What problem it solves
- How you would use it
- Any examples from your workflow

## Pull requests

1. Fork the repo and create a branch: `git checkout -b feat/your-feature`
2. Make your changes
3. Update docs if behavior changes
4. Commit with a clear message: `docs:`, `feat:`, or `fix:` prefix
5. Open a PR against `master`

## Code style

- Markdown: 100-character line wrap
- Skill frontmatter: keep `description` under 150 characters
- Reference links: relative paths only
```

- [x] **Step 2: Commit** ✅ (committed as 167ca5f)

---

### Task 3: Add GitHub issue and PR templates

**Files:**
- Create: `.github/PULL_REQUEST_TEMPLATE.md`
- Create: `.github/ISSUE_TEMPLATE/bug_report.md`
- Create: `.github/ISSUE_TEMPLATE/feature_request.md`

- [x] **Step 1: Create .github directories** ✅

```bash
mkdir -p .github/ISSUE_TEMPLATE
```

- [x] **Step 2: Write PULL_REQUEST_TEMPLATE.md** ✅

```markdown
## What changed

Brief description of the change.

## Why

Motivation or issue reference.

## Checklist

- [ ] Docs updated if behavior changed
- [ ] Sub-skill READMEs updated if affected
- [ ] No breaking changes without clear note
```

- [x] **Step 3: Write bug_report.md** ✅

```markdown
---
name: Bug report
about: Something is not working as expected
title: "[BUG] "
labels: bug
---

**Obsidian version**

**Claude Code version**

**Command that failed**
Paste the exact command.

**Expected behavior**

**Actual behavior**

**Screenshots or logs**
If applicable.
```

- [x] **Step 4: Write feature_request.md** ✅

```markdown
---
name: Feature request
about: Suggest an idea for this skill
title: "[FEAT] "
labels: enhancement
---

**Problem**
What limitation are you hitting?

**Proposed solution**
What should happen?

**Example workflow**
Show how you would use it.
```

- [x] **Step 5: Commit** ✅ (committed as 04a8532)

---

### Task 4: Rewrite README.md

**Files:**
- Modify: `README.md`

- [x] **Step 1: Write new README.md** ✅

```markdown
# Obsidian Skill for Claude Code

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Claude Code skill suite for automating [Obsidian](https://obsidian.md/) vaults via the official Obsidian CLI.

Every command routes through Obsidian's internal API — so moves auto-rewrite wikilinks, properties reflect immediately, and plugin configs are never silently overwritten.

## What is this?

This skill turns Claude Code into an intelligent vault assistant. Create notes, update properties, search across your entire second brain, toggle tasks, and run structured PKM workflows — all through natural conversation. No raw file manipulation, no broken links, no YAML corruption.

## Who is this for?

| Claude Code users | Obsidian users | Developers |
|---|---|---|
| Install one skill and control your vault with natural language. | Automate repetitive vault tasks without leaving your editor. | Extend the skill suite with new sub-skills or CLI commands. |

## Prerequisites

- Obsidian v1.12.7+ with CLI enabled ([setup guide](obsidian-workflows/references/platform-setup.md))
- Claude Code (this is a Claude Code skill)

## Installation

1. Copy this repo into your Claude Code skills directory:
   ```bash
   git clone https://github.com/Sourabh-Garg-tech/obsidian.git ~/.claude/skills/obsidian
   ```
2. Restart Claude Code or run `/skill refresh`
3. The skill auto-triggers on any Obsidian-related request

## Quick start

```bash
# Read a note
obsidian read file="Project Ideas"

# Search your vault
obsidian search query="deadline:2026-04-30" format=json

# Append to today's daily note
obsidian daily:append date="today" content="- [ ] Review Q2 goals"
```

## Sub-skills

| Sub-skill | What it does |
|---|---|
| [obsidian-cli](obsidian-cli/) | CLI syntax, parameters, and command reference |
| [obsidian-markdown](obsidian-markdown/) | Obsidian-flavored markdown: wikilinks, embeds, callouts, properties |
| [obsidian-bases](obsidian-bases/) | Bases `.base` files: filters, formulas, views |
| [json-canvas](json-canvas/) | Canvas `.canvas` files: nodes, edges, groups |
| [defuddle](defuddle/) | Extract clean markdown from web pages |
| [obsidian-workflows](obsidian-workflows/) | PKM routines, token-efficient loading, vault intelligence |
| [obsidian-vault-architect](obsidian-vault-architect/) | Vault blueprints, health audit, fix commands |

## Why this over raw file tools

| Raw file tools | Obsidian CLI (this skill) |
|---|---|
| `mv` breaks wikilinks | `obsidian move` rewrites all links automatically |
| Writing YAML by hand corrupts frontmatter | `property:set` writes safe YAML |
| Editing `.obsidian/*.json` gets overwritten | Plugin configs managed through the API |
| No cross-platform guarantees | Works on macOS, Windows, Linux |

## Safety rules

1. **Never `mv`/`cp`** vault files — use `obsidian move` to preserve wikilinks
2. **Never write raw YAML** into `.md` files — use `property:set`
3. **Never edit `.obsidian/*.json`** — Obsidian will overwrite changes
4. **Dry-run bulk ops** — echo commands first, then remove `echo`
5. **Confirm vault** with `obsidian vaults` if multiple vaults open
6. **>500 files** — use Python + `python-frontmatter`, then `obsidian reload`

See [full safety reference](references/full-reference.md#safety-rules).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE) — free for anyone to use, modify, and distribute.
```

- [x] **Step 2: Commit** ✅ (pending commit)

---

### Task 5: Add README.md to each sub-skill

**Files:**
- Create: `obsidian-cli/README.md`
- Create: `obsidian-markdown/README.md`
- Create: `obsidian-bases/README.md`
- Create: `json-canvas/README.md`
- Create: `defuddle/README.md`
- Create: `obsidian-workflows/README.md`
- Create: `obsidian-vault-architect/README.md`

- [x] **Step 1: Write obsidian-cli/README.md** ✅

```markdown
# obsidian-cli

CLI syntax, parameters, and complete command reference for the Obsidian CLI.

→ [Full skill definition](SKILL.md)  
→ [Command reference](references/command-reference.md)
```

- [x] **Step 2: Write obsidian-markdown/README.md** ✅

```markdown
# obsidian-markdown

Obsidian-flavored markdown syntax: wikilinks, embeds, callouts, properties, and Dataview.

→ [Full skill definition](SKILL.md)  
→ [Callouts reference](references/CALLOUTS.md)  
→ [Embeds reference](references/EMBEDS.md)  
→ [Properties reference](references/PROPERTIES.md)
```

- [x] **Step 3: Write obsidian-bases/README.md** ✅

```markdown
# obsidian-bases

Bases `.base` files: filters, formulas, views, and field types.

→ [Full skill definition](SKILL.md)  
→ [Functions reference](references/FUNCTIONS_REFERENCE.md)
```

- [x] **Step 4: Write json-canvas/README.md** ✅

```markdown
# json-canvas

Canvas `.canvas` files: nodes, edges, groups, and programmatic generation.

→ [Full skill definition](SKILL.md)  
→ [Examples](references/EXAMPLES.md)
```

- [x] **Step 5: Write defuddle/README.md** ✅

```markdown
# defuddle

Extract clean markdown from web pages for importing into Obsidian.

→ [Full skill definition](SKILL.md)
```

- [x] **Step 6: Write obsidian-workflows/README.md** ✅

```markdown
# obsidian-workflows

PKM routines, token-efficient vault loading, and vault intelligence patterns.

→ [Full skill definition](SKILL.md)  
→ [Intelligence patterns](references/intelligence-patterns.md)  
→ [PKM workflows](references/pkm-workflows.md)  
→ [Token efficiency](references/token-efficiency.md)  
→ [Platform setup](references/platform-setup.md)
```

- [x] **Step 7: Write obsidian-vault-architect/README.md** ✅

```markdown
# obsidian-vault-architect

Vault blueprints, health audits, scoring rubrics, and fix commands.

→ [Full skill definition](SKILL.md)  
→ [Vault blueprint](references/vault-blueprint.md)  
→ [Frontmatter schema](references/frontmatter-schema.md)  
→ [Scoring rubric](references/scoring-rubric.md)
```

- [x] **Step 8: Commit** ✅ (pending commit)

---

### Task 6: Final review and push

- [x] **Step 1: Review git log** ✅ (completed as part of project review)

- [ ] **Step 2: Push to origin**

```bash
git push origin master
```

---

## Self-review

**Spec coverage:**
- README rewrite with hero, badges, 3-audience layout → Task 4
- LICENSE file → Task 1
- CONTRIBUTING.md → Task 2
- Issue/PR templates → Task 3
- Sub-skill READMEs → Task 5
- GitHub repo metadata (topics) → Not in plan; must be done manually via GitHub UI after push

**Placeholder scan:**
- No TBD, TODO, or vague steps. Every file has complete content.
- No "similar to Task N" references.
- No undefined types or functions (this is markdown, so no code signatures).

**Type consistency:**
- All relative links are consistent: `SKILL.md`, `references/...`
- All commit messages follow `docs:` prefix convention.

---

### Task 7: Post-plan improvements (uncommitted)

These changes were made after the original plan was marked complete:

- **SKILL.md**: Expanded `description` from 1 line to 14-line auto-trigger list. Replaced inline Quick Reference with pointer to `references/quick-reference.md`. Added Scripts section and two new reference entries.
- **intelligence-patterns.md**: Added Patterns 12 (Bootstrap Project Intelligence) and 13 (Project Initiate Workflow). Added Intelligence Folder Scope section. Updated decision trail frontmatter from `type: decision` to `type: intelligence-report`.
- **token-efficiency.md**: Updated context-loading workflow to include Intelligence/_index step. Expanded _context/ pattern to show global vs project contexts.
- **New file**: `references/quick-reference.md` — Essential command table for daily use.
- **New file**: `obsidian-workflows/references/project-onboarding.md` — Project scaffolding, vault-project-init workflow, 3-folder structure.
- **New directory**: `scripts/` with `vault-health.sh` and `context-builder.sh`.

- [x] **Step 1: Write quick-reference.md** ✅
- [x] **Step 2: Write project-onboarding.md** ✅
- [x] **Step 3: Write vault-health.sh and context-builder.sh** ✅
- [x] **Step 4: Expand SKILL.md description and add scripts section** ✅
- [x] **Step 5: Expand intelligence-patterns.md and token-efficiency.md** ✅
- [x] **Step 6: Fix broken links in full-reference.md** ✅ (references/command-reference.md → obsidian-cli/references/command-reference.md, all Reference Files table paths corrected)
- [x] **Step 7: Fix broken link in obsidian-workflows/SKILL.md** ✅
- [x] **Step 8: Fix ambiguous reference in obsidian-cli/SKILL.md** ✅
- [x] **Step 9: Update stale v1.12.4+ → v1.12.7+ in full-reference.md** ✅
- [x] **Step 10: Add safety rules 9-10 to full-reference.md** ✅
- [x] **Step 11: Update cli-validation-report.md silent→open fix note** ✅
- [ ] **Step 12: Commit and push**
- File paths match the actual directory structure.

**Gap:** GitHub repo topics/tags must be added manually via GitHub UI after push. Suggest adding: `claude-code`, `obsidian`, `obsidian-md`, `pkm`, `cli`, `skill`, `automation`, `second-brain`.
