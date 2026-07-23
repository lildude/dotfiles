# GitHub Codespaces Setup Skill

Set up, connect to, and manage GitHub Codespaces from the terminal using `gh codespace` / `gh cs`. Optimized for the `github` and `github-ui` repositories.

## When to Use This Skill

- Creating a new Codespace for a repository
- Opening an existing Codespace in VS Code or JupyterLab
- Managing Codespace lifecycle (list, stop, delete, rebuild)
- SSHing into a Codespace or copying files to/from it
- Troubleshooting Codespace connectivity issues

## Installation

### Personal Skills
```bash
cp -r gh-codespace-setup-skill ~/.copilot/skills/
```

### Project Skills
```bash
cp -r gh-codespace-setup-skill /path/to/repo/.github/skills/
```

## Usage

This skill activates when you ask Copilot to:
- "Set up a codespace for github"
- "Create a codespace for github-ui"
- "Connect to my codespace"
- "List my codespaces"
- "Open my codespace in VS Code"
- "SSH into my codespace"
- "Stop my codespace"

## Examples

See the [examples/](./examples/) directory for common workflows.

## Quick Reference

| Task | Command |
|------|---------|
| Create | `gh codespace create --repo <owner>/<repo>` |
| List | `gh codespace list` |
| Open in VS Code | `gh codespace code --codespace <name>` |
| SSH | `gh codespace ssh --codespace <name>` |
| Stop | `gh codespace stop --codespace <name>` |
| Delete | `gh codespace delete --codespace <name>` |
| Rebuild | `gh codespace rebuild --codespace <name>` |
| View logs | `gh codespace logs --codespace <name>` |
| Forward ports | `gh codespace ports --codespace <name>` |
| Copy files | `gh codespace cp <src> <dest>` |