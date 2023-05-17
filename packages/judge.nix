{ stdenv, pkgs, janet, jpm, lndir, tree, janet-lib }:

stdenv.mkDerivation rec {
  name = "judge";
  src = pkgs.fetchFromGitHub {
    owner = "ianthehenry";
    repo = "judge";
    rev = "v2.4.0";
    sha256 = "ef2ol4k36tRCDyOdvBXu38t2U3baMRBM4b+eWOikW7w=";
  };

  buildInputs = [ janet jpm tree ];

  modules = pkgs.runCommand "modules" { src = src; } ''
    mkdir -p $out/lib/judge
    # Link passes in modules
    ${lndir}/bin/lndir ${janet-lib}/lib $out/lib/
    # Link Judge modules
    ${lndir}/bin/lndir $src/src/ $out/lib/judge/
  '';

  buildPhase = ''
    export JANET_MODPATH="${modules}/lib"
    export JANET_HEADERPATH="${janet}/include/janet"
    export JANET_LIBPATH="${janet}/lib"
    jpm quickbin ./src/judge judge
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp $name $out/bin/
    chmod +x $out/bin/$name
  '';
}
