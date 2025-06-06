#!/usr/bin/env bash
set -euo pipefail

echo "::group::Updating system"
sudo pacman -Syu --noconfirm
echo "::endgroup::"

# Set paths
WORKPATH=$GITHUB_WORKSPACE
HOME=/home/builder

echo "::group::Copying files from $WORKPATH to $HOME/work"
cd $HOME
mkdir -p work
cd work
cp -fv "$WORKPATH"/PKGBUILD .
if [ -f "$WORKPATH"/.SRCINFO ]; then
  cp -fv "$WORKPATH"/.SRCINFO .
fi
echo "::endgroup::"

echo "::group::Getting version info"
source PKGBUILD
npmver=$(echo "$_npmver" | cut -d' ' -f1)
pkgver_new=$(echo "$npmver" | sed 's/-/_/g')
echo "Current npmver: $npmver"
echo "Current pkgver: $pkgver"
echo "New pkgver should be: $pkgver_new"

# Test if URL exists
test_url="https://registry.npmjs.org/@sourcegraph/amp/-/amp-$npmver.tgz"
echo "Testing URL: $test_url"
if curl -I "$test_url" 2>/dev/null | grep -q "200 OK"; then
  echo "✅ URL is accessible"
else
  echo "❌ URL test failed - this might cause issues"
fi
echo "::endgroup::"

echo "::group::Updating pkgver and pkgrel"
sed -i "s/^pkgver=.*/pkgver=$pkgver_new/" PKGBUILD
sed -i "s/^pkgrel=.*/pkgrel=1/" PKGBUILD
git diff PKGBUILD || true
echo "::endgroup::"

echo "::group::Updating checksums"
updpkgsums
git diff PKGBUILD || true
echo "::endgroup::"

echo "::group::Installing dependencies"
source PKGBUILD
if [ ${#depends[@]} -gt 0 ]; then
  sudo pacman -S --needed --noconfirm "${depends[@]}" || true
fi
if [ ${#makedepends[@]} -gt 0 ]; then
  sudo pacman -S --needed --noconfirm "${makedepends[@]}" || true
fi
echo "::endgroup::"

echo "::group::Testing build"
makepkg --nobuild --nodeps
echo "::endgroup::"

echo "::group::Generating .SRCINFO"
makepkg --printsrcinfo > .SRCINFO
git diff .SRCINFO || true
echo "::endgroup::"

echo "::group::Copying files back"
sudo cp -fv PKGBUILD "$WORKPATH"/PKGBUILD
sudo cp -fv .SRCINFO "$WORKPATH"/.SRCINFO
echo "::endgroup::"
