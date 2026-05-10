# Token-Efficient Context Loading

Obsidian's biggest value for AI workflows is **selective retrieval** — loading only
the 2-5 notes relevant to the current task rather than pasting everything.

---

## The Anti-Pattern

Pasting entire vault content into a prompt wastes tokens and defeats the purpose.
Obsidian is external memory — reference it, do not dump it.

| Approach | Tokens per task |
|---|---|
| Raw prompting (repeat everything) | 10k - 50k |
| Obsidian, naive (dump whole vault) | same or worse |
| Obsidian + selective retrieval | 3k - 10k |
| Obsidian + retrieval + summaries | **500 - 3k** |

**Target:** under 3,000 tokens of loaded context per task.

---

## Context Loading Workflow

```
User task
   ↓
Load Intelligence/_index (global) + project/Intelligence/_index (project) — <300 tokens
   ↓
Search vault for relevant notes (2-5 max)
   ↓
Read only those notes
   ↓
Process
   ↓
Write result back to vault
```

---

## Three-Tier Vault Model

Organize notes by how often AI needs to read them:

| Tier | Load | Examples | Token budget |
|---|---|---|---|
| **Always** | Every session | `_context/`, `Intelligence/_index`, project `Intelligence/_index` | <500 tokens |
| **On demand** | When relevant | Research notes, references | 500-3000 tokens |
| **Never** | Search only | Archives, raw data | 0 tokens (search only) |

---

## The `_context/` Pattern

Keep a `_context/` folder at vault root **and** inside each project folder.

**Global `_context/`** (vault root):
```
_context/
├── active-projects.md     # index linking to each project's active-projects
├── coding-standards.md    # global conventions
├── vault-map.md           # vault-wide folder map
└── agent-instructions.md  # global agent behavior
```

**Project `_context/`** (per-project):
```
project/_context/
├── vault-map.md           # project folder map
├── active-projects.md     # this project's state
└── coding-standards.md    # project-specific overrides
```

**Loading order:**
1. Global `_context/active-projects` — find which project is active
2. Project `_context/vault-map` — navigate that project's structure
3. Project `_context/active-projects` — know that project's current state

Keep each under 100 words. Global active-projects is an index; project active-projects is the detail.

---

## Summary Note Patterns

Create rolling summaries that compress information:

- **Weekly summary**: Auto-generated from daily notes, 200-500 words
- **Project status**: 1-2 sentences per project, updated on change
- **Decision log**: Chronological record of key decisions and rationale

---

## RAG-Lite Retrieval

Approximate vector retrieval using keyword search + graph traversal:

1. **Keyword search**: `obsidian search query="topic" format=json` → get seed notes
2. **Graph expansion**: For each seed, check `obsidian backlinks` and `obsidian links` → find related notes
3. **Filter by relevance**: Read only the top 2-5 most connected notes
4. **Summarize if large**: If a note is >2000 words, summarize it before loading into context

This approximates semantic search without requiring embeddings.

---

## Retrieval by Task Type

| Task | Retrieval strategy |
|---|---|
| "Find notes about X" | Search + read top 3 results |
| "What's the status of project X?" | Read project summary + recent daily notes |
| "Connect note A to related notes" | Search for terms in A, check backlinks of A |
| "Weekly review" | Read last 7 daily notes (summarize if needed) |
| "Fix broken links" | `obsidian unresolved` → read source notes → fix |