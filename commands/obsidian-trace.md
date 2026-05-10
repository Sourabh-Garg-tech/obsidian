---
description: (Obsidian) Trace how thinking on a topic has evolved across your vault
argument-hint: "topic"
---

# /trace — Idea Evolution Tracker

Trace how thinking on a topic has evolved across the vault. Uses ONLY what the user wrote — no outside perspective.

## Input

Topic: $ARGUMENTS

## Steps

1. **Find all mentions.** `obsidian search` is unreliable on some platforms. Use the Grep tool on the vault directory instead:
   ```
   Grep: pattern="$ARGUMENTS" path="<vault>" glob="*.md" output_mode=files_with_matches
   ```
   For line-level context:
   ```
   Grep: pattern="$ARGUMENTS" path="<vault>" glob="*.md" output_mode=content -C=2
   ```

2. **Check for a dedicated note.** Try both:
   ```
   obsidian read file="$ARGUMENTS"
   obsidian read path="$ARGUMENTS.md"
   ```
   If it exists, read it — it's likely the most structured thinking on this topic.

3. **Get the link neighborhood.** Use `path=` not `file=` (file= is unreliable):
   ```
   obsidian backlinks path="<path to note>" format=json
   ```
   If a dedicated note exists, its backlinks show who references this thinking.

4. **Read the actual notes.** From the search results, read the 5-8 most relevant notes (prioritize daily notes and project notes over reference material). Use `obsidian read path="<path>"` for each.

5. **Order chronologically.** Sort by file modification date or daily note date. Daily notes have dates in filenames — use those. For other notes, note the context of when they were written.

6. **Produce:**
   - **Timeline** — chronological list of how this topic appears, with one-line summary per entry and date
   - **Shifts** — where thinking changed direction, got more specific, or reversed. Quote the user's own words.
   - **Consistencies** — what stayed the same across all mentions
   - **Contradictions** — where old and current thinking conflict
   - **Earliest seed** — the first mention and what triggered it

## Rules

- Only use evidence from the vault. Never introduce outside arguments.
- Quote the user's actual words when showing shifts.
- If fewer than 3 notes mention the topic, say so and present what exists — don't fabricate a narrative.
- Daily notes are the richest source for raw thinking. Prioritize them.