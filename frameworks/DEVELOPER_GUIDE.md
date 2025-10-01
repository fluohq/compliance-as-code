# Compliance Evidence: Developer Guide

## What You Need To Do

As a developer, you **annotate methods that handle sensitive operations** with evidence annotations. The system automatically captures inputs, outputs, and side effects while protecting sensitive data.

---

## Step 1: Generate Compliance Code

```bash
cd compliance-as-code/frameworks/generators

# Generate for your language
nix build .#java-gdpr        # Java + GDPR
nix build .#java-soc2        # Java + SOC 2
nix build .#all-java         # Java + All frameworks

# Generated code is in ./result/
```

## Step 2: Copy Generated Code to Your Project

```bash
# Java: Copy to your source directory
cp -r result/src/main/java/com/compliance/ your-project/src/main/java/

# This gives you:
# - com.compliance.annotations.*  (control IDs and evidence annotations)
# - com.compliance.evidence.*     (redaction annotations and span classes)
# - com.compliance.models.*       (control metadata)
```

## Step 3: Annotate Your Methods

### Example 1: User Registration (GDPR)

**What you need to do:**
1. Add `@GDPREvidence` annotation to the method
2. Specify which control this evidence is for
3. Mark sensitive parameters with `@Redact`

```java
import com.compliance.annotations.GDPREvidence;
import com.compliance.annotations.GDPRControls;
import com.compliance.evidence.*;

public class UserService {

    /**
     * Registers a new user with encrypted password.
     *
     * DEVELOPER: Just add the annotation - evidence is captured automatically!
     */
    @GDPREvidence(
        control = GDPRControls.Art_51f,  // Integrity and Confidentiality
        evidenceType = EvidenceType.AUDIT_TRAIL
    )
    public User registerUser(
        String email,
        @Redact String password  // ← Mark sensitive data - won't appear in evidence
    ) {
        // YOUR NORMAL CODE - no changes needed!
        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
        User user = new User(email, hashedPassword);
        userRepository.save(user);

        // Evidence automatically captured:
        // ✓ Timestamp, trace ID, span ID
        // ✓ Input: email = "user@example.com"
        // ✗ Input: password = <redacted>
        // ✓ Output: User{id="usr_123", email="user@example.com"}
        // ✓ Duration: 87ms
        // ✓ Side effect: userRepository.save()

        return user;
    }
}
```

**What gets captured as evidence:**
```json
{
  "timestamp": "2025-09-30T01:23:45Z",
  "traceId": "abc123...",
  "framework": "gdpr",
  "control": "Art.5(1)(f)",
  "evidenceType": "audit_trail",
  "result": "success",
  "duration": "87ms",
  "attributes": {
    "input.email": "user@example.com",
    "input.password": "<redacted>",
    "output.userId": "usr_123",
    "output.email": "user@example.com",
    "sideEffects": ["userRepository.save(User)"]
  }
}
```

---

### Example 2: Payment Processing (PCI-DSS)

**What you need to do:**
1. Annotate the payment method
2. Use `@Redact(strategy = TRUNCATE)` to show partial credit card numbers
3. Your payment code stays the same

```java
import com.compliance.annotations.PCIDSSEvidence;
import com.compliance.annotations.PCIDSSControls;
import com.compliance.evidence.*;

public class PaymentService {

    @PCIDSSEvidence(
        control = PCIDSSControls._3_4,  // Encryption at Rest
        evidenceType = EvidenceType.AUDIT_TRAIL
    )
    public PaymentResult processPayment(
        String userId,
        @Redact(strategy = RedactionStrategy.TRUNCATE, preserve = 4)
        String creditCardNumber,  // Shows "1234...6789" in evidence

        @Redact String cvv,       // Never shown

        double amount
    ) {
        // YOUR NORMAL PAYMENT CODE
        String encryptedCard = encryptionService.encrypt(creditCardNumber);
        PaymentResult result = paymentGateway.charge(encryptedCard, amount);

        if (result.success) {
            transactionRepository.save(new Transaction(userId, amount));
        }

        return result;

        // Evidence captured:
        // ✓ Input: userId = "usr_456"
        // ✓ Input: creditCardNumber = "1234...6789"  ← Truncated for safety
        // ✗ Input: cvv = <redacted>
        // ✓ Input: amount = 99.99
        // ✓ Output: PaymentResult{success=true, transactionId="txn_789"}
        // ✓ Side effects: encryptionService.encrypt(), paymentGateway.charge()
    }
}
```

---

### Example 3: Healthcare Data Access (HIPAA)

**What you need to do:**
1. Annotate methods that access protected health information (PHI)
2. Mark PHI fields with `@PII` for hashed capture
3. Your data access code doesn't change

