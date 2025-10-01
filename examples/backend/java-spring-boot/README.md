# Spring Boot with Compliance Evidence

This example shows how to integrate compliance evidence into a Spring Boot REST API using **annotation-based evidence capture**.

## Why Annotations?

Java's annotation system with Spring Boot allows:
1. Declarative compliance marking
2. Aspect-Oriented Programming (AOP) for evidence
3. Zero business logic changes
4. Framework integration

## Controls Demonstrated

- **GDPR Art.5(1)(f)**: Integrity and Confidentiality
- **GDPR Art.15**: Right of Access
- **GDPR Art.17**: Right to Erasure
- **SOC 2 CC6.1**: Logical Access - Authorization
- **HIPAA §164.312(a)(1)**: Access Control

## Example: REST Controller with Evidence

```java
package com.example.compliance;

import com.compliance.annotations.*;
import com.compliance.model.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    // Get user data - implements GDPR Right of Access
    @GetMapping("/{id}")
    @GDPREvidence(
        control = GDPRControls.Art_15,
        evidenceType = EvidenceType.AUDIT_TRAIL,
        description = "Retrieve user personal data"
    )
    public User getUser(@PathVariable String id) {
        return userService.findById(id);
    }

    // Delete user - implements GDPR Right to Erasure
    @DeleteMapping("/{id}")
    @GDPREvidence(
        control = GDPRControls.Art_17,
        evidenceType = EvidenceType.AUDIT_TRAIL,
        description = "Delete all user personal data"
    )
    public void deleteUser(@PathVariable String id) {
        userService.deleteAllData(id);
    }

    // Create user - multiple controls
    @PostMapping
    @GDPREvidence(
        control = GDPRControls.Art_51f,
        evidenceType = EvidenceType.AUDIT_TRAIL,
        description = "Create user with security measures"
    )
    @SOC2Evidence(
        control = SOC2Controls.CC6_1,
        evidenceType = EvidenceType.AUDIT_TRAIL,
        description = "Authorization check for user creation"
    )
    public User createUser(
        @RequestBody @Validated CreateUserRequest request,
        @RequestHeader("Authorization") String token
    ) {
        // Authorization happens here
        // Evidence captured automatically
        return userService.create(request);
    }

    // Update user - with data redaction
    @PutMapping("/{id}")
    @GDPREvidence(
        control = GDPRControls.Art_51f,
        evidenceType = EvidenceType.AUDIT_TRAIL
    )
    public User updateUser(
        @PathVariable String id,
        @RequestBody UpdateUserRequest request
    ) {
        // Sensitive fields automatically redacted in evidence
        return userService.update(id, request);
    }

    // Export user data - GDPR data portability
    @GetMapping("/{id}/export")
    @GDPREvidence(
        control = GDPRControls.Art_20,
        evidenceType = EvidenceType.AUDIT_TRAIL,
        description = "Export user data in portable format"
    )
    public DataExport exportUserData(@PathVariable String id) {
        return userService.exportData(id);
    }
}
```

## Service Layer with Evidence

```java
@Service
public class UserService {

    @GDPREvidence(
        control = GDPRControls.Art_15,
        evidenceType = EvidenceType.AUDIT_TRAIL
    )
    public User findById(String id) {
        return userRepository.findById(id)
            .orElseThrow(() -> new UserNotFoundException(id));
    }

    @GDPREvidence(
        control = GDPRControls.Art_17,
        evidenceType = EvidenceType.AUDIT_TRAIL
    )
    @Transactional
    public void deleteAllData(String userId) {
        // Delete from all tables
        userRepository.deleteById(userId);
        ordersRepository.deleteByUserId(userId);
        sessionsRepository.deleteByUserId(userId);
        auditLogRepository.deleteByUserId(userId);
    }

    @HIPAAEvidence(
        control = HIPAAControls.S164_312_a_1,
        evidenceType = EvidenceType.ACCESS_CONTROL
    )
    public boolean checkAccess(String userId, String resourceId) {
        return authorizationService.hasAccess(userId, resourceId);
    }
}
```

