{
  description = "AWS SDK Wrapper with compliance evidence";

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

        # Build the wrapper library
        app = pkgs.buildNpmPackage {
          pname = "aws-sdk-compliance-wrapper";
          version = "1.0.0";

          src = ./.;

          npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

          # Copy generated compliance code
          preBuild = ''
            mkdir -p node_modules/@compliance
            cp -r ${gdprCode} node_modules/@compliance/gdpr
            cp -r ${soc2Code} node_modules/@compliance/soc2
          '';

          buildPhase = ''
            npm run build
          '';

          installPhase = ''
            mkdir -p $out/bin $out/lib
            cp -r dist $out/lib/
            cp package.json $out/lib/

            cat > $out/bin/aws-compliance-demo << 'EOF'
            #!/usr/bin/env node
            require('$out/lib/dist/index.js');
            EOF
            chmod +x $out/bin/aws-compliance-demo
          '';
        };

        # Helper to query evidence
        query-evidence = pkgs.writeShellScriptBin "query-evidence" ''
          echo "=== Querying AWS Compliance Evidence ==="
          echo ""
          echo "This would query your OpenTelemetry backend for:"
          echo ""
          echo "1. S3 GetObject evidence (GDPR Art.15):"
          echo "   {compliance.framework=\"gdpr\", compliance.control=\"Art.15\", operation=\"S3.GetObject\"}"
          echo ""
          echo "2. S3 PutObject evidence (GDPR Art.5(1)(f) + SOC 2 CC6.1):"
          echo "   {compliance.framework=\"gdpr\", compliance.control=\"Art.5(1)(f)\", operation=\"S3.PutObject\"}"
          echo "   {compliance.framework=\"soc2\", compliance.control=\"CC6.1\", action=\"write_object\"}"
          echo ""
          echo "3. DynamoDB DeleteItem evidence (GDPR Art.17):"
          echo "   {compliance.framework=\"gdpr\", compliance.control=\"Art.17\", operation=\"DynamoDB.DeleteItem\"}"
          echo ""
          echo "Configure OTEL_EXPORTER_OTLP_ENDPOINT to emit evidence."
        '';

        # LocalStack helper
        localstack-setup = pkgs.writeShellScriptBin "localstack-setup" ''
          echo "=== Setting up LocalStack for Testing ==="
          echo ""
          echo "1. Start LocalStack (requires Docker):"
          echo "   docker run -d -p 4566:4566 localstack/localstack"
          echo ""
          echo "2. Create test resources:"
          echo "   aws --endpoint-url=http://localhost:4566 s3 mb s3://user-data"
          echo "   aws --endpoint-url=http://localhost:4566 dynamodb create-table \\"
          echo "     --table-name Users \\"
          echo "     --attribute-definitions AttributeName=userId,AttributeType=S \\"
          echo "     --key-schema AttributeName=userId,KeyType=HASH \\"
          echo "     --billing-mode PAY_PER_REQUEST"
          echo ""
          echo "3. Run demo:"
          echo "   nix run"
        '';

      in
      {
        packages = {
          default = app;
          query = query-evidence;
          setup = localstack-setup;
        };

        apps = {
          # Run the demo
          default = {
            type = "app";
            program = "${app}/bin/aws-compliance-demo";
          };

          # Query evidence
          query = {
            type = "app";
            program = "${query-evidence}/bin/query-evidence";
          };

          # Setup instructions
          setup = {
            type = "app";
            program = "${localstack-setup}/bin/localstack-setup";
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs_20
            nodePackages.typescript
            nodePackages.typescript-language-server
            awscli2
          ];

          shellHook = ''
            echo "AWS SDK Compliance Wrapper - Development Shell"
            echo ""
            echo "Generated compliance code available:"
            echo "  GDPR: ${gdprCode}/"
            echo "  SOC2: ${soc2Code}/"
            echo ""
            echo "Available commands:"
            echo "  npm install            - Install dependencies"
            echo "  npm run dev            - Run demo"
            echo "  npm run build          - Build library"
            echo "  nix run                - Run demo"
            echo "  nix run .#query        - Query evidence"
            echo "  nix run .#setup        - LocalStack setup"
            echo ""
            echo "Set AWS_ENDPOINT_URL=http://localhost:4566 for LocalStack"
          '';
        };
      }
    );
}
