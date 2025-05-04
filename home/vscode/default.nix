{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;

    enableExtensionUpdateCheck = true;
    enableUpdateCheck = true;

    extensions = with pkgs.vscode-marketplace; [
      # 42crunch.vscode-openapi # check "vscode-utils.extensionsFromVscodeMarketplace" https://www.reddit.com/r/NixOS/comments/115s2gi/how_do_i_reference_a_package_name_that_begins/
      alefragnani.bookmarks
      amih90.to
      # aws-scripting-guy.cform
      bbenoist.nix
      continue.continue
      dbaeumer.vscode-eslint
      denoland.vscode-deno
      # dotjoshjohnson.xml
      # eamodio.gitlens
      esbenp.prettier-vscode
      heaths.vscode-guid
      johnpapa.winteriscoming
      jsynowiec.vscode-insertdatestring
      # mhutchie.git-graph
      mohsen1.prettify-json
      # mongodb.mongodb-vscode
      # ms-azuretools.vscode-docker
      # ms-dotnettools.csdevkit
      # ms-dotnettools.csharp
      # ms-dotnettools.vscode-dotnet-runtime
      # ms-kubernetes-tools.vscode-kubernetes-tools
      # ms-python.debugpy
      # ms-python.isort
      # ms-python.python
      # ms-python.vscode-pylance
      # ms-vscode-remote.remote-containers
      naumovs.color-highlight
      orta.vscode-jest
      # redhat.java
      # redhat.vscode-xml
      redhat.vscode-yaml
      rvest.vs-code-prettier-eslint
      shd101wyy.markdown-preview-enhanced
      streetsidesoftware.code-spell-checker
      # threadheap.serverless-ide-vscode
      tim-koehler.helm-intellisense
      visualstudioexptteam.intellicode-api-usage-examples
      visualstudioexptteam.vscodeintellicode
      # vscjava.vscode-gradle
      # vscjava.vscode-java-debug
      # vscjava.vscode-java-dependency
      # vscjava.vscode-java-pack
      # vscjava.vscode-java-test
      # vscjava.vscode-maven
    ];
  };
}
