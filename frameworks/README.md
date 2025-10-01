# Compliance-as-Code: Evidence-Based Framework

This directory contains **canonical control definitions** for major compliance frameworks that generate **evidence-based compliance code** with automatic capture of immutable proof via OpenTelemetry spans.

## 🚀 Quick Start

```bash
# 1. Generate compliance code
cd generators
nix build .#java-gdpr

# 2. Copy to your project
cp -r result/src/main/java/com/compliance/ your-project/src/main/java/

# 3. Annotate your code
@GDPREvidence(
    control = GDPRControls.Art_51f,
    evidenceType = EvidenceType.AUDIT_TRAIL
)
public User createUser(String email, @Redact String password) {
    // Your code runs normally - evidence captured automatically!
    return userRepository.save(new User(email, hash(password)));
}
```

**📚 [Read the Developer Guide](./DEVELOPER_GUIDE.md)** for step-by-step examples.

## 📖 Documentation

| Document | Purpose |
|----------|---------|
| **[DEVELOPER_GUIDE.md](./DEVELOPER_GUIDE.md)** | Step-by-step guide with real-world examples showing exactly what you need to do |
| **[GENERATED_CODE_REFERENCE.md](./GENERATED_CODE_REFERENCE.md)** | Complete API reference of generated code |
| **[EVIDENCE_USAGE.md](./EVIDENCE_USAGE.md)** | Evidence concepts and OpenTelemetry integration |

## ✨ What's New: Evidence-Based Compliance

### Automatic Evidence Collection

Methods annotated with `@{Framework}Evidence` automatically capture **immutable evidence** as OpenTelemetry spans:

```java
@GDPREvidence(
    control = GDPRControls.Art_17,  // Right to Erasure
    evidenceType = EvidenceType.AUDIT_TRAIL
)
public DeletionResult deleteUserData(String userId) {
    int deleted = database.deleteAllUserData(userId);
    return DeletionResult.success(deleted);
}

// Evidence span automatically emitted:
// ✓ timestamp: "2025-09-30T01:00:00Z"
// ✓ traceId: "abc123..."
// ✓ framework: "gdpr"
// ✓ control: "Art.17"
// ✓ input.userId: "usr_123"
// ✓ output.deletedRecords: 47
// ✓ duration: 125ms
// ✓ sideEffects: ["database.deleteAllUserData"]
// → Immutable proof that deletion occurred
```

### Data Redaction

Sensitive data is protected from appearing in evidence:

```java
@GDPREvidence(control = GDPRControls.Art_51f)
public User register(
    String email,
    @Redact String password,                    // Excluded from evidence
    @PII String ssn,                            // Hashed: "sha256:abc..."
    @Redact(strategy = TRUNCATE, preserve = 4)
    String creditCard                           // Truncated: "1234...6789"
) {
    // Evidence contains email but NOT password or full credit card
}
```

**Redaction Strategies:**
- `EXCLUDE` - Don't include in evidence at all
- `REDACT` - Replace with `<redacted>` placeholder
- `HASH` - SHA-256 hash for correlation
- `TRUNCATE` - Show first/last N characters
- `ENCRYPT` - Encrypt with evidence key

### Type-Safe Control IDs

IDE autocomplete with compile-time validation:

```java
@GDPREvidence(
    control = GDPRControls.  // ← IDE shows all 22 GDPR controls
    //   Art_51f - Integrity and Confidentiality [CRITICAL]
    //   Art_15  - Right of Access [HIGH]
    //   Art_17  - Right to Erasure [HIGH]
    //   Art_32  - Security of Processing [CRITICAL]
    //   ...
)
```

Hover over a control to see:
- Full description
- Requirements
- Implementation guidance
- Testing procedures
- Risk level

### View Evidence in Grafana

Query compliance evidence in Grafana:

```promql
# All GDPR evidence
{compliance.framework="gdpr"}

# Critical controls only
{compliance.framework="gdpr", compliance.risk_level="critical"}

# Right to Erasure evidence
{compliance.control="Art.17"}

# Failed operations
{compliance.result="failure"}
```

## Supported Frameworks

| Framework | Controls | Java | TypeScript | Python | Go |
|-----------|----------|------|------------|--------|-----|
| **GDPR** | 22 | ✅ | ✅ | ✅ | ✅ |
| **SOC 2** | 8 | ✅ | ✅ | ✅ | ✅ |
| **HIPAA** | 11 | ✅ | ✅ | ✅ | ✅ |
| **FedRAMP** | 16 | ✅ | ✅ | ✅ | ✅ |
| **ISO 27001** | 14 | ✅ | ✅ | ✅ | ✅ |
| **PCI-DSS** | 24 | ✅ | ✅ | ✅ | ✅ |

### Language Support

