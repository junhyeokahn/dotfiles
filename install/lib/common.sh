#!/usr/bin/env bash

set -euo pipefail

append_once() {
    local line="$1"
    local file="$2"
    mkdir -p "$(dirname "$file")"
    touch "$file"
    grep -Fqx "$line" "$file" || echo "$line" >> "$file"
}

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "Error: required command '$1' not found."
        exit 1
    }
}

copy_file() {
    local src="$1"
    local dst="$2"

    [[ -f "${src}" ]] || {
        echo "Error: source file not found: ${src}"
        exit 1
    }

    echo "Copying $(basename "$src")..."
    mkdir -p "$(dirname "$dst")"
    cp -f "${src}" "${dst}"
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
    local local_bin_dir="${HOME}/.local/bin"

    if command -v fzf >/dev/null 2>&1; then
        return
    fi

    echo "Installing fzf..."
    need_cmd git

    if [[ ! -d "$HOME/.fzf" ]]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    fi

    "$HOME/.fzf/install" --bin --no-update-rc
    mkdir -p "${local_bin_dir}"
    ln -sf "$HOME/.fzf/bin/fzf" "${local_bin_dir}/fzf"
}

fix_linux_cli_names() {
    local local_bin_dir="${HOME}/.local/bin"
    mkdir -p "${local_bin_dir}"

    if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
        ln -sf "$(command -v fdfind)" "${local_bin_dir}/fd"
    fi

    if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
        ln -sf "$(command -v batcat)" "${local_bin_dir}/bat"
    fi
}
