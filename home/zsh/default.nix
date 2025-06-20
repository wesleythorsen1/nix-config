{
  config,
  pkgs,
  ...
}:

let
  denoCompletions =
    pkgs.runCommand "deno-completions"
      {
        buildInputs = [ pkgs.deno ];
      }
      ''
        deno completions zsh > $out
      '';
in
{
  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      custom = "${config.home.homeDirectory}/.oh-my-zsh-custom";
      # theme = "xiong-chiamiov-plus";
      # theme = "random";
      theme = "minimal";
      # theme = "funky";
      # theme = "agnoster"; # like oh-my-posh
      # theme = "amuse";
      # theme = "apple";
      plugins = [ "git-open" ];
    };

    autosuggestion = {
      enable = true;
      # highlight = "fg=#ff00ff,bg=cyan,bold,underline";
    };

    syntaxHighlighting = {
      enable = true;
    };
  };

  home.file = {
    ".oh-my-zsh-custom/git-posh.zsh" = {
      source = pkgs.fetchurl {
        url = "https://gist.githubusercontent.com/wesleythorsen1/6d251331f8b0f6ede7ff32d38d7d4ba8/raw/3eea77779577c64e3a251754cae50e96a3e2841d/git-posh.zsh";
        sha256 = "sha256-77wsJUCO+55iwqqsfjBdX3htnscL9zz5YZClVwjVbxs=";
      };
    };

    ".oh-my-zsh-custom/plugins/git-open" = {
      source = pkgs.fetchFromGitHub {
        owner = "paulirish";
        repo = "git-open";
        rev = "2a66fcd7e3583bc934843bad4af430ac2ffcd859";
        sha256 = "sha256-t5ZmFHjIlmQc5F/4EkC6E9vvFVTF9xN2COgDXYR7V9o=";
      };
    };

    ".oh-my-zsh-custom/plugins/deno/_deno" = {
      source = denoCompletions;
    };
  };
}
