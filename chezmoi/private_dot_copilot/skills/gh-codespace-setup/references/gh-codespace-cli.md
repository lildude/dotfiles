# `gh codespace` CLI Reference

## Overview

`gh codespace` (alias `gh cs`) is the GitHub CLI command group for managing GitHub Codespaces from your terminal. It supports the full Codespace lifecycle: create, connect, manage, and delete.

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `create` | Create a new Codespace |
| `list` | List your Codespaces |
| `view` | View details of a Codespace |
| `edit` | Edit Codespace settings (display name, machine type) |
| `code` | Open a Codespace in VS Code |
| `jupyter` | Open a Codespace in JupyterLab |
| `ssh` | SSH into a Codespace |
| `cp` | Copy files to/from a Codespace |
| `stop` | Stop a running Codespace |
| `delete` | Delete a Codespace |
| `rebuild` | Rebuild a Codespace container |
| `logs` | Access Codespace creation logs |
| `ports` | List and manage forwarded ports |

## Create Flags

| Flag | Description |
|------|-------------|
| `--repo` | Target repository (e.g., `github/github`) |
| `--branch` | Git branch to use |
| `--machine` | Machine type (e.g., `basicLinux32gb`, `largePremiumLinux`) |
| `--idle-timeout` | Auto-stop after idle duration (e.g., `30m`) |
| `--retention-period` | How long to keep stopped Codespace (e.g., `720h`) |
| `--devcontainer-path` | Path to devcontainer.json |
| `--default-permissions` | Use default GitHub App permissions |

## Authentication

Codespace commands require GitHub CLI authentication:

```bash
# Check auth status
gh auth status

# Login if needed
gh auth login
```

## Further Reading

- [GitHub CLI Codespace docs](https://cli.github.com/manual/gh_codespace)
- [GitHub Codespaces documentation](https://docs.github.com/en/codespaces)