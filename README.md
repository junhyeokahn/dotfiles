# Dotfiles

Personal development environment configuration files and installation scripts.

[![Test install scripts](https://github.com/junhyeokahn/dotfiles/actions/workflows/test-install-scripts.yml/badge.svg)](https://github.com/junhyeokahn/dotfiles/actions/workflows/test-install-scripts.yml)

# How to install
## starship, kitty, zk
- `bash install/starship.sh`
- `bash install/kitty.sh`
- `bash install/zk.sh`

## nvim

Neovim is managed as a Nix package (binary + plugins + LSP servers baked in). Requires [Nix](https://github.com/DeterminateSystems/nix-installer) to be installed first: `curl -fsSL https://install.determinate.systems/nix | sh -s -- install`

The `zk` binary is **not** bundled in the flake. The zk-nvim plugin still loads, but `<leader>z*` keymaps and the markdown LSP attach require `zk` on `PATH` — run `bash install/zk.sh` if you want those features.

### nvim workflows
- Install on a new machine (with dotfiles cloned):
```bash
nix profile add ~/dotfiles/install/nvim#nvim
```
- Install on a new machine (no clone needed):
```bash
nix profile add 'github:junhyeokahn/dotfiles?dir=install/nvim#nvim'
```
- Pull latest config + plugin versions on a machine with no clone
```bash
nix profile upgrade nvim
```
> If you pinned via the GitHub URL above, this re-fetches from `main` and rebuilds with the latest `flake.lock`.
- Update nvim or plugin versions (from a cloned machine)
```bash
cd ~/dotfiles/install/nvim
nix flake update # bumps flake.lock to latest nixpkgs (new nvim + plugin versions)
nix profile upgrade nvim # rebuild and installs the updated package
git add flake.lock && git commit -m 'bump flake.lock'
git push # other machines pick it up via nix profile upgrade
```
- Edit Lua config — just edit any file under `~/dotfiles/install/nvim/config/`; changes take effect on the next nvim launch with no rebuild needed.
