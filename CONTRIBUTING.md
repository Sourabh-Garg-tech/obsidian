# Contributing to Obsidian Skill

Thanks for your interest in making this skill better.

## Reporting bugs

Open an issue and use the Bug Report template. Include:
- Obsidian version
- Claude Code version
- Exact command that failed
- Expected vs actual behavior

## Suggesting features

Open an issue and use the Feature Request template. Describe:
- What problem it solves
- How you would use it
- Any examples from your workflow

## Pull requests

1. Fork the repo and create a branch: `git checkout -b feat/your-feature`
2. Make your changes
3. Update docs if behavior changes
4. Commit with a clear message: `docs:`, `feat:`, or `fix:` prefix
5. Open a PR against `master`

## Development setup

To install the skill locally for testing, copy or symlink this repository into your Claude Code skills directory:

```bash
# Copy
cp -r . ~/.claude/skills/obsidian

# Or symlink
ln -s $(pwd) ~/.claude/skills/obsidian
```

## Testing

Validate changes before submitting:

- Check that markdown renders correctly.
- Verify relative links point to existing files.
- Test commands against a test Obsidian vault.

## Licensing

All contributions are accepted under the MIT license.

## Issue templates

Use the templates in `.github/ISSUE_TEMPLATE/`:
- **Bug report** — for broken commands or incorrect behavior
- **Feature request** — for new commands, sub-skills, or workflow improvements

## Code style

- Markdown: 100-character line wrap
- Skill frontmatter: `description` uses YAML folded style (`>`) for readability; aim for conciseness
- Reference links: relative paths only
