# Overview

Needed a standalone Neovim package for an older Debian release, but a newer Neovim version.

This repository contains the `debian` directory used to build Neovim `.deb` files from upstream Neovim release tags.

## Release process

Release tags in this repository mirror upstream Neovim release tags. A repository tag named `v0.11.7` builds Debian package version `0.11.7-1` from upstream Neovim tag `v0.11.7`.

```sh
./prepare-release.sh 0.11.7
git push origin main
git push origin v0.11.7
```

Pushing the tag starts the GitHub Actions release workflow, which builds Debian 12 and Debian 13 packages and uploads them to the GitHub release.

## Configuration

```sh
export version=0.11.5
export build_dir=/tmp/build
# Debian build deps.
apt-get install -y build-essential devscripts debhelper equivs fakeroot pkgconf
# Neovim build deps.
apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ unzip curl doxygen
rm -rf ${build_dir} && mkdir -p ${build_dir} && cd ${build_dir}
git clone https://github.com/neovim/neovim neovim-${version}
mv neovim-${version}/.git .
tar -czvf neovim_${version}.orig.tar.gz neovim-${version}
mv .git neovim-${version}/
cd neovim-${version}
git checkout v${version}
git clone https://github.com/apartmentlines/neovim-debian.git packaging
cp -a packaging/debian .
DEB_BUILD_OPTIONS=nocheck debuild --no-lintian -i -us -uc -b -nc
```

## To bump the version

Use `prepare-release.sh` with the upstream Neovim release version, without the leading `v`.