```java
import com.compliance.annotations.HIPAAEvidence;
import com.compliance.annotations.HIPAAControls;
import com.compliance.evidence.*;

public class HealthRecordService {

    @HIPAAEvidence(
        control = HIPAAControls._164_312a1,  // Access Control
        evidenceType = EvidenceType.AUDIT_TRAIL
    )
    public HealthRecord getPatientRecord(
        String patientId,
        String requestedBy,  // Who's accessing the record
        String reason
    ) {
        // YOUR NORMAL CODE - just query the database
        HealthRecord record = healthRecordRepository.findById(patientId);

        // Log access for audit
        auditLog.logAccess(patientId, requestedBy, reason);

        return record;

        // Evidence captured:
        // ✓ Input: patientId = "pat_123"
        // ✓ Input: requestedBy = "dr_smith@hospital.com"
        // ✓ Input: reason = "routine checkup"
        // ✓ Output: HealthRecord{id="pat_123", ...}
        // ✓ Side effects: healthRecordRepository.findById(), auditLog.logAccess()
        // ✓ Proves: Access control was enforced
    }
}
```

---

### Example 4: Right to Erasure (GDPR Article 17)

**What you need to do:**
1. Annotate the deletion method
2. Evidence proves the deletion happened
3. Your deletion logic stays the same

```java
public class UserDeletionService {

    @GDPREvidence(
        control = GDPRControls.Art_17,  // Right to Erasure
        evidenceType = EvidenceType.AUDIT_TRAIL,
        notes = "Complete user data deletion per GDPR Article 17"
    )
    public DeletionReport deleteUserData(
        String userId,
        String requestReason,
        String requestedBy
    ) {
        // YOUR DELETION CODE
        int deletedRecords = 0;

        // Delete from all tables
        deletedRecords += userRepository.deleteById(userId);
        deletedRecords += orderRepository.deleteByUserId(userId);
        deletedRecords += activityLogRepository.deleteByUserId(userId);
        deletedRecords += sessionRepository.deleteByUserId(userId);

        // Create deletion report
        DeletionReport report = new DeletionReport(
            userId,
            deletedRecords,
            Instant.now(),
            requestReason,
            requestedBy
        );

        // Store deletion record (for compliance, ironically)
        deletionLogRepository.save(report);

        return report;

        // Evidence captured:
        // ✓ Input: userId = "usr_789"
        // ✓ Input: requestReason = "User requested account deletion"
        // ✓ Input: requestedBy = "usr_789@example.com"
        // ✓ Output: DeletionReport{deletedRecords=47, timestamp="..."}
        // ✓ Side effects: 4x delete operations, 1x save operation
        // ✓ Proves: Complete deletion occurred within 72 hours of request
    }
}
```

---

### Example 5: Class-Level Sensitive Data

**What you need to do:**
1. Annotate sensitive fields in your data classes
2. Evidence system respects these annotations
3. No other changes needed

```java
public class User {
    // Public data - captured in evidence
    public String id;
    public String email;
    public Instant createdAt;

    // SENSITIVE: Never captured
    @Sensitive
    public String passwordHash;

    @Sensitive
    public String apiKey;

    // PII: Captured as hash for correlation
    @PII
    public String ssn;

    @PII
    public String phoneNumber;

    // Partial data: Shows first/last 4 chars
    @Redact(strategy = RedactionStrategy.TRUNCATE, preserve = 4)
    public String creditCard;
}

// When this User is returned from an evidence-annotated method:
// Evidence contains:
// {
//   "id": "usr_123",
//   "email": "user@example.com",
//   "createdAt": "2025-09-30T00:00:00Z",
//   "passwordHash": "<excluded>",
//   "apiKey": "<excluded>",
//   "ssn": "sha256:abc123...",  ← Hashed
//   "phoneNumber": "sha256:def456...",  ← Hashed
//   "creditCard": "1234...6789"  ← Truncated
// }
```

---

### Example 6: Multi-Framework Compliance

**What you need to do:**
1. Stack annotations for multiple frameworks
2. Same method, multiple compliance controls
3. Single implementation proves compliance for all

```java
import com.compliance.annotations.*;
import com.compliance.evidence.*;

public class SecurityService {

    @GDPREvidence(control = GDPRControls.Art_32, evidenceType = EvidenceType.AUDIT_TRAIL)
    @HIPAAEvidence(control = HIPAAControls._164_312a1, evidenceType = EvidenceType.AUDIT_TRAIL)
    @SOC2Evidence(control = SOC2Controls.CC6_1, evidenceType = EvidenceType.AUDIT_TRAIL)
    public LoginResult authenticateUser(
        String username,
        @Redact String password,
        String ipAddress,
        String userAgent
    ) {
        // YOUR NORMAL AUTHENTICATION CODE
        User user = userRepository.findByUsername(username);

        if (user == null || !passwordEncoder.matches(password, user.passwordHash)) {
            auditLog.logFailedLogin(username, ipAddress);
            return LoginResult.failure("Invalid credentials");
        }

        String sessionToken = tokenService.createSession(user.id);
        auditLog.logSuccessfulLogin(user.id, ipAddress);

        return LoginResult.success(sessionToken);

        // THREE evidence spans emitted (one per framework):
        // 1. GDPR Art.32 evidence (security of processing)
        // 2. HIPAA §164.312(a)(1) evidence (access control)
        // 3. SOC 2 CC6.1 evidence (logical access controls)
        //
        // Each contains:
        // ✓ username, ipAddress, userAgent
        // ✗ password (redacted)
        // ✓ result: success or failure
        // ✓ side effects: database queries, session creation, audit logging
    }
}
```

