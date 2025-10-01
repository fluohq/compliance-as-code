# Generated Code Reference

## What Gets Generated

When you run `nix build .#java-gdpr`, you get a complete package of compliance code.

## Directory Structure

```
result/src/main/java/com/compliance/
├── evidence/                      # Evidence infrastructure (shared)
│   ├── ComplianceSpan.java       # Immutable base class for evidence
│   ├── EvidenceType.java         # AUDIT_TRAIL, LOG, METRIC, etc.
│   ├── Redact.java               # @Redact annotation
│   ├── RedactionStrategy.java   # EXCLUDE, HASH, TRUNCATE, etc.
│   ├── Sensitive.java            # @Sensitive annotation
│   └── PII.java                  # @PII annotation
│
├── annotations/                   # Framework-specific annotations
│   ├── GDPREvidence.java         # @GDPREvidence annotation
│   ├── GDPR.java                 # @GDPR annotation (legacy)
│   ├── GDPRControls.java         # Control ID constants
│   └── ...                        # (similar for other frameworks)
│
└── models/                        # Control metadata models
    ├── ComplianceControl.java    # Interface for all controls
    ├── GDPRControl.java          # Enum of all GDPR controls
    ├── GDPR_Art_51f.java         # Detailed Art.5(1)(f) model
    ├── GDPR_Art_15.java          # Detailed Art.15 model
    └── ...                        # (one class per control)
```

---

## Evidence Infrastructure

### ComplianceSpan.java

**Immutable base class for all evidence records.**

```java
package com.compliance.evidence;

import java.time.Instant;
import java.time.Duration;
import java.util.*;

public abstract class ComplianceSpan {
    // All fields are final (immutable)
    public final Instant timestamp;
    public final String traceId;
    public final String spanId;
    public final String parentSpanId;
    public final String framework;
    public final String control;
    public final String evidenceType;
    public final String result;
    public final Duration duration;
    public final String error;
    public final Map<String, Object> attributes;

    protected ComplianceSpan(Builder<?> builder) {
        // Validates and makes immutable
        this.timestamp = Objects.requireNonNull(builder.timestamp);
        this.traceId = Objects.requireNonNull(builder.traceId);
        // ... all fields are set once and frozen
        this.attributes = Collections.unmodifiableMap(builder.attributes);
    }

    // Builder pattern for construction
    protected static abstract class Builder<T extends Builder<T>> {
        // ... builder methods
        public abstract ComplianceSpan build();
    }

    // Export to OpenTelemetry
    public abstract void exportToOtel();
}
```

**Usage:** Extend this class for framework-specific evidence spans (future).

---

### Redact.java

**Annotation to mark sensitive data.**

```java
package com.compliance.evidence;

import java.lang.annotation.*;

@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.PARAMETER, ElementType.FIELD})
@Documented
public @interface Redact {
    RedactionStrategy strategy() default RedactionStrategy.EXCLUDE;
    int preserve() default 4;  // For TRUNCATE strategy
}
```

**Usage:**
```java
public void method(
    @Redact String password,                    // Excluded
    @Redact(strategy = HASH) String userId,     // Hashed
    @Redact(strategy = TRUNCATE, preserve = 4)
    String creditCard                           // "1234...6789"
) { }
```

---

### RedactionStrategy.java

**Enum defining how to redact sensitive data.**

```java
package com.compliance.evidence;

public enum RedactionStrategy {
    EXCLUDE,    // Don't include at all
    REDACT,     // Replace with "<redacted>"
    HASH,       // SHA-256 hash
    TRUNCATE,   // Show first/last N chars
    ENCRYPT     // Encrypt with evidence key
}
```

---

### Sensitive.java

**Shorthand for always-excluded fields.**

```java
package com.compliance.evidence;

import java.lang.annotation.*;

@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.FIELD, ElementType.PARAMETER})
@Documented
public @interface Sensitive {
}
```

**Usage:**
```java
public class User {
    public String email;        // Captured

    @Sensitive
    public String password;     // Never captured

    @Sensitive
    public String apiKey;       // Never captured
}
```

---

### PII.java

**Annotation for personally identifiable information.**

