# Evidence-Based Compliance Usage Guide

## Overview

The compliance code generators now produce **evidence-based annotations** that mark methods as producing immutable compliance evidence. Evidence is automatically captured and emitted as OpenTelemetry spans.

## Generated Components

### 1. Redaction Annotations
- `@Redact` - Mark sensitive parameters/fields to exclude from evidence
- `@Sensitive` - Always exclude from evidence (passwords, keys, etc.)
- `@PII` - Personally Identifiable Information (configurable handling)

### 2. Redaction Strategies
- `EXCLUDE` - Don't include in evidence at all
- `REDACT` - Replace with `<redacted>` placeholder
- `HASH` - SHA-256 hash for correlation without exposing data
- `TRUNCATE` - Show first/last N characters: `"1234...6789"`
- `ENCRYPT` - Encrypt with evidence key

### 3. Evidence Span Classes
- `ComplianceSpan` - Immutable base class for evidence records
- `EvidenceType` - Types of evidence (AUDIT_TRAIL, LOG, METRIC, etc.)

### 4. Framework Evidence Annotations
- `@GDPREvidence` - Mark methods producing GDPR evidence
- `@SOC2Evidence` - Mark methods producing SOC 2 evidence
- `@HIPAAEvidence` - Mark methods producing HIPAA evidence
- etc. for all 6 frameworks

## Usage Examples

### Basic Evidence Collection

```java
import com.compliance.annotations.GDPREvidence;
import com.compliance.annotations.GDPRControls;
import com.compliance.evidence.*;

public class UserService {

    /**
     * Creates a new user with encrypted personal data.
     * Evidence automatically captures inputs, outputs, and side effects.
     */
    @GDPREvidence(
        control = GDPRControls.Art_51f,  // Integrity and Confidentiality
        evidenceType = EvidenceType.AUDIT_TRAIL
    )
    public User createUser(
        String email,
        @Redact String password,           // Never appears in evidence
        @PII String name,                  // Hashed in evidence by default
        @Redact(strategy = RedactionStrategy.HASH) String ssn
    ) {
        // Evidence span automatically captures:
        // ✓ timestamp: 2025-09-30T00:13:45Z
        // ✓ traceId: abc123...
        // ✓ input.email: "user@example.com"
        // ✗ input.password: <excluded>
        // ✓ input.name: "sha256:def456..."
        // ✓ input.ssn: "sha256:ghi789..."
        // ✓ duration: 125ms
        // ✓ result: "success"

        byte[] hashedPassword = hashPassword(password);
        User user = new User(email, hashedPassword, name, ssn);
        database.save(user);

        // ✓ output.userId: "usr_abc123"
        // ✓ sideEffects: ["database.save(User)"]

        return user;
    }
}
```

### Multiple Controls

```java
@GDPREvidence(
    control = GDPRControls.Art_15,  // Right of Access
    evidenceType = EvidenceType.AUDIT_TRAIL,
    notes = "User data export for GDPR compliance"
)
public UserDataExport exportUserData(String userId) {
    // Evidence captures the complete data export operation
    UserDataExport export = new UserDataExport();
    export.personalData = database.findPersonalData(userId);
    export.activityLogs = database.findActivityLogs(userId);
    export.consentRecords = database.findConsentRecords(userId);

    return export;
}
```

### Class-Level Sensitive Fields

```java
public class User {
    public String id;              // ✓ Captured in evidence
    public String email;           // ✓ Captured in evidence

    @Sensitive
    public String password;        // ✗ Never captured

    @PII
    public String ssn;             // ✓ Captured as hash

    @Redact(strategy = RedactionStrategy.TRUNCATE, preserve = 4)
    public String creditCard;      // ✓ Captured as "1234...6789"
}
```

### Deletion Evidence (Right to Erasure)

```java
@GDPREvidence(
    control = GDPRControls.Art_17,  // Right to Erasure
    evidenceType = EvidenceType.AUDIT_TRAIL
)
public DeletionResult deleteUserData(
    String userId,
    String reason,
    String requestedBy
) {
    // Evidence proves the deletion occurred and was complete
    // ✓ input.userId: "usr_123"
    // ✓ input.reason: "User requested account deletion"
    // ✓ input.requestedBy: "user@example.com"

    int deletedRecords = database.deleteAllUserData(userId);

    // ✓ output.deletedRecords: 47
    // ✓ output.deletionTimestamp: "2025-09-30T00:15:00Z"
    // ✓ sideEffects: ["database.deleteAllUserData(usr_123)"]

    return DeletionResult.success(deletedRecords);
}
```

