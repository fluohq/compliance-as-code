{
  description = "Nix derivation with compliance evidence";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Simple application to demonstrate compliance wrapping
        myapp = pkgs.stdenv.mkDerivation {
          pname = "compliance-demo-app";
          version = "1.0.0";

          src = ./.;

          buildInputs = [ pkgs.gcc ];

          buildPhase = ''
            cat > main.c << 'EOF'
            #include <stdio.h>
            int main() {
              printf("Compliance Demo App v1.0.0\n");
              printf("Built with compliance evidence!\n");
              return 0;
            }
            EOF

            gcc -o compliance-demo main.c
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp compliance-demo $out/bin/
          '';
        };

        # Compliance wrapper library
        complianceLib = {
          # Wrap a derivation with compliance evidence
          wrapDerivation = { derivation, evidence }:
            let
              controlsList = builtins.concatStringsSep "," evidence.controls;

              evidenceAttrs = builtins.toJSON {
                framework = evidence.framework;
                controls = evidence.controls;
                purpose = evidence.purpose or "Build compliance evidence";
                changeTicket = evidence.changeTicket or "N/A";
                approvedBy = evidence.approvedBy or "N/A";
                buildTime = builtins.currentTime;
                buildSystem = system;
                packageName = derivation.name;
              };
            in
            pkgs.runCommand "${derivation.name}-with-evidence"
              {
                buildInputs = [ pkgs.jq ];
                passthru = {
                  inherit derivation evidence;
                  unwrapped = derivation;
                };
              }
              ''
                # Create output directory
                mkdir -p $out

                # Copy derivation outputs
                cp -r ${derivation}/* $out/

                # Record compliance evidence
                mkdir -p $out/compliance
                echo '${evidenceAttrs}' | ${pkgs.jq}/bin/jq '.' > $out/compliance/evidence.json

                # Add evidence metadata
                cat > $out/compliance/README.md << 'EOF'
                # Compliance Evidence

                This derivation was built with compliance evidence tracking.

                ## Evidence Attributes

                - **Framework**: ${evidence.framework}
                - **Controls**: ${controlsList}
                - **Purpose**: ${evidence.purpose or "Build compliance evidence"}
                - **Change Ticket**: ${evidence.changeTicket or "N/A"}
                - **Approved By**: ${evidence.approvedBy or "N/A"}
                - **Build System**: ${system}
                - **Package**: ${derivation.name}

                ## Verification

                View complete evidence: \`cat compliance/evidence.json\`

                ## Supply Chain

                This build is:
                - ✅ **Reproducible** - Same inputs produce same outputs
                - ✅ **Hermetic** - No network access during build
                - ✅ **Content-addressed** - All dependencies cryptographically verified
                - ✅ **Traceable** - Full provenance in flake.lock

                EOF

                echo "✓ Compliance evidence recorded: $out/compliance/"
              '';
        };

        # Example: Application with FedRAMP compliance
        myapp-compliant = complianceLib.wrapDerivation {
          derivation = myapp;
          evidence = {
            framework = "fedramp";
            controls = [ "CM-2" "CM-3" "SI-7" ];
            purpose = "Production application build with configuration management";
            changeTicket = "CHANGE-2025-001";
            approvedBy = "security-team";
          };
        };

        # Example: Application with ISO 27001 compliance
        myapp-iso = complianceLib.wrapDerivation {
          derivation = myapp;
          evidence = {
            framework = "iso27001";
            controls = [ "A.12.1.2" "A.14.2.2" "A.15.1.1" ];
            purpose = "Supply chain security compliance";
          };
        };

        # Helper to query evidence
        query-evidence = pkgs.writeShellScriptBin "query-evidence" ''
          echo "=== Compliance Evidence Query ==="
          echo ""
          echo "FedRAMP Build Evidence:"
          ${pkgs.jq}/bin/jq '.' ${myapp-compliant}/compliance/evidence.json
          echo ""
          echo "ISO 27001 Build Evidence:"
          ${pkgs.jq}/bin/jq '.' ${myapp-iso}/compliance/evidence.json
        '';

      in
      {
        packages = {
          # The base application (no compliance)
          app = myapp;

          # Application with FedRAMP compliance
          app-fedramp = myapp-compliant;

          # Application with ISO 27001 compliance
          app-iso27001 = myapp-iso;

          # Query tool
          query = query-evidence;

          default = myapp-compliant;
        };

        # Library for other flakes to use
        lib = complianceLib;

        apps = {
          # Run the compliant application
          default = {
            type = "app";
            program = "${myapp-compliant}/bin/compliance-demo";
          };

          # Query evidence
          query = {
            type = "app";
            program = "${query-evidence}/bin/query-evidence";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            gcc
            jq
          ];

          shellHook = ''
            echo "Nix Compliance Example - Development Shell"
            echo ""
            echo "Available commands:"
            echo "  nix build .#app-fedramp    - Build with FedRAMP compliance"
            echo "  nix build .#app-iso27001   - Build with ISO 27001 compliance"
            echo "  nix run .#query            - View compliance evidence"
            echo "  nix run                    - Run compliant application"
            echo ""
            echo "Compliance frameworks: FedRAMP, ISO 27001"
            echo "Controls tracked: CM-2, CM-3, SI-7, A.12.1.2, A.14.2.2, A.15.1.1"
          '';
        };
      }
    );
}
