---
description: (Obsidian) Stress-test a belief using evidence from your vault's own history
argument-hint: "belief or plan"
---

# /challenge — Belief Pressure-Tester

Stress-test a belief or plan using evidence from the vault's own history. The challenge comes from the user's past writing, not generic devil's advocacy.

## Input

Belief or plan: $ARGUMENTS

## Steps

1. **Search for direct mentions.** `obsidian search` is unreliable on some platforms. Use Grep instead:
   ```
   Grep: pattern="$ARGUMENTS" path="<vault>" glob="*.md" output_mode=files_with_matches
   ```
   Read the top 5-8 matching notes.

2. **Search for doubt and risk language.** Use Grep with combined patterns:
   ```
   Grep: pattern="($ARGUMENTS).{0,30}(risk|doubt|worried|concern|but|however|problem)" path="<vault>" glob="*.md" output_mode=content -C=2
   ```
   Also search separately for common hesitation signals:
   ```
   Grep: pattern="(risk|doubt|worried|concern)" path="<vault>" glob="*.md" output_mode=content -C=1
   ```
   Cross-reference with notes that also mention the topic.

3. **Check for past predictions.** Use Grep:
   ```
   Grep: pattern="($ARGUMENTS).{0,30}(will|should|going to|plan)" path="<vault>" glob="*.md" output_mode=content -C=2
   ```
   Look for past claims about what would happen — did they play out?

4. **Find similar past decisions.** If the topic is a plan ("go full-time on X", "launch Y"), search for analogous past decisions:
   ```
   Grep: pattern="(decided|started|committed|launched)" path="<vault>" glob="*.md" output_mode=content -C=2
   ```
   Read any that seem structurally similar.

5. **Produce:**
   - **The belief** — restate it clearly in one sentence
   - **Supporting evidence** — quotes from the vault that align with this belief
   - **Counter-evidence** — quotes from the vault that contradict or question it (label source + date)
   - **Past pattern** — has the user made similar decisions before? What happened?
   - **Unresolved tension** — what the vault hasn't resolved yet about this topic
   - **Verdict** — not a recommendation, but a structured summary: "Your vault says X on one hand, Y on the other. The unresolved question is Z."

## Rules

- Every counterargument must trace to a specific note. No generic devil's advocacy.
- If the vault has no counter-evidence, say so honestly — don't invent doubt.
- Never use Claude's training data as evidence. Only the vault.
- Present both sides with equal weight. Don't steer.