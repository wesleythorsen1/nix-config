{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    aliases = {
      co = "checkout";
      logl = "log --all --decorate --oneline --graph";
      pushf = "push --force-with-lease";
    };

    extraConfig = {
      push = {
        autoSetupRemote = true;
      };
      core = {
        editor = "vim";
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
    };
  };
}
