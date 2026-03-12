#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

OS="$(uname -s)"
KITTY_SOURCE_DIR="${REPO_ROOT}/kitty"
KITTY_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kitty"

case "${OS}" in
    Darwin)
        FONT_DIR="$HOME/Library/Fonts"
        ;;
    Linux)
        FONT_DIR="$HOME/.local/share/fonts"
        ;;
    *)
        echo "Unsupported operating system: ${OS}"
        exit 1
        ;;
esac

mkdir -p "$HOME/.config" "$FONT_DIR" "$HOME/.local/bin"

install_linux_deps() {
    echo "Installing Kitty dependencies for Linux..."
    apt_install curl unzip sed git
    install_fzf
}

install_macos_deps() {
    echo "Installing Kitty dependencies for macOS..."
    brew_install curl unzip git
    install_fzf
}

install_kitty_linux_desktop() {
    need_cmd cp
    need_cmd sed

    mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"

    ln -sf "$HOME/.local/kitty.app/bin/kitty" "$HOME/.local/bin/kitty"
    ln -sf "$HOME/.local/kitty.app/bin/kitten" "$HOME/.local/bin/kitten"

    cp "$HOME/.local/kitty.app/share/applications/kitty.desktop" \
       "$HOME/.local/share/applications/kitty.desktop"
    cp "$HOME/.local/kitty.app/share/applications/kitty-open.desktop" \
       "$HOME/.local/share/applications/kitty-open.desktop"

    for desktop_file in \
        "$HOME/.local/share/applications/kitty.desktop" \
        "$HOME/.local/share/applications/kitty-open.desktop"; do
        sed -i "s|Icon=kitty|Icon=$HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" "$desktop_file"
        sed -i "s|Exec=kitty|Exec=$HOME/.local/kitty.app/bin/kitty|g" "$desktop_file"
    done
}

install_kitty() {
    need_cmd curl
    need_cmd sh

    echo "Installing Kitty..."

    if [[ "${OS}" == "Darwin" ]]; then
        curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    else
        curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n
        install_kitty_linux_desktop
    fi
}

install_kitty_config() {
    [[ -d "${KITTY_SOURCE_DIR}" ]] || {
        echo "Error: Kitty config directory not found: ${KITTY_SOURCE_DIR}"
        exit 1
    }

    echo "Installing Kitty configuration files..."
    mkdir -p "${KITTY_CONFIG_DIR}"

    copy_file "${KITTY_SOURCE_DIR}/kitty.conf" "${KITTY_CONFIG_DIR}/kitty.conf"
    copy_file "${KITTY_SOURCE_DIR}/zoom_toggle.py" "${KITTY_CONFIG_DIR}/zoom_toggle.py"
    copy_file "${KITTY_SOURCE_DIR}/custom-hints.py" "${KITTY_CONFIG_DIR}/custom-hints.py"
    copy_file "${KITTY_SOURCE_DIR}/current-theme.conf" "${KITTY_CONFIG_DIR}/current-theme.conf"
}

install_nerd_fonts() {
    need_cmd curl
    need_cmd unzip

    local font_version="3.3.0"

    echo "Installing Nerd Fonts..."
    for font in JetBrainsMono NerdFontsSymbolsOnly; do
        local font_zip="${font}.zip"
        local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${font_version}/${font_zip}"
        local font_target_dir="${FONT_DIR}/${font}"

        echo "Downloading ${font}..."
        curl -fLo "/tmp/${font_zip}" "${font_url}"

        echo "Installing ${font}..."
        mkdir -p "${font_target_dir}"
        unzip -o "/tmp/${font_zip}" -d "${font_target_dir}" >/dev/null
        rm -f "/tmp/${font_zip}"
    done

    if [[ "${OS}" == "Linux" ]] && command -v fc-cache >/dev/null 2>&1; then
        echo "Refreshing font cache..."
        fc-cache -fv
    fi
}

main() {
    case "${OS}" in
        Darwin)
            install_macos_deps
            ;;
        Linux)
            install_linux_deps
            ;;
        *)
            echo "Unsupported operating system: ${OS}"
            exit 1
            ;;
    esac

    ensure_local_bin_path
    install_kitty
    install_kitty_config
    install_nerd_fonts

    echo
    echo "Kitty installation completed."
    echo 'Restart your terminal or run:'
    echo '  export PATH="$HOME/.local/bin:$PATH"'
}

main "$@"
