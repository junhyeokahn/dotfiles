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
- macOS (Apple Silicon)
- Ubuntu

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
│   ├── flake.nix              # Nix flake definition
│   ├── init.lua               # Neovim init configuration
│   └── lua/                   # Lua configuration modules
├── kitty.conf                 # Kitty terminal configuration
├── starship.toml              # Starship prompt configuration
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
