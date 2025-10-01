# Compliance as Code - Architecture

> **Evidence should be telemetry, not documentation.**

## System Overview

Compliance as Code is a **code generation framework** that transforms compliance controls into type-safe, language-specific code with automatic evidence capture via OpenTelemetry.

```
┌─────────────────────────────────────────────────────────────┐
│           Canonical Taxonomy (Abstract Security)            │
│              IAM.AUTH.VERIFY, IAM.AUTHZ.ACCESS              │
└─────────────────────┬───────────────────────────────────────┘
                      │
          ┌───────────┼───────────┬──────────────┐
          ↓           ↓           ↓              ↓
    ┌─────────┐ ┌─────────┐ ┌─────────┐   ┌──────────┐
    │ SOC 2   │ │ HIPAA   │ │  GDPR   │   │ FedRAMP  │
    │ CC6.1   │ │164.312  │ │ Art.15  │   │   AC-2   │
    └────┬────┘ └────┬────┘ └────┬────┘   └────┬─────┘
         │           │           │              │
         └───────────┼───────────┼──────────────┘
                     ↓
         ┌───────────────────────────┐
         │   Code Generators (Nix)   │
         │  Java, TypeScript, Python │
         │  Go, Rust, C#, Ruby       │
         └───────────┬───────────────┘
                     ↓
         ┌───────────────────────────┐
         │   Generated Evidence Code │
         │  @GDPREvidence, ctx=...   │
         └───────────┬───────────────┘
                     ↓
         ┌───────────────────────────┐
         │   OpenTelemetry Spans     │
         │   Immutable Evidence      │
         └───────────────────────────┘
```

## Core Principles

### 1. Single Source of Truth

All compliance controls are defined **once** in Nix:

```nix
mkControl {
  id = "Art.15";
  name = "Right of Access";
  category = "Data Subject Rights";
  description = "Data subjects have the right to obtain confirmation...";
  canonicalObjectives = ["IAM.AUTHZ.ACCESS.READ"];
  evidenceTypes = [evidenceTypes.AUDIT_TRAIL];
  riskLevel = riskLevels.HIGH;
}
```

### 2. Graph-Based Taxonomy

Controls point to **canonical security objectives**, not each other:

```
SOC 2 CC6.1 ────┐
                 ├──→ IAM.AUTHZ.ACCESS.LEAST_PRIVILEGE
HIPAA §164.312 ─┤
                 │
GDPR Art.32 ────┘
```

This enables:
- Finding all controls implementing same objective
- Cross-framework compliance mapping
- Avoiding 1:1 mapping complexity

### 3. Language-Agnostic Patterns

Different languages, same evidence:

| Language | Pattern | Evidence Mechanism |
|----------|---------|-------------------|
| Java | Annotations | AOP interceptors |
| TypeScript | Decorators | Method wrappers |
| Python | Decorators | Function wrappers |
| Go | Context | context.Context threading |
| Nix | Derivations | Build-time wrappers |

### 4. Evidence as Telemetry

Evidence is captured as **OpenTelemetry spans**, not logs or documents:

```
Span Attributes:
  compliance.framework = "gdpr"
  compliance.control = "Art.15"
  compliance.evidence_type = "audit_trail"
  input.userId = "123"
  output.recordsReturned = 5
  compliance.result = "success"
  compliance.duration_ms = 45
```

## Architecture Components

### 1. Canonical Taxonomy (`frameworks/taxonomy.nix`)

Abstract security objectives organized hierarchically:

```
Domain → Category → Capability → Objective
```

Example:
```
IAM (Identity and Access Management)
  └─ AUTH (Authentication)
      └─ VERIFY (Identity Verification)
          └─ MFA (Multi-Factor Authentication)
```

**Purpose**: Framework-agnostic security concepts that controls implement.

### 2. Control Schema (`frameworks/schema.nix`)

Defines the structure of control definitions:

```nix
{
  mkControl = { id, name, category, description, requirements,
                evidenceTypes, riskLevel, canonicalObjectives, ... };

  evidenceTypes = { AUDIT_TRAIL, LOG, METRIC, CONFIG, ... };

  riskLevels = { LOW, MEDIUM, HIGH, CRITICAL };

  redactionStrategies = { EXCLUDE, REDACT, HASH, TRUNCATE, ENCRYPT };
}
```

**Purpose**: Consistent structure across all frameworks.

### 3. Framework Definitions (`frameworks/{framework}/controls/`)

Specific compliance requirements for each framework:

```
frameworks/
  ├── gdpr/controls/default.nix        # 22 GDPR controls
  ├── soc2/controls/default.nix        # 8 SOC 2 controls
  ├── hipaa/controls/default.nix       # 11 HIPAA controls
  ├── fedramp/controls/default.nix     # 16 FedRAMP controls
  ├── iso27001/controls/default.nix    # 14 ISO 27001 controls
  └── pci-dss/controls/default.nix     # 24 PCI-DSS controls
```

**Purpose**: Framework-specific control definitions.

### 4. Code Generators (`frameworks/generators/flake.nix`)

Transform Nix definitions into target languages:

```nix
# Java generator
generateJava = controls: frameworkName:
  pkgs.runCommand "java-${frameworkName}" {} ''
    # Generate annotations
    cat > ${frameworkName}Evidence.java << EOF
    @Target({ElementType.METHOD, ElementType.TYPE})
    @Retention(RetentionPolicy.RUNTIME)
    public @interface ${frameworkName}Evidence {
        ${frameworkName}Controls control();
        EvidenceType evidenceType() default EvidenceType.AUDIT_TRAIL;
    }
    EOF

    # Generate control constants
    cat > ${frameworkName}Controls.java << EOF
    public enum ${frameworkName}Controls {
        ${builtins.concatStringsSep "," (map toJavaEnum controls)}
    }
    EOF
  '';
```

