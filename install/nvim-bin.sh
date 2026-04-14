#!/usr/bin/env bash
set -euo pipefail

NVIM_CHANNEL="nightly"

LOCAL_DIR="${HOME}/.local"
LOCAL_BIN_DIR="${LOCAL_DIR}/bin"

OS="$(uname -s)"
ARCH="$(uname -m)"

mkdir -p "${LOCAL_DIR}" "${LOCAL_BIN_DIR}"

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "Error: required command '$1' not found."
        exit 1
    }
}

append_once() {
    local line="$1"
    local file="$2"
    mkdir -p "$(dirname "$file")"
    touch "$file"
    grep -Fqx "$line" "$file" || echo "$line" >> "$file"
}

apt_install() {
    need_cmd apt-get
    if [[ "$(id -u)" -eq 0 ]]; then
        apt-get update
        apt-get install -y "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y "$@"
    else
        echo "Error: need root or sudo to install packages with apt-get."
        exit 1
    fi
}

brew_install() {
    need_cmd brew
    brew install "$@"
}

ensure_local_bin_path() {
    local path_line='export PATH="$HOME/.local/bin:$PATH"'
    append_once "${path_line}" "$HOME/.bashrc"
    append_once "${path_line}" "$HOME/.zshrc"
}

install_fzf() {
    if command -v fzf >/dev/null 2>&1; then
        return
    fi
    echo "Installing fzf..."
    need_cmd git
    if [[ ! -d "$HOME/.fzf" ]]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    fi
    "$HOME/.fzf/install" --bin --no-update-rc
    mkdir -p "${LOCAL_BIN_DIR}"
    ln -sf "$HOME/.fzf/bin/fzf" "${LOCAL_BIN_DIR}/fzf"
}

fix_linux_cli_names() {
    mkdir -p "${LOCAL_BIN_DIR}"
    if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
        ln -sf "$(command -v fdfind)" "${LOCAL_BIN_DIR}/fd"
    fi
    if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
        ln -sf "$(command -v batcat)" "${LOCAL_BIN_DIR}/bat"
    fi
}

install_linux_deps() {
    echo "Installing Neovim dependencies for Linux..."
    apt_install \
        curl \
        git \
        ripgrep \
        fd-find \
        bat \
        clang \
        libclang-dev

    local rustup_tmp
    rustup_tmp="$(mktemp)"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o "${rustup_tmp}"
    sh "${rustup_tmp}" -y
    rm -f "${rustup_tmp}"
    . "$HOME/.cargo/env"
    cargo install --locked tree-sitter-cli

    fix_linux_cli_names
    install_fzf
}

install_macos_deps() {
    echo "Installing Neovim dependencies for macOS..."
    brew_install curl \
        git \
        fd \
        ripgrep \
        bat \
        llvm \
        tree-sitter-cli

    install_fzf
}

install_nvim_macos() {
    need_cmd curl
    need_cmd tar

    local name file url

    case "${ARCH}" in
        arm64)  name="nvim-macos-arm64" ;;
        x86_64) name="nvim-macos-x86_64" ;;
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
        x86_64)         name="nvim-linux-x86_64.appimage" ;;
        aarch64|arm64)  name="nvim-linux-arm64.appimage" ;;
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

    echo
    echo "Neovim binary installation completed."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
