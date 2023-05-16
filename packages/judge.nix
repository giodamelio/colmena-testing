{ stdenv, pkgs, janet, jpm }:

stdenv.mkDerivation {
  name = "judge";
  # src = pkgs.fetchFromGitHub {
  #   owner = "ianthehenry";
  #   repo = "judge";
  #   rev = "v2.4.0";
  #   sha256 = "sha256-ef2ol4k36tRCDyOdvBXu38t2U3baMRBM4b+eWOikW7w=";
  # };
  src = pkgs.fetchFromGitHub {
    owner = "giodamelio";
    repo = "judge";
    rev = "add-lockfile";
    sha256 = "sha256-mJnzTcs5ux2FHGINnmz0YGkZsZFtOL+ICSl2B9+mTLA=";
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

    jpm -l deps
    jpm -l quickbin ./src/judge judge
    jpm help
    echo "After"
    ls -l
  '';

  installPhase = ''
    ls -l
    mkdir -p $out/bin
    cp build/$name $out/bin/
    chmod +x $out/bin/$name
  '';
}
