{
  description = "Build op:// reference strings from a secretspec manifest";

  inputs = {
    # Only the checks use it, for lib.runTests and runCommand. The library
    # itself is a plain import with no dependencies.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      lib = import ./secrets.nix;

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          failures = import ./tests/secrets.nix { inherit (pkgs) lib; };
        in
        {
          secrets =
            if failures == [ ] then
              pkgs.runCommand "secrets-tests-passed" { } "touch $out"
            else
              throw "secrets catalogue tests failed:\n${builtins.toJSON failures}";
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      # Entered through .envrc (`use flake`). Run with: task fmt, task lint, task test
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              deadnix # nix, find dead code
              go-task # task runner for taskfile.yml
              nixfmt # nix, official formatter
              statix # nix, lints and anti-patterns
            ];
          };
        }
      );
    };
}
