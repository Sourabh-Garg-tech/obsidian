# Intelligence Patterns

Automated analysis patterns that combine CLI data-gathering with Claude's reasoning.
CLI is the execution layer; Claude is the intelligence layer.

---

## When to Use Claude vs Shell

| Task | Use | Why |
|---|---|---|
| Read/write files | CLI | Safe link preservation |
| Extract entities, suggest links | Claude | Requires reasoning |
| Pattern detection across notes | Claude + CLI | CLI gathers, Claude analyzes |
| Bulk file operations | CLI or Python | CLI for <500, Python for more |
| Decide what connects to what | Claude | Requires domain understanding |
| Execute the connections | CLI | Safe link updates |

---

## Intelligence Folder Scope: Global vs Project

For multi-project vaults, maintain two intelligence layers with a unified frontmatter schema.

**Global** (`Intelligence/` at vault root): cross-project synthesis, vault health, strategic decisions.  
**Project** (`project/Intelligence/`): architecture decisions, feature rationale, domain-to-code mapping.

**Frontmatter schema (both use same):**
```yaml
type: intelligence-report          # unified type for all intelligence
report-type: decision | health | domain-extraction | gap-analysis
date: YYYY-MM-DD
project: project-name              # omit for global
```

**Hub notes link both ways:**
- Global: `Intelligence/_index.md` (`type: moc`) links to each project's `_index.md`
- Project: `project/Intelligence/_index.md` (`type: moc`) links back to global

---

## Pattern 1: Auto-Linking Engine

Find notes that should be linked but aren't.

### Basic Flow

```bash
# Gather: find notes mentioning a topic
obsidian search query="machine learning" format=json
# **Windows:** `search` may return empty without `path=`. Include `path="Folder/"` or use Grep tool on vault directory as fallback.

# Reason: for each result, identify entities that match other note names
# Execute: add wikilinks using append
obsidian append file="Draft Note" content="\nSee also: [[Machine Learning Basics]]"
```

### Advanced: Link Suggestion Generation

```bash
# Find notes with shared keywords but no links
obsidian eval code='var files=app.vault.getMarkdownFiles();var pairs=[];for(var i=0;i<files.length;i++){for(var j=i+1;j<files.length;j++){var ci=app.metadataCache.getFileCache(files[i]);var cj=app.metadataCache.getFileCache(files[j]);if(!ci||!cj)continue;var li=ci.links||[];var lj=cj.links||[];var linked=li.some(l=>l.link===files[j].basename)||lj.some(l=>l.link===files[i].basename);if(linked)continue;var ti=(ci.tags||[]).map(t=>t.tag);var tj=(cj.tags||[]).map(t=>t.tag);var shared=ti.filter(t=>tj.includes(t));if(shared.length>=2)pairs.push({a:files[i].basename,b:files[j].basename,tags:shared});}}pairs.slice(0,10);'
```

**Use case:** Discover hidden connections between notes that share multiple tags but are not explicitly linked. Output is a list of note pairs with shared tags.

---

## Pattern 2: Hub Detection

Find notes with many connections (potential MOC candidates).

### Basic Hub Score

```bash
obsidian backlinks path="Key Concept.md" counts
obsidian links path="Key Concept.md" total
```

Notes with high backlink + outgoing link counts are hubs — good candidates for Maps of Content or index notes.

### Automated Hub Ranking

```bash
obsidian eval code='var notes=app.vault.getMarkdownFiles().map(f=>{var c=app.metadataCache.getFileCache(f);var bl=app.metadataCache.getBacklinksForFile(f);return{name:f.basename,backlinks:bl?bl.data.size:0,links:(c?.links||[]).length,score:(bl?bl.data.size:0)+(c?.links||[]).length};}).sort((a,b)=>b.score-a.score).slice(0,20);'
```

**Use case:** Identify the top 20 most connected notes in the vault. These are either existing hubs or notes that should become hubs.

### Hub Gap Analysis

```bash
# After ranking hubs, check if high-connectivity notes have MOCs
obsidian eval code='var hubs=app.vault.getMarkdownFiles().map(f=>{var c=app.metadataCache.getFileCache(f);var bl=app.metadataCache.getBacklinksForFile(f);return{name:f.basename,score:(bl?bl.data.size:0)+(c?.links||[]).length,type:(c?.frontmatter?.type||"none")};}).filter(h=>h.score>10&&!h.type.includes("moc")).slice(0,10);'
```

