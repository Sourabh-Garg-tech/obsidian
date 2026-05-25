# Named Workflows

Detailed instructions for all `/obsidian <keyword>` workflows.

---

## Workflow Decision Tree

Use this tree to quickly find the right workflow:

```
What do you need?
│
├─ Start the day ──────────────────────── morning
├─ End the day ────────────────────────── evening
├─ Weekly review ──────────────────────── weekly
│
├─ Find something ────────────────────── search <query>
├─ Read a note ────────────────────────── read <name>
├─ Create a note ──────────────────────── create <name>
├─ Add to today's note ───────────────── daily <text>
├─ See my tasks ──────────────────────── tasks
├─ Work on a project ─────────────────── project <name>
│
├─ Ingest a web page/URL ─────────────── extract <url>
├─ Ingest a file into vault ──────────── ingest <source>
├─ Start a new project ───────────────── init <name>
│   (auto-detects CWD context if no name given)
├─ Log progress ──────────────────────── checkpoint <summary>
│
├─ Check vault health ─────────────────── health
├─ Find hub notes ────────────────────── hubs
├─ Find orphaned notes ───────────────── orphans
├─ Fix broken links ───────────────────── fix-links
├─ Check bidirectional links ──────────── backlinks
├─ Full intelligence scan ─────────────── intelligence
├─ Validate plugin structure ───────────── validate
├─ Create a canvas ────────────────────── canvas
├─ Create a base ─────────────────────── bases
│
├─ View session cache ────────────────── cache
├─ Reset session cache ───────────────── cache:clear
│
└─ Something else ────────────────────── treated as search query
```

**Thinking commands** (separate slash commands, not workflows):

| Command | Purpose |
|---------|---------|
| `/obsidian-trace <topic>` | How thinking evolved on a topic |
| `/obsidian-challenge <belief>` | Stress-test a belief with vault evidence |
| `/obsidian-connect <A, B>` | Find non-obvious connections between two domains |
| `/obsidian-emerge` | Surface latent ideas the vault implies |

## Auto-Context Behaviors

These fire automatically based on mode, time, and project state.

### Morning (6-11)

If today's daily note is empty, auto-populate:

```bash
# Yesterday's incomplete tasks (PowerShell for Windows colon commands)
powershell -c "obsidian 'daily:read' 'date=-1'" 2>/dev/null | grep "^\- \[ \]" | head -5
# Append to today's note
powershell -c "obsidian 'daily:append' 'content=- [ ] <yesterday incomplete tasks>'"
powershell -c "obsidian 'daily:append' 'content=
## Focus
<next action from active-projects>'"
```

### Evening (18+)

Show: "Run `/obsidian evening` to summarize today's work."

### Project Checkpoints (PROJECT MODE)

After a significant write operation (create, append, property:set, move), log a checkpoint:

```bash
powershell -c "obsidian 'append' 'path=<project>/Intelligence/daily/$(date +%Y-%m-%d).md' 'content=
## <checkpoint summary>
- What was done
- Decision: <if any>
- Next: <what follows>'"
```

Significant = decision recorded, status changed, new intelligence report, or multiple notes updated.

### Session Hot Cache

After any write, append a single line to `_context/session-cache.md`:

```bash
obsidian append path="_context/session-cache.md" content="- $(date +%Y-%m-%dT%H:%M) <symbol> <note-name> (<action>)"
```

Symbols: `+` created, `~` updated, `>` read (decision notes only). Max 10 entries; trim on stale reset. See `references/session-cache-workflow.md` for format details.

### Intelligence Auto-Run

- After `ingest` → hub detection + missing backlinks check
- After `create` with wikilinks → check if linked notes are hubs
- During `health` → include orphan count and broken link count

### Summary Format

```
## Obsidian [<MODE>] — <date>

**Focus:** <active project> — <phase/milestone> (P<#>)
**Next:** <next action from active-projects>
**Decision:** <latest decision + date>
**Gaps:** <domain gap count> (PROJECT MODE only)
**Tasks:** <today's open tasks from daily note>
**Checkpoint:** <project daily note updated> (PROJECT MODE only)
```

