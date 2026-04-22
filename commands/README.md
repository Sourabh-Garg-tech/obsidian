# Thinking Commands

Slash commands that use the vault as context for reasoning. These are **read-only** — they never write to the vault.

## Installation

Copy the commands into your vault's `.claude/commands/` directory:

```bash
# Replace VAULT_PATH with your Obsidian vault path
cp commands/*.md VAULT_PATH/.claude/commands/
```

Or use the Obsidian CLI:

```bash
obsidian create name=".claude/commands/trace" template="trace"
obsidian create name=".claude/commands/challenge" template="challenge"
obsidian create name=".claude/commands/connect" template="connect"
obsidian create name=".claude/commands/emerge" template="emerge"
```

## Commands

| Command | Input | What it does |
|---|---|---|
| `/trace <topic>` | Concept or project name | Timeline of how thinking evolved on this topic |
| `/challenge <belief>` | Stated belief or plan | Vault-sourced counterarguments and past patterns |
| `/connect <A, B>` | Two domains | Non-obvious connections between seemingly unrelated topics |
| `/emerge` | None | Latent ideas the vault implies but hasn't stated |