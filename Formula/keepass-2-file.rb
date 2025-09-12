class Keepass2File < Formula
  desc "Tool to generate environment files using secrets from a keepass file"
  homepage "https://github.com/Dracks/keepass-2-file"
  url "https://github.com/Dracks/keepass-2-file/archive/refs/tags/v0.6.0.tar.gz"
  sha256 "b823daa48a685dcf4013e0a55b485d3a87d980deec1fd28ed6c50bdfd4bd369c"
  license "GPL-3.0-or-later"
  head "https://github.com/Dracks/keepass-2-file.git", branch: "main"

  depends_on "rust" => :build

  conflicts_with cask: "keepass-2-file-bin"

  def install
    system "cargo", "install", *std_cargo_args
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
