{
  config,
  pkgs,
  lib,
  ...
}:

{
  # programs.bash.initContent = ''
  #   export PATH="$HOME/bin:$PATH"
  # '';
  programs.zsh.initContent = ''
    export PATH="$HOME/bin:$PATH"
  '';
  # programs.fish.initContent = ''
  #   export PATH="$HOME/bin:$PATH"
  # '';

  home.file = {
    "bin/nix" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        REAL_NIX="${pkgs.nix}/bin/nix"
        CONF="$HOME/.config/nix/aliases.conf"

        # make sure the config file exists
        mkdir -p "$(dirname "$CONF")"
        touch "$CONF"

        # dispatch on the first word
        cmd="$1"; shift

        # 1) nix alias list|set|unset …
        if [ "$cmd" = "alias" ]; then
          sub="$1"; shift
          case "$sub" in
            list)
              cat "$CONF"
              exit
              ;;
            set)
              key="$1"; shift        # e.g. "alias.co"
              val="$*"               # rest of the args as the alias value
              # remove any old entry for this key
              grep -v -E "^$key=" "$CONF" > "$CONF.tmp" || true
              printf '%s=%s\n' "$key" "$val" >> "$CONF.tmp"
              mv "$CONF.tmp" "$CONF"
              exit
              ;;
            unset)
              key="$1"               # e.g. "alias.co"
              grep -v -E "^$key=" "$CONF" > "$CONF.tmp" || true
              mv "$CONF.tmp" "$CONF"
              exit
              ;;
          esac
        fi

        # 2) lookup in ~/.config/nix/aliases.conf for any "alias.X=Y"
        #    and if cmd == X, run:   nix Y "$@"
        while IFS='=' read -r fullKey fullVal; do
          case "$fullKey" in
            alias.*)
              aliasKey="''${fullKey#alias.}"
              aliasVal="$fullVal"
              if [ "$cmd" = "$aliasKey" ]; then
                exec "$REAL_NIX" $aliasVal "$@"
              fi
              ;;
          esac
        done < "$CONF"

        # 3) fallback to the real nix
        exec "$REAL_NIX" "$cmd" "$@"
      '';
    };
  };

}