### Data Breach Notification

```java
@GDPREvidence(
    control = GDPRControls.Art_33,  // Breach Notification to Authority
    evidenceType = EvidenceType.AUDIT_TRAIL
)
public NotificationResult notifyDataBreach(
    BreachReport report,
    @Redact String internalIncidentDetails
) {
    // Evidence captures breach notification without exposing sensitive details
    // ✓ input.report.breachId: "breach_2025_001"
    // ✓ input.report.affectedUsers: 1234
    // ✓ input.report.dataTypes: ["email", "name"]
    // ✗ input.internalIncidentDetails: <excluded>

    NotificationResult result = supervisoryAuthority.notify(report);

    // ✓ output.notificationId: "notif_abc123"
    // ✓ output.timestamp: "2025-09-30T00:16:00Z"
    // ✓ sideEffects: ["supervisoryAuthority.notify(BreachReport)"]

    return result;
}
```

## Evidence Span Structure

Each evidence annotation automatically produces an immutable span:

```java
ComplianceSpan {
    timestamp: Instant          // When evidence was created
    traceId: String            // OpenTelemetry trace ID
    spanId: String             // Unique span ID
    parentSpanId: String       // Parent span (if nested)
    framework: "gdpr"          // Compliance framework
    control: "Art.5(1)(f)"     // Control ID
    evidenceType: "audit_trail"
    result: "success"          // or "failure", "error"
    duration: Duration         // How long the operation took
    error: String              // Error message if failed
    attributes: Map<String, Object> {
        "input.email": "user@example.com",
        "input.password": "<redacted>",
        "output.userId": "usr_123",
        "sideEffects": ["database.save(User)"]
    }
}
```

## OpenTelemetry Integration

Evidence spans are emitted with these attributes:

```
compliance.framework = "gdpr"
compliance.control = "Art.5(1)(f)"
compliance.evidence_type = "audit_trail"
compliance.risk_level = "critical"
compliance.result = "success"
compliance.user_id = "user@example.com"
compliance.action = "encrypt_user_data"
compliance.duration_ms = 125
compliance.side_effects = ["database.save"]
```

## Viewing Evidence in Grafana

Evidence spans can be queried in Grafana:

```promql
# All GDPR evidence
{compliance.framework="gdpr"}

# Critical controls only
{compliance.framework="gdpr", compliance.risk_level="critical"}

# Failed operations
{compliance.framework="gdpr", compliance.result="failure"}

# Specific control
{compliance.framework="gdpr", compliance.control="Art.5(1)(f)"}
```

## Generation

Generate evidence-based compliance code for all frameworks:

```bash
cd compliance-as-code/frameworks/generators

# Generate for specific framework
nix build .#java-gdpr      # GDPR
nix build .#java-soc2      # SOC 2
nix build .#java-hipaa     # HIPAA

# Generate all frameworks
nix build .#all-java       # All Java
nix build .#all-typescript # All TypeScript
nix build .#all-python     # All Python
```

## Next Steps

### TODO: Interceptor Implementation
- Automatic method interception (AspectJ for Java)
- Capture inputs, outputs, side effects
- Emit OpenTelemetry spans
- Handle redaction based on annotations

### TODO: TypeScript Implementation
- Decorators with Proxy-based interception
- Same evidence capture semantics
- OpenTelemetry JS SDK integration

### TODO: Python Implementation
- Function decorators with wrapt
- Automatic evidence capture
- OpenTelemetry Python SDK integration

## Design Principles

1. **Write-Once Evidence** - All evidence records are immutable
2. **Automatic Capture** - Annotations trigger automatic evidence collection
3. **Data Protection** - Redaction prevents sensitive data in evidence
4. **Type Safety** - Compile-time validation of control IDs
5. **OpenTelemetry Native** - Evidence is OTLP spans for universal tooling
6. **Framework Agnostic** - Same patterns for all 6 compliance frameworks