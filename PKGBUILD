_npmname=@sourcegraph/amp
_npmver=0.0.1749182771-gb19aef
pkgname=sourcegraph-amp # All lowercase
pkgver=0.0.1749182771_gb19aef
pkgrel=1
pkgdesc="CLI for Amp, an agentic coding tool in research preview from Sourcegraph."
arch=(any)
url="https://ampcode.com/"
license=()
depends=('nodejs')
makedepends=('npm')
optdepends=()
source=(https://registry.npmjs.org/$_npmname/-/$_npmname-$_npmver.tgz)
noextract=($_npmname-$_npmver.tgz)
sha1sums=('SKIP')

package() {
  cd $srcdir
  local _npmdir="$pkgdir/usr/lib/node_modules/"
  mkdir -p $_npmdir
  cd $_npmdir
  npm install -g --prefix "$pkgdir/usr" $_npmname@$_npmver
  chown -R root:root "$pkgdir"
}

# vim:set ts=2 sw=2 et:
