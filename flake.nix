{
  description = "guac";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["aarch64-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            colima
            docker
            docker-compose
            gcc
            go
            go-outline
            go-tools
            golangci-lint
            gopls
            goreleaser
            gotests
            jq
            nats-server
            protobuf
            protoc-gen-go
            protoc-gen-go-grpc
          ];
        };
        formatter = pkgs.alejandra;
        packages = let
          fs = pkgs.lib.fileset;
          sourceFiles = fs.unions [
            ./go.mod
            ./go.sum
            (fs.fileFilter (file: file.hasExt "go") ./.)
          ];
          src = fs.toSource {
            root = ./.;
            fileset = sourceFiles;
          };
        in {
          guacone = pkgs.buildGoModule {
            pname = "guacone";
            version = "1.0.0";

            inherit src;

            # vendorHash = pkgs.lib.fakeHash;
            vendorHash = "sha256-04W/BAO5ox//b25XTSH/dxiM22QJqBIrNR1SSNnuoCk=";

            # meta = with lib; {
            #   description = "Simple command-line snippet manager, written in Go";
            #   homepage = "https://github.com/knqyf263/pet";
            #   license = licenses.mit;
            #   maintainers = with maintainers; [ kalbasit ];
            # };

            #         main: ./cmd/guacone
            # id: guacone
            # binary: guacone-{{ .Os }}-{{ .Arch }}
            # ldflags:
            #   - -X {{.Env.PKG}}.Commit={{.FullCommit}}
            #   - -X {{.Env.PKG}}.Date={{.Date}}
            #   - -X {{.Env.PKG}}.Version={{.Summary}}
          };
        };
      };
    };
}
