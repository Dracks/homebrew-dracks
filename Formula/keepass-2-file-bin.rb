class Keepass2FileBin < Formula
  desc "Tool to generate environment files using secrets from a keepass file"
  homepage "https://github.com/Dracks/keepass-2-file"
  license "GPL-3.0-or-later"
  head "https://github.com/Dracks/keepass-2-file.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v1.1.0/keepass-2-file-1.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "7945c88eb9d84543d348fe07aee30fa103da163ab2ca627607332c87723f224d"

    end
    if Hardware::CPU.intel?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v1.1.0/keepass-2-file-1.1.0-x86_64-apple-darwin.tar.gz"
      sha256 "a1957c3f221c83cb1037ec491d2be48b0637af6b7050a85a5e41222f4b957c7a"

    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v1.1.0/keepass-2-file-1.1.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "e913985814dd06c7971c300d4bb51be9d67456aca0563ee84e864b5caacd8359"

    end
  end

  conflicts_with cask: "keepass-2-file"

  def install
    bin.install "keepass-2-file"
    generate_completions_from_executable(bin/"keepass-2-file", "completion")
  end
end
