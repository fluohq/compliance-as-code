{
  description = "Compliance as Code - Evidence-based compliance through code generation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    generators.url = "path:./frameworks/generators";
  };

  outputs = { self, nixpkgs, flake-utils, generators }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        # Expose all generated compliance code
        packages = {
          # Java generators
          java-gdpr = generators.packages.${system}.java-gdpr;
          java-soc2 = generators.packages.${system}.java-soc2;
          java-hipaa = generators.packages.${system}.java-hipaa;
          java-fedramp = generators.packages.${system}.java-fedramp;
          java-iso27001 = generators.packages.${system}.java-iso27001;
          java-pcidss = generators.packages.${system}.java-pcidss;
          all-java = generators.packages.${system}.all-java;

          # TypeScript generators
          ts-gdpr = generators.packages.${system}.ts-gdpr;
          ts-soc2 = generators.packages.${system}.ts-soc2;
          ts-hipaa = generators.packages.${system}.ts-hipaa;
          ts-fedramp = generators.packages.${system}.ts-fedramp;
          ts-iso27001 = generators.packages.${system}.ts-iso27001;
          ts-pcidss = generators.packages.${system}.ts-pcidss;
          all-typescript = generators.packages.${system}.all-typescript;

          # Python generators
          py-gdpr = generators.packages.${system}.py-gdpr;
          py-soc2 = generators.packages.${system}.py-soc2;
          py-hipaa = generators.packages.${system}.py-hipaa;
          py-fedramp = generators.packages.${system}.py-fedramp;
          py-iso27001 = generators.packages.${system}.py-iso27001;
          py-pcidss = generators.packages.${system}.py-pcidss;
          all-python = generators.packages.${system}.all-python;

          # Go generators
          go-gdpr = generators.packages.${system}.go-gdpr;
          go-soc2 = generators.packages.${system}.go-soc2;
          go-hipaa = generators.packages.${system}.go-hipaa;
          go-fedramp = generators.packages.${system}.go-fedramp;
          go-iso27001 = generators.packages.${system}.go-iso27001;
          go-pcidss = generators.packages.${system}.go-pcidss;
          all-go = generators.packages.${system}.all-go;

          # All generators
          all = pkgs.symlinkJoin {
            name = "compliance-as-code-all";
            paths = [
              generators.packages.${system}.all-java
              generators.packages.${system}.all-typescript
              generators.packages.${system}.all-python
              generators.packages.${system}.all-go
            ];
          };

          default = self.packages.${system}.all;
        };

        # Development shells
        devShells = {
          # Default development shell
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nixpkgs-fmt
              nix-tree
              jq
            ];

            shellHook = ''
              echo "Compliance as Code - Development Environment"
              echo ""
              echo "Available commands:"
              echo "  nix build .#java-gdpr       - Generate Java GDPR code"
              echo "  nix build .#all             - Generate all code"
              echo "  nix flake check             - Run all checks"
              echo "  nix run .#list-frameworks   - List all frameworks"
              echo ""
              echo "Frameworks: GDPR, SOC 2, HIPAA, FedRAMP, ISO 27001, PCI-DSS"
              echo "Languages: Java, TypeScript, Python, Go"
            '';
          };

          # Java development
          java = pkgs.mkShell {
            buildInputs = with pkgs; [
              jdk21
              maven
            ];
          };

          # Go development
          go = pkgs.mkShell {
            buildInputs = with pkgs; [
              go
              gopls
              gotools
            ];
          };

          # Python development
          python = pkgs.mkShell {
            buildInputs = with pkgs; [
              python312
              python312Packages.pip
              python312Packages.virtualenv
            ];
          };

          # TypeScript development
          typescript = pkgs.mkShell {
            buildInputs = with pkgs; [
              nodejs_20
              nodePackages.typescript
              nodePackages.typescript-language-server
            ];
          };
        };

        # Apps
        apps = {
          # List all frameworks and their controls
          list-frameworks = {
            type = "app";
            program = "${generators.apps.${system}.default.program}";
            meta = {
              description = "List all compliance frameworks and their controls";
            };
          };

          # Generate all code
          generate-all = {
            type = "app";
            program = "${pkgs.writeShellScript "generate-all" ''
              echo "Generating all compliance code..."
              ${pkgs.nix}/bin/nix build .#all
              echo "✓ Generated: Java, TypeScript, Python, Go"
              echo "✓ Location: ./result/"
              ls -lh result/
            ''}";
            meta = {
              description = "Generate all compliance code for all languages";
            };
          };

          default = self.apps.${system}.list-frameworks;
        };

        # Checks for CI
        checks = {
          # Build all generators
          all-generators = self.packages.${system}.all;

          # Check Nix formatting
          nix-fmt = pkgs.runCommand "check-nix-fmt" { } ''
            ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check ${./.}
            touch $out
          '';
        };
      }
    );
}
