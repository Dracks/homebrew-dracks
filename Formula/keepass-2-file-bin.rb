class Keepass2FileBin < Formula
  desc "Tool to generate environment files using secrets from a keepass file"
  homepage "https://github.com/Dracks/keepass-2-file"
  license "GPL-3.0-or-later"
  head "https://github.com/Dracks/keepass-2-file.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v0.4.0/keepass-2-file-0.4.0-aarch64-apple-darwin.tar.gz"
      sha256 "f148c4a3d5c30daffbb404f66bc49c2c9a6527b28485c98a8fedf3d29ada66f9"

      def install
        bin.install "keepass-2-file"
      end
    end
    if Hardware::CPU.intel?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v0.4.0/keepass-2-file-0.4.0-x86_64-apple-darwin.tar.gz"
      sha256 "72b82a1e4696d2b9696594f40a035f38622730ce49341b975f9306d9a8b0fa6c"

      def install
        bin.install "keepass-2-file"
      end
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v0.4.0/keepass-2-file-0.4.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "84fe55de94f27861f5b00941892a59e508b45ee9bdb2d60a5d4e0ff6ded1a3e7"

      def install
        bin.install "keepass-2-file"
      end
    end
  end
end
