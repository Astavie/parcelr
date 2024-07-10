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
        parcelr = pkgs.stdenv.mkDerivation {
          name = "parcelr";
          src = ./.;
          nativeBuildInputs = [ pkgs.odin ];
          buildPhase = ''
            runHook preBuild
            odin build . -out:parcelr
            runHook postBuild
          '';
          installPhase = ''
            runHook preInstall
            install -Dm755 parcelr -t $out/bin/
            runHook postInstall
          '';
        };
      });

      overlays.default = final: prev: {
        parcelr = prev.stdenv.mkDerivation {
          name = "parcelr";
          src = ./.;
          nativeBuildInputs = [ prev.odin ];
          buildPhase = ''
            runHook preBuild
            odin build . -out:parcelr
            runHook postBuild
          '';
          installPhase = ''
            runHook preInstall
            install -Dm755 parcelr -t $out/bin/
            runHook postInstall
          '';
        };
      };
    };
}
