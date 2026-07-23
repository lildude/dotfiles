---
name: gh-codespace-setup
description: Use when users ask to set up, connect to, or manage GitHub Codespaces with `gh codespace`/`gh cs`, especially for the `github` or `github-ui` repositories.
---

# GitHub Codespaces Setup with `gh codespace`

Use this skill when a user wants to create, open, connect to, or manage Codespaces from the terminal using GitHub CLI.

## Scope

This skill covers:

- Creating a Codespace for a repo
- Opening it in VS Code or JupyterLab
- Common lifecycle tasks (list, stop, delete, rebuild, logs, ports, ssh, cp, edit, view)
- Practical defaults for `github` and `github-ui` repos

## Defaults

When the user does not provide details:

- Prefer the repo they mention most recently (`github` or `github-ui`)
- Use the default branch
- Use a non-destructive flow first (`list`/`view`) before stop/delete
- Ask before destructive actions (`delete`)

## Prerequisites Checklist

Run and verify in order:

1. `gh --version`
2. `gh auth status`
3. `gh codespace --help`

If auth is missing, guide the user through:

- `gh auth login`

## Repo Resolution

Interpret repo names as:

- `github` → `github/github`
- `github-ui` → `github/github-ui`

## Fast Path: Create and Open

### Create a Codespace

Use:

- `gh codespace create --repo <owner>/<repo>`

Useful optional flags:

- `--branch <branch>`
- `--machine <machine-type>`
- `--idle-timeout <minutes>` (e.g., `30m`)
- `--retention-period <duration>`

### Open in VS Code

After create/list, open with:

- `gh codespace code --codespace <codespace-name>`

### Open in JupyterLab

- `gh codespace jupyter --codespace <codespace-name>`

## Day-2 Operations

- List: `gh codespace list`
- View details: `gh codespace view --codespace <name>`
- Edit settings: `gh codespace edit --codespace <name> [flags]`
- Stop: `gh codespace stop --codespace <name>`
- Delete: `gh codespace delete --codespace <name>`
- Rebuild: `gh codespace rebuild --codespace <name>`
- Logs: `gh codespace logs --codespace <name>`
- Ports: `gh codespace ports --codespace <name>`
- SSH: `gh codespace ssh --codespace <name>`
- Copy files: `gh codespace cp <source> <destination>`

## Suggested Agent Workflow

When helping a user, follow this order:

1. Confirm repo target (`github` or `github-ui`)
2. Verify `gh` + auth
3. Create Codespace (or reuse existing from `list`)
4. Connect (`code` or `ssh`)
5. Validate workspace readiness (basic repo checks)
6. Share next commands for daily management

## Common Scenarios

### Scenario A: Set up `github`

1. `gh codespace create --repo github/github`
2. `gh codespace list`
3. `gh codespace code --codespace <new-name>`

### Scenario B: Set up `github-ui`

1. `gh codespace create --repo github/github-ui`
2. `gh codespace list`
3. `gh codespace code --codespace <new-name>`

### Scenario C: Reconnect to an existing Codespace

1. `gh codespace list`
2. `gh codespace code --codespace <name>`

## Error Handling

If commands fail:

- Re-run with `--help` for command-level syntax check
- Confirm repo access permissions in GitHub
- Confirm the selected account with `gh auth status`
- For unhealthy environments, try `gh codespace rebuild --codespace <name>`
- For terminal-only access fallback, use `gh codespace ssh --codespace <name>`

## Response Style for This Skill

When executing this skill:

- Keep responses short and command-focused
- Prefer copy/paste-ready commands
- State assumptions explicitly (`<owner>`, branch, machine)
- Avoid destructive commands unless user asks or confirms