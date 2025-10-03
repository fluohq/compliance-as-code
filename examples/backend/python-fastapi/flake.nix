{
  description = "FastAPI with compliance evidence";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    compliance.url = "path:../../../frameworks/generators";
  };

  outputs = { self, nixpkgs, flake-utils, compliance }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Get generated Python GDPR and SOC2 code
        gdprCode = compliance.packages.${system}.py-gdpr;
        soc2Code = compliance.packages.${system}.py-soc2;

        python = pkgs.python312;
        pythonPackages = python.pkgs;

        # Build the FastAPI app
        app = pythonPackages.buildPythonApplication {
          pname = "fastapi-compliance-example";
          version = "1.0.0";

          src = ./.;

          propagatedBuildInputs = with pythonPackages; [
            fastapi
            uvicorn
            pydantic
            pydantic-core
            email-validator
            opentelemetry-api
            opentelemetry-sdk
            opentelemetry-exporter-otlp
          ];

          # Copy generated compliance code
          preBuild = ''
            mkdir -p app/compliance
            cp -r ${gdprCode}/gdpr/*.py app/compliance/
            cp -r ${soc2Code}/soc2/*.py app/compliance/
            touch app/compliance/__init__.py
          '';

          format = "other";

          installPhase = ''
            mkdir -p $out/bin $out/lib/python

            # Copy app
            cp -r app $out/lib/python/

            # Create run script
            cat > $out/bin/fastapi-compliance <<EOF
            #!${python}/bin/python
            import sys
            sys.path.insert(0, "$out/lib/python")
            from app.main import app
            import uvicorn
            uvicorn.run(app, host="0.0.0.0", port=8000)
            EOF

            chmod +x $out/bin/fastapi-compliance
          '';
        };

        # Test scripts
        test-requests = pkgs.writeShellScriptBin "test-requests" ''
          echo "=== Testing FastAPI Compliance Example ==="
          echo ""

          echo "1. GET /user/123 (GDPR Art.15 - Right of Access)"
          ${pkgs.curl}/bin/curl -s http://localhost:8000/user/123 | ${pkgs.jq}/bin/jq '.'
          echo ""

          echo "2. POST /user (GDPR Art.5(1)(f) + SOC 2 CC6.1)"
          ${pkgs.curl}/bin/curl -s -X POST http://localhost:8000/user \
            -H "Content-Type: application/json" \
            -d '{"email":"test@example.com","name":"Test User"}' | ${pkgs.jq}/bin/jq '.'
          echo ""

          echo "3. GET /users (List all users)"
          ${pkgs.curl}/bin/curl -s http://localhost:8000/users | ${pkgs.jq}/bin/jq '.'
          echo ""

          echo "4. DELETE /user/123 (GDPR Art.17 - Right to Erasure)"
          ${pkgs.curl}/bin/curl -s -X DELETE http://localhost:8000/user/123 -w "Status: %{http_code}\n"
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
            program = "${app}/bin/fastapi-compliance";
          };

          test = {
            type = "app";
            program = "${test-requests}/bin/test-requests";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            python
            pythonPackages.fastapi
            pythonPackages.uvicorn
            pythonPackages.pydantic
            pythonPackages.email-validator
            pkgs.curl
            pkgs.jq
          ];

          shellHook = ''
            echo "FastAPI Compliance Example - Development Shell"
            echo ""
            echo "Generated compliance code:"
            echo "  GDPR: ${gdprCode}/gdpr/"
            echo "  SOC2: ${soc2Code}/soc2/"
            echo ""
            echo "Available commands:"
            echo "  python -m app.main     - Run development server"
            echo "  nix build              - Build production binary"
            echo "  nix run                - Run server"
            echo "  nix run .#test         - Test endpoints"
            echo ""
            echo "The server will run on http://localhost:8000"
            echo "API docs: http://localhost:8000/docs"
            echo ""
            echo "Frameworks: GDPR, SOC 2"
            echo "Controls: Art.15, Art.17, Art.5(1)(f), CC6.1"
          '';
        };
      }
    );
}