```java
package com.compliance.evidence;

import java.lang.annotation.*;

@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.FIELD, ElementType.PARAMETER})
@Documented
public @interface PII {
    RedactionStrategy strategy() default RedactionStrategy.HASH;
}
```

**Usage:**
```java
public class User {
    @PII
    public String ssn;          // Hashed by default

    @PII
    public String phoneNumber;  // Hashed by default

    @PII(strategy = EXCLUDE)
    public String medicalRecord; // Excluded
}
```

---

### EvidenceType.java

**Types of compliance evidence.**

```java
package com.compliance.evidence;

public enum EvidenceType {
    AUDIT_TRAIL,     // Audit trail of actions
    LOG,             // Log entries
    METRIC,          // Metrics and measurements
    CONFIG,          // Configuration snapshots
    TEST,            // Test results
    SCAN,            // Security scan results
    CERTIFICATE,     // Certificates
    DOCUMENTATION    // Documentation and policies
}
```

---

## Framework Annotations

### GDPREvidence.java

**Annotation to mark methods that produce GDPR evidence.**

```java
package com.compliance.annotations;

import com.compliance.evidence.*;
import java.lang.annotation.*;

@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.METHOD, ElementType.TYPE})
@Documented
public @interface GDPREvidence {
    /**
     * Control ID from GDPRControls.
     */
    String control();

    /**
     * Type of evidence produced.
     */
    EvidenceType evidenceType() default EvidenceType.AUDIT_TRAIL;

    /**
     * Additional notes.
     */
    String notes() default "";

    /**
     * Capture method inputs?
     */
    boolean captureInputs() default true;

    /**
     * Capture method outputs?
     */
    boolean captureOutputs() default true;

    /**
     * Capture side effects?
     */
    boolean captureSideEffects() default true;
}
```

**Usage:**
```java
@GDPREvidence(
    control = GDPRControls.Art_51f,
    evidenceType = EvidenceType.AUDIT_TRAIL,
    notes = "Encrypts user data at rest"
)
public User createUser(String email, @Redact String password) {
    // Your code
}
```

---

### GDPRControls.java

**Type-safe constants for all GDPR control IDs.**

```java
package com.compliance.annotations;

public final class GDPRControls {
    private GDPRControls() {
        throw new UnsupportedOperationException();
    }

    /**
     * <b>Lawfulness, Fairness and Transparency</b>
     *
     * <p><b>Control ID:</b> Art.5(1)(a)</p>
     * <p><b>Category:</b> Principles</p>
     * <p><b>Risk Level:</b> high</p>
     *
     * <p><b>Description:</b><br>
     * Personal data shall be processed lawfully, fairly and in a
     * transparent manner in relation to the data subject.</p>
     *
     * <p><b>Requirements:</b></p>
     * <ul>
     * <li>Establish lawful basis for processing</li>
     * <li>Transparent privacy notices</li>
     * <li>Fair processing practices</li>
     * <li>Document lawful basis</li>
     * <li>Regular privacy policy updates</li>
     * </ul>
     */
    public static final String Art_51a = "Art.5(1)(a)";

    /**
     * <b>Integrity and Confidentiality</b>
     *
     * <p><b>Control ID:</b> Art.5(1)(f)</p>
     * <p><b>Category:</b> Principles</p>
     * <p><b>Risk Level:</b> critical</p>
     *
     * <p><b>Description:</b><br>
     * Personal data shall be processed in a manner that ensures
     * appropriate security of the personal data, including protection
     * against unauthorised or unlawful processing and against accidental
     * loss, destruction or damage.</p>
     *
     * <p><b>Requirements:</b></p>
     * <ul>
     * <li>Encryption of personal data at rest</li>
     * <li>Encryption of personal data in transit</li>
     * <li>Access controls for personal data</li>
     * <li>Data breach detection and response</li>
     * <li>Regular security assessments</li>
     * </ul>
     */
    public static final String Art_51f = "Art.5(1)(f)";

    /**
     * <b>Right of Access</b>
     *
     * <p><b>Control ID:</b> Art.15</p>
     * <p><b>Category:</b> Data Subject Rights</p>
     * <p><b>Risk Level:</b> high</p>
     *
     * <p><b>Description:</b><br>
     * The data subject shall have the right to obtain from the controller
     * confirmation as to whether or not personal data concerning them is
     * being processed, and where that is the case, access to the personal
     * data.</p>
     *
     * <p><b>Requirements:</b></p>
     * <ul>
     * <li>Provide copy of personal data</li>
     * <li>Information about processing purposes</li>
     * <li>Categories of data processed</li>
     * <li>Recipients of data</li>
     * <li>Retention periods</li>
     * <li>Right to rectification, erasure, or restriction</li>
     * <li>Right to lodge complaint with supervisory authority</li>
     * <li>Respond within one month</li>
     * </ul>
     */
    public static final String Art_15 = "Art.15";

    // ... all 22 GDPR controls
}
```

