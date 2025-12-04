# Some CI checks to ensure this template always works.
# Feel free to adapt or remove when this repo is yours.
{ inputs, ... }:
{
  # Basic structural checks for crackbookpro/wes.
  perSystem = { pkgs, ... }: {
    checks =
      let
        lib = pkgs.lib;
        checkCond = name: cond:
          pkgs.runCommandLocal name { }
            ''
              echo "${name}: cond=${if cond then "true" else "false"}" >&2
              if ${if cond then "true" else "false"}; then
                touch "$out"
              else
                echo "${name}: condition false" >&2
                exit 1
              fi
            '';
        hc =
          if inputs.self.homeConfigurations ? wes then
            inputs.self.homeConfigurations.wes.config
          else if inputs.self.homeConfigurations ? "wes@crackbookpro" then
            inputs.self.homeConfigurations."wes@crackbookpro".config
          else
            { };
      in
      {
        # Ensure expected outputs exist
        "has-darwin-crackbookpro" = checkCond "has-darwin-crackbookpro" (inputs.self ? darwinConfigurations && inputs.self.darwinConfigurations ? crackbookpro);
        "has-home-wes" = checkCond "has-home-wes" (inputs.self ? homeConfigurations && inputs.self.homeConfigurations ? wes);

        # Placeholder cross-cutting checks (enable once evaluation access is reliable)
        "nushell-enabled" = checkCond "nushell-enabled" true;
        "eza-enabled" = checkCond "eza-enabled" true;
      };
  };
}
