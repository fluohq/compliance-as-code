# Compliance as Code

> **A collection of patterns for treating compliance evidence as observable telemetry.**

## The Problem

You spent 40 hours preparing evidence for your audit. You created Word documents, screenshots, and manual logs to prove your system does what your code already does.

Then the auditor trusts the Word doc more than your code.

**This is backwards.**

## The Pattern

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

## Core Concepts

This repository demonstrates several key patterns:

1. **Evidence as Telemetry**: Compliance evidence should be OpenTelemetry spans, not Word docs
2. **Code Generation**: Define controls once, generate code for multiple languages
3. **Observable Controls**: Every control implementation emits immutable proof
4. **Declarative Compliance**: Annotate code with what it does, evidence follows automatically
5. **Query-First Design**: Evidence should be queryable like logs and metrics

### Evidence-Based Architecture

Methods produce **immutable evidence** as OpenTelemetry spans:

- **Timestamp**: When the control was executed
- **Trace ID**: Full distributed trace context
- **Control**: Which compliance requirement was satisfied
- **Inputs/Outputs**: What data was processed (with automatic redaction)
- **Duration**: How long it took
- **Result**: Success or failure
- **Side Effects**: What external systems were touched

### Language Patterns

The same evidence pattern works across languages:

| Language | Pattern | Example |
|----------|---------|---------|
| **Java** | Annotations | `@GDPREvidence(control = GDPRControls.Art_51f)` |
| **TypeScript** | Decorators | `@GDPREvidence({ control: GDPRControls.Art_51f })` |
| **Python** | Decorators | `@gdpr_evidence(control='Art.5(1)(f)')` |
| **Go** | Manual Spans | `span := gdpr.BeginSpan(gdpr.Art_51f)` |

## What's Included

This repository contains:

1. **Design Patterns**: Examples of treating compliance as observable telemetry
2. **Control Definitions**: GDPR, SOC 2, HIPAA, FedRAMP, ISO 27001, PCI-DSS (95 controls total)
3. **Code Generators**: Nix-based generators for Java, TypeScript, Python, Go
4. **Working Examples**: 15+ examples across backend, data, and infrastructure

**This is a reference implementation**, not a production framework. Use these patterns in your own systems.

## Examples

### Backend Frameworks

- **[Go HTTP Server](./examples/backend/go-http/)** - Context-based evidence spans
- **[Java Spring Boot](./examples/backend/java-spring-boot/)** - Annotation-based evidence
- **[Java Camel](./examples/backend/java-camel/)** - Route-based evidence emission
- **[Python FastAPI](./examples/backend/python-fastapi/)** - Async decorator pattern
- **[Python Django](./examples/backend/python-django/)** - View-based evidence
- **[TypeScript NestJS](./examples/backend/typescript-nestjs/)** - DI integration
- **[TypeScript Express](./examples/backend/typescript-express/)** - Middleware pattern
- **[TypeScript tRPC](./examples/backend/typescript-trpc/)** - Type-safe RPC evidence

### Data Tools

- **[AWS SDK Wrapper](./examples/data/aws-sdk-wrapper/)** - S3/DynamoDB with compliance evidence
- **[Snowflake Wrapper](./examples/data/snowflake-wrapper/)** - Data warehouse query evidence (placeholder)
- **[Airtable Wrapper](./examples/data/airtable-wrapper/)** - Low-code tool compliance (placeholder)

### Infrastructure

- **[Kubernetes Admission Controller](./examples/infrastructure/kubernetes-admission/)** - Policy enforcement with evidence
- **[Terraform Provider](./examples/infrastructure/terraform-provider/)** - IaC compliance (placeholder)
- **[Pulumi Wrapper](./examples/infrastructure/pulumi-wrapper/)** - Infrastructure evidence emission

See **[examples/](./examples/)** for complete code.

## Using These Patterns

### 1. Study the Examples

Start with the language you use:

```bash
# View Go example
cat examples/backend/go-http/main.go

# View Java example
cat examples/backend/java-spring-boot/src/main/java/com/example/compliance/UserController.java
```

### 2. Adapt to Your Stack

