{
  description = "Go HTTP Server with compliance evidence";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    compliance.url = "path:../../../frameworks/generators";
  };

  outputs = { self, nixpkgs, flake-utils, compliance }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Get generated Go GDPR and SOC2 code
        gdprCode = compliance.packages.${system}.go-gdpr;
        soc2Code = compliance.packages.${system}.go-soc2;

        # Build the HTTP server
        app = pkgs.buildGoModule {
          pname = "compliance-http-server";
          version = "1.0.0";

          src = ./.;

          vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

          # Copy generated compliance code
          preBuild = ''
            mkdir -p vendor/github.com/fluohq/compliance-as-code
            cp -r ${gdprCode}/gdpr vendor/github.com/fluohq/compliance-as-code/
            cp -r ${soc2Code}/soc2 vendor/github.com/fluohq/compliance-as-code/
          '';

          ldflags = [
            "-s"
            "-w"
            "-X main.version=1.0.0"
          ];
        };

        # Helper to query evidence
        query-evidence = pkgs.writeShellScriptBin "query-evidence" ''
          echo "=== Querying Compliance Evidence ==="
          echo ""
          echo "This would query your OpenTelemetry backend for:"
          echo ""
          echo "1. GDPR Art.15 evidence (Right of Access):"
          echo "   {compliance.framework=\"gdpr\", compliance.control=\"Art.15\"}"
          echo ""
          echo "2. GDPR Art.17 evidence (Right to Erasure):"
          echo "   {compliance.framework=\"gdpr\", compliance.control=\"Art.17\"}"
          echo ""
          echo "3. SOC 2 CC6.1 evidence (Authorization):"
          echo "   {compliance.framework=\"soc2\", compliance.control=\"CC6.1\"}"
          echo ""
          echo "Configure OTEL_EXPORTER_OTLP_ENDPOINT to emit evidence."
        '';

        # Example requests
        test-requests = pkgs.writeShellScriptBin "test-requests" ''
          echo "=== Testing Compliance HTTP Server ==="
          echo ""

          echo "1. GET /user?id=123 (GDPR Art.15 - Right of Access)"
          ${pkgs.curl}/bin/curl -s http://localhost:8080/user?id=123 | ${pkgs.jq}/bin/jq '.'
          echo ""

          echo "2. POST /user (GDPR Art.5(1)(f) + SOC 2 CC6.1)"
          ${pkgs.curl}/bin/curl -s -X POST http://localhost:8080/user \
            -H "Content-Type: application/json" \
            -d '{"email":"test@example.com","name":"Test User"}' | ${pkgs.jq}/bin/jq '.'
          echo ""

          echo "3. DELETE /user?id=123 (GDPR Art.17 - Right to Erasure)"
          ${pkgs.curl}/bin/curl -s -X DELETE http://localhost:8080/user?id=123
          echo ""

          echo "✓ Requests completed. Check evidence in your observability backend."
        '';

      in
      {
        packages = {
          default = app;
          query = query-evidence;
          test = test-requests;
        };

        apps = {
          # Run the server
          default = {
            type = "app";
            program = "${app}/bin/compliance-http-server";
          };

          # Query evidence
          query = {
            type = "app";
            program = "${query-evidence}/bin/query-evidence";
          };

          # Test requests
          test = {
            type = "app";
            program = "${test-requests}/bin/test-requests";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            gopls
            gotools
            curl
            jq
          ];

          shellHook = ''
            echo "Go HTTP Compliance Example - Development Shell"
            echo ""
            echo "Generated compliance code available:"
            echo "  GDPR: ${gdprCode}/gdpr/"
            echo "  SOC2: ${soc2Code}/soc2/"
            echo ""
            echo "Available commands:"
            echo "  go run main.go         - Run development server"
            echo "  nix build              - Build production binary"
            echo "  nix run                - Run server"
            echo "  nix run .#test         - Test endpoints"
            echo "  nix run .#query        - Query evidence"
            echo ""
            echo "The server will run on http://localhost:8080"
          '';
        };
      }
    );
}
