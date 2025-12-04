{ den, pkgs, ... }:
let
  toLua = str: "lua << EOF\n${str}\nEOF\n";
  toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";

  nvimConfig = pkgs.stdenv.mkDerivation {
    name = "nvim-config";
    src = ../../home/nvim/config;
    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };
in
{
  den.aspects.nvim = {
    homeManager = {
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        withNodeJs = false;
        plugins = with pkgs.vimPlugins; [
          vim-visual-multi
          {
            plugin = comment-nvim;
            config = toLua ''require("Comment").setup()'';
          }
          {
            plugin = nvim-lspconfig;
            config = toLuaFile ../../home/nvim/plugins/lsp.lua;
          }
          cmp-nvim-lsp-signature-help
          {
            plugin = onedark-nvim;
            config = toLuaFile ../../home/nvim/plugins/onedark.lua;
          }
          {
            plugin = telescope-nvim;
            config = toLuaFile ../../home/nvim/plugins/telescope.lua;
          }
          telescope-fzf-native-nvim
          {
            plugin = vim-fugitive;
            config = toLuaFile ../../home/nvim/plugins/fugitive.lua;
          }
          {
            plugin = undotree;
            config = toLuaFile ../../home/nvim/plugins/undotree.lua;
          }
          {
            plugin = lualine-nvim;
            config = toLuaFile ../../home/nvim/plugins/lualine.lua;
          }
          {
            plugin = gitsigns-nvim;
            config = toLuaFile ../../home/nvim/plugins/gitsigns.lua;
          }
          {
            plugin = nvim-treesitter.withAllGrammars;
            config = toLuaFile ../../home/nvim/plugins/treesitter.lua;
          }
          nvim-web-devicons
          {
            plugin = conform-nvim;
            config = toLuaFile ../../home/nvim/plugins/conform.lua;
          }
          nvim-cmp
          cmp-nvim-lsp
          cmp-buffer
          cmp-path
          luasnip
          cmp_luasnip
          {
            plugin = nvim-cmp;
            config = toLuaFile ../../home/nvim/plugins/completion.lua;
          }
          {
            plugin = snacks-nvim;
            config = toLuaFile ../../home/nvim/plugins/snacks.lua;
          }
          {
            plugin = render-markdown-nvim;
            config = toLuaFile ../../home/nvim/plugins/render-markdown.lua;
          }
        ];

        extraLuaConfig = ''
          vim.g.mapleader = " "
          package.path = package.path .. ";" .. "${nvimConfig}/?.lua"
          require("init")
        '';

        extraPackages = with pkgs; [
          lua-language-server
          nodejs_20
          nodePackages.typescript
          nodePackages.typescript-language-server
          nixd
          nodePackages.prettier
          nodePackages.eslint
          stylua
          nixfmt-rfc-style
        ];
      };
    };
  };
}
