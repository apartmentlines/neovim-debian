#!/usr/bin/env bash
set -euo pipefail

readonly CHANGELOG_FILE="changelog"
readonly PACKAGE_NAME="neovim"
readonly MAINTAINER="Chad Phillips <chad@apartmentlines.com>"
readonly UPSTREAM_REPO="https://github.com/neovim/neovim.git"
readonly SEMVER_PATTERN='^[0-9]+[.][0-9]+[.][0-9]+$'
readonly USAGE="Usage: ./prepare-release.sh X.Y.Z"

log() {
  printf '%s\n' "${*}"
}

fail() {
  printf 'Error: %s\n' "${*}" >&2
  exit 1
}

repo_root() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  printf '%s\n' "${script_dir}"
}

enter_repo_root() {
  cd "$(repo_root)"
}

require_version_argument() {
  if [ "${#}" -ne 1 ]; then
    fail "${USAGE}"
  fi
  if [[ ! "${1}" =~ ${SEMVER_PATTERN} ]]; then
    fail "version must use plain semver without a leading v: X.Y.Z"
  fi
}

require_clean_worktree() {
  if [ -n "$(git status --porcelain)" ]; then
    fail "working tree must be clean before preparing a release"
  fi
}

require_tag_available() {
  local tag
  tag="${1}"
  if git rev-parse --verify --quiet "refs/tags/${tag}" >/dev/null; then
    fail "tag already exists: ${tag}"
  fi
}

require_upstream_tag_exists() {
  local tag
  tag="${1}"
  if ! git ls-remote --exit-code --tags "${UPSTREAM_REPO}" "refs/tags/${tag}" >/dev/null; then
    fail "upstream Neovim tag does not exist: ${tag}"
  fi
}

changelog_version() {
  sed -n '1s/^.*(\([^)]*\)).*$/\1/p' "${CHANGELOG_FILE}"
}

require_changelog_package_name() {
  local changelog_package
  changelog_package="$(sed -n '1s/^\([^[:space:]]*\).*$/\1/p' "${CHANGELOG_FILE}")"
  if [ "${changelog_package}" != "${PACKAGE_NAME}" ]; then
    fail "${CHANGELOG_FILE} starts with package ${changelog_package}, expected ${PACKAGE_NAME}"
  fi
}

prepend_changelog_entry() {
  local version
  local date
  local current_changelog
  version="${1}"
  date="$(date -R)"
  current_changelog="$(cat "${CHANGELOG_FILE}")"
  {
    printf '%s (%s-1) unstable; urgency=medium\n\n' "${PACKAGE_NAME}" "${version}"
    printf '  * Custom build for Debian.\n\n'
    printf ' -- %s  %s\n\n' "${MAINTAINER}" "${date}"
    printf '%s\n' "${current_changelog}"
  } > "${CHANGELOG_FILE}"
}

changelog_already_prepared() {
  local version
  version="${1}"
  [ "$(changelog_version)" = "${version}-1" ]
}

require_expected_changes() {
  local changes
  changes="$(git status --porcelain)"
  if [ "${changes}" != " M ${CHANGELOG_FILE}" ]; then
    printf '%s\n' "${changes}" >&2
    fail "release preparation changed unexpected files"
  fi
}

commit_release() {
  local version
  version="${1}"
  git add "${CHANGELOG_FILE}"
  git commit -m "Release ${version}"
}

tag_release() {
  local version
  local tag
  version="${1}"
  tag="v${version}"
  git tag -a "${tag}" -m "Release ${version}"
}

prepare_changelog() {
  local version
  version="${1}"
  require_changelog_package_name
  if changelog_already_prepared "${version}"; then
    log "${CHANGELOG_FILE} already starts with ${version}-1"
    return
  fi
  prepend_changelog_entry "${version}"
  if ! changelog_already_prepared "${version}"; then
    fail "${CHANGELOG_FILE} was not updated to ${version}-1"
  fi
  require_expected_changes
  commit_release "${version}"
}

main() {
  local version
  local tag
  require_version_argument "${@}"
  version="${1}"
  tag="v${version}"
  enter_repo_root
  require_clean_worktree
  require_tag_available "${tag}"
  require_upstream_tag_exists "${tag}"
  log "Preparing release ${version}"
  prepare_changelog "${version}"
  tag_release "${version}"
  log "Created local tag ${tag}"
  log "Push with: git push origin main && git push origin ${tag}"
}

main "${@}"
