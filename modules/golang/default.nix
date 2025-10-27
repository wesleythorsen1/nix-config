{
  lib,
  config,
  pkgs,
}:

let
  cfg = config.modules.golang;

  packages = with pkgs; [
    cfg.package # pkgs.go
    clang
    libtool
    makeWrapper
  ];
in
{
  options.modules.golang = {
    enable = lib.mkEnableOption "Enable golang";
    package = lib.mkPackageOption pkgs "go" {
      default = pkgs.go;
      example = "pkgs.go";
    };
  };

  config.environment.systemPackages = lib.mkIf cfg.enable packages;
}
