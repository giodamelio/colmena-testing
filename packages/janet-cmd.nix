{ stdenv, pkgs, janet, jpm }:

stdenv.mkDerivation {
  name = "janet-cmd";
  src = pkgs.fetchFromGitHub {
    owner = "ianthehenry";
    repo = "cmd";
    rev = "v1.0.4";
    sha256 = "vJLayInIUi4oM8ZqPiNKFCulDiILn4StpoHZcG3/QQ8=";
  };

  buildInputs = [ janet jpm ];


  buildPhase = ''
    export JANET_PATH="$PWD/.jpm"
    export JANET_TREE="$JANET_PATH/jpm_tree"
    export JANET_LIBPATH="${pkgs.janet}/lib"
    export JANET_HEADERPATH="${pkgs.janet}/include/janet"
    export JANET_BUILDPATH="$JANET_PATH/build"
    export PATH="$PATH:$JANET_TREE/bin"

    mkdir -p "$JANET_TREE"
    mkdir -p "$JANET_BUILDPATH"
    mkdir -p "$PWD/.pkgs"

    jpm build
  '';

  installPhase = ''
    export JANET_PATH="$PWD/.jpm"
    export JANET_TREE="$JANET_PATH/jpm_tree"
    export JANET_LIBPATH="${pkgs.janet}/lib"
    export JANET_HEADERPATH="${pkgs.janet}/include/janet"
    export JANET_BUILDPATH="$JANET_PATH/build"
    export PATH="$PATH:$JANET_TREE/bin"

    mkdir -p $out/lib/cmd/
    mv src/*.janet $out/lib/cmd/
  '';
}
