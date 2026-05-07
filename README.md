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

Pushing the tag starts the GitHub Actions release workflow, which builds Debian packages and uploads them to the GitHub release.

## To bump the version

Use `prepare-release.sh` with the upstream Neovim release version, without the leading `v`.
