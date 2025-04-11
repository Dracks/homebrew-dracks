class Keepass2FileBin < Formula
  desc "Tool to generate environment files using secrets from a keepass file"
  homepage "https://github.com/Dracks/keepass-2-file"
  license "GPL-3.0-or-later"
  head "https://github.com/Dracks/keepass-2-file.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Dracks/keepass-2-file/releases/download/0.3.1/keepass-2-file-0.3.1-aarch64-apple-darwin.tar.gz"
      sha256 "7ed777d510c3835afdc34bbf3345201d3c597c0467b4cb12017f4e5e6c0f8f56"

      def install
        bin.install "keepass-2-file"
      end
    end
    if Hardware::CPU.intel?
      url "https://github.com/Dracks/keepass-2-file/releases/download/0.3.1/keepass-2-file-0.3.1-x86_64-apple-darwin.tar.gz"
      sha256 "3d6c23bc0d71caaa654dd43b8a7ef59bae43a39dba9a13a67a1a699e0d1ee6ed"

      def install
        bin.install "keepass-2-file"
      end
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/Dracks/keepass-2-file/releases/download/0.3.1/keepass-2-file-0.3.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "67bee1430b4e28ab6cfaa9e054697a481c58f905873a18e2cfb59ff252d395d4"

      def install
        bin.install "keepass-2-file"
      end
    end
  end
end