**Use case:** Find highly-connected notes that are NOT marked as MOCs. These are candidates for MOC creation.

> **Scaling:** For vaults >500 notes, use Python to iterate rather than per-note CLI calls.

---

## Pattern 3: Orphan Triage

Find and connect orphaned notes.

### Basic Triage

```bash
obsidian orphans                    # list all orphans
```

For each orphan:
1. Read the note content
2. Identify what it relates to
3. Add relevant wikilinks or tags
4. Move to appropriate folder if needed

### Batch Orphan Tagging

```bash
# Find orphans in a specific folder and auto-tag by folder
obsidian eval code='var orphans=app.vault.getMarkdownFiles().filter(f=>app.metadataCache.getBacklinksForFile(f).data.size===0);orphans.filter(f=>f.path.startsWith("Trading/")).forEach(f=>{var c=app.metadataCache.getFileCache(f);if(!c.frontmatter)c.frontmatter={};c.frontmatter.tags=[...(c.frontmatter.tags||[]),"needs-links"];});'
```

**Use case:** Auto-tag orphaned notes by folder with a "needs-links" tag, then triage them in batches.

### Orphan to MOC Matching

```bash
# Match orphans to the most relevant MOC based on folder proximity
obsidian eval code='var mocs=app.vault.getMarkdownFiles().filter(f=>{var c=app.metadataCache.getFileCache(f);return(c?.frontmatter?.type||"").includes("moc");}).map(f=>f.path);var orphans=app.vault.getMarkdownFiles().filter(f=>app.metadataCache.getBacklinksForFile(f).data.size===0);orphans.slice(0,10).map(f=>{var folder=f.path.split("/").slice(0,-1).join("/");var nearestMoc=mocs.find(m=>m.startsWith(folder));return{name:f.basename,folder:folder,suggestedMoc:nearestMoc||"None"};});'
```

**Use case:** For each orphan, suggest the nearest MOC based on folder path. Use the suggestion to add links.

---

## Pattern 4: Refactor — Merge Duplicate Notes

When two notes cover the same topic:

### Standard Merge

```bash
# Read both notes
obsidian read file="Note A"
obsidian read file="Note B"

# Create merged note with best content from both
obsidian create name="Merged Note" content="..."

# Move old notes to archive (preserves links in other notes)
obsidian move file="Note A" to="Archive/"
obsidian move file="Note B" to="Archive/"

# Update links pointing to old notes to point to merged note
```

### Automated Duplicate Detection

**Method 1: Exact normalized-name matches** (fast, works on any vault size)

```bash
# Find notes whose normalized names collide (case-insensitive, no punctuation)
obsidian eval code="var names={};app.vault.getMarkdownFiles().forEach(function(f){var n=f.basename.replace(/[^a-z0-9]/gi,'').toLowerCase();if(!names[n])names[n]=[];names[n].push(f.basename);});var dups=[];Object.keys(names).forEach(function(k){if(names[k].length>1)dups.push(names[k]);});dups.slice(0,20);"
```

**Use case:** Find notes with identical normalized names (e.g., `Technical Analysis.md` and `Technical Analysis(1).md` both normalize to `technicalanalysis`). These are near-certain duplicates.

**Method 2: Subset name matches** (one name contains another)

```bash
# Find notes where one normalized name is a substring of another (batched for large vaults)
# Adjust .slice() range for vaults >500 notes — process in batches of ~100
obsidian eval code="var names=app.vault.getMarkdownFiles().map(function(f){return f.basename;}).slice(0,100);var subs=[];for(var i=0;i<names.length;i++){for(var j=i+1;j<names.length;j++){var a=names[i].replace(/[^a-z0-9]/gi,'').toLowerCase();var b=names[j].replace(/[^a-z0-9]/gi,'').toLowerCase();if(a.length>5&&b.length>5&&(a.indexOf(b)!==-1||b.indexOf(a)!==-1))subs.push(names[i]+' <-> '+names[j]);}}subs.slice(0,20).join('; ');"
```

**Use case:** Find notes where one name is contained in another (e.g., "Motivation" inside "Trader mindset and motivation"). These are possible duplicates — read both before merging.

> **Scaling:** Method 1 is O(n) and works on any vault. Method 2 is O(n²) — for vaults >500 notes, run it in batches by changing `.slice(0,100)` to `.slice(100,200)`, `.slice(200,300)`, etc.

