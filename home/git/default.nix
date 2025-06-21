{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    delta = {
      enable = true;
      options = {
        side-by-side = true;
        line-numbers = true;
      };
    };

    aliases = {
      co = "checkout";
      logl = "log --all --decorate --oneline --graph";
      pushf = "push --force-with-lease";
      acane = "!git add -A && git commit --amend --no-edit";
    };

    extraConfig = {
      push = {
        autoSetupRemote = true;
      };
      core = {
        editor = "nvim";
        repositoryformatversion = 0;
        filemode = true;
        bare = false;
        logallrefupdates = true;
        ignorecase = false;
        precomposeunicode = true;
      };
      credential = {
        "https://github.com/".useHttpPath = true;
      };
      merge = {
        conflictstyle = "zdiff3";
      };
    };

    ignores = [
      ".DS_Store"
    ];
  };
}
