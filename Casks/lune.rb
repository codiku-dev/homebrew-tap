cask "lune" do
  version "1.0.2"
  sha256 "cf7dfb422749900ca670586ff5928d4e071fda3323c6cd0cefbc2c85fa7367eb"

  url "https://github.com/codiku-dev/lune-releases/releases/download/v#{version}/Lune-#{version}.dmg"
  name "Lune"
  desc "AI-powered terminal with local Ollama suggestions and chat"
  homepage "https://github.com/codiku-dev/lune-terminal"

  depends_on macos: :sonoma

  app "Lune.app"

  # The app is ad-hoc signed (not notarized), so Gatekeeper flags the
  # Homebrew-quarantined copy as "damaged". Strip the quarantine flag on install
  # so `brew install --cask lune` just works, like the DMG's first-run opener.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/Lune.app"]
  end

  zap trash: [
    "~/Library/Preferences/com.lune.terminal.plist",
    "~/Library/Saved Application State/com.lune.terminal.savedState",
    "~/.config/lune",
  ]
end
