#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

OS="$(uname -s)"

ZK_VERSION="v0.15.2"
ZK_INSTALL_DIR="$HOME/.local/bin"
ZK_BIN="${ZK_INSTALL_DIR}/zk"

ZK_SOURCE_DIR="${REPO_ROOT}/zk"
ZK_SOURCE_CONFIG="${ZK_SOURCE_DIR}/config.toml"
ZK_SOURCE_TEMPLATES_DIR="${ZK_SOURCE_DIR}/templates"

ZK_NOTEBOOK_DIR="$HOME/notebook"
ZK_NOTEBOOK_META_DIR="${ZK_NOTEBOOK_DIR}/.zk"
ZK_NOTEBOOK_CONFIG="${ZK_NOTEBOOK_META_DIR}/config.toml"
ZK_NOTEBOOK_TEMPLATES_DIR="${ZK_NOTEBOOK_META_DIR}/templates"

cleanup_tmpdir() {
    [[ -n "${TMPDIR_TO_CLEANUP:-}" ]] && rm -rf -- "${TMPDIR_TO_CLEANUP}"
}

install_linux_deps() {
    echo "Installing zk dependencies for Ubuntu..."
    apt_install git make golang-go
}

install_macos_deps() {
    echo "Installing zk dependencies for macOS..."
    brew_install git go make
}

setup_shell_init() {
    mkdir -p "${ZK_INSTALL_DIR}"

    append_once 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc"
    append_once 'export ZK_NOTEBOOK_DIR="$HOME/notebook"' "$HOME/.zshrc"

    append_once 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc"
    append_once 'export ZK_NOTEBOOK_DIR="$HOME/notebook"' "$HOME/.bashrc"
}

install_zk_from_source() {
    echo "Installing zk ${ZK_VERSION} from source..."

    need_cmd git
    need_cmd make
    need_cmd go
    need_cmd install
    need_cmd mktemp

    TMPDIR_TO_CLEANUP="$(mktemp -d)"
    trap cleanup_tmpdir EXIT

    git clone --branch "${ZK_VERSION}" --depth 1 https://github.com/zk-org/zk.git "${TMPDIR_TO_CLEANUP}/zk"
    cd "${TMPDIR_TO_CLEANUP}/zk"
    make build

    install -m 0755 ./zk "${ZK_BIN}"
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
        "${ZK_BIN}" init "${ZK_NOTEBOOK_DIR}"

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

    setup_shell_init
    install_zk_from_source
    bootstrap_zk_notebook

    echo
    echo "zk installation completed."
    "${ZK_BIN}" --version
}

main "$@"
