# Compliance as Code

> **Compliance evidence should be telemetry, not documentation.**

## The Problem

You spent 40 hours preparing evidence for your audit. You created Word documents, screenshots, and manual logs to prove your system does what your code already does.

Then the auditor trusts the Word doc more than your code.

**This is backwards.**

## The Solution

What if compliance evidence was just... telemetry? What if every method that implements a control automatically emits an immutable span proving it happened?

```java
@GDPREvidence(
    control = GDPRControls.Art_17,  // Right to Erasure
    evidenceType = EvidenceType.AUDIT_TRAIL
)
public DeletionResult deleteUserData(String userId) {
    int deleted = database.deleteAllUserData(userId);
    return DeletionResult.success(deleted);
}

// OpenTelemetry span automatically emitted:
// ✓ timestamp, traceId, framework, control
// ✓ input.userId, output.deletedRecords, duration
// ✓ sideEffects: ["database.deleteAllUserData"]
// → Immutable proof that deletion occurred
```

Query compliance evidence in Grafana like any other telemetry:

```promql
{compliance.framework="gdpr", compliance.control="Art.17"}
```

## How It Works

1. **Define controls once** in Nix (canonical source of truth)
2. **Generate code** for Java, TypeScript, Python, Go
3. **Annotate your methods** with compliance controls
4. **Evidence captured automatically** as OpenTelemetry spans
5. **Query in Grafana** like any other observability data

### Evidence-Based Architecture

Methods produce **immutable evidence** as OpenTelemetry spans:

- **Timestamp**: When the control was executed
- **Trace ID**: Full distributed trace context
- **Control**: Which compliance requirement was satisfied
- **Inputs/Outputs**: What data was processed (with automatic redaction)
- **Duration**: How long it took
- **Result**: Success or failure
- **Side Effects**: What external systems were touched

### Language Support

Different languages, same evidence:

| Language | Pattern | Example |
|----------|---------|---------|
| **Java** | Annotations | `@GDPREvidence(control = GDPRControls.Art_51f)` |
| **TypeScript** | Decorators | `@GDPREvidence({ control: GDPRControls.Art_51f })` |
| **Python** | Decorators | `@gdpr_evidence(control='Art.5(1)(f)')` |
| **Go** | Context | `ctx = gdpr.WithEvidence(ctx, gdpr.Art_51f)` |
| **Nix** | Derivations | `compliance.wrapDerivation { control = "Art.51f"; }` |

## Supported Frameworks

| Framework | Controls | Status |
|-----------|----------|--------|
| **GDPR** | 22 | ✅ Complete |
| **SOC 2** | 8 | ✅ Complete |
| **HIPAA** | 11 | ✅ Complete |
| **FedRAMP** | 16 | ✅ Complete |
| **ISO 27001** | 14 | ✅ Complete |
| **PCI-DSS** | 24 | ✅ Complete |

**Total: 95 controls across 6 frameworks**

## Quick Start

### 1. Generate Compliance Code

```bash
# Generate for your language
nix build github:fluohq/compliance-as-code#java-gdpr
nix build github:fluohq/compliance-as-code#ts-soc2
nix build github:fluohq/compliance-as-code#py-hipaa
nix build github:fluohq/compliance-as-code#go-fedramp

# Copy to your project
cp -r result/src/main/java/com/compliance/ your-project/src/main/java/
```

### 2. Annotate Your Code

```java
@GDPREvidence(
    control = GDPRControls.Art_51f,  // Integrity and Confidentiality
    evidenceType = EvidenceType.AUDIT_TRAIL
)
public User createUser(String email, @Redact String password) {
    // Evidence captured automatically!
    return userRepository.save(new User(email, hash(password)));
}
```

### 3. Query Evidence in Grafana

```promql
# All GDPR evidence
{compliance.framework="gdpr"}

# Critical controls only
{compliance.framework="gdpr", compliance.risk_level="critical"}

# Failed operations
{compliance.result="failure"}
```

## Architecture

### Graph-Based Control Definitions

```
Canonical Taxonomy (Abstract Security Objectives)
         ↑              ↑              ↑
         |              |              |
    SOC 2 Controls   HIPAA Controls   GDPR Controls
         ↓              ↓              ↓
    Generated Code (Java, TypeScript, Python, Go, Nix)
```

Controls point to **canonical security objectives** rather than cross-framework mappings:

```nix
# SOC 2 CC6.1
canonicalObjectives = ["IAM.AUTHZ.ACCESS.LEAST_PRIVILEGE"];

# HIPAA 164.312(a)(1)
canonicalObjectives = ["IAM.AUTHZ.ACCESS.LEAST_PRIVILEGE"];

# GDPR Art.32
canonicalObjectives = ["IAM.AUTHZ.ACCESS.LEAST_PRIVILEGE"];
```

Find all controls implementing the same objective across frameworks.

### Supply Chain Security

All dependencies locked with Nix flakes:

- **Reproducible builds**: Same inputs = same outputs
- **Cryptographic verification**: All dependencies content-addressed
- **Hermetic execution**: No network access during build
- **Audit trail**: Full provenance tracking

## Examples

Working examples for common frameworks:

- **[Java Spring Boot](./examples/backend/java-spring-boot/)** - REST API with @GDPREvidence
- **[Go HTTP Server](./examples/backend/go-http/)** - Context-based evidence
- **[Python FastAPI](./examples/backend/python-fastapi/)** - Async decorators
- **[TypeScript NestJS](./examples/backend/typescript-nestjs/)** - Dependency injection integration
- **[AWS SDK Wrapper](./examples/data/aws-sdk-wrapper/)** - Cloud service evidence
- **[Nix Flake](./examples/infrastructure/nix-flake/)** - Build evidence for derivations

See **[examples/](./examples/)** for more.

## Documentation

- **[Developer Guide](./frameworks/DEVELOPER_GUIDE.md)** - Step-by-step implementation examples
- **[Generated Code Reference](./frameworks/GENERATED_CODE_REFERENCE.md)** - Complete API documentation
- **[Evidence Usage](./frameworks/EVIDENCE_USAGE.md)** - Evidence concepts and OpenTelemetry integration
- **[Architecture](./ARCHITECTURE.md)** - System design and canonical taxonomy

## Philosophy

**Compliance should be a byproduct of good software**, not a separate artifact.

If your code implements a control, it should automatically prove it implemented that control. Evidence should be as observable as logs, metrics, and traces.

This is compliance as **observable infrastructure**.

## Contributing

We're building this in public. Contributions welcome!

See **[CONTRIBUTING.md](./CONTRIBUTING.md)** for guidelines.

### Adding a New Framework

1. Define controls in `frameworks/{framework}/controls/default.nix`
2. Add to `frameworks/generators/flake.nix`
3. Generate code: `nix build .#java-{framework}`

See **[frameworks/README.md](./frameworks/README.md)** for details.

## License

Apache 2.0 - Use freely in commercial projects with patent protection.

## Acknowledgments

Built with:
- **[Nix](https://nixos.org/)** - Reproducible builds and supply chain security
- **[OpenTelemetry](https://opentelemetry.io/)** - Evidence emission and collection

---

**Compliance is observable infrastructure.**
