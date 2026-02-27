class Keepass2FileBin < Formula
  desc "Tool to generate environment files using secrets from a keepass file"
  homepage "https://github.com/Dracks/keepass-2-file"
  license "GPL-3.0-or-later"
  head "https://github.com/Dracks/keepass-2-file.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v0.6.2/keepass-2-file-0.6.2-aarch64-apple-darwin.tar.gz"
      sha256 "a622e7b031162d577137feddd458b54d999a2419725886a63dd0f2eda6271edf"

    end
    if Hardware::CPU.intel?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v0.6.2/keepass-2-file-0.6.2-x86_64-apple-darwin.tar.gz"
      sha256 "67d52f0cda8c32c8ca2b6f80a23b091d54a61ca83c1702f0c925821f5668c0e3"

    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v0.6.2/keepass-2-file-0.6.2-x86_64-unknown-linux-musl.tar.gz"
      sha256 "6aa3b18f773ca9a83ed5510dd0a04355cedc104f8b3acf9eb4dcc0c0c640d09a"

    end
  end

  conflicts_with cask: "keepass-2-file"

  def install
    bin.install "keepass-2-file"
    generate_completions_from_executable(bin/"keepass-2-file", "completion")
  end
end
