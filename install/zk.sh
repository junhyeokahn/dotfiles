#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=install/zk-bin.sh
source "${SCRIPT_DIR}/zk-bin.sh"

ZK_SOURCE_DIR="${REPO_ROOT}/zk"
ZK_SOURCE_CONFIG="${ZK_SOURCE_DIR}/config.toml"
ZK_SOURCE_TEMPLATES_DIR="${ZK_SOURCE_DIR}/templates"

ZK_NOTEBOOK_DIR="$HOME/notebook"
ZK_NOTEBOOK_META_DIR="${ZK_NOTEBOOK_DIR}/.zk"
ZK_NOTEBOOK_CONFIG="${ZK_NOTEBOOK_META_DIR}/config.toml"
ZK_NOTEBOOK_TEMPLATES_DIR="${ZK_NOTEBOOK_META_DIR}/templates"

append_once() {
    local line="$1"
    local file="$2"
    mkdir -p "$(dirname "$file")"
    touch "$file"
    grep -Fqx "$line" "$file" || echo "$line" >> "$file"
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

setup_shell_init() {
    mkdir -p "${ZK_INSTALL_DIR}"

    append_once 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc"
    append_once 'export ZK_NOTEBOOK_DIR="$HOME/notebook"' "$HOME/.zshrc"

    append_once 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc"
    append_once 'export ZK_NOTEBOOK_DIR="$HOME/notebook"' "$HOME/.bashrc"
}

bootstrap_zk_notebook() {
    [[ -f "${ZK_SOURCE_CONFIG}" ]] || {
        echo "Error: zk config file not found: ${ZK_SOURCE_CONFIG}"
        exit 1
    }

    [[ -d "${ZK_SOURCE_TEMPLATES_DIR}" ]] || {
        echo "Error: zk templates directory not found: ${ZK_SOURCE_TEMPLATES_DIR}"
        exit 1
    }

    mkdir -p "${ZK_NOTEBOOK_DIR}"

    if [[ ! -d "${ZK_NOTEBOOK_META_DIR}" ]]; then
        echo "Initializing zk notebook at ${ZK_NOTEBOOK_DIR}..."
        "${ZK_BIN}" init "${ZK_NOTEBOOK_DIR}" --no-input

        echo "Installing default zk config..."
        copy_file "${ZK_SOURCE_CONFIG}" "${ZK_NOTEBOOK_CONFIG}"

        echo "Installing default zk templates..."
        mkdir -p "${ZK_NOTEBOOK_TEMPLATES_DIR}"
        cp -R "${ZK_SOURCE_TEMPLATES_DIR}/." "${ZK_NOTEBOOK_TEMPLATES_DIR}/"
    else
        echo "zk notebook already exists at ${ZK_NOTEBOOK_DIR}"

        if [[ ! -f "${ZK_NOTEBOOK_CONFIG}" ]]; then
            echo "Installing missing zk config..."
            copy_file "${ZK_SOURCE_CONFIG}" "${ZK_NOTEBOOK_CONFIG}"
        fi

        if [[ ! -d "${ZK_NOTEBOOK_TEMPLATES_DIR}" ]]; then
            echo "Installing missing zk templates..."
            mkdir -p "${ZK_NOTEBOOK_TEMPLATES_DIR}"
            cp -R "${ZK_SOURCE_TEMPLATES_DIR}/." "${ZK_NOTEBOOK_TEMPLATES_DIR}/"
        fi
    fi

    mkdir -p "${ZK_NOTEBOOK_DIR}/meeting"
    mkdir -p "${ZK_NOTEBOOK_DIR}/daily"
}

main_local() {
    case "${OS}" in
        Darwin) install_macos_deps ;;
        Linux)  install_linux_deps ;;
        *)
            echo "Unsupported operating system: ${OS}"
            exit 1
            ;;
    esac

    setup_shell_init
    install_zk_from_release
    bootstrap_zk_notebook

    echo
    echo "zk installation completed."
    "${ZK_BIN}" --version
}

main_local "$@"
