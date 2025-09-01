{
  pkgs,
  ...
}:

let
  toLua = str: "lua << EOF\n${str}\nEOF\n";
  toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";

  myConfig = pkgs.stdenv.mkDerivation {
    name = "my-nvim-config";
    src = ./my-config;
    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };
in
{
  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    withNodeJs = false; # temp disable, nodejs 20.19 issue

    # search all vimPlugins: nix-env -f '<nixpkgs>' -qaP -A vimPlugins
    plugins = with pkgs.vimPlugins; [
      {
        plugin = comment-nvim;
        config = toLua ''require("Comment").setup()'';
      }

      {
        plugin = nvim-lspconfig;
        config = toLuaFile ./lsp.lua;
      }

      {
        plugin = gruvbox-nvim;
        config = "colorscheme gruvbox";
      }

      {
        plugin = telescope-nvim;
        config = toLuaFile ./telescope.lua;
      }

      # telescope-fzf-native provides the sorter; it is loaded *from telescope.lua*
      # so no separate config block is needed here. Just ensure it’s built.
      telescope-fzf-native-nvim

      # completion engine + sources
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip

      {
        plugin = nvim-cmp;
        config = toLuaFile ./cmp.lua;
      }
    ];

    extraLuaConfig = ''
      vim.g.mapleader = " "

      -- Make the Lua config directory discoverable by `require()`
      package.path = package.path .. ";" .. "${myConfig}/?.lua"

      require("init")
    '';

    extraPackages = with pkgs; [
      # Lua LSP
      lua-language-server

      # TypeScript/JS LSP
      nodejs_20
      nodePackages.typescript
      nodePackages.typescript-language-server

      # Nix LSP
      nixd
    ];

  };
}
