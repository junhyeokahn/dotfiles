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

# Check if flakes are enabled
if ! nix flake --help &> /dev/null; then
    echo "Enabling flakes..."
    mkdir -p ~/.config/nix
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
fi

# Install nvim
echo "Install nvim-nix"
nix profile add 'github:junhyeokahn/dotfiles?dir=nvim-nix'
