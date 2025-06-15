{
    config,
    pkgs,
    ...
}:

{
    home = {
        packages = with pkgs; [
            nodejs_20
        ];

        shellAliases = {
            serverless = "npx serverless@3";
            sls = "serverless";
            # aicommits = "npx aicommits";
            # aic = "aicommits";
        };
    };
}
