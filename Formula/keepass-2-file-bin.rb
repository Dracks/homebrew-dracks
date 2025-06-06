class Keepass2FileBin < Formula
  desc "Tool to generate environment files using secrets from a keepass file"
  homepage "https://github.com/Dracks/keepass-2-file"
  license "GPL-3.0-or-later"
  head "https://github.com/Dracks/keepass-2-file.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v0.5.1/keepass-2-file-0.5.1-aarch64-apple-darwin.tar.gz"
      sha256 "47a8e5bd6e8d2088a5eb4c2b1bcccda63ed16968e3b227942780ac1b122c081d"

      def install
        bin.install "keepass-2-file"
      end
    end
    if Hardware::CPU.intel?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v0.5.1/keepass-2-file-0.5.1-x86_64-apple-darwin.tar.gz"
      sha256 "188e618b2fe046d239b2893555876d99b2a47c1b737d0206305a443e788b4846"

      def install
        bin.install "keepass-2-file"
      end
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v0.5.1/keepass-2-file-0.5.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "51e8a18927d308053898de110aae18a49d3ebaaff50be192bd72e1d863cf9eba"

      def install
        bin.install "keepass-2-file"
      end
    end
  end
end
