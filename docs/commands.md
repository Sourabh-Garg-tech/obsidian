# Thinking Commands

Slash commands that use the vault as context for reasoning. These are **read-only** — they never write to the vault.

## Installation

These commands are included automatically when you install the Obsidian skill plugin. They appear as `/obsidian-trace`, `/obsidian-challenge`, `/obsidian-connect`, and `/obsidian-emerge` in the `/` command menu.

If you prefer to install only the commands (without the full skill suite), copy them into your vault's `.claude/commands/` directory:

```bash
# Replace VAULT_PATH with your Obsidian vault path
cp commands/obsidian-*.md VAULT_PATH/.claude/commands/
```

Or use the Obsidian CLI:

```bash
obsidian create name=".claude/commands/obsidian-trace" template="obsidian-trace"
obsidian create name=".claude/commands/obsidian-challenge" template="obsidian-challenge"
obsidian create name=".claude/commands/obsidian-connect" template="obsidian-connect"
obsidian create name=".claude/commands/obsidian-emerge" template="obsidian-emerge"
```

## Commands

| Command | Input | What it does |
|---|---|---|
| `/obsidian-trace <topic>` | Concept or project name | Timeline of how thinking evolved on this topic |
| `/obsidian-challenge <belief>` | Stated belief or plan | Vault-sourced counterarguments and past patterns |
| `/obsidian-connect <A, B>` | Two domains | Non-obvious connections between seemingly unrelated topics |
| `/obsidian-emerge` | None | Latent ideas the vault implies but hasn't stated |
| `/obsidian` | Optional keyword | Main gateway — auto-routes to vault mode, project mode, or quick actions |

All commands are prefixed with `obsidian-` so typing `/obsidian` in the command menu shows the full list.
