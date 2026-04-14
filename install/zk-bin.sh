#!/usr/bin/env bash
set -euo pipefail

OS="$(uname -s)"
ARCH="$(uname -m)"

ZK_VERSION="v0.15.2"

ZK_INSTALL_DIR="$HOME/.local/bin"
ZK_BIN="${ZK_INSTALL_DIR}/zk"

TMPDIR_TO_CLEANUP=""
cleanup_tmpdir() {
    [[ -n "${TMPDIR_TO_CLEANUP:-}" ]] && rm -rf -- "${TMPDIR_TO_CLEANUP}"
}

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "Error: required command '$1' not found."
        exit 1
    }
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

install_linux_deps() {
    echo "Installing zk dependencies for Ubuntu..."
    apt_install curl tar
}

install_macos_deps() {
    echo "Installing zk dependencies for macOS..."
    brew_install curl gnu-tar
}

get_zk_platform() {
    case "${OS}" in
        Linux)  echo "linux" ;;
        Darwin) echo "macos" ;;
        *)
            echo "Unsupported operating system: ${OS}" >&2
            exit 1
            ;;
    esac
}

get_zk_arch() {
    case "${ARCH}" in
        x86_64|amd64)  echo "amd64" ;;
        arm64|aarch64) echo "arm64" ;;
        i386|i686)     echo "i386" ;;
        *)
            echo "Unsupported architecture: ${ARCH}" >&2
            exit 1
            ;;
    esac
}

install_zk_from_release() {
    echo "Installing zk ${ZK_VERSION} from prebuilt release..."

    need_cmd curl
    need_cmd tar
    need_cmd install
    need_cmd mktemp

    local platform arch asset_name download_url extracted_bin
    platform="$(get_zk_platform)"
    arch="$(get_zk_arch)"

    asset_name="zk-${ZK_VERSION}-${platform}-${arch}.tar.gz"
    download_url="https://github.com/zk-org/zk/releases/download/${ZK_VERSION}/${asset_name}"

    TMPDIR_TO_CLEANUP="$(mktemp -d)"
    trap cleanup_tmpdir EXIT

    mkdir -p "${ZK_INSTALL_DIR}"

    echo "Downloading ${asset_name}..."
    curl -fL "${download_url}" -o "${TMPDIR_TO_CLEANUP}/${asset_name}"

    echo "Extracting ${asset_name}..."
    tar -xzf "${TMPDIR_TO_CLEANUP}/${asset_name}" -C "${TMPDIR_TO_CLEANUP}"

    extracted_bin="$(find "${TMPDIR_TO_CLEANUP}" -type f -name zk | head -n 1 || true)"
    if [[ -z "${extracted_bin}" ]]; then
        echo "Error: could not find zk binary after extracting ${asset_name}"
        exit 1
    fi

    install -m 0755 "${extracted_bin}" "${ZK_BIN}"
}

main() {
    case "${OS}" in
        Darwin) install_macos_deps ;;
        Linux)  install_linux_deps ;;
        *)
            echo "Unsupported operating system: ${OS}"
            exit 1
            ;;
    esac

    install_zk_from_release

    echo
    echo "zk binary installation completed."
    "${ZK_BIN}" --version
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
