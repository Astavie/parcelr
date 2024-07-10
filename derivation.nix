{ odin, stdenv }: stdenv.mkDerivation {
  name = "parcelr";
  src = ./.;
  nativeBuildInputs = [ odin ];
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
}
