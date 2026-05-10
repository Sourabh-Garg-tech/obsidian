# Security Policy

## Supported Versions

Only the latest stable release is actively supported with security updates.

| Version | Supported          |
| ------- | ------------------ |
| 1.3.x   | :white_check_mark: |
| < 1.3   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability in the Obsidian Skill Suite, please
report it responsibly:

1. **Do not open a public issue.** Public issues may expose the vulnerability
   before a fix is available.
2. Open a private security advisory on the GitHub repository with the subject
   `[Security] obsidian-skill — <brief description>`.
3. Include:
   - A description of the vulnerability
   - Steps to reproduce (if applicable)
   - The potential impact
   - Any suggested fix or mitigation

You can expect:
- An acknowledgment within 48 hours
- A status update within 7 days
- A fix or mitigation plan within 30 days
- Public disclosure after the fix is released (with credit, if desired)

## What Qualifies as a Security Issue

Examples include:
- The skill inadvertently exposes vault contents or file paths to unauthorized
  parties
- A script allows unintended file system access outside the vault
- A validation bypass allows execution of untrusted commands
- Sensitive data (tokens, passwords) is logged or stored without encryption

## What Does Not Qualify

- Missing features or general improvements (use a feature request)
- Bugs that do not have security implications (use a bug report)
- Issues with Obsidian itself (report to Obsidian)

---

Thank you for helping keep the Obsidian Skill Suite safe for everyone.
