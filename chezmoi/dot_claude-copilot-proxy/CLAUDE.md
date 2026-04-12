# CLAUDE.md - .claude-copilot-proxy

## Quick commands
- Setup (interactive): `./bin/setup.sh`
- Setup (non-interactive): `./bin/setup.sh --quiet`
- Start proxy: `./bin/start-proxy.sh`
- Update model aliases: `./bin/update-models.sh` (`--dry-run` supported)
- Uninstall: `./bin/uninstall.sh`
- Full tests: `./test/run-tests.sh`
- Quick tests (skip API calls): `./test/run-tests.sh --quick`
- Verbose tests: `./test/run-tests.sh --verbose`
- Syntax checks only: `./test/check-syntax.sh`
- Health check: `curl http://localhost:4000/health`

## Project structure
- `config.yaml`: Active LiteLLM proxy/router config
- `config.yaml.example`: Template config
- `bin/`: Entrypoint scripts (`setup.sh`, `start-proxy.sh`, `update-models.sh`, `uninstall.sh`)
- `lib/`: Reusable modules and platform abstractions
  - `common.sh`: logging/prompt helpers and shared constants
  - `detect.sh`: platform, package manager, init-system detection
  - `config.sh`: shell env configuration
  - `deps/`: dependency installers (`brew`, `apt`, `pip`) via `deps/main.sh`
  - `token/`: token backends (macOS Keychain, Linux secret-tool, env) via `token/main.sh`
  - `service/`: launchd/systemd/manual service setup via `service/main.sh`
- `test/`: shell-based test suite (`run-tests.sh` + `check-*.sh`)

## Architecture notes
- `bin/setup.sh` is the installer orchestration entrypoint and sources modules in this order:
  `lib/common.sh` -> `lib/detect.sh` -> `lib/config.sh` -> `lib/deps/main.sh` -> `lib/token/main.sh` -> `lib/service/main.sh`.
- `bin/start-proxy.sh` retrieves a token from platform backends (or env fallback) and starts LiteLLM on port `4000`.
- Routing is config-driven via `config.yaml` wildcard route to `github_copilot/*` plus alias mapping in `router_settings.model_group_alias`.

## Coding conventions
- Executable scripts use strict mode: `set -euo pipefail`.
- Function names are `snake_case`; shared constants are `UPPER_CASE`.
- Domain modules use a dispatcher pattern: each domain has `main.sh` that routes to platform-specific implementations.
- Always source `lib/common.sh` before modules that use `info/success/warn/error/fatal`.
- Prefer explicit fallback chains (`cmd_a || cmd_b || cmd_c`) rather than broad error suppression.

## Gotchas
- Default host in `config.yaml` is `0.0.0.0` (container-friendly). Use `127.0.0.1` if localhost-only is required.
- PAT handling is multi-backend; ensure token source is configured (Keychain/secret-tool/env) before starting proxy.
- Full test suite expects runtime conditions (port, health endpoint, API path); use `--quick` for local structure/syntax checks.
- No CI pipeline is defined in this directory; validation is script-driven.
