cask "lune" do
  version "1.0.28"
  sha256 "3f0ce724efbe3a1ad0c95a6adcca7307928cf41aabc712e04d2b00d478b98a40"

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
