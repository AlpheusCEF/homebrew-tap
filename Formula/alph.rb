class Alph < Formula
  desc "Alpheus Context Engine Framework CLI — git-backed context management for LLMs"
  homepage "https://github.com/AlpheusCEF/alph-cli"
  url "https://github.com/AlpheusCEF/alph-cli/releases/download/v0.1.32/alph_cli-0.1.32.tar.gz"
  sha256 "19a95a4dac0577918c76c4b7fc205d6ea1f8d1e26ed8fd73f1c0b619dfc1ea4f"
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
    (zsh_completion/"_alph").write \
      Utils.safe_popen_read({ "_ALPH_COMPLETE" => "source_zsh" }, bin/"alph")
    (bash_completion/"alph").write \
      Utils.safe_popen_read({ "_ALPH_COMPLETE" => "source_bash" }, bin/"alph")
    (fish_completion/"alph.fish").write \
      Utils.safe_popen_read({ "_ALPH_COMPLETE" => "source_fish" }, bin/"alph")
  end

  test do
    assert_match "Alpheus Context Engine Framework", shell_output("#{bin}/alph --help")
  end
end
