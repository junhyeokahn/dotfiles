#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

OS="$(uname -s)"
STARSHIP_SOURCE_DIR="${REPO_ROOT}/starship"
STARSHIP_CONFIG_FILE="${STARSHIP_SOURCE_DIR}/starship.toml"

install_linux_deps() {
    echo "Installing Starship dependencies for Linux..."
    apt_install curl
}

install_macos_deps() {
    echo "Installing Starship dependencies for macOS..."
    brew_install curl
}

install_starship() {
    echo "Installing Starship..."

    if [[ "${OS}" == "Darwin" ]]; then
        brew_install starship
    else
        need_cmd curl
        download_and_run https://starship.rs/install.sh -y
    fi
}

install_starship_config() {
    [[ -f "${STARSHIP_CONFIG_FILE}" ]] || {
        echo "Error: Starship config file not found: ${STARSHIP_CONFIG_FILE}"
        exit 1
    }

    echo "Installing Starship configuration..."
    mkdir -p "$HOME/.config"
    copy_file "${STARSHIP_CONFIG_FILE}" "$HOME/.config/starship.toml"
}

setup_starship_shell_init() {
    append_once 'eval "$(starship init zsh)"' "$HOME/.zshrc"
    append_once 'eval "$(starship init bash)"' "$HOME/.bashrc"
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

    install_starship
    install_starship_config
    setup_starship_shell_init

    echo
    echo "Starship installation completed."
}

main "$@"
