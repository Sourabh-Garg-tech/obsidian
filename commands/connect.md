---
description: Find non-obvious connections between two domains from the vault
argument-hint: "topic A, topic B"
---

# /connect — Cross-Domain Bridge

Find non-obvious connections between two seemingly unrelated domains, projects, or concepts from the vault.

## Input

Two topics: $ARGUMENTS (comma-separated, e.g., "filmmaking, startup fundraising")

## Steps

1. **Parse the two domains.** Split the input on comma. Call them A and B.

2. **Find notes for each domain.** `obsidian search` is unreliable. Use Grep instead:
   ```
   Grep: pattern="<A>" path="<vault>" glob="*.md" output_mode=files_with_matches
   Grep: pattern="<B>" path="<vault>" glob="*.md" output_mode=files_with_matches
   ```

3. **Find direct intersection.** Compare the two result sets. Notes that appear in BOTH are direct bridges. Read them.

4. **Find shared neighbors.** For the top 3-5 notes in each domain, run backlinks using `path=` (not `file=`):
   ```
   obsidian backlinks path="<note path>" format=json
   ```
   Notes that backlink to both domains are second-degree connections.

5. **Check tags for overlap.** Run:
   ```
   obsidian tags sort=count
   ```
   Tags used heavily in both domains suggest shared themes.

6. **Read the bridge notes.** Read any intersection or shared-neighbor notes found in steps 3-4. These contain the actual thinking to synthesize.

7. **Produce:**
   - **Direct connections** — notes mentioning both domains (list with one-line summary each)
   - **Second-degree connections** — notes linking to notes in both domains
   - **Shared language** — words, phrases, or frameworks that appear in both domains
   - **Synthesis** — one paragraph: what is the underlying connection? What idea does the vault suggest the user is circling without naming?
   - **Implication** — one actionable idea that follows from this connection

## Rules

- Only use vault evidence. No importing outside analogies.
- If no connections exist, say so — don't force a narrative.
- The synthesis should feel like "oh, that's what I've been reaching for" not "here's a clever comparison."
- If one domain has many more notes than the other, note the asymmetry — it may indicate where attention actually lies.