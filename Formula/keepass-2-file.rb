class Keepass2File < Formula
  desc "Tool to generate environment files using secrets from a keepass file"
  homepage "https://github.com/Dracks/keepass-2-file"
  url "https://github.com/Dracks/keepass-2-file/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "d32486c619c9b0ce4c5a2c17a740eefabf1c3064e2d39cc5b55b919391aed82d"
  license "GPL-3.0-or-later"
  head "https://github.com/Dracks/keepass-2-file.git", branch: "main"

  depends_on "rust" => :build

  conflicts_with cask: "keepass-2-file-bin"

  def install
    system "cargo", "install", *std_cargo_args
    generate_completions_from_executable(bin/"keepass-2-file", "completion", shells: [:bash, :zsh, :fish])
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test keepass-2-file`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system bin/"program", "do", "something"`.
    assert_match version.to_s, shell_output("#{bin}/keepass-2-file --version")
  end
end
