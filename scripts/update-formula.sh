#!/usr/bin/env bash
# Update Formula/alph.rb to a new alph-cli release.
#
# Usage:
#   ./scripts/update-formula.sh 0.2.0
#
# Requires: curl, shasum, sed
# Run from the repo root.

set -euo pipefail

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
  echo "usage: $0 <version>  (e.g. 0.2.0)" >&2
  exit 1
fi

FORMULA="Formula/alph.rb"
URL="https://github.com/AlpheusCEF/alph-cli/archive/refs/tags/v${VERSION}.tar.gz"

echo "fetching tarball for v${VERSION}..."
SHA256=$(curl -sL "$URL" | shasum -a 256 | awk '{print $1}')

echo "sha256: $SHA256"
echo "updating $FORMULA..."

# Update url, sha256, and version lines in-place
sed -i '' \
  -e "s|url \".*\"|url \"${URL}\"|" \
  -e "s|sha256 \".*\"|sha256 \"${SHA256}\"|" \
  -e "s|version \".*\"|version \"${VERSION}\"|" \
  "$FORMULA"

echo "done. verify with: brew audit --strict Formula/alph.rb"