**Usage:**
```java
import com.compliance.annotations.GDPRControls;

@GDPREvidence(control = GDPRControls.Art_15)  // IDE autocompletes!
public UserData exportUserData(String userId) {
    // Your code
}
```

**In your IDE:**
- Type `GDPRControls.` and get autocomplete with all 22 controls
- Hover over any control to see full documentation
- Cmd+Click (Mac) or Ctrl+Click (Win/Linux) to jump to definition

---

## Control Models

### GDPRControl.java

**Enum of all GDPR controls with metadata.**

```java
package com.compliance.models;

import java.util.*;

public enum GDPRControl {
    Art_51a("Art.5(1)(a)", "Lawfulness, Fairness and Transparency", "Principles", RiskLevel.HIGH),
    Art_51f("Art.5(1)(f)", "Integrity and Confidentiality", "Principles", RiskLevel.CRITICAL),
    Art_15("Art.15", "Right of Access", "Data Subject Rights", RiskLevel.HIGH),
    Art_17("Art.17", "Right to Erasure", "Data Subject Rights", RiskLevel.HIGH),
    // ... all 22 controls

    private final String id;
    private final String name;
    private final String category;
    private final RiskLevel riskLevel;

    GDPRControl(String id, String name, String category, RiskLevel riskLevel) {
        this.id = id;
        this.name = name;
        this.category = category;
        this.riskLevel = riskLevel;
    }

    public String getId() { return id; }
    public String getName() { return name; }
    public String getCategory() { return category; }
    public RiskLevel getRiskLevel() { return riskLevel; }

    // Find control by ID
    public static GDPRControl fromId(String id) {
        for (GDPRControl control : values()) {
            if (control.id.equals(id)) return control;
        }
        throw new IllegalArgumentException("Unknown control ID: " + id);
    }

    // Get controls by category
    public static List<GDPRControl> getByCategory(String category) {
        // ...
    }

    // Get controls by risk level
    public static List<GDPRControl> getByRiskLevel(RiskLevel riskLevel) {
        // ...
    }

    public enum RiskLevel {
        LOW, MEDIUM, HIGH, CRITICAL
    }
}
```

**Usage:**
```java
// Programmatic access to control metadata
GDPRControl control = GDPRControl.Art_51f;
System.out.println(control.getName());      // "Integrity and Confidentiality"
System.out.println(control.getRiskLevel()); // CRITICAL

// Get all high-risk controls
List<GDPRControl> highRisk = GDPRControl.getByRiskLevel(RiskLevel.HIGH);

// Get all controls in a category
List<GDPRControl> rights = GDPRControl.getByCategory("Data Subject Rights");
```

---

### GDPR_Art_51f.java

**Detailed model for Art.5(1)(f) - Integrity and Confidentiality.**

