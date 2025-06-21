# AGENT.md - Sourcegraph Amp AUR Package

## Build/Test Commands

### Local Testing

- Test PKGBUILD: `cd sourcegraph-amp && makepkg -si`
- Check for updates: `./pkg.sh check-latest`
- Get current version: `./pkg.sh get-version [git_ref]`
- Manual update: `./pkg.sh update` (interactive)
- Generate .SRCINFO: `cd sourcegraph-amp && makepkg --printsrcinfo > .SRCINFO`
- Update checksums: `cd sourcegraph-amp && updpkgsums`

### Automated/CI Operations

- Automated update: `./pkg.sh update --ci` (non-interactive, auto-commits changes) (Runs in GitHub Actions)

## Architecture

- AUR package repository for Sourcegraph Amp CLI
- Core package files in `sourcegraph-amp/` directory (PKGBUILD, .SRCINFO)
- Package management orchestrated by `pkg.sh` script
- Version detection script in `scripts/get-version.sh`
- Automated dependency updates via Renovate

## Code Style

- Shell scripts use bash with `set -euo pipefail`
- Function-based modular design with single responsibility
- Color-coded output using ANSI escape sequences
- Interactive mode by default, `--ci` flag for automation
- Git-based version control with semantic commit messages
- Follow Arch Linux PKGBUILD standards and Node.js package guidelines
