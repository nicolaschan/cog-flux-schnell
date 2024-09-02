{
  description = "A Nix flake for building Replicate's Cog";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.cog = pkgs.stdenv.mkDerivation rec {
          pname = "cog";
          version = "0.9.20"; # Update this to the latest version as needed

          src = pkgs.fetchurl {
            url = "https://github.com/replicate/cog/releases/download/v${version}/cog_Linux_x86_64";
            # To update, replace with the output of:
            # nix hash to-sri --type sha256 $(nix-prefetch-url https://github.com/replicate/cog/releases/download/v0.7.1/cog_0.7.1_linux_x86_64.tar.gz)
            hash = "sha256-p6FiSMkkuff2pvmrWpz9xR4EltJ1DmtKitI+K8OcGLM=";
          };

          dontUnpack = true;

          installPhase = ''
            mkdir -p $out/bin
            cp $src $out/bin/cog
            chmod +x $out/bin/cog
          '';

          meta = with pkgs.lib; {
            description = "Containers for machine learning";
            homepage = "https://github.com/replicate/cog";
            license = licenses.asl20;
            platforms = [ "x86_64-linux" ];
            maintainers = with maintainers; [ ]; # Add maintainers if desired
          };
        };

        defaultPackage = self.packages.${system}.cog;

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            self.packages.${system}.cog
            python3
            docker
          ];

          shellHook = ''
            export PATH="${self.packages.${system}.cog}/bin:$PATH"
            echo "Cog binary is now available in your PATH"
            echo "Cog version: $(cog --version)"
            echo "Cog, Python, and Docker environment is ready!"
          '';
        };
      }
    );
}