**Method 3: Numbered duplicate scan** (no eval needed)

```bash
# Find notes with (1), (2), (3) suffixes — these are always duplicates from Google Keep imports
obsidian files | grep -E '\([0-9]+\)'
```

**Use case:** The simplest and most reliable detection. Notes like `Nifty.md` and `Nifty(1).md` are always duplicates. No eval required.

---

## Pattern 5: Split Large Notes

When a note covers multiple topics:

### Standard Split

```bash
# Read the large note
obsidian read file="Big Note"

# Create separate notes for each topic
obsidian create name="Topic A" content="..."
obsidian create name="Topic B" content="..."

# Replace original with a hub note linking to the new notes
obsidian create name="Big Note" content="# Big Note\n\nSee [[Topic A]] and [[Topic B]]." overwrite
```

### Size-Based Split Detection

```bash
# Find the largest notes (candidates for splitting)
obsidian eval code='app.vault.getMarkdownFiles().map(f=>{var s=app.metadataCache.getFileCache(f)?.size||0;return{name:f.basename,size:s,path:f.path};}).sort((a,b)=>b.size-a.size).slice(0,20);'
```

**Use case:** Identify the 20 largest notes by word count. Notes over 2,000 words are often covering multiple topics and should be split.

---

## Pattern 6: Graph Health Report

Generate a snapshot of vault connectivity.

### Basic Health Check

```bash
obsidian unresolved total           # broken links
obsidian orphans total              # unlinked notes
obsidian deadends total             # dead-end notes
obsidian files total                # total notes
obsidian tags sort=count counts     # tag distribution
```

Use these metrics to track vault health over time.

### Comprehensive Health Dashboard

```bash
# Run all health metrics at once
obsidian eval code='var total=app.vault.getMarkdownFiles().length;var orphans=app.vault.getMarkdownFiles().filter(f=>app.metadataCache.getBacklinksForFile(f).data.size===0).length;var deadends=app.vault.getMarkdownFiles().filter(f=>(app.metadataCache.getFileCache(f)?.links||[]).length===0).length;var unresolved=app.vault.getMarkdownFiles().filter(f=>(app.metadataCache.getFileCache(f)?.frontmatter?.type==="unresolved")).length;var avgLinks=app.vault.getMarkdownFiles().reduce((sum,f)=>sum+(app.metadataCache.getFileCache(f)?.links||[]).length,0)/total;JSON.stringify({total,orphans,deadends,unresolved,avgLinks:avgLinks.toFixed(2),orphanRate:(orphans/total*100).toFixed(1),deadendRate:(deadends/total*100).toFixed(1)});'
```

**Use case:** Generate a JSON health snapshot with totals, rates, and averages. Store this in `Intelligence/vault-health-YYYY-MM-DD.md` to track trends.

### Health Trend Tracking

```bash
# Compare current health to previous report
obsidian read path="Intelligence/vault-health-2026-04-01.md"
obsidian read path="Intelligence/vault-health-2026-04-22.md"
```

**Use case:** Track whether orphan rate is improving or degrading over time.

---

## Pattern 7: Intelligence Generation with `eval`

Generate structured intelligence from vault data using `obsidian eval` to execute JavaScript against the Obsidian API.

### Data Extraction Scripts