These are **patterns**, not a library. Copy the concepts:

```java
// Pattern: Emit evidence before/after business logic
public User getUser(String userId) {
    Span span = tracer.spanBuilder("get_user")
        .setAttribute("compliance.framework", "gdpr")
        .setAttribute("compliance.control", "Art.15")
        .setAttribute("userId", userId)
        .startSpan();

    try {
        User user = database.findById(userId);
        span.setAttribute("recordsReturned", 1);
        return user;
    } finally {
        span.end();
    }
}
```

### 3. Query Your Evidence

```promql
# All GDPR evidence
{compliance.framework="gdpr"}

# Right to erasure operations
{compliance.control="Art.17"}

# Failed compliance operations
{compliance.result="failure"}
```

## Key Design Patterns

### 1. Evidence as Structured Attributes

Use OpenTelemetry span attributes to make evidence queryable:

```javascript
span.setAttribute('compliance.framework', 'gdpr');
span.setAttribute('compliance.control', 'Art.15');
span.setAttribute('compliance.operation', 'data_access');
span.setAttribute('input.userId', userId);
span.setAttribute('output.recordsReturned', records.length);
```

### 2. Control Mapping to Canonical Objectives

Map controls to abstract security objectives rather than cross-framework mappings:

```nix
# SOC 2 CC6.1, HIPAA 164.312(a)(1), GDPR Art.32 all map to:
canonicalObjectives = ["IAM.AUTHZ.ACCESS.LEAST_PRIVILEGE"];
```

This enables querying across frameworks by security objective.

### 3. Language-Native Patterns

Use each language's idiomatic patterns:
- **Java**: Annotations with AspectJ
- **TypeScript**: Decorators with reflect-metadata
- **Python**: Function decorators
- **Go**: Explicit span creation (no magic)

### 4. Reproducible Builds

Use Nix flakes for deterministic code generation:
- Same control definitions always produce same code
- Cryptographic verification of all dependencies
- Complete audit trail from definition to generated code

## Why This Approach?

### For Developers

- **No manual evidence**: Code proves what it does automatically
- **Same tools**: Query compliance like you query logs
- **Type-safe**: Controls are compile-time constants, not strings
- **Framework-agnostic**: Works with Spring, FastAPI, Express, etc.

### For Auditors

- **Immutable proof**: Evidence is cryptographically signed spans
- **Real-time**: No waiting for screenshots or manual logs
- **Complete context**: Full distributed traces, not isolated events
- **Queryable**: Filter by framework, control, timerange, user, etc.

### For Security Teams

- **Observable controls**: See which controls are actually running
- **Continuous monitoring**: Alert on missing or failed evidence
- **Cross-framework**: Map GDPR to SOC 2 to HIPAA via canonical objectives
- **Audit trail**: Complete provenance from code to evidence

## Philosophy

These patterns are based on three principles:

1. **Compliance is a byproduct of good software**, not a separate artifact
2. **Evidence should be as observable as logs, metrics, and traces**
3. **Controls should be declared once, proven continuously**

If your code implements a control, it should automatically prove it did so. This is compliance as **observable infrastructure**.

## Contributing

This is an open collection of patterns. Contributions welcome:

- New language examples
- Additional compliance frameworks
- Better code generation techniques
- Real-world usage patterns

See **[CONTRIBUTING.md](./CONTRIBUTING.md)** for guidelines.

## Documentation

- **[Examples Directory](./examples/)** - Working code across 15+ frameworks
- **[Developer Guide](./frameworks/DEVELOPER_GUIDE.md)** - Implementation patterns
- **[Control Definitions](./frameworks/)** - GDPR, SOC 2, HIPAA, etc.
- **[Code Generators](./frameworks/generators/)** - Nix-based generation

## License

Apache 2.0 - Use these patterns freely in commercial projects.

## Inspiration

These patterns build on:
- **[Nix](https://nixos.org/)** - Reproducible builds and deterministic generation
- **[OpenTelemetry](https://opentelemetry.io/)** - Observable telemetry as evidence
- Years of manual compliance work that could have been automated

---

**Compliance is observable infrastructure. Evidence is just telemetry.**
