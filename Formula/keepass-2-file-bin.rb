class Keepass2FileBin < Formula
  desc "Tool to generate environment files using secrets from a keepass file"
  homepage "https://github.com/Dracks/keepass-2-file"
  license "GPL-3.0-or-later"
  head "https://github.com/Dracks/keepass-2-file.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v0.6.0/keepass-2-file-0.6.0-aarch64-apple-darwin.tar.gz"
      sha256 "80811b0614cb37e57fa5f04535b355d7310ba7c1eb0b7e58374639ffef532d23"

    end
    if Hardware::CPU.intel?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v0.6.0/keepass-2-file-0.6.0-x86_64-apple-darwin.tar.gz"
      sha256 "8a21f0789ca71eed9c8c08febe0cfe7cfba4cac5547bc607cce812df39c556cb"

    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v0.6.0/keepass-2-file-0.6.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "e91beae6edf4c7687104ac72ff560c8ae29f5fbb2b5228573cd91230df93471a"

    end
  end

  on_windows do
    if Hardware::CPU.intel?
      url "https://github.com/Dracks/keepass-2-file/releases/download/untagged-d1fae6eb5fbfc63287e9/keepass-2-file-0.6.0-x86_64-pc-windows-msvc.zip"
      sha256 "8f97c8a1812bcd3d582c4101d6f7354d4c43f5b00076897e83c48307e5119774"
    end
  end

  conflicts_with cask: "keepass-2-file"

  def install
    bin.install "keepass-2-file"
  end
end
