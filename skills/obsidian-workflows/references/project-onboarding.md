# Project Onboarding — `vault-project-init`

Scaffold a new project into the vault with a consistent 3-folder structure. Detects project context from the current working directory.

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

## Auto-Detection

When `/obsidian` is invoked from outside the vault and no matching project is found, the skill scans the CWD for project markers:

| Marker | Detects |
|---|---|
| `.git/` | Git project |
| `README.md` | Project description (read first line for project name) |
| `CLAUDE.md` | AI context (read for project name and conventions) |
| `package.json` | Node.js project (extract `name` field) |
| `pyproject.toml` | Python project (extract project name) |
| `Cargo.toml` | Rust project |
| `go.mod` | Go project |
| `Makefile` | C/C++ or build-based project |

If 2+ markers are found, the skill suggests: "I detected you're in `<project-name>` but it has no vault project yet. Run `/obsidian init` to set up `Projects/<project-name>` in your vault?"

The project name is extracted in this priority:
1. `CLAUDE.md` project name (if present)
2. `package.json` `name` field
3. `pyproject.toml` `[project] name` field
4. CWD directory basename (fallback)

---

## The `vault-project-init` Workflow

### 1. Discover

```bash
# Get vault path
obsidian vaults

# Check if project already exists
obsidian search query="path:<project-name>" path="Projects/" format=json limit=1
```

If the project folder does not exist, create it. If it exists but lacks `_context/`, `docs/`, or `Intelligence/`, offer to add the missing structure.

### 2. Create Structure — Using Obsidian CLI (never raw mkdir/cp)

All folder creation goes through `obsidian create` with placeholder notes to establish the folder structure:

```bash
# Create folder structure with placeholder notes
obsidian create name="<project>/docs/specs/.keep" content="---\ntype: placeholder\n---"
obsidian create name="<project>/docs/plans/.keep" content="---\ntype: placeholder\n---"
obsidian create name="<project>/Intelligence/decisions/.keep" content="---\ntype: placeholder\n---"
obsidian create name="<project>/Intelligence/reports/.keep" content="---\ntype: placeholder\n---"
obsidian create name="<project>/Intelligence/gaps/.keep" content="---\ntype: placeholder\n---"
obsidian create name="<project>/Intelligence/templates/.keep" content="---\ntype: placeholder\n---"
obsidian create name="<project>/_context/.keep" content="---\ntype: placeholder\n---"
```

Move loose `.md` files into `docs/`:
```bash
# For each file in the project that's not in the 3 folders
obsidian files folder="<project>"
# → move each stray file to <project>/docs/ using:
obsidian move file="<project>/<stray-note>" to="<project>/docs/"
```

### 3. Ingest — Pull project context into vault

Read project context files from CWD and create vault notes using `obsidian create` (never raw `cp`):

```bash
# Read CLAUDE.md from project dir for context
# (use file read tools, then create vault notes)

# Create vault note from project README
obsidian create name="<project>/docs/README" content="# <project>\n\n<!-- Imported from project README -->\n<readme content>"

# Create vault note from CLAUDE.md conventions
obsidian create name="<project>/_context/coding-standards" content="# Coding Standards\n\n<!-- Imported from CLAUDE.md -->\n<conventions content>"

# Reindex after bulk creation
obsidian reload
```

**Important:** Never use `cp` or `rm -rf` on vault files. Use `obsidian create` to copy content into vault notes, and `obsidian delete` to remove vault files. The original project directory files remain untouched.

### 4. Intelligence — Bootstrap

```bash
# Create project hub
obsidian create name="<project>/Intelligence/_index" content="---\ntype: moc\npurpose: intelligence-hub\nproject: <project>\ntags: [intelligence, index]\n---\n\n# Intelligence — <Project>\n\n## Decision Trails\n| Decision | Date | Status |\n|---|---|---|\n\n## Reports\n| Report | Date | Type |\n|---|---|---|\n\n## Global Context\n- [[Intelligence/_index]] — Cross-project synthesis"

# Create decision trail template
obsidian create name="<project>/Intelligence/templates/decision-trail" content="---\ntype: intelligence-report\nreport-type: decision\nproject: <project>\ndate: <today>\ntags: [intelligence, decision, <project>]\n---\n\n# Decision: <title>\n\n## Context\n\n## Decision\n\n## Consequences\n\n## Alternatives Considered"
```

### 5. Context — Build starting point

```bash
# Create project vault-map
obsidian create name="<project>/_context/vault-map" content="---\ntype: context\ntags: [context, vault-map]\nproject: <project>\n---\n\n# Vault Map — <Project>\n\n## Design Specs\n`docs/specs/` — Architecture and design documents\n\n## Plans\n`docs/plans/` — Implementation plans and roadmaps\n\n## Intelligence\n`Intelligence/` — Decision trails, reports, templates\n\n## How to Load Context\n1. **Always**: Read this note + `_context/active-projects`\n2. **On demand**: Read relevant spec or Intelligence note\n3. **Search only**: Archives, raw data\n→ Target: <3,000 tokens per task"

# Create project active-projects
obsidian create name="<project>/_context/active-projects" content="---\ntype: context\nproject: <project>\ntags: [context, active-projects]\n---\n\n# Active Projects — <Project>\n\n## Project State\n| Attribute | Value |\n|---|---|\n| **Status** | #project/planning |\n| **Priority** | P0 |\n| **Next Action** | TBD |\n\n## Global Context\n- [[_context/active-projects]] — All active projects\n- [[_context/coding-standards]] — Project-wide conventions\n- [[<project>/_context/vault-map]] — Project navigation"
```

### 6. Link global context

```bash
# Update global active-projects
obsidian append file="_context/active-projects" content="\n| <Project> | #project/planning | P0 | Next action | [[<project>/_context/active-projects]] |"

# Update global vault-map to link to project
obsidian append file="_context/vault-map" content="\n## Projects\n- [[<project>/_context/vault-map]] — <Project> navigation"

# Set session cache to this project
obsidian create path="_context/session-cache.md" content="---\ntype: session-cache\ndate: <today>\ntags: [system]\nlast-project: <project>\n---\n" overwrite
```

### 7. Validate

```bash
obsidian unresolved path="<project>"
obsidian orphans path="<project>"
obsidian deadends path="<project>"
```

Fix any broken links or orphaned notes before declaring complete.

---

## Frontmatter Convention (all project files)

```yaml
# docs/specs/ and docs/plans/
type: spec             # or type: plan
project: <project>
tags: [spec, <project>]

# Intelligence/
type: intelligence-report
report-type: decision | health | domain-extraction | gap-analysis
project: <project>
date: YYYY-MM-DD
tags: [intelligence, <project>]

# _context/
type: context
project: <project>
tags: [context, <project>]
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

---

## Safety Rules

1. **Never use `mkdir -p`** for vault folders — use `obsidian create` with placeholder notes to establish the folder structure
2. **Never use `cp`** to copy files into the vault — use `obsidian create` to create new vault notes from content read via file tools
3. **Never use `rm -rf`** to remove files from the project directory — the project directory stays untouched; only vault files are managed
4. **Always run `obsidian reload`** after bulk creation of 5+ notes