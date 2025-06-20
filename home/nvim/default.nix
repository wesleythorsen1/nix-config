{ config, pkgs, ... }:

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

    extraPackages = with pkgs; [
      wl-clipboard
    ];

    # extraConfig = ''
    #   ${builtins.readFile ./.nvimrc}
    # '';

    # search all vimPlugins: nix-env -f '<nixpkgs>' -qaP -A vimPlugins
    plugins = with pkgs.vimPlugins; [
      {
        plugin = comment-nvim;
        config = toLua "require(\"Comment\").setup()";
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

      {
        plugin = telescope-fzf-native-nvim;
        config = toLuaFile ./telescope.lua;
      }
    ];

    extraLuaConfig = ''
      -- Make the Lua config directory discoverable by `require()`
      package.path = package.path .. ";" .. "${myConfig}/?.lua"

      require("init")
    '';
  };
}
