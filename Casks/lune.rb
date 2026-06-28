cask "lune" do
  version "1.0.0"
  sha256 "852019226de71a2b0f89013cae21336ff9bbdec9c6a57f6865561b1ff82534b5"

  url "https://github.com/codiku-dev/lune-releases/releases/download/v#{version}/Lune-#{version}.dmg"
  name "Lune"
  desc "AI-powered terminal with local Ollama suggestions and chat"
  homepage "https://github.com/codiku-dev/lune-terminal"

  depends_on macos: :sonoma

  app "Lune.app"

  zap trash: [
    "~/Library/Preferences/com.lune.terminal.plist",
    "~/Library/Saved Application State/com.lune.terminal.savedState",
    "~/.config/lune",
  ]
end
