# sourcegraph-amp (AUR)

[![AUR version](https://img.shields.io/aur/version/sourcegraph-amp)](https://aur.archlinux.org/packages/sourcegraph-amp)
[![AUR votes](https://img.shields.io/aur/votes/sourcegraph-amp)](https://aur.archlinux.org/packages/sourcegraph-amp)

AUR package for [Amp by Sourcegraph](https://ampcode.com/).

## Installation

Install from the AUR using your preferred AUR helper:

```bash
# Using yay
yay -S sourcegraph-amp

# Using paru
paru -S sourcegraph-amp

# Manual installation
git clone https://aur.archlinux.org/sourcegraph-amp.git
cd sourcegraph-amp
makepkg -si
```

This package is maintained using [aurpublish](https://github.com/eli-schwartz/aurpublish/).
To update the package, run `./pkg.sh update` to check for new versions of the program,
update the PKGBUILD and .SRCINFO files, and commit the changes.
Then, run `aurpublish` to push the changes to the AUR.

## Disclaimer

This is an **unofficial community package** for Amp by Sourcegraph. This package is not affiliated with or endorsed by Sourcegraph. For issues with the AUR package, please use this repository. For issues with Amp itself, please contact [Amp support](https://ampcode.com/manual#support).

## Links

- [AUR Package](https://aur.archlinux.org/packages/sourcegraph-amp)
- [Amp by Sourcegraph](https://ampcode.com/)
- [npm Package](https://www.npmjs.com/package/@sourcegraph/amp)

---

*Most of this repository was written with the help of Amp.*
