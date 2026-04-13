#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=install/nvim-bin.sh
source "${SCRIPT_DIR}/nvim-bin.sh"

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
NVIM_SOURCE_DIR="${REPO_ROOT}/nvim"

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

main_local() {
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

main_local "$@"
