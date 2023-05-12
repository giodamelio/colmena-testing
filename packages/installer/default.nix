{ stdenv, janet, jpm }:

stdenv.mkDerivation {
  name = "installer";
  src = ./.;

  buildInputs = [ janet jpm ];

  buildPhase = ''
    export JANET_LIBPATH="${janet}/lib"
    export JANET_HEADERPATH="${janet}/include/janet"
    jpm build
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp build/$name $out/bin/
    chmod +x $out/bin/$name
  '';
}
