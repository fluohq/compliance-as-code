{
  description = "Apache Camel with compliance evidence";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    compliance.url = "path:../../../frameworks/generators";
  };

  outputs = { self, nixpkgs, flake-utils, compliance }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Get generated Java GDPR and SOC2 code
        gdprCode = compliance.packages.${system}.java-gdpr;
        soc2Code = compliance.packages.${system}.java-soc2;

        # Build the Camel application
        app = pkgs.stdenv.mkDerivation {
          pname = "camel-compliance-example";
          version = "1.0.0";

          src = ./.;

          nativeBuildInputs = with pkgs; [
            maven
            jdk21
          ];

          buildPhase = ''
            # Copy generated compliance code to src
            mkdir -p src/main/java/com/compliance/evidence
            cp -r ${gdprCode}/gdpr/src/main/java/com/compliance/evidence/* src/main/java/com/compliance/evidence/
            cp -r ${soc2Code}/soc2/src/main/java/com/compliance/evidence/* src/main/java/com/compliance/evidence/

            # Build with Maven
            mvn package -DskipTests
          '';

          installPhase = ''
            mkdir -p $out/bin $out/lib

            # Copy jar
            cp target/*.jar $out/lib/camel-compliance-example.jar

            # Copy dependencies
            cp -r target/lib $out/

            # Create run script
            cat > $out/bin/camel-compliance-example <<EOF
            #!/bin/sh
            exec ${pkgs.jdk21}/bin/java -cp "$out/lib/*:$out/lib/camel-compliance-example.jar" com.example.compliance.Application "\$@"
            EOF

            chmod +x $out/bin/camel-compliance-example
          '';
        };

        # Helper scripts
        test-requests = pkgs.writeShellScriptBin "test-requests" ''
          echo "=== Testing Camel Compliance Example ==="
          echo ""

          echo "1. GET /user/123 (GDPR Art.15 - Right of Access)"
          ${pkgs.curl}/bin/curl -s http://localhost:8080/user/123 | ${pkgs.jq}/bin/jq '.'
          echo ""

          echo "2. POST /user (GDPR Art.5(1)(f) + SOC 2 CC6.1)"
          ${pkgs.curl}/bin/curl -s -X POST http://localhost:8080/user \
            -H "Content-Type: application/json" \
            -d '{"email":"test@example.com","name":"Test User"}' | ${pkgs.jq}/bin/jq '.'
          echo ""

          echo "3. DELETE /user/123 (GDPR Art.17 - Right to Erasure)"
          ${pkgs.curl}/bin/curl -s -X DELETE http://localhost:8080/user/123 -w "Status: %{http_code}\n"
          echo ""

          echo "4. GET /user/123 again (should be 404)"
          ${pkgs.curl}/bin/curl -s http://localhost:8080/user/123 | ${pkgs.jq}/bin/jq '.'
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
            program = "${app}/bin/camel-compliance-example";
          };

          test = {
            type = "app";
            program = "${test-requests}/bin/test-requests";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            jdk21
            maven
            curl
            jq
          ];

          shellHook = ''
            echo "Camel Compliance Example - Development Shell"
            echo ""
            echo "Generated compliance code:"
            echo "  GDPR: ${gdprCode}/gdpr/"
            echo "  SOC2: ${soc2Code}/soc2/"
            echo ""
            echo "Available commands:"
            echo "  mvn compile            - Compile project"
            echo "  mvn exec:java          - Run in development mode"
            echo "  nix build              - Build production binary"
            echo "  nix run                - Run server"
            echo "  nix run .#test         - Test endpoints"
            echo ""
            echo "The server will run on http://localhost:8080"
            echo ""
            echo "Frameworks: GDPR, SOC 2"
            echo "Controls: Art.15, Art.17, Art.5(1)(f), CC6.1"
          '';
        };
      }
    );
}
