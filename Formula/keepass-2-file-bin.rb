class Keepass2FileBin < Formula
  desc "Tool to generate environment files using secrets from a keepass file"
  homepage "https://github.com/Dracks/keepass-2-file"
  license "GPL-3.0-or-later"
  head "https://github.com/Dracks/keepass-2-file.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v0.6.1/keepass-2-file-0.6.1-aarch64-apple-darwin.tar.gz"
      sha256 "aab9c48f7cda1458b3d19c2a5d65e6df44775d1f6f10eb1ed7d402bc91357b8c"

    end
    if Hardware::CPU.intel?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v0.6.1/keepass-2-file-0.6.1-x86_64-apple-darwin.tar.gz"
      sha256 "a9806bd2cd0970f2bbaaf3190718d3351bf66c6dd2cb2fdcc0f5a975584d8f94"

    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/Dracks/keepass-2-file/releases/download/v0.6.1/keepass-2-file-0.6.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "7d4f32afbc596657d0368ca554b45ed9e5e5462df239ac2463d16ee7ffdbbb77"

    end
  end

  conflicts_with cask: "keepass-2-file"

  def install
    bin.install "keepass-2-file"
    generate_completions_from_executable(bin/"keepass-2-file", "completion")
  end
end
