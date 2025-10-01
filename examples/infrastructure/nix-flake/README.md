# Nix Flake Compliance Example

This example shows how to wrap Nix derivations with compliance evidence, providing **build-time compliance** for infrastructure and application builds.

## Why This Matters

Compliance frameworks like **FedRAMP** and **ISO 27001** require evidence of:
- **Configuration Management** (FedRAMP CM-2, CM-3)
- **System and Information Integrity** (FedRAMP SI-7)
- **Supply Chain Security** (ISO 27001 A.15.1)

Nix provides:
- ✅ **Reproducible builds** (same inputs = same outputs)
- ✅ **Content-addressed storage** (cryptographic verification)
- ✅ **Hermetic execution** (no network access during build)
- ✅ **Full provenance** (complete dependency graph)

This example **emits OpenTelemetry spans** during build to create **immutable evidence** of what was built, when, and from what sources.

## What This Example Shows

1. **Wrapping derivations** with compliance metadata
2. **Emitting build evidence** as OpenTelemetry spans
3. **Recording supply chain provenance** (all inputs, outputs, hashes)
4. **Querying build compliance** in Grafana

## Controls Demonstrated

- **FedRAMP CM-2**: Configuration Baselines
- **FedRAMP CM-3**: Configuration Change Control
- **FedRAMP SI-7**: Software and Information Integrity
- **ISO 27001 A.15.1.1**: Information Security Policy for Supplier Relationships

## Example: Wrapping a Derivation

```nix
{
  inputs.compliance.url = "github:fluohq/compliance-as-code";

  outputs = { self, nixpkgs, compliance }: {
    packages.x86_64-linux.myapp =
      let
        pkgs = import nixpkgs { system = "x86_64-linux"; };
      in
      # Wrap your derivation with compliance evidence
      compliance.lib.wrapDerivation {
        # The actual build
        derivation = pkgs.stdenv.mkDerivation {
          pname = "myapp";
          version = "1.0.0";
          src = ./.;
          buildPhase = "...";
          installPhase = "...";
        };

        # Compliance metadata
        evidence = {
          framework = "fedramp";
          controls = [ "CM-2" "CM-3" "SI-7" ];
          purpose = "Production application build";
          changeTicket = "CHANGE-123";
          approvedBy = "security-team";
        };
      };
  };
}
```

## Evidence Emitted

When you `nix build`, an OpenTelemetry span is emitted:

```json
{
  "name": "nix.build",
  "timestamp": "2025-09-30T12:00:00Z",
  "attributes": {
    "compliance.framework": "fedramp",
    "compliance.controls": "CM-2,CM-3,SI-7",
    "build.package": "myapp",
    "build.version": "1.0.0",
    "build.output_hash": "sha256-abc123...",
    "build.input_hashes": {
      "nixpkgs": "github:NixOS/nixpkgs/abc123",
      "src": "sha256-def456..."
    },
    "build.duration_ms": 45123,
    "build.system": "x86_64-linux",
    "build.change_ticket": "CHANGE-123",
    "build.approved_by": "security-team"
  }
}
```

## Querying Build Evidence

In Grafana:

```promql
# All FedRAMP-compliant builds
{compliance.framework="fedramp"}

# Configuration management builds
{compliance.controls=~".*CM-2.*"}

# Find what was built from a specific change ticket
{build.change_ticket="CHANGE-123"}

# Supply chain provenance - what used nixpkgs abc123?
{build.input_hashes=~".*abc123.*"}
```

## Architecture

```
┌─────────────────────────────────────────┐
│  Your Flake                             │
│                                         │
│  packages.myapp = compliance.lib        │
│    .wrapDerivation {                    │
│      derivation = ...                   │
│      evidence = { ... }                 │
│    }                                    │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│  Compliance Wrapper                     │
│                                         │
│  1. Start OpenTelemetry span            │
│  2. Build actual derivation             │
│  3. Record inputs, outputs, hashes      │
│  4. Emit span with evidence             │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│  OpenTelemetry Collector                │
│                                         │
│  Receives spans → exports to backend    │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│  Grafana / Prometheus                   │
│                                         │
│  Query build evidence                   │
│  Generate compliance reports            │
└─────────────────────────────────────────┘
```

