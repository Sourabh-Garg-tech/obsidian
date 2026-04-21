# Platform Setup

Obsidian CLI requires Obsidian v1.12.7+ with the CLI enabled.

## Enable CLI

1. Open Obsidian → Settings → General
2. Toggle **Command line interface** ON
3. Follow the prompt to register the CLI
4. Restart your terminal

## macOS

The CLI registration creates a symlink at `/usr/local/bin/obsidian`. This requires
administrator privileges — you will be prompted via a system dialog.

Verify:
```bash
ls -l /usr/local/bin/obsidian
```

If missing, create manually:
```bash
sudo ln -sf /Applications/Obsidian.app/Contents/MacOS/obsidian-cli /usr/local/bin/obsidian
```

If you previously registered with an older version, you may have a leftover PATH entry
in `~/.zprofile`. The new registration removes this automatically, but if it remains,
delete lines starting with `# Added by Obsidian` from `~/.zprofile`.

## Windows

Requires the Obsidian 1.12.7+ installer. Windows uses an `Obsidian.com` terminal
redirector that connects Obsidian to stdin/stdout.

**Must run with normal user privileges** — admin terminals produce silent failures.

The CLI registration adds Obsidian to your user's PATH. Restart your terminal after
registration.

### Git Bash / MSYS2 Issue

Bash resolves `obsidian` to `Obsidian.exe` (GUI) instead of `Obsidian.com` (CLI),
causing colon subcommands with parameters to fail with exit 127.

**Fix:** Create a wrapper script at `~/bin/obsidian`:
```bash
#!/bin/bash
/c/path/to/Obsidian.com "$@"
```

Then add to `~/.bashrc`:
```bash
export PATH="$HOME/bin:$PATH"
```

### Missing Obsidian.com

If colon subcommands (`property:set`, `daily:append`, etc.) return exit 127 even
from a normal terminal, check that `Obsidian.com` exists alongside `Obsidian.exe`.
If missing, you have an outdated installer — download the latest from
obsidian.md/download and reinstall.

## Linux

The CLI registration copies the binary to `~/.local/bin/obsidian`.

Ensure `~/.local/bin` is in your PATH:
```bash
export PATH="$PATH:$HOME/.local/bin"
```

Verify:
```bash
ls -l ~/.local/bin/obsidian
```

If missing, copy manually:
```bash
cp /path/to/Obsidian/obsidian-cli ~/.local/bin/obsidian
chmod 755 ~/.local/bin/obsidian
```

### Snap Warning

Snap packages restrict IPC and break the CLI. Use the `.deb` package instead.
If you must use snap: `sudo snap connect obsidian:system-observe` (may not fully resolve issues).

### Headless / Server Setup

For running Obsidian CLI on a headless Linux server:

1. Install the `.deb` package (not snap)
2. Install and start xvfb:
   ```bash
   Xvfb :5 -screen 0 1920x1080x24 &
   ```
3. Start Obsidian under xvfb:
   ```bash
   DISPLAY=:5 obsidian &
   ```
4. Run CLI commands:
   ```bash
   DISPLAY=:5 obsidian daily:read
   ```

### Systemd Service

If running as a systemd service, ensure `PrivateTmp=false` so the IPC socket
is accessible:

```ini
[Service]
PrivateTmp=false
```

Filter harmless GPU/Electron warnings:
```bash
DISPLAY=:5 obsidian search query="test" 2>/dev/null
```

## Multi-Vault

When multiple vaults are open, the CLI targets the most recently focused vault.
Pass `vault="Name"` explicitly to target a specific vault:

```bash
obsidian vault="My Vault" daily:read
```

> **Note:** On some environments, `obsidian vault="Name" command` returns
> `Error: Command "Name" not found`. If this occurs, omit the vault name and
> switch vaults in the Obsidian UI before running CLI commands.