---

## Common Redaction Patterns

### 1. Passwords and Secrets
```java
public void method(
    @Redact String password,      // Default: EXCLUDE
    @Sensitive String apiKey       // Same as @Redact
) { }
```

### 2. Personal Identifiable Information
```java
public void method(
    @PII String ssn,               // Default: HASH
    @PII String email              // Hashed for correlation
) { }
```

### 3. Partial Data (Credit Cards, Phone Numbers)
```java
public void method(
    @Redact(strategy = RedactionStrategy.TRUNCATE, preserve = 4)
    String creditCard,             // Shows "1234...6789"

    @Redact(strategy = RedactionStrategy.TRUNCATE, preserve = 3)
    String phoneNumber             // Shows "555...7890"
) { }
```

### 4. Hashing for Correlation
```java
public void method(
    @Redact(strategy = RedactionStrategy.HASH)
    String userId,                 // "sha256:abc123..."

    @Redact(strategy = RedactionStrategy.HASH)
    String sessionId               // Can correlate without exposing
) { }
```

---

## What Happens Automatically

### 1. Method Execution
```java
@GDPREvidence(control = GDPRControls.Art_51f)
public Result method(String input, @Redact String secret) {
    // Your code runs normally
    return result;
}
```

### 2. Evidence Capture (Automatic)
- Start time recorded
- Trace ID generated (or inherited from current trace)
- Span ID generated
- Method inputs captured (respecting @Redact annotations)
- Your method executes
- Method output captured (respecting @Redact annotations)
- Side effects tracked (database calls, HTTP requests)
- End time recorded
- Duration calculated

### 3. Evidence Emission (Automatic)
- Immutable `ComplianceSpan` object created
- Emitted as OpenTelemetry span with attributes:
  ```
  compliance.framework = "gdpr"
  compliance.control = "Art.5(1)(f)"
  compliance.evidence_type = "audit_trail"
  compliance.result = "success"
  span.kind = "internal"
  ```
- Sent to OTLP endpoint (Grafana, Jaeger, etc.)
- Stored in time-series database
- Available for auditing and reporting

---

## Viewing Evidence

### In Grafana
```promql
# All evidence for a control
{compliance.control="Art.5(1)(f)"}

# Failed operations
{compliance.result="failure"}

# Evidence for a specific user
{compliance.user_id="user@example.com"}

# High-risk controls
{compliance.risk_level="critical"}
```

### In Jaeger
Search for traces with:
- Tag: `compliance.framework=gdpr`
- Tag: `compliance.control=Art.5(1)(f)`
- Tag: `compliance.result=success`

---

## Testing Your Evidence

### 1. Call your method normally
```java
User user = userService.registerUser("test@example.com", "secretPassword");
```

### 2. Evidence is emitted automatically
Check your OpenTelemetry collector logs or Grafana:

```bash
# Check OTLP collector
curl http://localhost:4317/traces | jq '.spans[] | select(.attributes["compliance.framework"] == "gdpr")'
```

### 3. Verify redaction worked
```bash
# Should NOT contain the password
curl http://localhost:4317/traces | grep "secretPassword"
# (no results = redaction worked!)

# Should contain the email
curl http://localhost:4317/traces | grep "test@example.com"
# (found = capture worked!)
```

---

## IDE Support

Your IDE will autocomplete control IDs:

```java
@GDPREvidence(
    control = GDPRControls.  // ← IDE shows all 22 GDPR controls
    //                          Art_51a - Lawfulness, Fairness, Transparency
    //                          Art_51f - Integrity and Confidentiality
    //                          Art_15 - Right of Access
    //                          Art_17 - Right to Erasure
    //                          ...
)
```

Hover over a control to see:
- Control name and description
- Requirements
- Implementation guidance
- Testing procedures
- Risk level

---

## Summary: What You Actually Do

1. **Generate code** - `nix build .#java-gdpr`
2. **Copy to project** - `cp -r result/src/main/java/com/compliance/ your-project/`
3. **Annotate methods** - Add `@GDPREvidence(control = ...)` to sensitive methods
4. **Mark sensitive data** - Add `@Redact` to passwords, secrets, PII
5. **Deploy normally** - Evidence is automatically captured and emitted
6. **View in Grafana** - Query spans by `compliance.control` or `compliance.framework`

**That's it!** Your code doesn't change - you just add annotations. Evidence collection happens automatically.