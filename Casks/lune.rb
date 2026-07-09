cask "lune" do
  version "1.0.17"
  sha256 "b27ca55416b1513da56c1967fa790bc16bb593bdd4343dc418ee48a23151f9e5"

  url "https://github.com/codiku-dev/lune-releases/releases/download/v#{version}/Lune-#{version}.dmg"
  name "Lune"
  desc "AI-powered terminal with local Ollama suggestions and chat"
  homepage "https://github.com/codiku-dev/lune-terminal"

  depends_on macos: :sonoma

  # Install manually instead of `app` so upgrades succeed when the user removed
  # /Applications/Lune.app (Homebrew's default app uninstall fails if missing).
  preflight do
    destination = Pathname("#{appdir}/Lune.app")
    system_command "/bin/rm", args: ["-rf", destination] if destination.exist?
  end

  postflight do
    destination = Pathname("#{appdir}/Lune.app")
    source = staged_path.join("Lune.app")

    system_command "/usr/bin/ditto",
                   args: ["--rsrc", source.to_s, destination.to_s]

    # Ad-hoc signed (not notarized): strip quarantine so Gatekeeper does not
    # report the Homebrew copy as "damaged".
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", destination.to_s]
  end

  uninstall_preflight do
    destination = Pathname("#{appdir}/Lune.app")
    system_command "/bin/rm", args: ["-rf", destination] if destination.exist?
  end

  zap trash: [
    "~/.config/lune",
    "~/Library/Preferences/com.lune.terminal.plist",
    "~/Library/Saved Application State/com.lune.terminal.savedState",
  ]
end
