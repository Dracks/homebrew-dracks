class Keepass2FileBin < Formula
  desc "Tool to generate environment files using secrets from a keepass file"
  homepage "https://github.com/Dracks/keepass-2-file"
  license "GPL-3.0-or-later"
  head "https://github.com/Dracks/keepass-2-file.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v0.5.0/keepass-2-file-0.5.0-aarch64-apple-darwin.tar.gz"
      sha256 "4886716b9d29acf50507b28907b43a34bbb45c4ba7c62e6a908b45d22a6cf50e"

      def install
        bin.install "keepass-2-file"
      end
    end
    if Hardware::CPU.intel?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v0.5.0/keepass-2-file-0.5.0-x86_64-apple-darwin.tar.gz"
      sha256 "a07e98e64347ae052cd6cefb6a0749466128c1b048b8d2b7f31615c001480df5"

      def install
        bin.install "keepass-2-file"
      end
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v0.5.0/keepass-2-file-0.5.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "eac418e2648acb818189b5fb2238c3b33868069f993eea50eacbe3fe4a44db89"

      def install
        bin.install "keepass-2-file"
      end
    end
  end
end
