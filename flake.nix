{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: 
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = [ pkgs.ols ];
          nativeBuildInputs = [ pkgs.odin ];
        };
      });

      packages = forEachSupportedSystem ({ pkgs }: rec {
        default = parcelr;
        parcelr = pkgs.callPackage ./derivation.nix {};
      });

      overlays.default = final: prev: {
        parcelr = prev.callPackage ./derivation.nix {};
      };
    };
}