| Language | Pattern | Example | Notes |
|----------|---------|---------|-------|
| **Java** | Annotations | `@GDPREvidence(control = ...)` | Full Javadoc, type-safe |
| **TypeScript** | Decorators | `@GDPREvidence({ control: ... })` | Experimental decorators |
| **Python** | Decorators | `@gdpr_evidence(control=...)` | Type hints, .pyi stubs |
| **Go** | Context | `ctx = gdpr.WithEvidence(ctx, ...)` | Idiomatic Go pattern |
| **JavaScript** | Wrappers | `withGDPREvidence({ ... }, fn)` | 🚧 Coming soon |
| **Rust** | Macros | `#[gdpr_evidence(...)]` | 🚧 Coming soon |

Each framework includes:
- **Java/TS/Python**: Evidence annotations (`@GDPREvidence`, `@SOC2Evidence`, etc.)
- **Go**: Context-based evidence (`WithEvidence()`, `BeginEvidence()`)
- Type-safe control constants
- Automatic redaction of sensitive data
- Control metadata (requirements, guidance, testing)
- Full documentation (Javadoc/TSDoc/docstrings/godoc)

## Architecture

The system follows a graph-based architecture:

```
Canonical Taxonomy (Abstract Security Objectives)
         ↑              ↑              ↑
         |              |              |
    SOC 2 Controls   HIPAA Controls   FedRAMP Controls
         ↓              ↓              ↓
    Generated Code (Java, TypeScript, Python, etc.)
```

### Key Components

1. **`taxonomy.nix`** - Canonical security control taxonomy
   - Defines abstract security objectives (e.g., "Unique User Identification")
   - Organized as Domain → Category → Capability → Objective
   - Framework-agnostic security concepts

2. **`schema.nix`** - Control definition schema
   - Structure for defining controls
   - Validation rules
   - Evidence types
   - Implementation patterns

3. **Framework Definitions** - Specific control requirements
   - `soc2/controls/` - SOC 2 Trust Service Criteria
   - `hipaa/controls/` - HIPAA Security Rule
   - `fedramp/controls/` - FedRAMP Moderate Baseline
   - `iso27001/controls/` - ISO 27001:2022 Annex A
   - `pci-dss/controls/` - PCI-DSS v4.0

4. **`generators/`** - Code generation infrastructure
   - Transforms Nix definitions into target languages
   - Supports Java, TypeScript, Python, JSON, and more

## Usage

### Generate Code

```bash
# Generate Java annotations for SOC 2
nix build ./generators#java-soc2
cat result/src/main/java/com/compliance/annotations/SOC2.java

# Generate TypeScript decorators for HIPAA
nix build ./generators#ts-hipaa
cat result/src/hipaa.ts

# Generate Python decorators for FedRAMP
nix build ./generators#py-fedramp
cat result/compliance/fedramp.py

# Generate Go context-based evidence for GDPR
nix build ./generators#go-gdpr
cat result/gdpr/evidence.go

# Generate all code for all frameworks
nix build ./generators#all-java
nix build ./generators#all-typescript
nix build ./generators#all-python
nix build ./generators#all-go
```

### List Available Frameworks

```bash
cd generators
nix run
# or
nix run .#list-frameworks
```

### Generate All Code

```bash
cd generators
nix run .#generate-all
```

## Control Definition Structure

Each control is defined with:

```nix
mkControl {
  id = "CC6.1";  # Framework-specific control ID
  name = "Logical Access - Authorization";
  category = "Logical and Physical Access Controls";
  description = ''
    Detailed description of what this control requires...
  '';
  requirements = [
    "Specific requirement 1"
    "Specific requirement 2"
  ];
  evidenceTypes = [
    evidenceTypes.AUDIT_TRAIL
    evidenceTypes.CONFIG
  ];
  implementationGuidance = ''
    How to implement this control...
  '';
  riskLevel = riskLevels.HIGH;
  technicalControls = [
    technicalControlTypes.ACCESS_CONTROL
    technicalControlTypes.AUTHORIZATION
  ];
  canonicalObjectives = [
    "IAM.AUTHZ.ACCESS.LEAST_PRIVILEGE"
    "IAM.AUTHZ.ACCESS.RBAC"
    "IAM.AUTHZ.ACCESS.DENY_DEFAULT"
  ];
  testingProcedures = [
    "How to test this control..."
  ];
  patterns = [
    patterns.INTERCEPTOR
    patterns.MIDDLEWARE
  ];
  metadata = {
    tags = ["technical" "access-control"];
    automatable = true;
    priority = "high";
  };
}
```

## Canonical Taxonomy

The taxonomy defines abstract security objectives organized hierarchically:

- **Domain**: High-level security area (e.g., Identity and Access Management)
- **Category**: Specific security function (e.g., Authentication)
- **Capability**: Implementation approach (e.g., Multi-Factor Authentication)
- **Objective**: Specific security goal (e.g., "IAM.AUTH.VERIFY.MFA")

### Example Taxonomy Path

```
Identity and Access Management (IAM)
  └─ Authentication (IAM.AUTH)
      └─ Identity Verification (IAM.AUTH.VERIFY)
          └─ Multi-Factor Authentication (IAM.AUTH.VERIFY.MFA)
```

