class Alph < Formula
  desc "Alpheus Context Engine Framework CLI — git-backed context management for LLMs"
  homepage "https://github.com/AlpheusCEF/alph-cli"
  url "https://github.com/AlpheusCEF/alph-cli/releases/download/v0.1.34/alph_cli-0.1.34.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "AGPL-3.0-or-later"

  # Maturin-built Rust extensions (cryptography, pydantic-core, rpds-py,
  # watchfiles) use @rpath-based dylib IDs. Homebrew's post-install relocation
  # tries to rewrite those to absolute paths, which fails because the pre-built
  # wheels lack headerpad space. preserve_rpath tells Homebrew to leave @rpath
  # install names alone — the extensions live inside our private venv and never
  # need absolute dylib IDs.
  preserve_rpath

  depends_on "python@3.12"

  def install
    python3 = Formula["python@3.12"].opt_bin/"python3.12"
    system python3, "-m", "venv", libexec

    system libexec/"bin/pip", "install", "--no-cache-dir", buildpath

    bin.install_symlink libexec/"bin/alph"
    bin.install_symlink libexec/"bin/alph-mcp"

    man1.install "man/alph.1"

    # Generate shell completions.  Typer exposes the completion script via
    # the _ALPH_COMPLETE=source_<shell> environment variable.
    # Typer emits a leading newline before #compdef — strip it so compinit
    # recognises the file (compinit requires #compdef on byte 0).
    (zsh_completion/"_alph").write \
      Utils.safe_popen_read({ "_ALPH_COMPLETE" => "source_zsh" }, bin/"alph").lstrip
    (bash_completion/"alph").write \
      Utils.safe_popen_read({ "_ALPH_COMPLETE" => "source_bash" }, bin/"alph")
    (fish_completion/"alph.fish").write \
      Utils.safe_popen_read({ "_ALPH_COMPLETE" => "source_fish" }, bin/"alph")
  end

  def caveats
    <<~EOS
      Tab completion has been installed for zsh, bash, and fish.

      zsh: add the following to ~/.zshrc if not already present:
        fpath=(#{HOMEBREW_PREFIX}/share/zsh/site-functions $fpath)
        autoload -Uz compinit && compinit

      bash: add the following to ~/.bashrc if not already present:
        [[ -r "#{HOMEBREW_PREFIX}/etc/bash_completion.d/alph" ]] && source "#{HOMEBREW_PREFIX}/etc/bash_completion.d/alph"

      fish: completions are loaded automatically — no setup needed.

      Reload your shell (exec zsh / exec bash) after editing your rc file.
    EOS
  end

  test do
    assert_match "Alpheus Context Engine Framework", shell_output("#{bin}/alph --help")
  end
end