```bash
# Count notes by folder
obsidian eval code="app.vault.getFiles().filter(f => f.extension === 'md').map(f => f.parent.path).reduce((a, p) => { a[p] = (a[p]||0)+1; return a; }, {})"

# Find notes without properties
obsidian eval code="app.vault.getMarkdownFiles().filter(f => Object.keys(app.metadataCache.getFileCache(f)?.frontmatter || {}).length === 0).map(f => f.path).join('\n')"

# List all unique tags
obsidian eval code="[...new Set(app.vault.getMarkdownFiles().flatMap(f => app.metadataCache.getFileCache(f)?.tags?.map(t => t.tag) || []))].sort().join('\n')"

# Notes created in the last 7 days
obsidian eval code="app.vault.getMarkdownFiles().filter(f => (Date.now() - f.stat.ctime) < 7*24*60*60*1000).map(f => f.path).join('\n')"

# Notes modified in the last 7 days
obsidian eval code="app.vault.getMarkdownFiles().filter(f => (Date.now() - f.stat.mtime) < 7*24*60*60*1000).map(f => f.path).join('\n')"

# Notes by frontmatter type
obsidian eval code='var types={};app.vault.getMarkdownFiles().forEach(f=>{var t=app.metadataCache.getFileCache(f)?.frontmatter?.type||"untagged";types[t]=(types[t]||0)+1;});JSON.stringify(types);'

# Find notes with the most outgoing links (information brokers)
obsidian eval code='app.vault.getMarkdownFiles().map(f=>{var c=app.metadataCache.getFileCache(f);return{name:f.basename,links:(c?.links||[]).length};}).sort((a,b)=>b.links-a.links).slice(0,15);'

# Find notes with the most backlinks (authority notes)
obsidian eval code='app.vault.getMarkdownFiles().map(f=>{var bl=app.metadataCache.getBacklinksForFile(f);return{name:f.basename,backlinks:bl?bl.data.size:0};}).sort((a,b)=>b.backlinks-a.backlinks).slice(0,15);'
```

**Pattern:** Use `eval` for one-off data extraction that the CLI does not expose directly. For repeated patterns, prefer CLI commands for readability. For complex multi-step analysis, pipe `eval` output to Claude for reasoning.

> **Scaling limit:** Complex `eval` scripts that iterate all files and call `getBacklinksForFile()` per file may silently return empty on vaults >500 notes. For large vaults, prefer CLI commands (`backlinks total`, `orphans total`) or split eval into smaller batches (`.slice(0,50)`).

---

## Pattern 8: Domain Knowledge to Implementation Intelligence

Bridge accumulated domain knowledge (trading, medicine, law, etc.) to code or project decisions.

### Phase 1: Inventory Domain Knowledge

```bash
# Count notes by domain folder
obsidian files folder="Domain/Subfolder" total

# List all tags in domain
obsidian tags file="Domain Note" counts

# Find compilation or MOC notes in domain
obsidian eval code='app.vault.getFiles().filter(f=>f.path.startsWith("Domain/")&&f.extension==="md").map(f=>{var c=app.metadataCache.getFileCache(f);return{name:f.basename,type:c?.frontmatter?.type||"none"};}).filter(n=>n.type.includes("moc")||n.type.includes("compilation"));'
```

### Phase 2: Extract Rules and Principles

```bash
# Gather all domain notes
obsidian files folder="Domain/Subfolder"

# Read and extract rules/patterns
obsidian read file="Key Rules"
obsidian read file="Principles"
obsidian read file="Patterns"

# Use eval to find notes with specific keywords (rule markers)
obsidian eval code='var keywords=["rule","principle","always","never","must","should not"];var notes=app.vault.getMarkdownFiles().filter(f=>f.path.startsWith("Domain/"));var results=[];for(var f of notes){var content=await app.vault.read(f);var matches=[];for(var kw of keywords){var regex=new RegExp(kw,"gi");var count=(content.match(regex)||[]).length;if(count>0)matches.push({keyword:kw,count:count});}if(matches.length>0)results.push({name:f.basename,matches:matches});}results.sort((a,b)=>{var sa=a.matches.reduce((s,m)=>s+m.count,0);var sb=b.matches.reduce((s,m)=>s+m.count,0);return sb-sa;}).slice(0,15);'
```

**Use case:** Find the 15 notes in a domain folder that contain the most rule-like keywords ("rule", "principle", "always", "never", etc.). These are likely to contain actionable domain wisdom.

### Phase 3: Map to Implementation

```bash
# Read a code architecture or community note
obsidian read path="project/_communities/Module Name.md"

# Search vault for related domain concepts
obsidian search query="concept OR pattern" path="Domain"

# Link documentation to domain knowledge
obsidian append file="Module Name" content="\n\n## Domain Knowledge\n- [[Key Principle]] — applies to this module\n"
```

### Phase 4: Generate Intelligence Report

