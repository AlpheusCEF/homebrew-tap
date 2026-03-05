class Alph < Formula
  desc "Alpheus Context Engine Framework CLI — git-backed context management for LLMs"
  homepage "https://github.com/AlpheusCEF/alph-cli"
  url "https://github.com/AlpheusCEF/alph-cli/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "50907ae2483be5a42c037a0ecd1534c38922ed708e2426a84be7e8dc5d2b9999"
  version "0.1.0"
  license "MIT"

  depends_on "python@3.12"

  def install
    venv = virtualenv_create(libexec, "python3.12")
    system libexec/"bin/pip", "install", "--no-cache-dir", "."
    bin.install_symlink libexec/"bin/alph"
  end

  test do
    assert_match "Alpheus Context Engine Framework", shell_output("#{bin}/alph --help")
  end
end
