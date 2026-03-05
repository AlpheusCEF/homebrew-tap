# AlpheusCEF Homebrew Tap

Homebrew formulae for [AlpheusCEF](https://github.com/AlpheusCEF) tools.

## Install

```bash
brew tap AlpheusCEF/tap
brew install alph
```

## What's here

| Formula | Description |
|---------|-------------|
| `alph` | Alpheus Context Engine Framework CLI — git-backed context management for LLMs |

## Releasing a new version

Update the formula when a new `alph-cli` release is tagged:

```bash
./scripts/update-formula.sh 0.2.0
git add Formula/alph.rb
git commit -m "alph: bump to 0.2.0"
git push
```

The `update-formula.sh` script fetches the release tarball, computes sha256,
and patches `Formula/alph.rb` in place.

## Development

```bash
# Audit formula locally
brew audit --strict Formula/alph.rb

# Install from local source
brew install --build-from-source Formula/alph.rb

# Test
brew test Formula/alph.rb
```