```java
package com.compliance.models;

import java.util.*;

/**
 * <h2>Integrity and Confidentiality</h2>
 *
 * <p><b>Control ID:</b> Art.5(1)(f)</p>
 * <p><b>Framework:</b> gdpr</p>
 * <p><b>Category:</b> Principles</p>
 * <p><b>Risk Level:</b> critical</p>
 *
 * <h3>Description</h3>
 * <p>Personal data shall be processed in a manner that ensures appropriate
 * security of the personal data, including protection against unauthorised
 * or unlawful processing and against accidental loss, destruction or damage,
 * using appropriate technical or organisational measures.</p>
 *
 * <h3>Requirements</h3>
 * <ul>
 * <li>Encryption of personal data at rest</li>
 * <li>Encryption of personal data in transit</li>
 * <li>Access controls for personal data</li>
 * <li>Data breach detection and response</li>
 * <li>Regular security assessments</li>
 * </ul>
 *
 * <h3>Implementation Guidance</h3>
 * <p>Use industry-standard encryption (AES-256 for data at rest, TLS 1.3
 * for data in transit). Implement role-based access controls. Deploy
 * intrusion detection systems. Conduct regular security audits and
 * penetration testing.</p>
 *
 * <h3>Testing Procedures</h3>
 * <ul>
 * <li>Verify encryption at rest using database inspection</li>
 * <li>Verify TLS configuration with sslyze or similar tools</li>
 * <li>Test access controls with different user roles</li>
 * <li>Simulate data breaches to test detection</li>
 * <li>Review security assessment reports</li>
 * </ul>
 */
public final class GDPR_Art_51f implements ComplianceControl {
    public static final String ID = "Art.5(1)(f)";
    public static final String NAME = "Integrity and Confidentiality";
    public static final String CATEGORY = "Principles";
    public static final String RISK_LEVEL = "critical";

    public static final List<String> REQUIREMENTS = List.of(
        "Encryption of personal data at rest",
        "Encryption of personal data in transit",
        "Access controls for personal data",
        "Data breach detection and response",
        "Regular security assessments"
    );

    public static final List<String> EVIDENCE_TYPES = List.of(
        "config", "audit_trail", "test", "scan"
    );

    private GDPR_Art_51f() {}

    @Override
    public String getId() { return ID; }

    @Override
    public String getName() { return NAME; }

    @Override
    public String getCategory() { return CATEGORY; }

    @Override
    public String getDescription() {
        return """
            Personal data shall be processed in a manner that ensures
            appropriate security of the personal data...
            """;
    }

    @Override
    public String getRiskLevel() { return RISK_LEVEL; }

    @Override
    public List<String> getRequirements() { return REQUIREMENTS; }

    @Override
    public List<String> getEvidenceTypes() { return EVIDENCE_TYPES; }

    public static String getImplementationGuidance() {
        return """
            Use industry-standard encryption (AES-256 for data at rest,
            TLS 1.3 for data in transit)...
            """;
    }

    public static List<String> getTestingProcedures() {
        return List.of(
            "Verify encryption at rest using database inspection",
            "Verify TLS configuration with sslyze",
            "Test access controls with different user roles",
            "Simulate data breaches to test detection",
            "Review security assessment reports"
        );
    }
}
```

**Usage:**
```java
// Access control metadata programmatically
System.out.println(GDPR_Art_51f.NAME);
System.out.println(GDPR_Art_51f.RISK_LEVEL);

for (String req : GDPR_Art_51f.REQUIREMENTS) {
    System.out.println("- " + req);
}

String guidance = GDPR_Art_51f.getImplementationGuidance();
List<String> tests = GDPR_Art_51f.getTestingProcedures();
```

---

## All Frameworks

The same structure is generated for all 6 frameworks:

- **GDPR**: 22 controls (Art.5, Art.15, Art.17, etc.)
- **SOC 2**: 8 controls (CC6.1, CC7.2, etc.)
- **HIPAA**: 11 controls (§164.312(a)(1), §164.308(a)(1)(i), etc.)
- **FedRAMP**: 16 controls (AC-2, AU-2, IA-2, etc.)
- **ISO 27001**: 14 controls (A.9.2.1, A.10.1.1, etc.)
- **PCI-DSS**: 24 controls (3.4, 4.1, 8.1, etc.)

Each framework gets:
- `{Framework}Evidence` annotation
- `{Framework}Controls` constants
- `{Framework}Control` enum
- `{Framework}_{ControlId}` detailed models

---

## Summary

Generated code provides:

1. **Evidence Infrastructure** - Immutable spans, redaction, PII handling
2. **Type-Safe Annotations** - IDE autocomplete for control IDs
3. **Control Metadata** - Requirements, guidance, testing procedures
4. **Compile-Time Validation** - Invalid control IDs fail at compile time
5. **Full Documentation** - Javadoc with control details

**No runtime dependencies** - Pure Java annotations and classes.
**Framework agnostic** - Works in any Java environment.
**IDE friendly** - Full autocomplete and navigation support.