{ stdenv, pkgs, janet, jpm }:

stdenv.mkDerivation {
  name = "janet-sh";
  src = pkgs.fetchFromGitHub {
    owner = "andrewchambers";
    repo = "janet-sh";
    rev = "221bcc869bf998186d3c56a388c8313060bfd730";
    sha256 = "pqpEs/qfHe/e2ywSuqzWZhfw/YHZNkTsKHZHoaoVTc4=";
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

    mkdir -p $out/
    mv $JANET_BUILDPATH/* $out/
    mv sh.janet $out/
  '';
}
