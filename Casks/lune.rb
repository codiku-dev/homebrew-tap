cask "lune" do
  version "1.0.0"
  sha256 "c4bec48ecfe4c0a44aa4e7b605ec41819a12aea80170c327736644673fbab7fe"

  url "https://github.com/codiku-dev/lune-releases/releases/download/v#{version}/Lune-#{version}.dmg"
  name "Lune"
  desc "AI-powered terminal with local Ollama suggestions and chat"
  homepage "https://github.com/codiku-dev/lune-terminal"

  depends_on macos: ">= :sonoma"

  app "Lune.app"

  zap trash: [
    "~/Library/Preferences/com.lune.terminal.plist",
    "~/Library/Saved Application State/com.lune.terminal.savedState",
    "~/.config/lune",
  ]
end
