# Copyright (c) 2023 BirdeeHub
# Licensed under the MIT license

{
  description = "Neovim configuration with nixCats";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
  };

  outputs = { self, nixpkgs, nixCats, ... }@inputs: let
    inherit (nixCats) utils;
    luaPath = ./.;
    forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;

    # Extra overlays to apply to nixpkgs
    # Empty list since we don't need to override anything
    dependencyOverlays = [];

    # Extra nixpkgs config like allowUnfree
    extra_pkg_config = {
      allowUnfree = true;
    };

    # Define categories of dependencies
    # Each category is a function that takes the package definition and returns a set
    categoryDefinitions = { pkgs, settings, categories, name, ... }@packageDef: {
      # LSPs and runtime dependencies
      lspsAndRuntimeDeps = {
        general = with pkgs; [
          # Language servers
          lua-language-server
          basedpyright
          ruff
          clang-tools
          bash-language-server

          # Formatters and linters
          stylua
          ruff

          # Runtime dependencies
          fzf
          ripgrep
        ];
      };

      # Startup plugins - loaded at startup
      startupPlugins = {
        general = with pkgs.vimPlugins; [
          # Core plugins
          guess-indent-nvim
          comment-nvim
          gitsigns-nvim
          vim-visual-multi
          fzf-lua

          # LSP and completion
          nvim-lspconfig
          conform-nvim
          nvim-cmp
          cmp-nvim-lsp
          cmp-path
          cmp_luasnip
          luasnip

          # UI and themes
          kanagawa-nvim
          todo-comments-nvim
          mini-nvim
          render-markdown-nvim

          # Treesitter
          nvim-treesitter.withAllGrammars
          nvim-treesitter-context

          # Editor enhancements
          nvim-autopairs
          neoscroll-nvim
          flash-nvim
          oil-nvim
          harpoon2

          # Git
          git-blame-nvim

          # Dependencies
          plenary-nvim
          nvim-web-devicons

          # AI assistance
          copilot-vim
        ];
      };
    };

    # Package definitions - different neovim configurations
    packageDefinitions = {
      nvim = { pkgs, ... }: {
        settings = {
          # These settings are the defaults provided by nixCats
          wrapRc = true;
          configDirName = "nixCats-nvim"; # Name of the config directory in ~/.config
          aliases = [ "vi" "vim" ]; # Shell aliases for this neovim
        };

        categories = {
          general = true; # Enable the 'general' category defined above
          # Add more categories as needed
        };
      };
    };

    defaultPackageName = "nvim";
  in

  # Define outputs for each system
  forEachSystem (system: let
    nixCatsBuilder = utils.baseBuilder luaPath {
      inherit nixpkgs system dependencyOverlays;
      inherit extra_pkg_config;
    } categoryDefinitions packageDefinitions;

    defaultPackage = nixCatsBuilder defaultPackageName;
  in {
    # Packages available via `nix build` or `nix run`
    packages = utils.mkPackages nixCatsBuilder packageDefinitions defaultPackageName;

    # Development shells available via `nix develop`
    devShells = {
      default = nixCatsBuilder.devShell {
        default_pkg = defaultPackageName;
      };
    };
  }) // {
    # System-independent outputs

    # Overlay for using this neovim configuration in other flakes
    overlays.default = utils.mergeOverlayLists dependencyOverlays [
      (utils.standardOverlay luaPath categoryDefinitions packageDefinitions defaultPackageName)
    ];

    # NixOS module for system-wide installation
    nixosModules.default = utils.mkNixosModules {
      inherit dependencyOverlays luaPath packageDefinitions categoryDefinitions defaultPackageName;
    };

    # Home Manager module for user installation
    homeModules.default = utils.mkHomeModules {
      inherit dependencyOverlays luaPath packageDefinitions categoryDefinitions defaultPackageName;
    };

    # Inherit utils for convenience
    inherit utils;

    # Inherit the inputs for use in other flakes
    inherit inputs;
  };
}