## Evidence Emitted

### GET /api/users/123 (GDPR Art.15)

```json
{
  "name": "compliance.evidence",
  "timestamp": "2025-09-30T12:00:00Z",
  "attributes": {
    "compliance.framework": "gdpr",
    "compliance.control": "Art.15",
    "compliance.evidence_type": "audit_trail",
    "compliance.description": "Retrieve user personal data",
    "input.userId": "123",
    "output.email": "user@example.com",
    "output.name": "John Doe",
    "compliance.result": "success",
    "compliance.duration_ms": 45,
    "http.method": "GET",
    "http.url": "/api/users/123",
    "http.status_code": 200,
    "spring.bean": "UserController",
    "spring.method": "getUser"
  }
}
```

### DELETE /api/users/123 (GDPR Art.17)

```json
{
  "name": "compliance.evidence",
  "timestamp": "2025-09-30T12:00:30Z",
  "attributes": {
    "compliance.framework": "gdpr",
    "compliance.control": "Art.17",
    "input.userId": "123",
    "output.deletedRecords": 47,
    "output.tablesCleared": 4,
    "compliance.result": "success",
    "compliance.duration_ms": 523,
    "http.method": "DELETE"
  }
}
```

## AOP Aspect for Evidence Capture

```java
@Aspect
@Component
public class ComplianceEvidenceAspect {

    @Autowired
    private OpenTelemetryTracer tracer;

    @Around("@annotation(gdprEvidence)")
    public Object captureGDPREvidence(
        ProceedingJoinPoint joinPoint,
        GDPREvidence gdprEvidence
    ) throws Throwable {

        Span span = tracer.spanBuilder("compliance.evidence")
            .setAttribute("compliance.framework", "gdpr")
            .setAttribute("compliance.control", gdprEvidence.control().toString())
            .setAttribute("compliance.evidence_type", gdprEvidence.evidenceType().toString())
            .startSpan();

        try (Scope scope = span.makeCurrent()) {
            // Record inputs
            recordInputs(span, joinPoint);

            // Execute method
            long start = System.currentTimeMillis();
            Object result = joinPoint.proceed();
            long duration = System.currentTimeMillis() - start;

            // Record outputs
            recordOutputs(span, result);
            span.setAttribute("compliance.duration_ms", duration);
            span.setAttribute("compliance.result", "success");

            return result;
        } catch (Exception e) {
            span.setAttribute("compliance.result", "failure");
            span.setAttribute("compliance.error", e.getMessage());
            span.recordException(e);
            throw e;
        } finally {
            span.end();
        }
    }

    private void recordInputs(Span span, ProceedingJoinPoint joinPoint) {
        Object[] args = joinPoint.getArgs();
        String[] paramNames = getParameterNames(joinPoint);

        for (int i = 0; i < args.length; i++) {
            if (!shouldRedact(paramNames[i])) {
                span.setAttribute("input." + paramNames[i], String.valueOf(args[i]));
            }
        }
    }
}
```

## Configuration

```java
@Configuration
@EnableAspectJAutoProxy
public class ComplianceConfig {

    @Bean
    public ComplianceEvidenceAspect complianceAspect() {
        return new ComplianceEvidenceAspect();
    }

    @Bean
    public OpenTelemetry openTelemetry() {
        return GlobalOpenTelemetry.get();
    }
}
```

## Application Properties

```properties
# OpenTelemetry configuration
otel.service.name=compliance-spring-boot-example
otel.exporter.otlp.endpoint=http://localhost:4318
otel.traces.exporter=otlp
otel.metrics.exporter=none

# Enable compliance evidence
compliance.evidence.enabled=true
compliance.evidence.frameworks=gdpr,soc2,hipaa

# Redaction patterns
compliance.evidence.redact.patterns=password,ssn,creditCard,token,apiKey
