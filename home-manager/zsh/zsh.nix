{ config, pkgs, ... }:

{
  programs.zsh = {
      enable = true;
      initExtra = ''
        # Nix
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
          . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
        # End Nix
      '';
      oh-my-zsh = {
        enable = false;
        custom = "$HOME/.oh-my-zsh-custom";
        # theme = "random";
        # theme = "minimal";
        theme = "xiong-chiamiov-plus";
        # theme = "funky";
        # theme = "agnoster"; # like oh-my-posh
        # theme = "amuse";
        # theme = "apple";
        plugins = [ "git-open" ];
      };
    };
}