```bash
obsidian create name="Intelligence/YYYY-MM-DD-domain-to-project" content="---
date: YYYY-MM-DD
type: intelligence-report
tags: [intelligence, domain-name]
---

# Domain-to-Project Intelligence Report

## Knowledge Inventory

| Category | Count | Key Insights |
|---|---|---|
| Total notes | N | Scope of domain knowledge |
| Rules extracted | N | Actionable principles |
| Patterns identified | N | Recurring themes |

## Extracted Rules

1. Rule 1 (from [[Source Note]])
2. Rule 2 (from [[Source Note]])

## Code Mapping

| Domain Concept | Implementation |
|---|---|
| Concept | module/file.py |

## Recommendations

1. Implementation recommendation 1
2. Implementation recommendation 2

## Next Steps

1. Read [[Analysis Notes]] for deeper patterns
2. Review [[Architecture]] for integration points
"
```

---

## Pattern 9: Accumulated Wisdom Extraction

Extract recurring themes and rules from a large body of domain notes.

### Step 1: Gather

```bash
# List all notes in a domain folder (files does not support format=json)
obsidian files folder="Domain/Subfolder"

# For structured JSON output, use search instead:
obsidian search query="" path="Domain/Subfolder" format=json

# Count notes per subfolder
obsidian eval code='var counts={};app.vault.getFiles().filter(f=>f.path.startsWith("Domain/")&&f.extension==="md").forEach(f=>{var parts=f.path.split("/");var sub=parts.slice(0,3).join("/");counts[sub]=(counts[sub]||0)+1;});JSON.stringify(counts);'
```

### Step 2: Prioritize

```bash
# Use wordcount to prioritize: short notes are often distilled rules
obsidian wordcount file="Key Rules"
obsidian wordcount file="Principles"

# Find notes with high link density (information-dense)
obsidian eval code='app.vault.getMarkdownFiles().filter(f=>f.path.startsWith("Domain/")).map(f=>{var c=app.metadataCache.getFileCache(f);var size=c?.size||1;var links=(c?.links||[]).length;return{name:f.basename,density:(links/size*1000).toFixed(2),links,size};}).sort((a,b)=>b.density-a.density).slice(0,15);'
```

**Use case:** Find notes with the highest link-per-word ratio. These are often densely-connected concept notes that bridge multiple ideas.

### Step 3: Extract

```bash
# Use eval to pull all frontmatter tags from a folder
obsidian eval code='app.vault.getFiles().filter(f => f.path.startsWith("Domain/Subfolder/") && f.extension === "md").map(f => { var cache = app.metadataCache.getFileCache(f); return { name: f.basename, tags: cache?.tags?.map(t => t.tag) || [], links: cache?.links?.length || 0 }; })'

# Extract all unique tags in domain with counts
obsidian eval code='var tagCounts={};app.vault.getMarkdownFiles().filter(f=>f.path.startsWith("Domain/")).forEach(f=>{(app.metadataCache.getFileCache(f)?.tags||[]).forEach(t=>{tagCounts[t.tag]=(tagCounts[t.tag]||0)+1;});});var sorted=Object.entries(tagCounts).sort((a,b)=>b[1]-a[1]);JSON.stringify(sorted.slice(0,20));'
```

### Step 4: Compile

Build a rule library from accumulated domain notes:
1. Find notes tagged with domain markers (e.g., `#rule`, `#principle`, `#pattern`)
2. Extract rules into a single compilation note in `Intelligence/`
3. Use the compilation to guide implementation
4. Update compilation periodically as new notes are added

---

## Pattern 10: Project Context Loading

Load the minimal vault context needed for a task, avoiding full-dump anti-patterns.

### Standard Context Stack

```bash
# For a coding task:
# 1. Load project architecture (always)
obsidian read path="project/docs/ARCHITECTURE.md"

# 2. Load relevant module documentation
obsidian read path="project/docs/MODULE.md"

# 3. Load relevant domain knowledge (2-3 notes max)
obsidian read file="Domain Principle 1"
obsidian read file="Domain Principle 2"

# 4. Load current implementation
obsidian read path="project/src/module.py"
```

**Token budget:** ~2,000 tokens for project docs + ~1,500 tokens for domain knowledge = **3,500 tokens total**.

**Never dump:** Do not load all domain notes. Do not load all project files. Select 3-5 max per task.

### Context Loading by Task Type

**For bug fixes:**
1. Load the failing test or error report
2. Load the relevant module docs
3. Load 1-2 domain notes related to the bug area

**For feature design:**
1. Load the architecture doc
2. Load the feature request or spec
3. Load 2-3 domain notes that inform the feature
4. Load similar existing implementations

**For code review:**
1. Load the code being reviewed
2. Load the module's documentation
3. Load 1 domain note if the code implements domain logic

