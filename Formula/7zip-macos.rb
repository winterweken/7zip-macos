class SevenzipMac < Formula
  desc "7-Zip console binaries for macOS"
  homepage "https://www.7-zip.org/"
  url "https://github.com/ip7z/7zip/releases/download/26.01/7z2601-mac.tar.xz"
  sha256 "8ea0fc8a135e7b848e80a4116fe22dff56c8c4518dde1f43cce67f4e340b437a"

  def install
    bin.install "7zz", "7zr", "7za"
  end

  test do
    assert_match "7-Zip", shell_output("#{bin}/7zz --help")
  end
end
