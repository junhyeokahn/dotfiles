#!/usr/bin/env bash
set -euo pipefail

# --- helpers ---------------------------------------------------------------
msg() { printf "\033[1;32m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m!! \033[0m %s\n" "$*"; }
err() { printf "\033[1;31m!! \033[0m %s\n" "$*" >&2; }

OS="$(uname -s || echo unknown)"
IS_ROOT="$([ "${EUID:-$(id -u)}" -eq 0 ] && echo 1 || echo 0)"
COPY_CONFIGS=0

# --- arg parse -------------------------------------------------------------
for arg in "$@"; do
  case "$arg" in
    --copy-configs) COPY_CONFIGS=1 ;;
    -h|--help)
      cat <<'EOF'
Usage: install_nvim_nix.sh [--copy-configs]

Options:
  --copy-configs  Download init.lua and lua/ to ~/.config/nvim-nix
  -h, --help      Show this help
EOF
      exit 0
      ;;
    *) warn "Unknown argument: $arg" ;;
  esac
done

# --- nix env sourcing ------------------------------------------------------
source_nix_env() {
  if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    # shellcheck disable=SC1091
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  elif [ -f "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]; then
    # shellcheck disable=SC1091
    . "${HOME}/.nix-profile/etc/profile.d/nix.sh"
  fi
  export PATH="/nix/var/nix/profiles/default/bin:${HOME}/.nix-profile/bin:/nix/profile/bin:${PATH}"
}

need_nix_install() { ! command -v nix >/dev/null 2>&1; }

choose_install_flags() {
  if [ "$OS" = "Darwin" ]; then
    echo "--daemon --yes"; return
  fi
  if command -v systemctl >/dev/null 2>&1 && systemctl is-system-running >/dev/null 2>&1; then
    echo "--daemon --yes"
  else
    echo "--no-daemon --yes"
  fi
}

# --- ensure nix ------------------------------------------------------------
if need_nix_install; then
  msg "Nix is not installed. Installing Nix..."
  command -v curl >/dev/null 2>&1 || { err "curl is required to install Nix"; exit 1; }
  INSTALL_FLAGS="$(choose_install_flags)"
  sh <(curl -L https://nixos.org/nix/install) "$INSTALL_FLAGS"
  source_nix_env
  command -v nix >/dev/null 2>&1 || { err "Nix installed but not on PATH; open a new shell and rerun."; exit 1; }
  msg "Nix installed successfully."
else
  source_nix_env
  msg "Nix already installed."
fi

# --- install nvim flake package -------------------------------------------
msg "Installing nvim from flake 'github:junhyeokahn/dotfiles?dir=nvim-nix'"

PROFILE_ARGS=(--extra-experimental-features "nix-command flakes")

if [ "$IS_ROOT" = "1" ]; then
  SYS_PROFILE="/nix/var/nix/profiles/default"
  if [ -w "$SYS_PROFILE" ] || [ ! -e "$SYS_PROFILE" ]; then
    nix "${PROFILE_ARGS[@]}" profile install --accept-flake-config \
      --profile "$SYS_PROFILE" 'github:junhyeokahn/dotfiles?dir=nvim-nix' || {
        warn "System profile install failed; falling back to user profile."
        nix "${PROFILE_ARGS[@]}" profile install --accept-flake-config \
          'github:junhyeokahn/dotfiles?dir=nvim-nix'
      }
  else
    warn "No write access to $SYS_PROFILE; installing to user profile instead."
    nix "${PROFILE_ARGS[@]}" profile install --accept-flake-config \
      'github:junhyeokahn/dotfiles?dir=nvim-nix'
  fi
else
  nix "${PROFILE_ARGS[@]}" profile install --accept-flake-config \
    'github:junhyeokahn/dotfiles?dir=nvim-nix'
fi

source_nix_env
if command -v nvim >/dev/null 2>&1; then
  msg "nvim is installed at: $(command -v nvim)"
else
  warn "nvim not found on PATH yet; you may need a new shell session."
fi

# --- copy configs on demand -----------------------------------------------
download_configs() {
  local dest="${HOME}/.config/nvim-nix"
  local tmp
  tmp="$(mktemp -d)"
  mkdir -p "$dest"

  if command -v git >/dev/null 2>&1; then
    msg "Fetching configs via shallow sparse clone..."
    git -c advice.detachedHead=false clone --depth=1 \
      --filter=blob:none --sparse https://github.com/junhyeokahn/dotfiles "$tmp/repo"
    ( cd "$tmp/repo"
      git sparse-checkout set nvim-nix
    )
    if [ -f "$tmp/repo/nvim-nix/init.lua" ] && [ -d "$tmp/repo/nvim-nix/lua" ]; then
      cp -f "$tmp/repo/nvim-nix/init.lua" "$dest/"
      rm -rf "$dest/lua"
      cp -R "$tmp/repo/nvim-nix/lua" "$dest/"
      msg "Configs copied to ${dest}"
      rm -rf "$tmp"
      return 0
    fi
    warn "Expected files not found in cloned repo; falling back to tarball."
    rm -rf "$tmp"
  fi

  # Fallback: curl + tar (no git required)
  command -v curl >/dev/null 2>&1 || { err "curl is required to download configs"; return 1; }
  command -v tar  >/dev/null 2>&1 || { err "tar is required to extract configs";  return 1; }

  tmp="$(mktemp -d)"
  msg "Fetching configs via GitHub tarball..."
  # This downloads the default branch tarball and extracts only nvim-nix/ paths
  curl -Ls "https://api.github.com/repos/junhyeokahn/dotfiles/tarball" \
    | tar -xz -C "$tmp"
  # Find the extracted root (owner-repo-<sha>/)
  local root
  root="$(find "$tmp" -maxdepth 1 -type d -name "junhyeokahn-dotfiles-*" | head -n1 || true)"
  if [ -z "${root:-}" ]; then
    err "Could not locate tarball root directory."
    rm -rf "$tmp"; return 1
  fi
  if [ -f "$root/nvim-nix/init.lua" ] && [ -d "$root/nvim-nix/lua" ]; then
    cp -f "$root/nvim-nix/init.lua" "$dest/"
    rm -rf "$dest/lua"
    cp -R "$root/nvim-nix/lua" "$dest/"
    msg "Configs copied to ${dest}"
  else
    err "init.lua or lua/ not found in tarball."
    rm -rf "$tmp"; return 1
  fi
  rm -rf "$tmp"
}

if [ "$COPY_CONFIGS" -eq 1 ]; then
  msg "Downloading Neovim configs (--copy-configs enabled)"
  download_configs || { err "Failed to download configs."; exit 1; }
else
  msg "Skipping config download (no --copy-configs)"
fi

msg "Done."

