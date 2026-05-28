class Keepass2FileBin < Formula
  desc "Tool to generate environment files using secrets from a keepass file"
  homepage "https://github.com/Dracks/keepass-2-file"
  license "GPL-3.0-or-later"
  head "https://github.com/Dracks/keepass-2-file.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v1.0.1/keepass-2-file-1.0.1-aarch64-apple-darwin.tar.gz"
      sha256 "93df3324c284f94839834b4ff819c9d10ae7d85526e2d9dab087b34c8b170869"

    end
    if Hardware::CPU.intel?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v1.0.1/keepass-2-file-1.0.1-x86_64-apple-darwin.tar.gz"
      sha256 "65f5b9020580bee129ec7b5ebb35bcca9b95d499af60fa3f5ce1f239c3860819"

    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v1.0.1/keepass-2-file-1.0.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "1e264a2f2c4a9e51276878d80e724ea75953876e538f03341478764c915d00e9"

    end
  end

  conflicts_with cask: "keepass-2-file"

  def install
    bin.install "keepass-2-file"
    generate_completions_from_executable(bin/"keepass-2-file", "completion")
  end
end
