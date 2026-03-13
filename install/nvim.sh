#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

NVIM_CHANNEL="nightly"

LOCAL_DIR="${HOME}/.local"
LOCAL_BIN_DIR="${LOCAL_DIR}/bin"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
NVIM_SOURCE_DIR="${REPO_ROOT}/nvim"

OS="$(uname -s)"
ARCH="$(uname -m)"

mkdir -p "${LOCAL_DIR}" "${LOCAL_BIN_DIR}"

install_linux_deps() {
    echo "Installing Neovim dependencies for Linux..."
    apt_install \
        curl \
        git \
        ripgrep \
        fd-find \
        bat

    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    . "$HOME/.cargo/env"
    cargo install tree-sitter-cli

    fix_linux_cli_names
    install_fzf
}

install_macos_deps() {
    echo "Installing Neovim dependencies for macOS..."
    brew_install curl git fd ripgrep bat tree-sitter-cli
    install_fzf
}

install_nvim_macos() {
    need_cmd curl
    need_cmd tar

    local name file url

    case "${ARCH}" in
        arm64)
            name="nvim-macos-arm64"
            ;;
        x86_64)
            name="nvim-macos-x86_64"
            ;;
        *)
            echo "Unsupported macOS architecture: ${ARCH}"
            exit 1
            ;;
    esac

    file="${name}.tar.gz"
    url="https://github.com/neovim/neovim/releases/download/${NVIM_CHANNEL}/${file}"

    echo "Downloading Neovim ${NVIM_CHANNEL} for macOS (${ARCH})..."
    curl -fL "${url}" -o "/tmp/${file}"

    rm -rf "${LOCAL_DIR:?}/${name}" "${LOCAL_BIN_DIR}/nvim"
    tar xzf "/tmp/${file}" -C "${LOCAL_DIR}"
    ln -sf "${LOCAL_DIR}/${name}/bin/nvim" "${LOCAL_BIN_DIR}/nvim"

    rm -f "/tmp/${file}"
}

install_nvim_linux() {
    need_cmd curl

    local name url

    case "${ARCH}" in
        x86_64)
            name="nvim-linux-x86_64.appimage"
            ;;
        aarch64|arm64)
            name="nvim-linux-arm64.appimage"
            ;;
        *)
            echo "Unsupported Linux architecture: ${ARCH}"
            exit 1
            ;;
    esac

    url="https://github.com/neovim/neovim/releases/download/${NVIM_CHANNEL}/${name}"

    echo "Downloading Neovim ${NVIM_CHANNEL} AppImage for Linux (${ARCH})..."
    curl -fL "${url}" -o "${LOCAL_BIN_DIR}/nvim"
    chmod u+x "${LOCAL_BIN_DIR}/nvim"
}

install_nvim_config() {
    [[ -d "${NVIM_SOURCE_DIR}" ]] || {
        echo "Error: Neovim config directory not found: ${NVIM_SOURCE_DIR}"
        exit 1
    }

    echo "Installing Neovim config..."
    rm -rf "${CONFIG_DIR}"
    mkdir -p "$(dirname "${CONFIG_DIR}")"
    cp -R "${NVIM_SOURCE_DIR}" "${CONFIG_DIR}"
}

main() {
    case "${OS}" in
        Darwin)
            install_macos_deps
            install_nvim_macos
            ;;
        Linux)
            install_linux_deps
            install_nvim_linux
            ;;
        *)
            echo "Unsupported operating system: ${OS}"
            exit 1
            ;;
    esac

    ensure_local_bin_path
    install_nvim_config

    echo
    echo "Neovim installation completed."
    echo 'Run this now or restart your shell:'
    echo '  export PATH="$HOME/.local/bin:$PATH"'
    echo "Then verify with:"
    echo "  nvim --version"
}

main "$@"
