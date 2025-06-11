# Maintainer: Anirudh Konduru <anirudhmkonduru@gmail.com>

_npmname=@sourcegraph/amp
_npmver=0.0.1749614780-g9a56bd # renovate: datasource=npm depName=@sourcegraph/amp
_basename=amp
pkgname=sourcegraph-amp # All lowercase
pkgver=${_npmver//-/_}
pkgrel=1
pkgdesc="CLI for Amp, an agentic coding tool in research preview from Sourcegraph."
arch=(any)
url="https://ampcode.com/"
license=('custom')
depends=('nodejs')
makedepends=('npm')
optdepends=()
source=(https://registry.npmjs.org/$_npmname/-/$_basename-$_npmver.tgz)
noextract=($_basename-$_npmver.tgz)
sha1sums=('df33e84129d016f7888b78b10af396a1f4d117cc')

package() {
  cd "$srcdir"
  local _npmdir="$pkgdir/usr/lib/node_modules/"
  mkdir -p "$_npmdir"
  cd "$_npmdir"
  npm install -g --prefix "$pkgdir/usr" "$_npmname@$_npmver"

  # Remove references to build directories
  # https://wiki.archlinux.org/title/Node.js_package_guidelines#Package_contains_reference_to_$srcdir/$pkgdir
  find "$pkgdir" -name package.json -print0 | xargs -r -0 sed -i '/_where/d'

  chown -R root:root "$pkgdir"
}

# vim:set ts=2 sw=2 et:
