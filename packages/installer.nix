{ stdenv }:

stdenv.mkDerivation {
  name = "installer";
  src = ./.;
  installPhase = ''
    echo "Hello World" > $out
  '';
}
