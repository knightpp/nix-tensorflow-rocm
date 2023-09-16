{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["x86_64-linux"];
    forAllSystems = f:
      nixpkgs.lib.genAttrs systems (
        system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              overlays = [(import ./overlay.nix)];
            };
          }
      );
  in {
    devShells = forAllSystems ({pkgs}: {
      default = import ./shell.nix {inherit pkgs;};
    });
  };
}
