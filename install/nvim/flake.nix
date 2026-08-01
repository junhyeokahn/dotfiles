{
  description = "Neovim with plugins, LSP servers, and formatters";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        plugins = with pkgs.vimPlugins; [
          guess-indent-nvim
          comment-nvim
          copilot-vim
          gitsigns-nvim
          git-blame-nvim
          fzf-lua
          nvim-web-devicons
          flash-nvim
          oil-nvim
          harpoon2
          nvim-lspconfig
          conform-nvim
          nvim-cmp
          luasnip
          cmp_luasnip
          cmp-nvim-lsp
          cmp-path
          nvim-autopairs
          vim-visual-multi
          kanagawa-nvim
          todo-comments-nvim
          plenary-nvim
          mini-nvim
          (nvim-treesitter.withPlugins (p: [
            p.bash p.cpp p.diff p.html p.lua p.luadoc
            p.markdown p.markdown_inline p.python p.vim p.vimdoc p.yaml
          ]))
          neoscroll-nvim
          render-markdown-nvim
          zk-nvim
        ];

        extraBinaries = with pkgs; [
          lua-language-server
          basedpyright
          clang-tools
          bash-language-server
          stylua
          python3Packages.yapf
          fzf
          ripgrep
          fd
          nodejs
          git
        ];

        configDir = ./config;

        neovimConfig = pkgs.neovimUtils.makeNeovimConfig {
          inherit plugins;
          customRC = ''
            lua << EOF
            local live = vim.fn.expand("~/dotfiles/install/nvim/config")
            local baked = "${configDir}"
            local cfg = vim.fn.isdirectory(live) == 1 and live or baked
            vim.opt.rtp:prepend(cfg)
            vim.opt.rtp:append(cfg .. "/after")
            package.path = cfg .. "/lua/?.lua;" .. cfg .. "/lua/?/init.lua;" .. package.path
            dofile(cfg .. "/init.lua")
            EOF
          '';
        };

        nvim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped (neovimConfig // {
          wrapperArgs = neovimConfig.wrapperArgs
            ++ [ "--prefix" "PATH" ":" (pkgs.lib.makeBinPath extraBinaries) ];
        });
      in {
        packages.nvim = nvim;
        packages.default = nvim;
      }
    );
}
