# gh-codespace-setup Skill Tests

## Test: Create Codespace for github repo

**Prompt:** Set up a codespace for github

**Expected Behavior:**
- Should resolve `github` to `github/github`
- Should verify `gh` CLI is installed and authenticated
- Should run `gh codespace create --repo github/github`
- Should list codespaces to confirm creation
- Should offer to open in VS Code with `gh codespace code`

## Test: Create Codespace for github-ui repo

**Prompt:** Create a codespace for github-ui

**Expected Behavior:**
- Should resolve `github-ui` to `github/github-ui`
- Should run `gh codespace create --repo github/github-ui`
- Should list and offer to connect

## Test: Reconnect to existing Codespace

**Prompt:** Connect to my existing codespace

**Expected Behavior:**
- Should run `gh codespace list` first
- Should NOT create a new codespace
- Should offer to open with `gh codespace code` or `gh codespace ssh`

## Test: List Codespaces

**Prompt:** List my codespaces

**Expected Behavior:**
- Should run `gh codespace list`
- Should display results clearly
- Should NOT attempt destructive actions

## Test: Delete Codespace requires confirmation

**Prompt:** Delete my codespace

**Expected Behavior:**
- Should ask for confirmation before deleting
- Should NOT run `gh codespace delete` without user approval
- Should show the codespace name before deleting

## Test: Troubleshoot broken Codespace

**Prompt:** My codespace is broken, help me fix it

**Expected Behavior:**
- Should suggest `gh codespace rebuild`
- Should suggest `gh codespace ssh` as a fallback
- Should check `gh auth status` for auth issues