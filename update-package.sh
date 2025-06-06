#!/bin/bash
# AUR Package Update Script for sourcegraph-amp
#
# This script automatically updates the sourcegraph-amp AUR package to the latest
# version from npm. It handles version checking, PKGBUILD updates, checksum
# calculation, and git commits.
#
# Usage: ./update-package.sh
#
# Requirements: npm, curl, makepkg, updpkgsums (pacman-contrib), git

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variables
declare -g current_npmver latest_npmver
declare -g ci_mode=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
	case $1 in
	--ci | --non-interactive)
		ci_mode=true
		shift
		;;
	-h | --help)
		echo "Usage: $0 [--ci|--non-interactive]"
		echo "  --ci, --non-interactive  Run in non-interactive mode (for CI)"
		exit 0
		;;
	*)
		echo "Unknown option: $1"
		exit 1
		;;
	esac
done

# No cleanup needed

# Logging function
log() {
	local message="$1"
	local color="${2:-$NC}"
	echo -e "${color}${message}${NC}"
}

# Check current and latest versions
check_versions() {
	log "🔍 Checking for @sourcegraph/amp updates..." "$BLUE"

	# Get current version from PKGBUILD
	current_npmver=$(awk -F'=' '/^_npmver=/ {print $2}' PKGBUILD | cut -d' ' -f1)
	log "Current version: $current_npmver" "$YELLOW"

	# Get latest version from npm
	echo "Fetching latest version from npm..."
	latest_npmver=$(npm view @sourcegraph/amp version)
	log "Latest version:  $latest_npmver" "$GREEN"

	# Check if update is needed
	if [ "$current_npmver" = "$latest_npmver" ]; then
		log "✅ Already up to date!" "$GREEN"
		exit 0
	fi

	log "📦 Update available: $current_npmver → $latest_npmver" "$YELLOW"
}

# Ask for user confirmation
confirm_update() {
	if [ "$ci_mode" = true ]; then
		log "🤖 Running in CI mode - proceeding with update" "$BLUE"
		return
	fi

	read -p "Do you want to update? (y/N): " -n 1 -r
	echo
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		echo "Update cancelled."
		exit 0
	fi
}

# Update PKGBUILD with new version
update_pkgbuild() {
	log "🔧 Updating package..." "$BLUE"

	# Backup current PKGBUILD
	cp PKGBUILD PKGBUILD.backup
	echo "Backed up PKGBUILD to PKGBUILD.backup"

	# Update _npmver (preserve any existing comment)
	sed -i "s/^_npmver=[^# ]*/_npmver=$latest_npmver/" PKGBUILD
	log "✅ Updated _npmver" "$GREEN"

	# Reset pkgrel to 1
	sed -i "s/^pkgrel=.*/pkgrel=1/" PKGBUILD
	log "✅ Reset pkgrel to 1" "$GREEN"
}

# Test URL and update checksums
update_checksums() {
	local test_url="https://registry.npmjs.org/@sourcegraph/amp/-/amp-$latest_npmver.tgz"

	log "🔗 Testing URL accessibility: $test_url" "$BLUE"

	# Test URL with HEAD request (no download)
	if curl -L --head --silent --fail "$test_url" >/dev/null; then
		log "✅ URL is accessible" "$GREEN"

		# Use updpkgsums to update all checksums automatically
		log "🔢 Updating checksums..." "$BLUE"
		if command -v updpkgsums >/dev/null 2>&1; then
			updpkgsums
			log "✅ Updated checksums with updpkgsums" "$GREEN"
		else
			# Fallback for CI environments without updpkgsums
			log "🔄 updpkgsums not found - using manual checksum calculation" "$YELLOW"
			wget -q "https://registry.npmjs.org/@sourcegraph/amp/-/amp-$latest_npmver.tgz"
			new_checksum=$(sha256sum "amp-$latest_npmver.tgz" | cut -d' ' -f1)
			sed -i "s/^sha256sums=.*/sha256sums=('$new_checksum')/" PKGBUILD
			rm -f "amp-$latest_npmver.tgz"
			log "✅ Updated checksums manually" "$GREEN"
		fi
	else
		log "❌ URL test failed - restoring backup" "$RED"
		cp PKGBUILD.backup PKGBUILD
		exit 1
	fi
}

# Generate new .SRCINFO
generate_srcinfo() {
	log "📄 Generating new .SRCINFO..." "$BLUE"
	makepkg --printsrcinfo >.SRCINFO
	log "✅ Generated .SRCINFO" "$GREEN"
}

# Show summary and commit changes
commit_changes() {
	log "🎉 Update completed successfully!" "$GREEN"
	echo ""
	log "📋 Summary of changes:" "$BLUE"

	# Calculate pkgver for display
	pkgver_new=${latest_npmver//-/_}

	echo "• _npmver: $current_npmver → $latest_npmver"
	echo "• pkgver: → $pkgver_new"
	echo "• pkgrel: → 1"
	echo "• checksums: updated"
	echo "• .SRCINFO: regenerated"
	echo ""

	# Show the diff
	log "📝 Changes made:" "$BLUE"
	if [ "$ci_mode" = true ]; then
		git --no-pager diff PKGBUILD .SRCINFO
	else
		git diff PKGBUILD .SRCINFO
	fi

	# Commit automatically in CI mode
	if [ "$ci_mode" = true ]; then
		log "🤖 CI mode - automatically committing changes..." "$BLUE"
	else
		# Ask for confirmation to commit
		echo ""
		read -p "Do you want to commit these changes? (y/N): " -n 1 -r
		echo
		if [[ ! $REPLY =~ ^[Yy]$ ]]; then
			log "Commit cancelled. Changes are still applied to files." "$YELLOW"
			log "🔄 To restore backup: cp PKGBUILD.backup PKGBUILD" "$BLUE"
			exit 0
		fi
	fi

	# Commit the changes
	log "📦 Committing changes..." "$BLUE"
	git add PKGBUILD .SRCINFO
	git commit -m "chore(deps): update @sourcegraph/amp to $latest_npmver"
	log "✅ Changes committed successfully!" "$GREEN"

	if [ "$ci_mode" = false ]; then
		echo ""
		log "🔄 To undo: git reset --hard HEAD~1" "$BLUE"
	fi
}

# Main execution
main() {
	check_versions
	confirm_update
	update_pkgbuild
	update_checksums
	generate_srcinfo
	commit_changes
}

# Run main function
main