### Finding Related Controls

Instead of cross-framework mappings, controls point to canonical objectives:

```nix
# SOC 2 CC6.1
canonicalObjectives = ["IAM.AUTHZ.ACCESS.LEAST_PRIVILEGE"];

# HIPAA 164.312(a)(1)
canonicalObjectives = ["IAM.AUTHZ.ACCESS.LEAST_PRIVILEGE"];

# FedRAMP AC-3
canonicalObjectives = ["IAM.AUTHZ.ACCESS.LEAST_PRIVILEGE"];
```

Traverse the graph to find all controls implementing the same objective:

```bash
# Find all controls implementing least privilege
nix eval .#findControlsByObjective --arg objective "IAM.AUTHZ.ACCESS.LEAST_PRIVILEGE"
```

## Generated Code Examples

### Java

```java
@SOC2({"CC6.1", "CC6.2"})
@HIPAA({"164.312(a)(1)"})
public class UserService {
    public void grantAccess(User user, Resource resource) {
        // Implementation automatically generates compliance evidence
    }
}
```

### TypeScript

```typescript
import { SOC2, HIPAA } from './compliance';

class UserService {
  @SOC2(['CC6.1', 'CC6.2'])
  @HIPAA(['164.312(a)(1)'])
  async grantAccess(user: User, resource: Resource) {
    // Implementation automatically generates compliance evidence
  }
}
```

### Python

```python
from compliance.soc2 import SOC2Compliance
from compliance.hipaa import HIPAACompliance

class UserService:
    @SOC2Compliance(['CC6.1', 'CC6.2'])
    @HIPAACompliance(['164.312(a)(1)'])
    def grant_access(self, user, resource):
        # Implementation automatically generates compliance evidence
        pass
```

### Go (Context-Based)

```go
import (
    "context"
    "github.com/fluo/compliance/gdpr"
    "github.com/fluo/compliance/soc2"
)

func createUser(ctx context.Context, email, password string) (User, error) {
    // Context-based evidence (idiomatic Go)
    ctx = gdpr.WithEvidence(ctx, gdpr.Art_51f)
    defer gdpr.EmitEvidence(ctx)

    // Your normal code - evidence captured automatically
    user := User{Email: email, Password: hash(password)}
    return userRepo.Save(ctx, user)
}

// Alternative: explicit span management
func deleteUser(ctx context.Context, userId string) error {
    span := gdpr.BeginEvidence(ctx, gdpr.Art_17)
    defer span.End()

    span.SetInput("userId", userId)
    deleted := userRepo.DeleteAll(ctx, userId)
    span.SetOutput("deletedRecords", deleted)

    return nil
}
```

**Go Pattern Benefits:**
- **Idiomatic**: Uses `context.Context` (standard Go pattern)
- **No reflection**: Zero runtime overhead
- **Explicit**: Clear evidence capture points
- **Type-safe**: Control constants validated at compile time
- **OpenTelemetry native**: Direct span emission

## Adding a New Framework

1. Create directory: `frameworks/new-framework/controls/`
2. Create `default.nix` with control definitions:

```nix
{ schema }:
let
  inherit (schema) mkControl evidenceTypes riskLevels technicalControlTypes patterns;
in
{
  myControl = mkControl {
    id = "CTRL-1";
    name = "My Control";
    category = "My Category";
    description = "...";
    canonicalObjectives = ["IAM.AUTH.VERIFY.UNIQUE_ID"];
    # ... other fields
  };

  allControls = [ myControl ];
}
```

3. Add to generators/flake.nix:

```nix
newFrameworkControls = import ../new-framework/controls/default.nix { inherit schema; };

packages = {
  java-newframework = generateJava newFrameworkControls.allControls "NewFramework";
  # ... other generators
};
```

## Integration with FLUO Backend

The generated Java annotations are designed to integrate with FLUO's compliance system:

```java
// In your backend code
@SOC2({"CC6.1"})
@HIPAA({"164.312(a)(1)"})
public Tenant createTenant(TenantRequest request) {
    // OpenTelemetry span automatically created with compliance attributes
    // span.setAttribute("compliance.framework", "soc2")
    // span.setAttribute("compliance.control", "CC6.1")
    return tenantService.create(request);
}
```

See `backend/COMPLIANCE_OTEL_GRAFANA.md` for OpenTelemetry integration details.

## Benefits

1. **Single Source of Truth**: Control definitions in one place
2. **Multi-Language Support**: Generate code for any language
3. **Graph Traversal**: Find related controls across frameworks
4. **Type Safety**: Generated code is type-safe and validated
5. **Supply Chain Security**: Nix ensures reproducible builds
6. **Automatic Updates**: Regenerate code when controls change
7. **Framework Independence**: Abstract security objectives separate from framework specifics

## Next Steps

- Add more frameworks (GDPR, CCPA, etc.)
- Generate documentation from control definitions
- Create web dashboard for control browsing
- Add AI-powered control mapping suggestions
- Generate test cases from control definitions