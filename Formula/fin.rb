class Fin < Formula
  desc "Daily task CLI built on AlpheusCEF"
  homepage "https://github.com/AlpheusCEF/fin-cli"
  url "https://github.com/AlpheusCEF/fin-cli/releases/download/v0.1.0/fin_cli-0.1.0.tar.gz"
  sha256 "246cc3464088f0e090eb172ba9597fbf73ab00416749ce9ba5d0903b0759d08a"
  license "AGPL-3.0-or-later"

  preserve_rpath

  depends_on "python@3.12"

  resource "alph-cli" do
    url "https://github.com/AlpheusCEF/alph-cli/releases/download/v0.1.36/alph_cli-0.1.36.tar.gz"
    sha256 "758306736d8ccf14f54233f7c996b6639eba52ccf14bbd26c022368e8ad35002"
  end

  def install
    python3 = Formula["python@3.12"].opt_bin/"python3.12"
    system python3, "-m", "venv", libexec

    # Install alph-cli first (fin's dependency)
    resource("alph-cli").stage do
      system libexec/"bin/pip", "install", "--no-cache-dir", "."
    end

    # Install fin-cli
    system libexec/"bin/pip", "install", "--no-cache-dir", "--no-deps", buildpath

    bin.install_symlink libexec/"bin/fin"
    bin.install_symlink libexec/"bin/fins"
    bin.install_symlink libexec/"bin/fine"

    # Generate shell completions for all three entry points.
    # Typer emits a leading newline before #compdef — strip it so compinit
    # recognises the file (compinit requires #compdef on byte 0).
    %w[fin fins fine].each do |cmd|
      env_var = "_#{cmd.upcase}_COMPLETE"
      (zsh_completion/"_#{cmd}").write \
        Utils.safe_popen_read({ env_var => "source_zsh" }, bin/cmd).lstrip
      (bash_completion/cmd).write \
        Utils.safe_popen_read({ env_var => "source_bash" }, bin/cmd)
      (fish_completion/"#{cmd}.fish").write \
        Utils.safe_popen_read({ env_var => "source_fish" }, bin/cmd)
    end
  end

  def caveats
    <<~EOS
      Tab completion has been installed for zsh, bash, and fish
      for all three commands: fin, fins, fine.

      zsh: add the following to ~/.zshrc if not already present:
        fpath=(#{HOMEBREW_PREFIX}/share/zsh/site-functions $fpath)
        autoload -Uz compinit && compinit

      bash: add the following to ~/.bashrc:
        for f in #{HOMEBREW_PREFIX}/etc/bash_completion.d/{fin,fins,fine}; do
          [[ -r "$f" ]] && source "$f"
        done

      fish: completions are loaded automatically — no setup needed.

      Reload your shell (exec zsh / exec bash) after editing your rc file.
    EOS
  end

  test do
    assert_match "Daily task CLI", shell_output("#{bin}/fin --help")
  end
end
