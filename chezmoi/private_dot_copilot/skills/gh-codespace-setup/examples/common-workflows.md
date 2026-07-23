# Common Codespace Workflows

## Create and open a Codespace for `github/github`

```bash
# Create
gh codespace create --repo github/github

# List to find the name
gh codespace list

# Open in VS Code
gh codespace code --codespace <codespace-name>
```

## Create a Codespace with custom settings

```bash
gh codespace create \
  --repo github/github-ui \
  --branch main \
  --machine largePremiumLinux \
  --idle-timeout 30m \
  --retention-period 720h
```

## Reconnect to an existing Codespace

```bash
# Find your Codespace
gh codespace list

# Open in VS Code
gh codespace code --codespace <codespace-name>

# Or connect via SSH
gh codespace ssh --codespace <codespace-name>
```

## Copy a file from your machine to a Codespace

```bash
gh codespace cp ./local-file.txt remote:/workspaces/github/
```

## Copy a file from a Codespace to your machine

```bash
gh codespace cp remote:/workspaces/github/output.log ./output.log
```

## Check forwarded ports

```bash
gh codespace ports --codespace <codespace-name>
```

## Rebuild a broken Codespace

```bash
gh codespace rebuild --codespace <codespace-name>
```

## Clean up: stop and delete

```bash
# Stop first
gh codespace stop --codespace <codespace-name>

# Then delete
gh codespace delete --codespace <codespace-name>
```