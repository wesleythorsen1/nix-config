{ den, pkgs, ... }:
let
  pythonWithPip = pkgs.python3.withPackages (
    ps: with ps; [
      pip
      setuptools
      wheel
      uv
    ]
  );
in
{
  den.aspects.python3 = {
    homeManager = {
      home = {
        packages = [ pythonWithPip ];
        shellAliases = {
          python = "python3";
          pip = "pip3";
        };
      };
    };
  };
}
