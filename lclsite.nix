with (import <nixpkgs> {}); let
  env = bundlerEnv {
    name = "jstrattonsmith.github.io";
    inherit ruby;
    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset = ./gemset.nix;
  };
in
  stdenv.mkDerivation {
    name = "jstrattonsmith.github.io";
    buildInputs = [env ruby bundler bundix];

    shellHook = ''
      echo "jstrattonsmith.github.io dev shell"
      echo "  ./tools/run.sh                          # serve at localhost:4000 with live reload"
      echo "  ./tools/test.sh                          # production build + htmlproofer"
      echo "  bundle lock && bundix                    # after editing Gemfile, then re-enter nix-shell"
    '';
  }