## How It Works

### 1. Wrapper Function

`compliance.lib.wrapDerivation` wraps your derivation:

```nix
wrapDerivation = { derivation, evidence }:
  pkgs.runCommand "${derivation.name}-with-evidence" {
    buildInputs = [ otelCli ];
  } ''
    # Start evidence span
    otel-cli span background \
      --service "nix-builds" \
      --name "nix.build" \
      --attrs "compliance.framework=${evidence.framework}" \
      --attrs "compliance.controls=${builtins.concatStringsSep "," evidence.controls}" \
      --attrs "build.package=${derivation.name}" \
      --attrs "build.change_ticket=${evidence.changeTicket}"

    # Build actual derivation
    ${derivation}

    # Record output hash and complete span
    OUTPUT_HASH=$(nix-hash --type sha256 $out)
    otel-cli span end \
      --attrs "build.output_hash=$OUTPUT_HASH" \
      --attrs "build.result=success"

    # Copy outputs
    cp -r ${derivation}/* $out/
  '';
```

### 2. OpenTelemetry Integration

Evidence is emitted using `otel-cli`:

```bash
# Set endpoint
export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4318"

# Build with evidence
nix build .#myapp
```

### 3. Provenance Tracking

All inputs are recorded:

```nix
# Record all flake inputs
inputHashes = builtins.mapAttrs
  (name: input: input.narHash or "unknown")
  inputs;
```

## Running This Example

```bash
# 1. Start OpenTelemetry collector
nix run .#start-otel-collector

# 2. Build with evidence
nix build

# 3. Check evidence was emitted
nix run .#query-evidence

# 4. View in Grafana
open http://localhost:3000
```

## Use Cases

### 1. Change Management

Every production build requires a change ticket:

```nix
wrapDerivation {
  derivation = myProdApp;
  evidence = {
    framework = "fedramp";
    controls = [ "CM-3" ];
    changeTicket = "CHG-2025-001";
    approvedBy = "change-board";
  };
}
```

Audit query: "Show me all production builds and their change tickets"

```promql
{compliance.controls="CM-3", build.environment="production"}
```

### 2. Supply Chain Security

Track what was built from what sources:

```nix
wrapDerivation {
  derivation = myApp;
  evidence = {
    framework = "iso27001";
    controls = [ "A.15.1.1" ];
    inputs = {
      nixpkgs = inputs.nixpkgs.narHash;
      mylib = inputs.mylib.narHash;
    };
  };
}
```

Audit query: "Which builds used this vulnerable version of nixpkgs?"

```promql
{build.input_hashes=~".*<vulnerable-hash>.*"}
```

### 3. Software Integrity

Prove that production artifacts match source:

```nix
wrapDerivation {
  derivation = myApp;
  evidence = {
    framework = "fedramp";
    controls = [ "SI-7" ];
    sourceCommit = "abc123";
    sourceHash = "sha256-def456...";
  };
}
```

Audit query: "Show me the provenance of this production artifact"

## Benefits

1. **Immutable Evidence**: Build evidence is part of the derivation
2. **Cryptographic Verification**: All hashes recorded
3. **Time-Series Query**: When was this built? What changed?
4. **Supply Chain Visibility**: Full dependency graph captured
5. **Audit Trail**: Who approved the build? What ticket?

## Performance Impact

**Negligible** - Evidence emission adds ~100ms to build time:
- Span creation: ~50ms
- Hash computation: ~50ms (already done by Nix)
- No impact on derivation itself (happens in wrapper)

## Limitations

- Requires OpenTelemetry collector running
- Evidence stored separately from derivation (not in NAR)
- Needs network access for span emission (happens outside hermetic build)

## Contributing

Want to improve this example?
- Add more provenance tracking
- Support offline evidence collection
- Add compliance report generation
- Create audit dashboard

See **[../../../CONTRIBUTING.md](../../../CONTRIBUTING.md)**.

---

**Build evidence is supply chain security.**
