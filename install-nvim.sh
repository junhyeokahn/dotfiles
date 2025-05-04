VERSION="v0.11.1"
LOCAL_DIR="${HOME}/.local"
LOCAL_BIN_DIR="${LOCAL_DIR}/bin"

mkdir -p "${LOCAL_DIR}" "${LOCAL_BIN_DIR}"

if [[ "$(uname -s)" == "Darwin" ]]; then
    NAME="nvim-macos-arm64"
    FILE="${NAME}.tar.gz"

    echo "Downloading Neovim for macOS..."
    curl -L "https://github.com/neovim/neovim/releases/download/${VERSION}/${FILE}" --output "${FILE}"

    echo "Clearing extended attributes..."
    xattr -c "${FILE}"

    echo "Extracting to ${LOCAL_DIR}..."
    tar xzvf "${FILE}" --strip-components=1 -C "${LOCAL_DIR}"
    echo "export PATH=\$PATH:${LOCAL_BIN_DIR}" >> ~/.zshrc

    rm "${FILE}"
elif [[ "$(uname -s)" == "Linux" ]]; then
    NAME="nvim.appimage"

    echo "Downloading Neovim AppImage for Linux..."
    curl -L "https://github.com/neovim/neovim/releases/download/${VERSION}/${NAME}" --output "${LOCAL_BIN_DIR}/nvim"

    chmod u+x "${LOCAL_BIN_DIR}/nvim"
    echo "export PATH=\$PATH:${LOCAL_BIN_DIR}" >> ~/.bashrc
else
    echo "Unsupported operating system. Exiting."
    exit 1
fi

git clone https://github.com/junhyeokahn/nvim-config.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim

echo 'Installation completed. Please restart your terminal or source your rc file to apply changes.'
