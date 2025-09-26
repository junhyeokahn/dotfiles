#!/usr/bin/env bash
set -euo pipefail

# --- helpers ---------------------------------------------------------------
msg() { printf "\033[1;32m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m!! \033[0m %s\n" "$*"; }
err() { printf "\033[1;31m!! \033[0m %s\n" "$*" >&2; }

OS="$(uname -s || echo unknown)"

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

# --- ensure nix ------------------------------------------------------------
if need_nix_install; then
  msg "Nix is not installed. Installing Nix..."
  command -v curl >/dev/null 2>&1 || { err "curl is required to install Nix"; exit 1; }
  sh <(curl -L https://nixos.org/nix/install) --daemon --yes
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

nix "${PROFILE_ARGS[@]}" profile install --accept-flake-config \
  'github:junhyeokahn/dotfiles?dir=nvim-nix'

source_nix_env
if command -v nvim >/dev/null 2>&1; then
  msg "nvim is installed at: $(command -v nvim)"
else
  warn "nvim not found on PATH yet; you may need a new shell session."
fi

# --- copy configs -----------------------------------------------
download_configs() {
  local dest="${HOME}/.config/nvim-nix"
  local tmp
  tmp="$(mktemp -d)"
  mkdir -p "$dest"

  msg "Fetching configs via shallow sparse clone..."
  git -c advice.detachedHead=false clone --depth=1 \
    --filter=blob:none --sparse https://github.com/junhyeokahn/dotfiles "$tmp/repo"
  ( cd "$tmp/repo"
    git sparse-checkout set nvim-nix
  )

  cp -f "$tmp/repo/nvim-nix/init.lua" "$dest/"
  rm -rf "$dest/lua"
  cp -R "$tmp/repo/nvim-nix/lua" "$dest/"
  msg "Configs copied to ${dest}"
  rm -rf "$tmp"
}

msg "Downloading Neovim configs"
download_configs || { err "Failed to download configs."; exit 1; }

msg "Done."

