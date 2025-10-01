{
  description = "Spring Boot with compliance evidence";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    compliance.url = "path:../../../frameworks/generators";
  };

  outputs = { self, nixpkgs, flake-utils, compliance }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Get generated Java compliance code
        gdprCode = compliance.packages.${system}.java-gdpr;
        soc2Code = compliance.packages.${system}.java-soc2;
        hipaaCode = compliance.packages.${system}.java-hipaa;

        # Build the Spring Boot application
        app = pkgs.stdenv.mkDerivation {
          pname = "compliance-spring-boot";
          version = "1.0.0";

          src = ./.;

          buildInputs = [ pkgs.jdk21 pkgs.maven ];

          # Copy generated compliance code to src
          preBuild = ''
            mkdir -p src/main/java/com/compliance
            cp -r ${gdprCode}/src/main/java/com/compliance/* src/main/java/com/compliance/
            cp -r ${soc2Code}/src/main/java/com/compliance/* src/main/java/com/compliance/
            cp -r ${hipaaCode}/src/main/java/com/compliance/* src/main/java/com/compliance/
          '';

          buildPhase = ''
            mvn clean package -DskipTests
          '';

          installPhase = ''
            mkdir -p $out/bin $out/lib
            cp target/*.jar $out/lib/app.jar

            # Create run script
            cat > $out/bin/compliance-spring-boot << 'EOF'
            #!/bin/sh
            exec ${pkgs.jdk21}/bin/java \
              -jar $out/lib/app.jar \
              "$@"
            EOF
            chmod +x $out/bin/compliance-spring-boot
          '';
        };

        # Helper script to test the API
        test-api = pkgs.writeShellScriptBin "test-api" ''
          echo "=== Testing Spring Boot Compliance API ==="
          echo ""

          BASE_URL="http://localhost:8080"

          echo "1. Health check"
          ${pkgs.curl}/bin/curl -s $BASE_URL/api/users/health | ${pkgs.jq}/bin/jq '.'
          echo ""

          echo "2. List users (GDPR Art.15)"
          ${pkgs.curl}/bin/curl -s $BASE_URL/api/users | ${pkgs.jq}/bin/jq '.'
          echo ""

          echo "3. Get user by ID (GDPR Art.15)"
          ${pkgs.curl}/bin/curl -s $BASE_URL/api/users/1 | ${pkgs.jq}/bin/jq '.'
          echo ""

          echo "4. Create user (GDPR Art.5(1)(f) + SOC2 CC6.1)"
          ${pkgs.curl}/bin/curl -s -X POST $BASE_URL/api/users \
            -H "Content-Type: application/json" \
            -d '{"email":"test@example.com","name":"Test User"}' | ${pkgs.jq}/bin/jq '.'
          echo ""

          echo "5. Delete user (GDPR Art.17)"
          ${pkgs.curl}/bin/curl -s -X DELETE $BASE_URL/api/users/1
          echo ""

          echo "✓ API tests completed. Check evidence in your observability backend."
        '';

      in
      {
        packages = {
          default = app;
          test = test-api;
        };

        apps = {
          # Run the Spring Boot application
          default = {
            type = "app";
            program = "${app}/bin/compliance-spring-boot";
          };

          # Test the API
          test = {
            type = "app";
            program = "${test-api}/bin/test-api";
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
            echo "Spring Boot Compliance Example - Development Shell"
            echo ""
            echo "Generated compliance code available:"
            echo "  GDPR: ${gdprCode}/src/main/java/com/compliance/"
            echo "  SOC2: ${soc2Code}/src/main/java/com/compliance/"
            echo "  HIPAA: ${hipaaCode}/src/main/java/com/compliance/"
            echo ""
            echo "Available commands:"
            echo "  mvn spring-boot:run    - Run development server"
            echo "  mvn test               - Run tests"
            echo "  nix build              - Build production JAR"
            echo "  nix run                - Run server"
            echo "  nix run .#test         - Test API endpoints"
            echo ""
            echo "The server will run on http://localhost:8080"
          '';
        };
      }
    );
}
