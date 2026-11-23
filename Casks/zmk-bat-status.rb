cask "zmk-bat-status" do
  version "0.1.0"
  sha256 "2ea0163a29bee808be5cfd546e7da9a4c419f48faed3efd2c2420e724d625f1b"

  url "https://github.com/aucubin/zmk-battery-applet/archive/d8b66ac89cc49ed36f0d87504e93646dd0003fd1.tar.gz"
  name "ZMK Battery"
  desc "Menu bar applet showing ZMK split keyboard battery levels"
  homepage "https://github.com/aucubin/zmk-battery-applet"

  depends_on formula: "rust"
  depends_on :macos

  app "zmk-battery-applet-d8b66ac89cc49ed36f0d87504e93646dd0003fd1/target/bundle/ZMK Battery.app"

  preflight_steps do
    run "/usr/bin/env",
        args:           ["cargo", "build", "--release", "--locked"],
        chdir:          "zmk-battery-applet-d8b66ac89cc49ed36f0d87504e93646dd0003fd1",
        env:            { "CARGO_HOME" => ".cargo" },
        writable_paths: ["zmk-battery-applet-d8b66ac89cc49ed36f0d87504e93646dd0003fd1"],
        writable_base:  :staged_path,
        network_access: true
    run "/bin/bash",
        args:           ["scripts/bundle-macos.sh"],
        chdir:          "zmk-battery-applet-d8b66ac89cc49ed36f0d87504e93646dd0003fd1",
        writable_paths: ["zmk-battery-applet-d8b66ac89cc49ed36f0d87504e93646dd0003fd1"],
        writable_base:  :staged_path
  end
end
