#!/usr/bin/env bash

set -e

# Check if nix is installed
if ! command -v nix &> /dev/null; then
    echo "Nix is not installed. Please install Nix first:"
    echo "curl -L https://nixos.org/nix/install | sh"
    exit 1
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
