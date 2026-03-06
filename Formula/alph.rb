class Alph < Formula
  desc "Alpheus Context Engine Framework CLI — git-backed context management for LLMs"
  homepage "https://github.com/AlpheusCEF/alph-cli"
  url "https://github.com/AlpheusCEF/alph-cli/releases/download/v0.1.7/alph_cli-0.1.7.tar.gz"
  sha256 "7598f7e60be42960eb6db50409ceb062032f088701099856e47aaa0954c75840"
  version "0.1.7"
  license "AGPL-3.0-or-later"

  depends_on "python@3.12"
  depends_on "rust" => :build  # required to build cryptography from source (avoids dylib header overflow)

  def install
    python3 = Formula["python@3.12"].opt_bin/"python3.12"
    system python3, "-m", "venv", libexec

    # fastmcp depends on Authlib which depends on cryptography. The pre-built
    # cryptography wheel ships a Rust extension whose Mach-O header lacks
    # padding for Homebrew's absolute dylib ID rewrite. Build from source so
    # -headerpad_max_install_names takes effect and the rewrite succeeds.
    ENV.append "LDFLAGS", "-headerpad_max_install_names"
    ENV.append "CFLAGS", "-headerpad_max_install_names"
    system libexec/"bin/pip", "install", "--no-cache-dir",
           "--no-binary", "cryptography",
           buildpath

    bin.install_symlink libexec/"bin/alph"
    bin.install_symlink libexec/"bin/alph-mcp"
  end

  test do
    assert_match "Alpheus Context Engine Framework", shell_output("#{bin}/alph --help")
  end
end
