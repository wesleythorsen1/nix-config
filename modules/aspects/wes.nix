{ den, inputs, ... }:
{
  den.aspects.wes = {
    # Include batteries for primary user; add feature aspects as needed.
    includes = [
      <den/primary-user>
      <den/git>
      <den/shell>
      <den/tree>
      <den/eza>
      <den/fd>
      <den/fzf>
      <den/gh>
      <den/nvim>
      <den/helix>
      <den/golang>
      <den/nushell>
      <den/openai>
      <den/open-faas>
      <den/python3>
      <den/fabric-ai>
      <den/nodejs>
      <den/charm>
      <den/chromium>
      <den/codex>
      <den/email>
      <den/email-personal>
      <den/email-take2>
      <den/thunderbird>
      <den/vscode>
      <den/wezterm>
      <den/starship>
    ];

    homeManager =
      { config, overlays, ... }:
      {
        nixpkgs = {
          overlays = overlays;
          config = {
            allowUnfree = true;
            allowUnfreePredicate = _: true;
          };
        };

        home.username = "wes";
        home.homeDirectory = "/Users/wes";

        # Git identity (tools live in git aspect).
        programs.git.settings = {
          user.name = "wesleythorsen";
          user.email = "wesley.thorsen@gmail.com";
          credential.helper = "osxkeychain";
        };

        # Import the shared home profile (minus git/shell/tree which are handled as aspects)
        imports = [
          ../../home
          inputs.mac-app-util.homeManagerModules.default
        ];

      };
  };
}
