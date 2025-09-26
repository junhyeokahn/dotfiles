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

**Key differences from regular nvim:**
- **Plugin Management**: Uses Nix instead of lazy.nvim - all plugins are pre-installed and pinned to specific versions
- **Dependencies**: All LSPs, formatters, and tools are bundled with the package (no need for Mason or manual installations)
- **Configuration**: Uses `~/.config/nvim-nix/` instead of `~/.config/nvim/` to avoid conflicts
- **Configuration Mode**: Can toggle between Nix store (reproducible) and live config (development) using `NIXCATS_UNWRAP_RC` environment variable
- **Ideal for**: Docker containers, CI/CD environments, and systems where you want a fully reproducible setup

**Benefits of Nix installation:**
- Reproducible builds across different machines
- Isolated from system packages
- Easy rollback and updates
- All LSPs and tools included in the package
- Perfect for containerized environments where you can't easily install dependencies

**Configuration Modes:**
The nvim-nix installation supports two configuration modes controlled by the `NIXCATS_UNWRAP_RC` environment variable:

1. **Nix Store Mode (default)**: Configuration is embedded in the Nix derivation for full reproducibility
   ```bash
   # Run with Nix store configuration (reproducible)
   nvim
   ```

2. **Live Reload Mode**: Uses configuration files from `~/.config/nvim-nix/` for development
   ```bash
   # Run with live configuration files (for development/testing)
   export NIXCATS_UNWRAP_RC=1
   nvim

   # Or as a one-time command
   NIXCATS_UNWRAP_RC=1 nvim
   ```

This allows you to test configuration changes without rebuilding the Nix package, then freeze them into the Nix store once finalized.

**Updating the Neovim package:**
```bash
# Tells Nix to re-fetch the input (GitHub repo) and resolve it again
nix profile upgrade --refresh nvim-nix
```

**Updating dependencies (plugins, LSPs, etc.):**
To update the actual plugin versions and dependencies, you need to update the `flake.lock` file in the repository:
```bash
# Clone the repository
git clone https://github.com/junhyeokahn/dotfiles.git
cd dotfiles/nvim-nix

# Update all flake inputs (plugins, nixpkgs, etc.)
nix flake update

# Commit and push the updated flake.lock
git add flake.lock
git commit -m "Update nvim-nix dependencies"
git push

# Then on any machine, run the upgrade command above
```

**Rolling back changes:**
```bash
# If the update causes issues, rollback to previous version
nix profile rollback
```

### Traditional Neovim Installation (`install-nvim.sh`)

Traditional Neovim installation script that uses lazy.nvim for plugin management.

**Key differences from nvim-nix:**
- **Plugin Management**: Uses lazy.nvim - plugins are downloaded on first launch
- **Dependencies**: Requires manual installation of LSPs and tools (uses Mason for LSP management)
- **Configuration**: Uses standard `~/.config/nvim/` directory
- **Ideal for**: Personal development machines where you want flexibility to modify plugins on the fly

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