Every line actionable. Skip empty slots.

---

## Workflow Reference

| Keyword | Action | Details |
|---------|--------|---------|
| `morning` | Populate daily note with yesterday's tasks + today's focus from `_context/active-projects` | Runs morning auto-context |
| `evening` | Read today's daily note → summarize → append to daily + `_summaries/week-YYYY-WWW.md` | Also updates project daily note if PROJECT MODE |
| `weekly` | `obsidian tags sort=count counts` + intelligence report summary + update `_summaries/week-YYYY-WWW.md` | Weekly review automation |
| `health` | Run `scripts/vault-health.sh` (macOS/Linux) or `scripts/vault-health.ps1` (Windows), delegate to `obsidian-vault-architect` for scoring | Includes vault intelligence metrics |
| `validate` | Run `scripts/validate-skills.sh` (macOS/Linux) or `scripts/validate-skills.ps1` (Windows) | Validates plugin structure, frontmatter, links, and commands |
| `search <q>` | `obsidian search query="<q>" path="." format=json limit=10` | Falls back to plain text if JSON fails |
| `read <name>` | `obsidian read file="<name>"` | Resolves by wikilink name |
| `create <name>` | `obsidian create name="<name>" content="---\ntype: note\ncreated: <date>\ntags: []\n---\n\n# <name>\n"` | Creates with frontmatter |
| `daily <text>` | `obsidian daily:append content="<text>"` | Appends to today's daily note |
| `tasks` | PROJECT: read `<project>/_context/active-projects` and extract next actions. VAULT/EXTERNAL: `obsidian daily:read \| grep "^\- \[ \]" \| head -5` | Context-aware task list |
| `project <name>` | When in EXTERNAL MODE: pin `<name>` as `last-project` in session cache and load its context. When in vault: `obsidian search query="<name>" path="Projects/" format=json limit=10` | Find or pin project |
| `canvas` | Auto-load `json-canvas` sub-skill | Delegate to canvas skill |
| `bases` | Auto-load `obsidian-bases` sub-skill | Delegate to bases skill |
| `extract <url>` | Auto-load `defuddle` sub-skill | URL → clean markdown extraction |
| `init <name>` | Run `vault-project-init` workflow — detect project context from CWD, create 3-folder structure in vault, seed notes, link to global context | See `skills/obsidian-workflows/references/project-onboarding.md` |
| `checkpoint <summary>` | Manually log a checkpoint to `<project>/Intelligence/daily/YYYY-MM-DD.md` | PROJECT MODE only |
| `cache` | `obsidian read path="_context/session-cache.md"` | Read session hot cache |
| `cache:clear` | Create empty session cache | Resets touch log and narrative |
| `ingest <source>` | Preview-gated ingestion: extract → analyze → preview → approve → create → index | See `references/ingestion-workflow.md` |
| `intelligence` | Full vault intelligence scan: hubs + orphans + broken links + missing backlinks | See `references/vault-intelligence-workflow.md` |
| `hubs` | List top 10 hub notes by backlink count via `eval` | Notes with 10+ backlinks |
| `orphans` | Find orphaned notes + suggest connections via search | 0 backlink notes |
| `fix-links` | Scan unresolved links + suggest fixes via fuzzy match | Broken link repair |
| `backlinks` | Check for missing bidirectional links: compare `links` vs `backlinks` | Reverse link suggestions |

If keyword does not match any workflow, treat as search query.

---

## Quick Actions

Show 5 contextual suggestions adapted to mode, time, and project state:

- PROJECT MODE → tasks, checkpoint, read, search, init
- VAULT MODE → morning/evening, tasks, search, project, read
- EXTERNAL MODE → morning, search, read, project, init (if no project detected)
- Morning (6-11) → include `/obsidian morning`
- Evening (18+) → include `/obsidian evening`
- After write ops → hot cache auto-updates

Example output:
```
Try: /obsidian morning · search <q> · read <name> · tasks · project <name>
```