**Purpose**: Generate type-safe, idiomatic code for each language.

### 5. OpenTelemetry Integration

Evidence emission via OpenTelemetry:

```
Application Method
    ↓
@GDPREvidence annotation
    ↓
AOP Interceptor / Decorator
    ↓
Start OTel Span
    ↓
Execute Method
    ↓
Record inputs/outputs (with redaction)
    ↓
End Span with result
    ↓
OTel Collector
    ↓
Tempo / Grafana / Prometheus
```

**Purpose**: Evidence is queryable like logs/metrics.

## Code Generation Flow

### 1. Define Controls (Nix)

```nix
# frameworks/gdpr/controls/default.nix
{
  art15 = mkControl {
    id = "Art.15";
    name = "Right of Access";
    canonicalObjectives = ["IAM.AUTHZ.ACCESS.READ"];
    evidenceTypes = [evidenceTypes.AUDIT_TRAIL];
  };
}
```

### 2. Generate Code (Nix Build)

```bash
nix build .#java-gdpr
# Generates:
#   result/src/main/java/com/compliance/annotations/GDPREvidence.java
#   result/src/main/java/com/compliance/annotations/GDPRControls.java
#   result/src/main/java/com/compliance/annotations/EvidenceType.java
```

### 3. Use in Application (Java)

```java
@GDPREvidence(
    control = GDPRControls.Art_15,
    evidenceType = EvidenceType.AUDIT_TRAIL
)
public User getUser(String userId) {
    return userRepository.findById(userId);
}
```

### 4. Evidence Emitted (OpenTelemetry)

```json
{
  "name": "compliance.evidence",
  "attributes": {
    "compliance.framework": "gdpr",
    "compliance.control": "Art.15",
    "input.userId": "123",
    "output.email": "user@example.com",
    "compliance.result": "success"
  }
}
```

## Language-Specific Patterns

### Java: Annotations + AOP

```java
@Aspect
public class ComplianceAspect {
    @Around("@annotation(gdprEvidence)")
    public Object capture(ProceedingJoinPoint pjp, GDPREvidence gdprEvidence) {
        Span span = tracer.spanBuilder("compliance.evidence")
            .setAttribute("compliance.control", gdprEvidence.control().toString())
            .startSpan();
        // Execute and capture
    }
}
```

### Go: Context Threading

```go
func getUser(ctx context.Context, userId string) (User, error) {
    span := gdpr.BeginEvidence(ctx, gdpr.Art_15)
    defer span.End()

    span.SetInput("userId", userId)
    user, err := db.FindUser(ctx, userId)
    span.SetOutput("email", user.Email)

    return user, err
}
```

### Python: Decorators

```python
@gdpr_evidence(control=GDPRControls.Art_15)
def get_user(user_id: str) -> User:
    return db.find_user(user_id)
```

### TypeScript: Decorators

```typescript
@GDPREvidence({ control: GDPRControls.Art_15 })
async getUser(userId: string): Promise<User> {
    return await userRepository.findById(userId);
}
```

### Nix: Derivation Wrapping

```nix
wrapDerivation {
    derivation = myApp;
    evidence = {
        framework = "fedramp";
        controls = ["CM-2" "CM-3"];
    };
}
```

## Data Redaction

Sensitive data is automatically excluded from evidence:

```nix
# Schema defines sensitive patterns
sensitivePatterns = [
  "password" "passwd" "pwd"
  "token" "apiKey" "api_key"
  "secret" "privateKey"
  "ssn" "creditCard" "cvv"
];

# Code generators implement redaction
if shouldRedact(fieldName):
    value = "<redacted>"
```

## Supply Chain Security

Nix provides:
- **Reproducible builds**: Same inputs = same outputs
- **Content-addressed storage**: Cryptographic hashes
- **Hermetic execution**: No network during build
- **Full provenance**: Complete dependency graph in `flake.lock`

```bash
# Verify build reproducibility
nix build .#java-gdpr
sha256sum result/src/main/java/com/compliance/annotations/GDPREvidence.java

# Check on different machine - same hash
```

## Benefits

### For Developers
- **Type-safe**: IDE autocomplete for controls
- **Zero overhead**: Evidence captured automatically
- **Language-native**: Idiomatic patterns for each language

### For Security Teams
- **Queryable**: Evidence in Grafana like logs/metrics
- **Immutable**: OpenTelemetry spans can't be modified
- **Real-time**: Evidence emitted as operations happen

### For Auditors
- **Traceable**: Full trace from code to evidence
- **Verifiable**: Cryptographic hashes prove integrity
- **Complete**: Every control has evidence

## Performance Impact

Evidence capture is designed for production use:

| Operation | Overhead | Notes |
|-----------|----------|-------|
| Java annotation processing | ~0.1ms | AOP interception |
| Go context passing | ~0.05ms | Zero reflection |
| Python decorator | ~0.2ms | Function wrapper |
| OTel span emission | Async | Non-blocking |

## Future Enhancements

- **Rust support**: Procedural macros
- **C# support**: Attributes
- **More frameworks**: CCPA, NIST CSF, CIS Controls
- **Query DSL**: Structured compliance queries
- **Evidence aggregation**: Multi-span compliance proofs

---

**Compliance is observable infrastructure.**