### Quick Context Builder

```bash
# Build context for a specific file
obsidian eval code='var target="project/src/module.py";var file=app.vault.getAbstractFileByPath(target);var cache=app.metadataCache.getFileCache(file);var bl=app.metadataCache.getBacklinksForFile(file);var related=cache?.links?.map(l=>l.link).slice(0,5)||[];var blFiles=bl?Array.from(bl.data.keys()).slice(0,5).map(f=>f.basename):[];JSON.stringify({target,related,backlinks:blFiles});'
```

**Use case:** Given a target file, find its 5 most linked-to notes and 5 most linked-from notes. Use these as the context stack.

---

## Pattern 11: Decision Trail Documentation

When making project decisions, link back to vault knowledge to create an audit trail.

### Standard Decision Note

```bash
obsidian create name="Intelligence/YYYY-MM-DD-decision-name" content="---
date: YYYY-MM-DD
type: intelligence-report
report-type: decision
project: project-name
tags: [intelligence, decision, project-name]
---

# Decision: What was decided

## Rationale
Based on [[Domain Note]] and [[Principle Note]],
context and reasoning.

## Impact
- Change 1
- Change 2

## Code Changes
- file.py: change description

## Related
- [[Module Documentation]]
- [[Domain Principle]]"
```

**Use case:** Months later, when reviewing why a decision was made, the intelligence note provides full context with links to original domain knowledge.

> **Content safety:** Decision trails contain code references (`ClassName`, `file.py`). Bash interprets backticks as command substitution. For complex content, write the note body to a temp file first, then create: `obsidian create name="..." content="$(cat /tmp/note.md)"`. Or use the `Write` tool for notes with code blocks or tables.

### Decision Registry

```bash
# List all decisions for a project
obsidian files folder="Intelligence"
obsidian search query="type:decision project:project-name" path="Intelligence"

# Find decisions related to a specific module
obsidian search query="file.py" path="Intelligence"
```

**Use case:** Build a searchable decision registry. When onboarding new developers or reviewing legacy code, the registry explains the "why" behind each decision.

---

## Intelligence Report Templates

### Template 1: Domain Extraction Report

Store in: `Intelligence/YYYY-MM-DD-domain-extraction.md`

Purpose: Summarize rules, patterns, and principles extracted from a domain folder.

Sections:
- **Knowledge Inventory** — Table of note counts by subfolder
- **Top Principles** — List of extracted rules with sources
- **Code Mapping** — Table mapping domain concepts to code modules
- **Gaps** — Domain knowledge not yet reflected in code
- **Recommendations** — Prioritized actions

### Template 2: Project Health Report

Store in: `Intelligence/YYYY-MM-DD-project-health.md`

Purpose: Track vault health metrics over time.

Sections:
- **Metrics** — Total notes, orphans, deadends, unresolved, avg links
- **Trends** — Comparison to previous report
- **Priority Fixes** — Top 5 issues to address
- **Quick Wins** — Single-command fixes

### Template 3: Decision Audit Trail

Store in: `Intelligence/YYYY-MM-DD-decision-name.md`

Purpose: Document why a specific decision was made.

Sections:
- **Decision** — What was decided
- **Context** — Situation at the time
- **Rationale** — Why this decision, with vault links
- **Alternatives Considered** — Other options and why rejected
- **Impact** — Expected and actual outcomes
- **Code Changes** — Files modified
- **Reversal Criteria** — When to reconsider

### Template 4: Knowledge Gap Analysis

Store in: `Intelligence/YYYY-MM-DD-knowledge-gaps.md`

Purpose: Identify missing connections between domain knowledge and implementation.

Sections:
- **Domain Concepts Not in Code** — Knowledge without implementation
- **Code Without Domain Rationale** — Implementation without documented reasoning
- **Suggested Links** — New connections to create
- **MOCs Needed** — New index notes to create

---

## Pattern Combinations

### Combination 1: Weekly Intelligence Cycle

```
Monday:    Graph Health Report (Pattern 6)
Tuesday:   Orphan Triage (Pattern 3)
Wednesday: Hub Detection (Pattern 2)
Thursday:  Auto-Linking (Pattern 1)
Friday:    Decision Trail Review (Pattern 11)
```

### Combination 2: New Feature Workflow

