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
      logl = "log --oneline --graph --all"; # [l]og [o]ne-line [g]raph a[l]l
      pfwl = "push --force-with-lease"; # [p]ush [f]orce [w]ith [l]ease
      aacane = "!git add -A && git commit --amend --no-edit"; # [a]dd [a]ll [c]ommit [a]mend [n]o-[e]dit
      bcu = "!f() { git branch -D \"$1\" && git branch -D --remote \"origin/$1\" && git push origin --delete \"$1\"; }; f"; # [b]ranch [c]lean [u]p
    };

    extraConfig = {
      user.signingkey = "FAE484F021AE49E5"; # FIXME: Use variable for Git GPG signing key
      commit.gpgsign = true;
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
