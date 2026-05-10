# Project Onboarding — `vault-project-init`

Scaffold a new project into the vault with a consistent 3-folder structure.

---

## The 3-Folder Rule

Every project uses exactly 3 top-level folders. Subfolders are allowed, but no additional top-level folders.

| Folder | Purpose | Subfolders |
|---|---|---|
| `docs/` | Design specs, plans, architecture, API docs | `specs/`, `plans/`, `architecture/`, `api/` |
| `Intelligence/` | Decision trails, reports, domain extraction | `decisions/`, `reports/`, `gaps/`, `templates/` |
| `_context/` | Project state, coding standards, vault-map | (flat, max 5 short notes) |

**Why these 3:**
- `docs/` = what the project is and what is planned
- `Intelligence/` = why decisions were made and what gaps remain
- `_context/` = how to work on it right now

Everything else goes into subfolders of these 3. No `notes/`, `scratch/`, `temp/` at top level.

---

## The `vault-project-init` Workflow

### 1. Discover

```bash
obsidian vaults
obsidian search query="project-name" format=json
```

If the project folder does not exist, create it:
```bash
obsidian create name="project-name/docs/PLACEHOLDER.md" content="---\ntype: placeholder\n---\n"
```

### 2. Organize — Enforce 3-folder structure

```bash
# Create missing folders
mkdir -p "vault/project-name/docs/specs"
mkdir -p "vault/project-name/docs/plans"
mkdir -p "vault/project-name/Intelligence/decisions"
mkdir -p "vault/project-name/Intelligence/reports"
mkdir -p "vault/project-name/Intelligence/gaps"
mkdir -p "vault/project-name/Intelligence/templates"
mkdir -p "vault/project-name/_context"

# Move loose .md files into docs/
for f in $(obsidian files folder="project-name"); do
  if [ "$f" != "project-name/docs/*" ] && [ "$f" != "project-name/Intelligence/*" ] && [ "$f" != "project-name/_context/*" ]; then
    obsidian move file="$f" to="project-name/docs/"
  fi
done
```

### 3. Ingest — Pull working-directory docs into vault

```bash
# Copy specs from project dir
for f in project-dir/docs/superpowers/specs/*.md; do
  cp "$f" "vault/project-name/docs/specs/"
done
for f in project-dir/docs/superpowers/plans/*.md; do
  cp "$f" "vault/project-name/docs/plans/"
done

# Reindex
obsidian reload

# Delete from project dir after verify
rm -rf project-dir/docs
```

### 4. Intelligence — Bootstrap

```bash
# Create project hub
obsidian create name="project-name/Intelligence/_index" content="---\ntype: moc\npurpose: intelligence-hub\nproject: project-name\ntags: [intelligence, index]\n---\n\n# Intelligence — Project Name\n\n## Decision Trails\n| Decision | Date | Status |\n|---|---|---|\n\n## Reports\n| Report | Date | Type |\n|---|---|---|\n\n## Global Context\n- [[Intelligence/_index]] — Cross-project synthesis"

# Create templates
obsidian create name="project-name/Intelligence/templates/decision-trail" content="..."
```

### 5. Context — Build starting point

```bash
# Create project vault-map
obsidian create name="project-name/_context/vault-map" content="---\ntype: context\ntags: [context, vault-map]\n---\n\n# Vault Map — Project Name\n\n## Design Specs\n`docs/specs/` — Architecture and design documents\n\n## Plans\n`docs/plans/` — Implementation plans and roadmaps\n\n## Intelligence\n`Intelligence/` — Decision trails, reports, templates\n\n## How to Load Context\n1. **Always**: Read this note + `_context/active-projects`\n2. **On demand**: Read relevant spec or Intelligence note\n3. **Search only**: Archives, raw data\n→ Target: <3,000 tokens per task"

# Create project active-projects
obsidian create name="project-name/_context/active-projects" content="---\ntype: context\nproject: project-name\ntags: [context, active-projects]\n---\n\n# Active Projects — Project Name\n\n## Project State\n| Attribute | Value |\n|---|---|\n| **Status** | #project/planning |\n| **Priority** | P0 |\n| **Next Action** | TBD |\n\n## Global Context\n- [[_context/active-projects]] — All active projects\n- [[_context/coding-standards]] — Project-wide conventions\n- [[_context/vault-map]] — Vault navigation"
```

### 6. Link global context

```bash
# Update global active-projects
obsidian append file="_context/active-projects" content="\n| Project Name | #project/planning | P0 | Next action | [[Project - Name]] | [[project-name/_context/active-projects]] |"

# Update global _context to link to project
obsidian append file="_context/vault-map" content="\n## Projects\n- [[project-name/_context/vault-map]] — Project navigation"
```

### 7. Validate

```bash
obsidian unresolved path="project-name"
obsidian orphans  path="project-name"
obsidian deadends path="project-name"
```

Fix any broken links or orphaned notes before declaring complete.

---

## Frontmatter Convention (all project files)

```yaml
# docs/specs/ and docs/plans/
type: spec             # or type: plan
project: project-name
tags: [spec, project-name]

# Intelligence/
type: intelligence-report
report-type: decision | health | domain-extraction | gap-analysis
project: project-name
date: YYYY-MM-DD
tags: [intelligence, project-name]

# _context/
type: context
project: project-name
tags: [context, project-name]
```

---

## Token Budget per Session

| Step | Files | Tokens |
|---|---|---|
| Global `_context/` | 3 files | ~400 |
| Project `_context/` | 2 files | ~200 |
| Relevant spec | 1 file | ~800-2000 |
| **Total** | 6 files | **<3000** |

---

## Why This Pattern Exists

Without structure, every session starts with:
1. "Where are the docs?" — 5 minutes of searching
2. "What's the current state?" — 10 minutes of reading scattered notes
3. "What's the convention?" — Guessing or asking

With `vault-project-init`, every session starts the same way:
1. Load `_context/active-projects` — 200 tokens, know what's active
2. Load `project/_context/vault-map` — 200 tokens, know where things are
3. Load relevant spec — 1000 tokens, know what to do
