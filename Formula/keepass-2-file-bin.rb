class Keepass2FileBin < Formula
  desc "Tool to generate environment files using secrets from a keepass file"
  homepage "https://github.com/Dracks/keepass-2-file"
  license "GPL-3.0-or-later"
  head "https://github.com/Dracks/keepass-2-file.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v1.0.0/keepass-2-file-1.0.0-aarch64-apple-darwin.tar.gz"
      sha256 "9b4f4ef65fc626041ba4039cabf029ded1f87810da92c99871f0d3f2b38fde4b"

    end
    if Hardware::CPU.intel?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v1.0.0/keepass-2-file-1.0.0-x86_64-apple-darwin.tar.gz"
      sha256 "44364367ca6d1429aa51371414b3ec6b7b4781b5dd7778a1f744d27a38020454"

    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v1.0.0/keepass-2-file-1.0.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "4275a0b7de2e31389f24ae11f92638308228e45e2032f88092043a8dd8fc4cdf"

    end
  end

  conflicts_with cask: "keepass-2-file"

  def install
    bin.install "keepass-2-file"
    generate_completions_from_executable(bin/"keepass-2-file", "completion")
  end
end
