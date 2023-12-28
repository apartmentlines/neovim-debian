# Overview

Needed a standalone Neovim package for an older Debian release, but a newer Neovim version.

These are the skeleton files that should live in the `debian` directory to build the Neovim .deb file.

# Configuration

```sh
export version=0.9.4
export build_dir=/tmp/build
# Debian build deps.
apt-get install -y build-essential devscripts debhelper
# Neovim build deps.
apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen
# Neovim runtime deps.
apt-get install -y libc6 libluajit-5.1-2 libmsgpackc2 libtermkey1 libunibilium4 libuv1 libvterm0
rm -rf ${build_dir} && mkdir -p ${build_dir} && cd ${build_dir}
git clone https://github.com/neovim/neovim neovim-${version}
mv neovim-${version}/.git .
tar -czvf neovim_${version}.orig.tar.gz neovim-${version}
mv .git neovim-${version}/
cd neovim-${version}
git checkout v${version}
git clone https://github.com/apartmentlines/neovim-debian.git debian
DEB_BUILD_OPTIONS=nocheck debuild --no-lintian -i -us -uc -b -nc
```
