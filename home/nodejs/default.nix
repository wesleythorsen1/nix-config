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
            opencommit = "npx opencommit";
            oco = "opencommit";
        };

        # oco config set OCO_API_KEY=<OPENAI_API_KEY>
        # oco config set OCO_PROMPT_MODULE=@commitlint
        # oco config set OCO_PROMPT_MODULE=conventional-commit
    };
}
