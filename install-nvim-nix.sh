#!/usr/bin/env bash

set -e

# Check if nix is installed
if ! command -v nix &> /dev/null; then
    echo "Nix is not installed. Installing Nix..."
    curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes

    # Source nix environment
    if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    elif [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
        . ~/.nix-profile/etc/profile.d/nix.sh
    else
        echo "Failed to source Nix environment. Please restart your shell and run this script again."
        exit 1
    fi

    echo "Nix installed successfully."
fi

# Enable flakes (always configure to ensure it's set)
echo "Configuring Nix experimental features..."
if [ "$EUID" -eq 0 ]; then
    # System-wide config for root/daemon mode
    mkdir -p /etc/nix
    echo "experimental-features = nix-command flakes" > /etc/nix/nix.conf
else
    # User config
    mkdir -p ~/.config/nix
    echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
fi

# Restart nix-daemon if running to pick up config changes (skip in Docker)
if [ "$EUID" -eq 0 ] && command -v systemctl &> /dev/null && systemctl is-active --quiet nix-daemon; then
    systemctl restart nix-daemon
fi

# Install nvim
echo "Install nvim-nix"
nix profile add 'github:junhyeokahn/dotfiles?dir=nvim-nix'
