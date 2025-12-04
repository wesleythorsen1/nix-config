{ den, lib, ... }:
{
  den.aspects.eza = {
    homeManager =
      { config, pkgs, ... }:
      let
        ezaDynamic = builtins.readFile ../../home/eza/eza_dynamic.sh;
      in
      {
        programs.eza = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          extraOptions = [
            "-a"
            "-I '.git'"
            "--group-directories-first"
          ];
        };

        home.shellAliases = {
          l = "eza -la";
          lt = "eza_dynamic";
        };

        programs.zsh = {
          enable = true;
          initContent = ezaDynamic;
        };
      };

    # Cross-cutting: when both eza and nushell are active, add aliases suitable for nushell.
    den.aspects.eza._.nushell.homeManager =
      { config, ... }:
      lib.mkIf (config.programs.eza.enable or false) {
        programs.eza.enableNushellIntegration = true;
        programs.nushell.shellAliases = {
          l = "eza -la";
          lt = "eza_dynamic";
        };
      };
  };
}
