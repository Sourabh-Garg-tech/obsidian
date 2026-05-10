---
description: Surface latent ideas the vault implies but hasn't stated explicitly
argument-hint: ""
---

# /emerge — Latent Idea Surfacer

Surface ideas the vault implies but hasn't stated explicitly. Finds patterns in what the user has been writing about without consciously naming.

## Prerequisite

This command needs at least 2-3 weeks of daily notes to produce meaningful results. If the vault has fewer, say so and suggest running again after building more writing habit.

## Steps

1. **Get recent activity.** Run:
   ```
   obsidian recents
   ```
   These are the notes the user has been actively working with.

2. **Check what topics dominate.** Run:
   ```
   obsidian tags sort=count
   ```
   The top 10-15 tags reveal where attention has been concentrated.

3. **Read recent daily notes.** For the last 14-30 days, read daily notes:
   ```
   obsidian daily:read
   ```
   Also read recent dailies by adjusting the date. Daily notes contain raw, unfiltered thinking — the richest source for latent patterns.

4. **Find unconnected ideas.** Run:
   ```
   obsidian orphans
   ```
   Orphan notes may represent ideas the user hasn't integrated into their thinking yet. Read a sample (3-5).

5. **Find dead ends.** Run:
   ```
   obsidian deadends
   ```
   Notes with no outgoing links may represent topics the user hasn't explored further. Read a sample (3-5).

6. **Look for recurring phrases.** Use Grep across the vault to find repeated language:
   ```
   Grep: pattern="(always|never|should|need to|must|key|fundamental)" path="<vault>" glob="Daily Notes/*.md" output_mode=content
   ```
   Track repeated phrases, questions, or framings that appear across multiple days without a dedicated note.

7. **Produce 3-5 emergent theses**, each structured as:
   - **Statement** — "You seem to believe that..." (direct, first-person-to-second-person)
   - **Evidence** — 2-3 specific notes that imply this, with dates
   - **What's unspoken** — the edge of this idea that hasn't been articulated yet

## Rules

- Every thesis must reference specific notes. No generic observations.
- Phrase theses as things the user would recognize as true, not things they'd argue with.
- Don't confuse frequency with importance — a topic appearing often in daily notes matters more than one with many tags.
- If the vault is too thin to find patterns, say so honestly. Suggest: "Write daily notes for 2-3 more weeks, then try again."
- Never introduce ideas that aren't implied by the vault content. The theses should feel like the user said them already, just not out loud.