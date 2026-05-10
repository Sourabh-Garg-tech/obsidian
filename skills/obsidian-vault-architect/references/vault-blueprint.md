# Vault Blueprint — Reference

The ideal vault structure for token-efficient AI workflows. All audits measure against this blueprint.

---

## Folder Hierarchy

```
vault/
├── _context/                    ← Tier 1: Always-loaded session constants
│   ├── coding-standards.md
│   ├── architecture.md
│   ├── agent-instructions.md
│   ├── glossary.md
│   └── current-sprint.md
│
├── _summaries/                  ← Tier 2: Pre-computed lookups
│   ├── week-YYYY-WW.md
│   ├── project-X-status.md
│   └── decisions-log.md
│
├── Templates/                   ← Note templates (Obsidian Templates plugin)
│
├── Projects/                    ← Tier 2: Active project notes
│   └── <project-name>/
│       ├── README.md
│       └── ...
│
├── Areas/                       ← Tier 2: Ongoing responsibility areas
│
├── Resources/                   ← Tier 2: Reference material
│
├── Archive/                     ← Tier 3: Cold storage
│
├── Daily Notes/                 ← Tier 3: Raw capture (never load directly)
│
├── Inbox/                       ← Tier 3: Unprocessed items
│
└── .obsidian/                   ← Obsidian config (never edit directly)
```

---

## Required Folders

| Folder | Tier | Required | Purpose |
|---|---|---|---|
| `_context/` | 1 | Yes | Always-loaded session constants |
| `_summaries/` | 2 | Yes | Pre-computed lookups |
| `Projects/` | 2 | Yes | Active project notes |
| `Archive/` | 3 | Yes | Cold storage |
| `Daily Notes/` | 3 | Yes | Raw capture |
| `Inbox/` | 3 | Yes | Unprocessed items |
| `Templates/` | N/A | Recommended | Note templates |
| `Areas/` | 2 | Optional | PARA-style areas |
| `Resources/` | 2 | Optional | Reference material |

---

## Naming Rules

| Rule | Pattern | Valid | Invalid |
|---|---|---|---|
| Note files | `kebab-case.md` | `rate-limiter.md` | `Rate Limiter.md`, `rate_limiter.md` |
| Daily notes | `YYYY-MM-DD.md` | `2026-04-21.md` | `Apr 21.md`, `21-04-2026.md` |
| Weekly summaries | `week-YYYY-WW.md` | `week-2026-16.md` | `week 16.md` |
| Project status | `project-<name>-status.md` | `project-auth-status.md` | `Auth Status.md` |
| Context files | lowercase, hyphenated | `coding-standards.md` | `CodingStandards.md` |
| Folder names | `PascalCase` or `kebab-case` | `Projects/`, `rate-limiter/` | `my projects/` |

### Naming Check Commands

```bash
# Files with spaces in name
obsidian files | grep ' '

# Files not in kebab-case (excluding daily notes and special patterns)
obsidian files | grep -v '^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}' | grep -v '^_' | grep '[A-Z_]'
```

---

## Tier Assignment Rules

| Folder | Tier | Load strategy | Token budget |
|---|---|---|---|
| `_context/` | 1 | Always load at session start | <400 tokens total |
| `_summaries/` | 2 | Load when relevant to current task | 300-1500 tokens |
| `Projects/`, `Areas/`, `Resources/` | 2 | Search + load 2-5 specific notes | 300-1500 tokens |
| `Archive/`, `Daily Notes/`, `Inbox/` | 3 | Never load directly; use summaries | 0 tokens |
| `Templates/` | N/A | Only read by `obsidian create template=` | On demand |

### Tier 1 Size Limits

Each `_context/` file should be under 200 words (~120 tokens). The entire `_context/` folder should total under 400 tokens. If any file exceeds this, it should be summarized or split.

---

## PKM Method Detection

When auditing a vault, detect the organizational method from folder structure:

| Folders detected | Likely method |
|---|---|
| `Projects/`, `Areas/`, `Resources/`, `Archive/` | PARA |
| `01 Fleeting/`, `02 Literature/`, `03 Permanent/` | Zettelkasten |
| `MOC/`, `Map of Content` files | LYT/Linking |
| `Inbox/`, `Next Actions/`, `Someday/` | GTD |

The audit scores against the 3-tier model regardless of PKM method. PARA/Zettelkasten/GDT users should still have `_context/` and `_summaries/` for AI token efficiency.

---

## Anti-Patterns to Flag

| Anti-pattern | Why it's bad | Fix |
|---|---|---|
| No `_context/` folder | Every session re-explains architecture, wasting tokens | `mkdir _context && obsidian reload` |
| No `_summaries/` folder | Daily notes loaded raw instead of summarized | `mkdir _summaries && obsidian reload` |
| Oversized `_context/` files | Exceeds 400-token budget per session | Split into smaller files |
| Stray `.md` files at vault root | Disorganized, no tier assignment | Move to appropriate folder |
| Files with spaces in name | Inconsistent, breaks CLI commands on some systems | `obsidian rename` to kebab-case |
| Missing `tags` property | Can't search by tag, can't auto-link | `property:set` to add tags |
| Missing `type` property on typed notes | Can't filter by note type | `property:set` to add type |
| No weekly summaries | Daily notes loaded raw (expensive) | Create `_summaries/week-YYYY-WW.md` |