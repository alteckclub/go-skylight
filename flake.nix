{
  description = "Go CLI and client library for the Skylight Calendar API";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = false;
        };

        # Version derived from git describe --tags --always
        version = if self ? shortRev then self.shortRev else "dev";
      in
      {
        packages.default = pkgs.buildGoModule {
          pname = "skylight";
          inherit version;

          src = pkgs.lib.cleanSourceWith {
            src = ./.;
            name = "go-skylight-source";
          };

          vendorHash = "sha256-Zl7W30TVimmzRWoq8uA3g/CZOUWKcmwYmgv+X5/AH4o=";

          ldflags = [
            "-s"
            "-w"
            "-X main.Version=${version}"
          ];

          # Rename go-skylight -> skylight and copy SKILL.md alongside
          postInstall = ''
            mv "$out/bin/go-skylight" "$out/bin/skylight"
            rm -f "$out/bin/alpaca-trigger"
            install -m 0755 -d "$out/share/doc/skylight"
            cp '${./.claude/skills/skylight.md}' "$out/share/doc/skylight/SKILL.md"
          '';

          meta = {
            description = "Go CLI and client library for the Skylight Calendar API";
            homepage = "https://github.com/sebrandon1/go-skylight";
            license = pkgs.lib.licenses.mit;
            maintainers = [];
            mainProgram = "skylight";
          };
        };

        devShells.default = pkgs.mkShell {
          name = "go-skylight-dev";
          packages = with pkgs; [
            go
            gopls
            golangci-lint
            go-tools
          ];
        };
      });
}
