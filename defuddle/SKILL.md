---
name: defuddle
description: >
  This skill should be used when the user asks to "extract markdown from web page",
  "clean web page content", "defuddle", "convert web page to markdown",
  "read article markdown", "extract article content", or provides a URL to a standard
  web page (not ending in .md) for reading or analysis. Use instead of WebFetch
  for online documentation, articles, blog posts, or any standard web page.
  Do NOT use for URLs ending in .md — those are already markdown, use WebFetch directly.
---

# Defuddle

Use Defuddle CLI to extract clean readable content from web pages. Prefer over WebFetch for standard web pages — it removes navigation, ads, and clutter, reducing token usage.

If not installed: `npm install -g defuddle`

## Usage

Always use `--md` for markdown output:

```bash
defuddle parse <url> --md
```

Save to file:

```bash
defuddle parse <url> --md -o content.md
```

Extract specific metadata:

```bash
defuddle parse <url> -p title
defuddle parse <url> -p description
defuddle parse <url> -p domain
```

## Output formats

| Flag | Format |
|------|--------|
| `--md` | Markdown (default choice) |
| `--json` | JSON with both HTML and markdown |
| (none) | HTML |
| `-p <name>` | Specific metadata property |