class Alph < Formula
  desc "Alpheus Context Engine Framework CLI — git-backed context management for LLMs"
  homepage "https://github.com/AlpheusCEF/alph-cli"
  url "https://github.com/AlpheusCEF/alph-cli/releases/download/v0.1.10/alph_cli-0.1.10.tar.gz"
  sha256 "1e57f4925913d4c4d2da18cc2044e122af832591f90168045fc8818af9e91040"
  license "AGPL-3.0-or-later"

  depends_on "rust" => :build # required to build cryptography from source (avoids dylib header overflow)
  depends_on "python@3.12"

  def install
    python3 = Formula["python@3.12"].opt_bin/"python3.12"
    system python3, "-m", "venv", libexec

    # Several dependencies (cryptography, pydantic-core, rpds, etc.) ship pre-built
    # Rust-extension wheels whose Mach-O headers lack padding for Homebrew's absolute
    # dylib ID rewrite. Build all packages from source so -headerpad_max_install_names
    # takes effect across the board. The build takes longer but installs cleanly.
    ENV.append "LDFLAGS", "-headerpad_max_install_names"
    ENV.append "CFLAGS", "-headerpad_max_install_names"
    system libexec/"bin/pip", "install", "--no-cache-dir",
           "--no-binary", ":all:",
           buildpath

    bin.install_symlink libexec/"bin/alph"
    bin.install_symlink libexec/"bin/alph-mcp"
  end

  test do
    assert_match "Alpheus Context Engine Framework", shell_output("#{bin}/alph --help")
  end
end
