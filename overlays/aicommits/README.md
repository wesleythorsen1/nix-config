# WORK IN PROGRESS

notes for future me:

* originally I was trying to use `node2nix` by **creating my own npm project** and installing `aicommits` **as a dep** (creating a package.json and package-lock.json)
* this is wrong, `node2nix` needs to be run **on the source project**
* I could clone the `aicommits` repo here and run `node2nix`, but this doesn't make sense
* I realized I need to do something like `src = pkgs.fetchFromGitHub { repo = "aicommits"; ... };` to get the code, then run `node2nix` on it
* but there's no good documentation on how to do this. Also, it does not appear that `node2nix` is intended to be used this way - all examples assume that you have a local copy of the repo, and run `node2nix` as a part of the package's release process.
  * I may be able to re-use the "node-env.nix" module that comes with the `node2nix` package - it looks like this isn't auto-generated (might just be copied as-is). I think it contains a set of utility methods for wrapping a node project as a nix module, and I could pass in whatever source I wanted (with `pkgs.fetchFromGitHub`, versus using local code)
* there's a package `serokell/nix-npm-buildpackage` that *might* solve this issue but I've spent way to much time trying to figure this out
* going to "install" `aicommits` by adding a shell alias `aicommits = "npx aicommits"` in "./home/nodejs/default.nix" for now. I'll come back to this someday.


