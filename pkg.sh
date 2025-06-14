#!/bin/bash
# Generic Package Management Tool
#
# This script orchestrates focused utilities for package operations.
# Clean, modular design with single-responsibility utilities.

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
NPM_PACKAGE="@sourcegraph/amp"
PACKAGE_DIR="sourcegraph-amp"
PKGBUILD_PATH="$PACKAGE_DIR/PKGBUILD"

# Utility functions
eprint() {
	local message="$1"
	local color="${2:-$NC}"
	echo -e "${color}${message}${NC}" >&2
}

show_help() {
	eprint "Package Management Tool"
	eprint ""
	eprint "Usage: $0 [COMMAND] [OPTIONS]"
	eprint ""
	eprint "COMMANDS:"
	eprint "  update              Update package to latest version (default)"
	eprint "  check-latest        Check if update available"
	eprint "  get-version [ref]   Get package version (current or at git ref)"
	eprint "  help                Show this help"
	eprint ""
	eprint "OPTIONS:"
	eprint "  --ci                Run non-interactively"
}

# Command implementations
check_latest() {
	local current latest

	eprint "🔍 Checking for updates..." "$BLUE"

	current=$(./scripts/get-version.sh) || exit 1
	latest=$(npm view "$NPM_PACKAGE" version 2>/dev/null) || {
		eprint "❌ Failed to fetch latest version from npm" "$RED"
		exit 1
	}

	eprint "Current: $current" "$YELLOW"
	eprint "Latest:  $latest" "$GREEN"

	if [[ "$current" != "$latest" ]]; then
		eprint "📦 Update available: $current → $latest" "$YELLOW"
		echo "latest_version=$latest"
		return 0
	else
		eprint "✅ Already up to date" "$GREEN"
		return 1
	fi
}

get_version() {
	./scripts/get-version.sh "$@"
}

update_package() {
	local ci_mode="${1:-false}"
	local current latest

	# Check if update needed
	if ! output=$(check_latest); then
		eprint "No update needed" "$GREEN"
		return 0
	fi

	# Extract latest version from output
	latest=$(echo "$output" | grep "latest_version=" | cut -d= -f2)

	# Confirm update
	if [[ "$ci_mode" != "true" ]]; then
		read -p "Update to $latest? (y/N): " -n 1 -r
		echo
		[[ ! $REPLY =~ ^[Yy]$ ]] && {
			eprint "Cancelled" "$YELLOW"
			exit 0
		}
	fi

	eprint "🔧 Updating package..." "$BLUE"

	# Update PKGBUILD
	eprint "🔧 Updating PKGBUILD..." "$BLUE"
	sed -i "s/^_npmver=[^#]*/_npmver=$latest /" "$PKGBUILD_PATH"
	sed -i "s/^pkgrel=.*/pkgrel=1/" "$PKGBUILD_PATH"

	# Update checksums
	eprint "🔢 Updating checksums..." "$BLUE"
	if ! command -v updpkgsums >/dev/null 2>&1; then
		eprint "❌ updpkgsums not found - please install pacman-contrib" "$RED"
		git checkout -- "$PKGBUILD_PATH"
		exit 1
	fi
	(cd "$PACKAGE_DIR" && updpkgsums) || {
		eprint "❌ Failed to update checksums" "$RED"
		git checkout -- "$PKGBUILD_PATH"
		exit 1
	}

	# Generate .SRCINFO
	eprint "📄 Generating .SRCINFO..." "$BLUE"
	(cd "$PACKAGE_DIR" && makepkg --printsrcinfo >.SRCINFO) || {
		eprint "❌ Failed to generate .SRCINFO" "$RED"
		exit 1
	}

	# Show changes
	eprint "📝 Changes made:" "$BLUE"
	git diff "$PACKAGE_DIR/"

	# Commit
	if [[ "$ci_mode" == "true" ]]; then
		eprint "🤖 Auto-committing..." "$BLUE"
		git add "$PACKAGE_DIR/PKGBUILD" "$PACKAGE_DIR/.SRCINFO"
		git commit -m "chore(deps): update $NPM_PACKAGE to $latest"
	else
		read -p "Commit changes? (y/N): " -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			git add "$PACKAGE_DIR/PKGBUILD" "$PACKAGE_DIR/.SRCINFO"
			git commit -m "chore(deps): update $NPM_PACKAGE to $latest"
		fi
	fi

	eprint "✅ Update completed!" "$GREEN"
}

# Parse arguments
command="${1:-update}"
ci_mode="false"

case "$command" in
update)
	shift || true
	while [[ $# -gt 0 ]]; do
		case $1 in
		--ci)
			ci_mode="true"
			shift
			;;
		*)
			eprint "Unknown option: $1" "$RED"
			exit 1
			;;
		esac
	done
	update_package "$ci_mode"
	;;
check-latest)
	check_latest
	;;
get-version)
	shift || true
	get_version "$@"
	;;
help | -h | --help)
	show_help
	;;
*)
	eprint "Unknown command: $command" "$RED"
	show_help
	exit 1
	;;
esac
