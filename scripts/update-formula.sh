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
# Point at the sdist asset attached to the release, not the auto-generated
# GitHub source archive. Auto-generated tarballs have unstable SHA256 hashes.
URL="https://github.com/AlpheusCEF/alph-cli/releases/download/v${VERSION}/alph_cli-${VERSION}.tar.gz"

echo "fetching release asset for v${VERSION}..."
TMPFILE=$(mktemp)
curl -fsSL -o "$TMPFILE" "$URL"
SHA256=$(shasum -a 256 "$TMPFILE" | awk '{print $1}')
rm -f "$TMPFILE"

echo "sha256: $SHA256"
echo "updating $FORMULA..."

# Update url and sha256 lines in-place (version is parsed from the URL by Homebrew)
sed -i '' \
  -e "s|url \".*\"|url \"${URL}\"|" \
  -e "s|sha256 \".*\"|sha256 \"${SHA256}\"|" \
  "$FORMULA"

echo "done. verify with: brew audit --strict Formula/alph.rb"
