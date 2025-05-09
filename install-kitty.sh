if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "Installing Kitty on macOS..."
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

    FONT_DIRECTORY="/Library/Fonts"

    echo "Installing Starship prompt..."
    brew install starship
    echo 'eval "$(/opt/homebrew/bin/starship init zsh --print-full-init)"' >> ~/.zshrc

elif [[ "$(uname -s)" == "Linux" ]]; then
    echo "Installing Kitty on Linux..."
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n

    echo "Setting up Kitty symlinks and desktop entries..."
    ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
    cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
    cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
    sed -i "s|Icon=kitty|Icon=$HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
    sed -i "s|Exec=kitty|Exec=$HOME/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop

    FONT_DIRECTORY="/usr/share/fonts"

    echo "Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh
    echo 'eval "$(starship init bash)"' >> ~/.bashrc
else
    echo "Unsupported operating system. Exiting."
    exit 1
fi

# Configure Kitty
echo "Copying Kitty configuration files..."
KITTY_CONFIG_DIR="$HOME/.config/kitty"
mkdir -p "$KITTY_CONFIG_DIR"
for file in kitty.conf zoom_toggle.py custom-hints.py current-theme.conf; do
    cp "$file" "$KITTY_CONFIG_DIR/$file"
done

# Install Nerd Fonts
FONT_VERSION="3.3.0"
echo "Downloading and installing Nerd Fonts..."
for font in JetBrainsMono NerdFontsSymbolsOnly; do
    FONT_ZIP="${font}.zip"
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v${FONT_VERSION}/${FONT_ZIP}"
    echo "Downloading ${font}..."
    curl -L -o "$FONT_ZIP" "$FONT_URL"

    echo "Installing ${font} to ${FONT_DIRECTORY}..."
    sudo unzip -o "$FONT_ZIP" -d "${FONT_DIRECTORY}/${font}"
    rm "$FONT_ZIP"
done

# Configure Starship
echo "Configuring Starship..."
cp startship.toml ~/.config/starship.toml

echo "Installation completed. Please restart your terminal or source your rc file to apply changes."
