{
  description = "NestJS with compliance evidence";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    compliance.url = "path:../../../frameworks/generators";
  };

  outputs = { self, nixpkgs, flake-utils, compliance }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Get generated TypeScript GDPR and SOC2 code
        gdprCode = compliance.packages.${system}.ts-gdpr;
        soc2Code = compliance.packages.${system}.ts-soc2;

        # Build the NestJS app
        app = pkgs.buildNpmPackage {
          pname = "nestjs-compliance-example";
          version = "1.0.0";

          src = ./.;

          npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

          # Copy generated compliance code
          preBuild = ''
            mkdir -p node_modules/@compliance
            cp -r ${gdprCode}/gdpr node_modules/@compliance/
            cp -r ${soc2Code}/soc2 node_modules/@compliance/
          '';

          buildPhase = ''
            npm run build
          '';

          installPhase = ''
            mkdir -p $out/bin $out/lib

            # Copy built files
            cp -r dist $out/lib/
            cp -r node_modules $out/lib/
            cp package.json $out/lib/

            # Create run script
            cat > $out/bin/nestjs-compliance <<EOF
            #!/bin/sh
            cd $out/lib
            exec ${pkgs.nodejs_20}/bin/node dist/main.js
            EOF

            chmod +x $out/bin/nestjs-compliance
          '';
        };

        # Test scripts
        test-requests = pkgs.writeShellScriptBin "test-requests" ''
          echo "=== Testing NestJS Compliance Example ==="
          echo ""

          echo "1. GET /user/123 (GDPR Art.15 - Right of Access)"
          ${pkgs.curl}/bin/curl -s http://localhost:3000/user/123 | ${pkgs.jq}/bin/jq '.'
          echo ""

          echo "2. POST /user (GDPR Art.5(1)(f) + SOC 2 CC6.1)"
          ${pkgs.curl}/bin/curl -s -X POST http://localhost:3000/user \
            -H "Content-Type: application/json" \
            -d '{"email":"test@example.com","name":"Test User"}' | ${pkgs.jq}/bin/jq '.'
          echo ""

          echo "3. GET /user (List all users)"
          ${pkgs.curl}/bin/curl -s http://localhost:3000/user | ${pkgs.jq}/bin/jq '.'
          echo ""

          echo "4. DELETE /user/123 (GDPR Art.17 - Right to Erasure)"
          ${pkgs.curl}/bin/curl -s -X DELETE http://localhost:3000/user/123 -w "Status: %{http_code}\n"
          echo ""

          echo "✓ Test requests completed"
        '';

      in
      {
        packages = {
          default = app;
          test = test-requests;
        };

        apps = {
          default = {
            type = "app";
            program = "${app}/bin/nestjs-compliance";
          };

          test = {
            type = "app";
            program = "${test-requests}/bin/test-requests";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs_20
            nodePackages.typescript
            nodePackages.ts-node
            curl
            jq
          ];

          shellHook = ''
            echo "NestJS Compliance Example - Development Shell"
            echo ""
            echo "Generated compliance code:"
            echo "  GDPR: ${gdprCode}/gdpr/"
            echo "  SOC2: ${soc2Code}/soc2/"
            echo ""
            echo "Available commands:"
            echo "  npm install            - Install dependencies"
            echo "  npm run dev            - Run development server"
            echo "  npm run build          - Build production"
            echo "  nix build              - Build with Nix"
            echo "  nix run                - Run server"
            echo "  nix run .#test         - Test endpoints"
            echo ""
            echo "The server will run on http://localhost:3000"
            echo ""
            echo "Frameworks: GDPR, SOC 2"
            echo "Controls: Art.15, Art.17, Art.5(1)(f), CC6.1"
          '';
        };
      }
    );
}
