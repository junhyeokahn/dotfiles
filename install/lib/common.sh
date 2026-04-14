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
    local fzf_target="$HOME/.fzf/bin/fzf"
    local fzf_link="${local_bin_dir}/fzf"

    if [[ -L "${fzf_link}" && "$(readlink "${fzf_link}")" == "${fzf_target}" && -x "${fzf_target}" ]]; then
        return
    fi

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
    ln -sf "${fzf_target}" "${fzf_link}"
}

# sha256_cmd prints the command to use for sha256 verification.
sha256_cmd() {
    if command -v sha256sum >/dev/null 2>&1; then
        echo "sha256sum"
    elif command -v shasum >/dev/null 2>&1; then
        echo "shasum -a 256"
    else
        echo "Error: need sha256sum or shasum to verify checksums." >&2
        exit 1
    fi
}

# verify_sha256 <file> <expected_hex>
verify_sha256() {
    local file="$1"
    local expected="$2"
    local actual
    actual="$($(sha256_cmd) "${file}" | awk '{print $1}')"
    if [[ "${actual}" != "${expected}" ]]; then
        echo "Error: checksum mismatch for ${file}" >&2
        echo "  expected: ${expected}" >&2
        echo "  actual:   ${actual}" >&2
        exit 1
    fi
}

# download_and_run <url> [args...] — downloads to a temp file, runs it, cleans up.
download_and_run() {
    local url="$1"
    shift
    need_cmd curl
    local tmp rc=0
    tmp="$(mktemp)"
    curl -fsSL "${url}" -o "${tmp}"
    chmod +x "${tmp}"
    sh "${tmp}" "$@" || rc=$?
    rm -f "${tmp}"
    return "${rc}"
}