```
1. Project Context Loading (Pattern 10)
   → Load architecture + module docs + domain notes
2. Domain Knowledge Validation (Pattern 8)
   → Search domain notes for relevant patterns
3. Decision Trail (Pattern 11)
   → Document design decisions with vault links
4. Intelligence Report (Template 3)
   → Summarize how domain knowledge informed the feature
```

### Combination 3: Vault Health Sprint

```
1. Graph Health Report (Pattern 6)
   → Identify top issues
2. Orphan Triage (Pattern 3)
   → Fix unlinked notes
3. Auto-Linking (Pattern 1)
   → Connect related orphans
4. Hub Detection (Pattern 2)
   → Create MOCs for high-connectivity notes
5. Health Report Update (Template 2)
   → Document improvements
```

---

## Vault Intelligence Workflow

For vaults that serve as knowledge bases for active projects:

```
Domain Notes (raw accumulation)
    |
    v
Intelligence Extraction (Patterns 8-9)
    |
    v
Intelligence/ Folder (compiled reports)
    |
    v
Project Context Loading (Pattern 10)
    |
    v
Implementation + Decision Trail (Pattern 11)
    |
    v
Back to Domain Notes (new learnings)
```

**The Intelligence folder** acts as the bridge between raw domain knowledge and project implementation. It is the layer where accumulated wisdom becomes actionable.

**Convention:** Store all intelligence reports and decision trails in `Intelligence/` at vault root. For multi-project vaults, see **Intelligence Folder Scope** at the top of this file for the project-level pattern.

---

## Pattern 12: Bootstrap Project Intelligence

When a new project needs its own Intelligence folder:

```bash
# 1. Create hub
obsidian create name="project/Intelligence/_index" content="---\ntype: moc\npurpose: intelligence-hub\nproject: project-name\ntags: [intelligence, index]\n---\n\n# Intelligence — Project Name\n\n## Decision Trails\n| Decision | Date | Status |\n|---|---|---|\n\n## Reports\n| Report | Date | Type |\n|---|---|---|\n\n## Global Context\n- [[Intelligence/_index]] — Cross-project synthesis"

# 2. Create first decision from template
obsidian create name="project/Intelligence/decisions/YYYY-MM-DD-decision-name" content="..."

# 3. Link global hub to project hub
obsidian append file="Intelligence/_index" content="\n| [[project/Intelligence/_index]] | Active | Project hub |"
```

**Project Intelligence structure:**
```
project/Intelligence/
├── _index.md              # type: moc — links to global Intelligence/_index
├── decisions/             # Pattern 11 decision trails
├── reports/                 # health, domain-extraction, gap-analysis
├── gaps/                    # knowledge-to-code gap notes
└── templates/               # copy to create new notes
```

**Frontmatter convention (all project intelligence):**
```yaml
type: intelligence-report          # unified type
report-type: decision | health | domain-extraction | gap-analysis
date: YYYY-MM-DD
project: project-name              # omit for global
tags: [intelligence, ...]
```

---

## Pattern 13: Project Initiate Workflow

Scaffold a new project into the vault with a consistent structure. See full reference: `project-onboarding.md`.

### The 3-Folder Rule

Every project uses exactly 3 top-level folders:

| Folder | Purpose |
|---|---|
| `docs/` | Design specs, plans, architecture |
| `Intelligence/` | Decision trails, reports, templates |
| `_context/` | Project state, conventions, vault-map |

Everything else goes into subfolders. No additional top-level folders.

### Quick Init

```bash
# 1. Create 3-folder scaffold
mkdir -p project/{docs/{specs,plans},Intelligence/{decisions,reports,gaps,templates},_context}

# 2. Create hub notes
obsidian create name="project/Intelligence/_index" content="..."
obsidian create name="project/_context/vault-map" content="..."
obsidian create name="project/_context/active-projects" content="..."

# 3. Link to global context
obsidian append file="_context/active-projects" content="| Project | [[project/_context/active-projects]] |"

# 4. Validate
obsidian unresolved path="project"
obsidian orphans  path="project"
```

### Why

Without structure, every session starts with searching for docs and guessing state. With this pattern, every session loads the same 2-3 context notes and is oriented in under 3,000 tokens.

→ Full workflow, templates, and validation: `project-onboarding.md`

---

## Pattern 14: Source Ingestion (Preview-Gated)

Ingest external sources into the vault as structured notes.

### When to Use

