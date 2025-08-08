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
    buildInputs = [env ruby];

    shellHook = ''
      exec ${env}/bin/jekyll serve --watch
    '';
  }