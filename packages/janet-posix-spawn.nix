{ stdenv, pkgs, janet, jpm }:

stdenv.mkDerivation {
  name = "janet-sh";
  src = pkgs.fetchFromGitHub {
    owner = "andrewchambers";
    repo = "janet-posix-spawn";
    rev = "d73057161a8d10f27b20e69f0c1e2ceb3e145f97";
    sha256 = "kiEPQKiAZ+zPY7cBEhTYrdIVVu9353Mpeq3YbB27u8w=";
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
    mv posix-spawn.janet $out/
  '';
}
