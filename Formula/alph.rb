class Alph < Formula
  desc "Alpheus Context Engine Framework CLI — git-backed context management for LLMs"
  homepage "https://github.com/AlpheusCEF/alph-cli"
  url "https://github.com/AlpheusCEF/alph-cli/releases/download/v0.1.3/alph_cli-0.1.3.tar.gz"
  sha256 "28ba96fa9176132afa960c60f40115ee27b89862b751e1de45fd1e59cd01d610"
  version "0.1.3"
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
