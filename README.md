# Dotfiles

Personal development environment configuration files and installation scripts.

[![Test install scripts](https://github.com/junhyeokahn/dotfiles/actions/workflows/test-install-scripts.yml/badge.svg)](https://github.com/junhyeokahn/dotfiles/actions/workflows/test-install-scripts.yml)

## Quick Start

```bash
# Clone the repository
git clone https://github.com/junhyeokahn/dotfiles.git
cd dotfiles

# Install everything
./install-prerequisite.sh  # Install base dependencies
./install-kitty.sh         # Install Kitty terminal
./install-nvim-nix.sh      # Install Neovim via Nix
```

## Installation Scripts

### Prerequisites (`install-prerequisite.sh`)

Installs essential development tools and dependencies.

**What it installs:**
- **macOS**: Homebrew, Xcode Command Line Tools, git, cmake, clang-format, llvm, curl, gcc, wget, ripgrep, pyright
- **Linux**: curl, vim, clang-format, gcc, wget, unzip, ripgrep, xclip, npm
- **Both**: fzf (fuzzy finder)

**Usage:**
```bash
./install-prerequisite.sh
```

### Kitty Terminal (`install-kitty.sh`)

Installs and configures the Kitty terminal emulator with custom settings.

**What it installs:**
- Kitty terminal emulator
- JetBrainsMono Nerd Font
- Nerd Fonts Symbols
- Starship prompt
- Custom Kitty configuration files

**Usage:**
```bash
./install-kitty.sh
```

**Note:** Requires sudo for font installation. The script will prompt for your password.

### Neovim with Nix (`install-nvim-nix.sh`)

Installs Neovim using Nix package manager with a custom configuration.

**What it does:**
1. Installs Nix package manager (if not present)
2. Installs Neovim from the flake configuration
3. Downloads Neovim configuration to `~/.config/nvim-nix/`

**Usage:**
```bash
./install-nvim-nix.sh
```

**Benefits of Nix installation:**
- Reproducible builds across different machines
- Isolated from system packages
- Easy rollback and updates
- All LSPs and tools included in the package

### Alternative Neovim Installation (`install-nvim.sh`)

Traditional Neovim installation script (alternative to Nix version).

**Usage:**
```bash
./install-nvim.sh
```

## System Requirements

### Supported Operating Systems
- macOS (Intel and Apple Silicon)
- Ubuntu/Debian-based Linux distributions

### Required Software
- Git
- Curl
- Bash 4.0+

## Directory Structure

```
dotfiles/
├── install-prerequisite.sh    # Base dependencies installer
├── install-kitty.sh           # Kitty terminal installer
├── install-nvim-nix.sh        # Neovim Nix installer
├── install-nvim.sh            # Traditional Neovim installer
├── nvim-nix/                  # Neovim Nix configuration
│   ├── flake.nix             # Nix flake definition
│   ├── init.lua              # Neovim init configuration
│   └── lua/                  # Lua configuration modules
├── kitty.conf                 # Kitty terminal configuration
├── starship.toml             # Starship prompt configuration
└── .github/workflows/         # CI/CD workflows
```

## Configuration Files

### Kitty Configuration
- **Location**: `~/.config/kitty/`
- **Files**: `kitty.conf`, `current-theme.conf`, `zoom_toggle.py`, `custom-hints.py`

### Neovim Configuration
- **Location**: `~/.config/nvim-nix/`
- **Files**: `init.lua` and `lua/` directory with plugin configurations

### Starship Configuration
- **Location**: `~/.config/starship.toml`
- Custom prompt with git information, directory context, and more

## Troubleshooting

### Nix Installation Issues

If you encounter rate limiting errors when installing with Nix:
```bash
export NIX_CONFIG="access-tokens = github.com=YOUR_GITHUB_TOKEN"
./install-nvim-nix.sh
```

### Kitty Font Issues

If fonts aren't displaying correctly:
1. Restart your terminal
2. On Linux, you may need to run: `fc-cache -fv`
3. Check font installation: `fc-list | grep JetBrains`

### FZF Not Found

If fzf isn't available after installation:
```bash
# Add to your shell configuration
export PATH="$HOME/.fzf/bin:$PATH"
source ~/.fzf/bash  # for bash
source ~/.fzf/zsh   # for zsh
```

### Permission Denied

If you get permission errors:
```bash
chmod +x install-*.sh
```

## CI/CD

The repository includes GitHub Actions workflows that test all installation scripts on:
- macOS (latest, ARM64)
- Ubuntu (latest)

Tests run automatically on:
- Push to main branch
- Pull requests
- Manual workflow dispatch

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Ensure tests pass
5. Submit a pull request

## License

This repository contains personal configuration files. Feel free to use and modify for your own purposes.