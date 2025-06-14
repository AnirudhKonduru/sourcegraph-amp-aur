#!/bin/bash
# Get _npmver from PKGBUILD at current working tree or any git ref
# Usage: get-version.sh [git_ref] [pkgbuild_path]

set -euo pipefail

git_ref="${1:-}"
pkgbuild_path="${2:-sourcegraph-amp/PKGBUILD}"

if [[ -z "$git_ref" ]]; then
	# No ref specified - get current version from working tree
	if [[ ! -f "$pkgbuild_path" ]]; then
		echo "PKGBUILD not found: $pkgbuild_path" >&2
		exit 1
	fi

	awk -F'=' '/^_npmver=/ {
		version = $2
		gsub(/^[ \t]+|[ \t]+$/, "", version)
		gsub(/#.*$/, "", version)
		gsub(/[ \t]+$/, "", version)
		print version
		exit
	}' "$pkgbuild_path"
else
	# Git ref specified - get version from that ref
	if ! git cat-file -e "$git_ref:$pkgbuild_path" 2>/dev/null; then
		echo "File $pkgbuild_path not found at ref $git_ref" >&2
		exit 1
	fi

	git show "$git_ref:$pkgbuild_path" 2>/dev/null |
		awk -F'=' '/^_npmver=/ {
		version = $2
		gsub(/^[ \t]+|[ \t]+$/, "", version)
		gsub(/#.*$/, "", version)
		gsub(/[ \t]+$/, "", version)
		print version
		exit
	}'
fi
