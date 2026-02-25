{
  description = "Quorumeum - Bitcoin Core fork";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        quorumeum = pkgs.stdenv.mkDerivation {
          pname = "quorumeum";
          version = "30.2.0";

          src = ./.;

          nativeBuildInputs = with pkgs; [
            cmake
            pkg-config
            python3
          ];

          buildInputs = with pkgs; [
            boost
            libevent
            sqlite
            zeromq
          ];

          cmakeFlags = [
            "-DWITH_ZMQ=ON"
            "-DBUILD_GUI=OFF"
            "-DENABLE_IPC=OFF"
          ];
        };

        configFile = pkgs.writeText "quorumeum-signet.conf" ''
          signet=1

          [signet]
          signetchallenge=51208d8dfd7fdc663efe1d54f05182fddddd7cf47ba3ed6e6932eccd41b7722da91b
          connect=167.71.167.51
        '';
      in
      {
        packages = {
          default = quorumeum;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [ quorumeum ];

          shellHook = ''
            alias quorumeumd='bitcoind -conf=${configFile}'
            alias quorumeum-cli='bitcoin-cli -conf=${configFile}'
            echo "Quorumeum signet shell ready."
            echo "  quorumeumd    - start the node (signet)"
            echo "  quorumeum-cli - interact with the node"
          '';
        };
      }
    );
}
