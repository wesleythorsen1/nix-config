{ den, ... }:
{
  den.aspects.git = {
    homeManager = {
      programs = {
        delta = {
          enable = true;
          enableGitIntegration = true;
          options = {
            side-by-side = true;
            line-numbers = true;
          };
        };

        git = {
          enable = true;
          ignores = [ ".DS_Store" ];
          settings = {
            alias = {
              co = "checkout";
              loga = "log --oneline --graph --all";
              logl = "log --oneline --graph --all";
              logp = "log --oneline --graph --all --abbrev-commit --date=relative --pretty=format:'%C(auto)%h%Creset -%C(auto)%d%Creset %s %C(bold blue)<%an>%Creset %C(bold white)(%cr)'";
              pf = "push --force-with-lease";
              aacane = "!git add -A && git commit --amend --no-edit";
              bcu = "!f() { git branch -D \"$1\" && git branch -D --remote \"origin/$1\" && git push origin --delete \"$1\"; }; f";
            };
            user.signingkey = "FAE484F021AE49E5"; # FIXME: variable for GPG key
            commit.gpgsign = true;
            push.autoSetupRemote = true;
            core = {
              editor = "hx";
              repositoryformatversion = 0;
              filemode = true;
              bare = false;
              logallrefupdates = true;
              ignorecase = false;
              precomposeunicode = true;
            };
            credential."https://github.com/".useHttpPath = true;
            merge.conflictstyle = "zdiff3";
          };
        };
      };
    };

    # Cross-cutting: darwin host uses osxkeychain helper.
    den.aspects.git._.crackbookpro.homeManager = {
      programs.git.settings.credential.helper = "osxkeychain";
    };
  };
}
