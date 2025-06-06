class Keepass2File < Formula
  desc "Tool to generate environment files using secrets from a keepass file"
  homepage "https://github.com/Dracks/keepass-2-file"
  url "https://github.com/Dracks/keepass-2-file/archive/refs/tags/v0.5.1.tar.gz"
  sha256 "7ff6372768382024c66c496b5fe754257e5a37b3ccbddb293dba9ea6bdded83d"
  license "GPL-3.0-or-later"
  head "https://github.com/Dracks/keepass-2-file.git", branch: "main"

  depends_on "rust" => :build

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