- You found a useful article, paper, or document and want to extract entities/concepts
- You want cross-referenced notes without manually creating each one
- You want a traceable link back to the original source

### Prerequisites

- `defuddle` sub-skill loaded (for URLs)
- `obsidian-cli` sub-skill loaded (for creation)
- Vault has a `Sources/` folder (create if missing)

### Phase 1: Extract

**For URLs:**
```bash
# Delegate to defuddle for clean markdown extraction
# The skill extracts article content, strips ads/headers
```

**For local files:**
```bash
obsidian read path="Downloads/article.md"
```

**For pasted text:**
- Treat as raw markdown source

### Phase 2: Analyze

Claude identifies from the source:
- **Entities** — named things (people, companies, products, tools)
- **Concepts** — abstract ideas (patterns, principles, methodologies)
- **Decisions** — explicit or implicit choices made by the author
- **Open questions** — gaps or unresolved points

### Phase 3: Preview

Show the user a structured preview before creating anything:

```
=== Ingestion Preview ===
Source: https://example.com/article
Notes to create: 4
- [[Entity Name]] (entity)
- [[Concept Name]] (concept)
- [[Open Question]] (question)
- [[Sources/Article Name|Source: Article Name]] (source index)
Proposed tags: #ingested #topic-name
Cross-links: [[Existing Note A]] [[Existing Note B]]
===
```

**User can:**
- Approve all (Y)
- Veto individual notes ("skip Entity Name")
- Rename notes ("call it 'Better Name'")
- Cancel entirely (N)

### Phase 4: Execute

For each approved note:
```bash
obsidian create name="Entity Name" content="---
type: entity
date: 2026-05-09
source: https://example.com/article
tags: [ingested]
---

# Entity Name

## Source
From [[Sources/Article Name|Source: Article Name]]

## Key Points
- ...

## See Also
- [[Concept Name]]"
```

### Phase 5: Index

Update or create `Sources/Article Name.md`:
```bash
obsidian create name="Sources/Article Name" content="---
type: source
date: 2026-05-09
source: https://example.com/article
url: https://example.com/article
tags: [source]
---

# Article Name

## Entities
- [[Entity Name]]

## Concepts
- [[Concept Name]]

## Decisions
- ...

## Open Questions
- ...
"
```

### Safety Gates

| Scenario | Gate |
|---|---|
| Note name collision | Append `(Source)` or ask user to rename |
| Source >10,000 words | Truncate to 5,000, ask if rest needed |
| 0 extractable notes | Stop, explain why |
| User rejects preview | Log cancellation to hot cache, stop |

### Frontmatter Convention

All ingested notes:
```yaml
---
type: entity | concept | source | question
date: YYYY-MM-DD
source: <original URL or file path>
tags: [ingested]
---
```

Source index notes additionally use:
```yaml
url: <original URL>
```

---

## Advanced: Custom Intelligence Queries

### Find Notes Created During a Specific Sprint

```bash
obsidian eval code='var sprintStart=new Date("2026-04-01").getTime();var sprintEnd=new Date("2026-04-15").getTime();app.vault.getMarkdownFiles().filter(f=>{var t=f.stat.ctime;return t>=sprintStart&&t<=sprintEnd;}).map(f=>({name:f.basename,created:new Date(f.stat.ctime).toISOString().split("T")[0]}));'
```

### Find the Most Referenced External Resources

```bash
obsidian eval code='var urls={};app.vault.getMarkdownFiles().forEach(f=>{(app.metadataCache.getFileCache(f)?.links||[]).filter(l=>l.link.startsWith("http")).forEach(l=>{urls[l.link]=(urls[l.link]||0)+1;});});var sorted=Object.entries(urls).sort((a,b)=>b[1]-a[1]);JSON.stringify(sorted.slice(0,10));'
```

### Find Notes That Need Summaries

```bash
obsidian eval code='app.vault.getMarkdownFiles().filter(f=>{(app.metadataCache.getFileCache(f)?.size||0)>1000&&!app.vault.getAbstractFileByPath("_summaries/"+f.basename)}).map(f=>({name:f.basename,size:app.metadataCache.getFileCache(f)?.size,path:f.path})).sort((a,b)=>b.size-a.size).slice(0,10);'
```

**Use case:** Find the 10 largest notes that don't have corresponding summary notes in `_summaries/`. These are candidates for summarization to improve token efficiency.