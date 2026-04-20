#!/usr/bin/env bash
# Cut a new release by tagging HEAD and pushing the tag.
# The GitHub Actions workflow (.github/workflows/main.yml) picks up the
# tag push, builds the Linux AppImage + Windows installer, and publishes
# a GitHub release with both artifacts attached.
#
# Usage:
#   build-scripts/release.sh                  # auto-bump patch from latest tag
#   build-scripts/release.sh patch|minor|major
#   build-scripts/release.sh v1.2.3           # explicit version (leading v optional)
#
# Flags:
#   -n, --dry-run   show what would happen, change nothing
#   -y, --yes       skip the confirmation prompt
#   -w, --watch     stream the workflow run via `gh run watch` after pushing
#   -h, --help      show this help
#
# Requires: git, and optionally gh (for --watch).
set -euo pipefail

usage() {
  # Print the leading comment block (skipping the shebang) until the first
  # non-comment line, stripping the leading "# ".
  awk 'NR==1 && /^#!/ {next} /^#/ {sub(/^# ?/, ""); print; next} {exit}' "$0"
  exit "${1:-0}"
}

die() {
  echo "error: $*" >&2
  exit 1
}

DRY_RUN=0
ASSUME_YES=0
WATCH=0
BUMP_OR_VERSION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run) DRY_RUN=1 ;;
    -y|--yes)     ASSUME_YES=1 ;;
    -w|--watch)   WATCH=1 ;;
    -h|--help)    usage 0 ;;
    -*)           die "unknown flag: $1" ;;
    *)
      [[ -n "$BUMP_OR_VERSION" ]] && die "unexpected extra argument: $1"
      BUMP_OR_VERSION="$1"
      ;;
  esac
  shift
done

run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "DRY-RUN: $*"
  else
    echo "+ $*"
    "$@"
  fi
}

command -v git >/dev/null || die "git is not installed"

repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" \
  || die "not inside a git repository"
cd "$repo_root"

# Refuse to release from a dirty tree unless dry-running; shipping a tag
# that doesn't match anything on disk is a great way to get confused later.
if [[ $DRY_RUN -eq 0 ]] && ! git diff --quiet HEAD --; then
  die "working tree has uncommitted changes; commit/stash them first"
fi

current_branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$current_branch" != "main" && "$current_branch" != "master" ]]; then
  echo "warning: releasing from branch '$current_branch' (not main/master)"
fi

echo "Fetching tags from origin..."
run git fetch --tags --prune origin

latest_tag="$(git tag --list 'v*' --sort=-v:refname | head -n 1 || true)"
if [[ -z "$latest_tag" ]]; then
  latest_version="0.0.0"
  echo "No previous v* tag found; treating latest as 0.0.0."
else
  latest_version="${latest_tag#v}"
  echo "Latest tag: $latest_tag"
fi

bump_version() {
  # Split "MAJOR.MINOR.PATCH" and increment the requested component.
  local version="$1" part="$2"
  local major minor patch
  IFS='.' read -r major minor patch <<< "${version%%-*}"
  major="${major:-0}"; minor="${minor:-0}"; patch="${patch:-0}"
  case "$part" in
    major) echo "$((major + 1)).0.0" ;;
    minor) echo "$major.$((minor + 1)).0" ;;
    patch) echo "$major.$minor.$((patch + 1))" ;;
    *) die "unknown bump component: $part" ;;
  esac
}

case "$BUMP_OR_VERSION" in
  ""|patch|minor|major)
    component="${BUMP_OR_VERSION:-patch}"
    new_version="$(bump_version "$latest_version" "$component")"
    ;;
  *)
    # Treat anything else as an explicit version; accept optional leading "v"
    # and validate it matches MAJOR.MINOR.PATCH(-prerelease)?.
    candidate="${BUMP_OR_VERSION#v}"
    [[ "$candidate" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$ ]] \
      || die "'$BUMP_OR_VERSION' is not a valid semver (expected e.g. v1.2.3 or 1.2.3-beta.1)"
    new_version="$candidate"
    ;;
esac

new_tag="v${new_version}"

if git rev-parse "refs/tags/${new_tag}" >/dev/null 2>&1; then
  die "tag ${new_tag} already exists locally"
fi
if git ls-remote --tags --exit-code origin "refs/tags/${new_tag}" >/dev/null 2>&1; then
  die "tag ${new_tag} already exists on origin"
fi

echo
echo "About to release:"
echo "  branch:      $current_branch"
echo "  commit:      $(git rev-parse --short HEAD) - $(git log -1 --pretty=%s)"
echo "  previous:    ${latest_tag:-<none>}"
echo "  new tag:     $new_tag"
echo

if [[ $ASSUME_YES -eq 0 && $DRY_RUN -eq 0 ]]; then
  read -r -p "Proceed? [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]] || die "aborted"
fi

run git tag -a "$new_tag" -m "$new_tag"
run git push origin "$new_tag"

echo
echo "Pushed $new_tag. GitHub Actions will build and publish the release."

if [[ $WATCH -eq 1 && $DRY_RUN -eq 0 ]]; then
  if command -v gh >/dev/null; then
    echo "Streaming workflow run via gh..."
    # Give Actions a moment to register the run before we attach to it.
    sleep 3
    gh run watch --exit-status || echo "gh run watch exited non-zero"
  else
    echo "gh CLI not found; skipping --watch. Install from https://cli.github.com/."
  fi
fi
