{ schema }:

let
  inherit (schema) mkControl evidenceTypes riskLevels technicalControlTypes patterns;

  # FedRAMP Moderate Baseline Controls (subset of NIST 800-53)
  # Access Control Family (AC)
  accessControl = {
    ac_2 = mkControl {
      id = "AC-2";
      name = "Account Management";
      category = "Access Control";
      description = ''
        The organization manages information system accounts, including:
        identifying account types, establishing conditions for group membership,
        specifying authorized users, requiring approvals, creating/enabling/
        modifying/disabling accounts, monitoring account use, and removing
        accounts when no longer required.
      '';
      requirements = [
        "Identify and document account types"
        "Assign account managers"
        "Establish group and role membership conditions"
        "Specify authorized users and approval procedures"
        "Monitor account use"
        "Remove or disable accounts within timeframe"
        "Audit account creation, modification, and deletion"
      ];
      evidenceTypes = [
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.CONFIG
        evidenceTypes.LOG
        evidenceTypes.DOCUMENTATION
      ];
      implementationGuidance = ''
        Implement automated account lifecycle management.
        Use identity providers (SSO/SAML) for centralized control.
        Regular automated account reviews (quarterly).
        Disable inactive accounts automatically (90 days).
        Log all account management operations.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.ACCESS_CONTROL
        technicalControlTypes.AUTHENTICATION
        technicalControlTypes.LOGGING
      ];
      mappings = {
        soc2 = [ "CC6.1" "CC6.2" "CC6.3" ];
        hipaa = [ "164.308(a)(3)(ii)(B)" "164.308(a)(3)(ii)(C)" "164.312(a)(2)(i)" ];
        iso27001 = [ "A.9.2.1" "A.9.2.2" "A.9.2.6" ];
        pcidss = [ "8.1" "8.2" ];
      };
      testingProcedures = [
        "Review account types and documentation"
        "Verify approval procedures"
        "Test automated account lifecycle"
        "Review inactive account reports"
      ];
      patterns = [
        patterns.POLICY
        patterns.INTERCEPTOR
      ];
      metadata = {
        tags = [ "technical" "access-control" ];
        automatable = true;
        priority = "high";
        baseline = "moderate";
      };
    };

    ac_3 = mkControl {
      id = "AC-3";
      name = "Access Enforcement";
      category = "Access Control";
      description = ''
        The information system enforces approved authorizations for logical
        access to information and system resources in accordance with applicable
        access control policies.
      '';
      requirements = [
        "Implement access control policies (e.g., RBAC, ABAC)"
        "Enforce least privilege"
        "Enforce separation of duties"
        "Deny by default"
        "Log access decisions"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.CODE_REVIEW
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.TEST
      ];
      implementationGuidance = ''
        Implement RBAC with tenant isolation.
        All access decisions must be explicit (no implicit grants).
        Log all authorization decisions with context.
        Use policy engines for complex authorization rules.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.AUTHORIZATION
        technicalControlTypes.ACCESS_CONTROL
        technicalControlTypes.LOGGING
      ];
      mappings = {
        soc2 = [ "CC6.1" ];
        hipaa = [ "164.312(a)(1)" ];
        iso27001 = [ "A.9.4.1" ];
        pcidss = [ "7.1" ];
      };
      testingProcedures = [
        "Test unauthorized access attempts"
        "Verify least privilege enforcement"
        "Review access decision logs"
      ];
      patterns = [
        patterns.INTERCEPTOR
        patterns.POLICY
        patterns.MIDDLEWARE
      ];
      validations = [
        "All resources deny access by default"
        "Authorization is enforced for every request"
        "Access decisions are logged"
      ];
      metadata = {
        tags = [ "technical" "access-control" ];
        automatable = true;
        priority = "high";
        baseline = "moderate";
      };
    };

    ac_11 = mkControl {
      id = "AC-11";
      name = "Session Lock";
      category = "Access Control";
      description = ''
        The information system prevents further access by initiating a session
        lock after a defined period of inactivity, or upon receiving a request
        from a user, and retains the session lock until the user reestablishes
        access using established identification and authentication procedures.
      '';
      requirements = [
        "Session timeout after 15 minutes of inactivity"
        "User-initiated session lock"
        "Re-authentication required to unlock"
        "Session lock notifications"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.TEST
        evidenceTypes.LOG
      ];
      implementationGuidance = ''
        Implement JWT with short expiration times (15 minutes).
        Refresh tokens with 7-day expiration.
        Log session timeout events.
        Display timeout warnings to users.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.AUTHENTICATION
        technicalControlTypes.ACCESS_CONTROL
      ];
      mappings = {
        hipaa = [ "164.312(a)(2)(iii)" ];
        iso27001 = [ "A.9.1.2" ];
      };
      testingProcedures = [
        "Test session timeout"
        "Verify re-authentication requirement"
        "Review timeout configuration"
      ];
      patterns = [
        patterns.MIDDLEWARE
        patterns.INTERCEPTOR
      ];
      metadata = {
        tags = [ "technical" "access-control" ];
        automatable = true;
        baseline = "moderate";
      };
    };
  };

  # Audit and Accountability Family (AU)
  auditAccountability = {
    au_2 = mkControl {
      id = "AU-2";
      name = "Audit Events";
      category = "Audit and Accountability";
      description = ''
        The organization determines that the information system is capable of
        auditing specified events and coordinates the security audit function
        with other organizational entities requiring audit-related information.
      '';
      requirements = [
        "Define auditable events"
        "Coordinate audit requirements across organization"
        "Audit successful/unsuccessful account logon events"
        "Audit account management events"
        "Audit object access"
        "Audit policy changes"
        "Audit privilege functions"
        "Audit system events"
      ];
      evidenceTypes = [
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.LOG
        evidenceTypes.DOCUMENTATION
      ];
      implementationGuidance = ''
        Use OpenTelemetry for comprehensive event tracking.
        Define security-relevant events in system design.
        Implement distributed tracing across services.
        Include tenant context in all audit events.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.LOGGING
        technicalControlTypes.MONITORING
      ];
      mappings = {
        soc2 = [ "CC7.1" ];
        hipaa = [ "164.312(b)" ];
        iso27001 = [ "A.12.4.1" ];
        pcidss = [ "10.2" ];
      };
      testingProcedures = [
        "Review list of auditable events"
        "Verify all required events are logged"
        "Test audit log completeness"
      ];
      patterns = [
        patterns.INTERCEPTOR
        patterns.ASPECT
      ];
      metadata = {
        tags = [ "technical" "logging" ];
        automatable = true;
        priority = "high";
        baseline = "moderate";
      };
    };

    au_3 = mkControl {
      id = "AU-3";
      name = "Content of Audit Records";
      category = "Audit and Accountability";
      description = ''
        The information system generates audit records containing information
        that establishes what type of event occurred, when the event occurred,
        where the event occurred, the source of the event, the outcome of the
        event, and the identity of any individuals or subjects associated with
        the event.
      '';
      requirements = [
        "Record event type"
        "Record timestamp"
        "Record event source"
        "Record outcome (success/failure)"
        "Record user/subject identity"
        "Record additional detail as needed"
      ];
      evidenceTypes = [
        evidenceTypes.LOG
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Use structured logging (JSON format).
        Include standard fields: timestamp, user_id, tenant_id, action, outcome, source_ip.
        Use OpenTelemetry span attributes for rich context.
        Include trace_id for correlation.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.LOGGING
      ];
      mappings = {
        soc2 = [ "CC7.1" ];
        hipaa = [ "164.312(b)" ];
        iso27001 = [ "A.12.4.1" ];
        pcidss = [ "10.3" ];
      };
      testingProcedures = [
        "Review sample audit records"
        "Verify all required fields present"
        "Test log format compliance"
      ];
      patterns = [
        patterns.INTERCEPTOR
        patterns.DECORATOR
      ];
      metadata = {
        tags = [ "technical" "logging" ];
        automatable = true;
        priority = "high";
        baseline = "moderate";
      };
    };

    au_6 = mkControl {
      id = "AU-6";
      name = "Audit Review, Analysis, and Reporting";
      category = "Audit and Accountability";
      description = ''
        The organization reviews and analyzes information system audit records
        weekly for indications of inappropriate or unusual activity, investigates
        suspicious activity or suspected violations, and reports findings to
        designated organizational officials.
      '';
      requirements = [
        "Review audit logs weekly"
        "Analyze for anomalies"
        "Investigate suspicious activity"
        "Report findings to security team"
        "Document review procedures"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.METRIC
      ];
      implementationGuidance = ''
        Implement automated log analysis with SIEM.
        Use ML for anomaly detection.
        Create Grafana dashboards for log visualization.
        Automated alerting for suspicious patterns.
        Weekly review reports sent to security team.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.MONITORING
        technicalControlTypes.LOGGING
        technicalControlTypes.INCIDENT_RESPONSE
      ];
      mappings = {
        soc2 = [ "CC7.1" "CC7.2" ];
        hipaa = [ "164.308(a)(1)(ii)(D)" ];
        iso27001 = [ "A.12.4.1" ];
        pcidss = [ "10.6" ];
      };
      testingProcedures = [
        "Review log analysis procedures"
        "Verify review frequency"
        "Test automated alerting"
      ];
      patterns = [
        patterns.ASPECT
      ];
      metadata = {
        tags = [ "administrative" "monitoring" ];
        automatable = true;
        baseline = "moderate";
      };
    };
  };

  # Identification and Authentication Family (IA)
  identificationAuthentication = {
    ia_2 = mkControl {
      id = "IA-2";
      name = "Identification and Authentication";
      category = "Identification and Authentication";
      description = ''
        The information system uniquely identifies and authenticates
        organizational users (or processes acting on behalf of organizational
        users).
      '';
      requirements = [
        "Unique user identification"
        "Authentication before access"
        "Multi-factor authentication for privileged accounts"
        "MFA for remote access"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.LOG
      ];
      implementationGuidance = ''
        Integrate with enterprise IdP (WorkOS, Auth0, Okta).
        Enforce MFA for all users (not just privileged).
        Use OAuth 2.0 / OpenID Connect.
        Log all authentication attempts.
      '';
      riskLevel = riskLevels.CRITICAL;
      technicalControls = [
        technicalControlTypes.AUTHENTICATION
      ];
      mappings = {
        soc2 = [ "CC6.1" ];
        hipaa = [ "164.312(a)(2)(i)" "164.312(d)" ];
        iso27001 = [ "A.9.2.1" ];
        pcidss = [ "8.2" ];
      };
      testingProcedures = [
        "Verify MFA enforcement"
        "Test authentication flows"
        "Review authentication logs"
      ];
      patterns = [
        patterns.MIDDLEWARE
        patterns.INTERCEPTOR
      ];
      metadata = {
        tags = [ "technical" "authentication" ];
        automatable = true;
        priority = "critical";
        baseline = "moderate";
      };
    };

    ia_4 = mkControl {
      id = "IA-4";
      name = "Identifier Management";
      category = "Identification and Authentication";
      description = ''
        The organization manages information system identifiers by receiving
        authorization from a designated organizational official to assign an
        individual, group, role, or device identifier.
      '';
      requirements = [
        "Authorized identifier assignment"
        "Prevent identifier reuse for defined period"
        "Disable identifiers after period of inactivity"
      ];
      evidenceTypes = [
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.CONFIG
        evidenceTypes.DOCUMENTATION
      ];
      implementationGuidance = ''
        Use email addresses as user identifiers.
        UUIDs for system/service accounts.
        Never reuse identifiers (soft delete pattern).
        Auto-disable after 90 days of inactivity.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.ACCESS_CONTROL
        technicalControlTypes.AUTHENTICATION
      ];
      mappings = {
        hipaa = [ "164.312(a)(2)(i)" ];
        iso27001 = [ "A.9.2.1" ];
      };
      testingProcedures = [
        "Review identifier assignment process"
        "Verify no identifier reuse"
        "Test inactive account detection"
      ];
      patterns = [
        patterns.POLICY
      ];
      metadata = {
        tags = [ "administrative" "authentication" ];
        automatable = true;
        baseline = "moderate";
      };
    };

    ia_5 = mkControl {
      id = "IA-5";
      name = "Authenticator Management";
      category = "Identification and Authentication";
      description = ''
        The organization manages information system authenticators by verifying
        the identity of the individual, group, role, or device receiving the
        authenticator, establishing initial authenticator content, and ensuring
        authenticators have sufficient strength of mechanism.
      '';
      requirements = [
        "Verify identity before issuing authenticator"
        "Initial authenticator/password requirements"
        "Minimum password complexity"
        "Password change requirements"
        "Protect authenticator content"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.DOCUMENTATION
        evidenceTypes.TEST
      ];
      implementationGuidance = ''
        Delegate to enterprise IdP for password policies.
        If managing passwords: min 12 characters, complexity requirements.
        Force password change on first login.
        Bcrypt/Argon2 for password hashing.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.AUTHENTICATION
      ];
      mappings = {
        hipaa = [ "164.312(d)" ];
        iso27001 = [ "A.9.4.3" ];
        pcidss = [ "8.2.3" "8.2.4" ];
      };
      testingProcedures = [
        "Review password policies"
        "Test password complexity enforcement"
        "Verify password storage security"
      ];
      patterns = [
        patterns.POLICY
      ];
      metadata = {
        tags = [ "technical" "authentication" ];
        automatable = true;
        priority = "high";
        baseline = "moderate";
      };
    };
  };

  # System and Communications Protection Family (SC)
  systemCommunications = {
    sc_8 = mkControl {
      id = "SC-8";
      name = "Transmission Confidentiality and Integrity";
      category = "System and Communications Protection";
      description = ''
        The information system protects the confidentiality and integrity of
        transmitted information.
      '';
      requirements = [
        "Encrypt data in transit"
        "Use TLS 1.2 or higher"
        "Validate certificates"
        "Use approved cryptographic mechanisms"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.SCAN
        evidenceTypes.CERTIFICATE
      ];
      implementationGuidance = ''
        Enforce TLS 1.3 for all external communications.
        Mutual TLS for internal service mesh.
        Certificate rotation every 90 days.
        Regular vulnerability scans for weak ciphers.
      '';
      riskLevel = riskLevels.CRITICAL;
      technicalControls = [
        technicalControlTypes.ENCRYPTION
        technicalControlTypes.NETWORK_SECURITY
      ];
      mappings = {
        soc2 = [ "CC6.7" ];
        hipaa = [ "164.312(e)(1)" ];
        iso27001 = [ "A.13.2.1" ];
        pcidss = [ "4.1" ];
      };
      testingProcedures = [
        "Scan for TLS version"
        "Test certificate validation"
        "Verify cipher suite configuration"
      ];
      patterns = [
        patterns.MIDDLEWARE
      ];
      metadata = {
        tags = [ "technical" "encryption" ];
        automatable = true;
        priority = "critical";
        baseline = "moderate";
      };
    };

    sc_13 = mkControl {
      id = "SC-13";
      name = "Cryptographic Protection";
      category = "System and Communications Protection";
      description = ''
        The information system implements required cryptographic protections
        using cryptographic modules that comply with applicable federal laws,
        Executive Orders, directives, policies, regulations, standards, and
        guidance.
      '';
      requirements = [
        "Use FIPS 140-2 validated cryptography"
        "Approved algorithms only"
        "Proper key management"
        "Cryptographic module validation"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.CERTIFICATE
        evidenceTypes.CODE_REVIEW
      ];
      implementationGuidance = ''
        Use FIPS 140-2 validated modules.
        Approved algorithms: AES-256, RSA-2048+, SHA-256+.
        Store keys in HSM or cloud KMS.
        Regular cryptographic reviews.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.ENCRYPTION
        technicalControlTypes.DATA_PROTECTION
      ];
      mappings = {
        soc2 = [ "CC6.6" "CC6.7" ];
        hipaa = [ "164.312(a)(2)(iv)" "164.312(e)(2)(ii)" ];
        iso27001 = [ "A.10.1.1" ];
        pcidss = [ "3.4" "3.5" ];
      };
      testingProcedures = [
        "Review cryptographic implementations"
        "Verify FIPS compliance"
        "Test key management procedures"
      ];
      patterns = [ ];
      metadata = {
        tags = [ "technical" "encryption" ];
        automatable = false;
        priority = "high";
        baseline = "moderate";
      };
    };

    sc_28 = mkControl {
      id = "SC-28";
      name = "Protection of Information at Rest";
      category = "System and Communications Protection";
      description = ''
        The information system protects the confidentiality and integrity of
        information at rest.
      '';
      requirements = [
        "Encrypt data at rest"
        "Use approved cryptographic mechanisms"
        "Secure key storage"
        "Key rotation procedures"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.CODE_REVIEW
        evidenceTypes.SCAN
      ];
      implementationGuidance = ''
        Database encryption at rest (TDE or application-level).
        Encrypted file systems for sensitive data.
        Key storage in KMS/HSM.
        Automated key rotation (annual minimum).
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.ENCRYPTION
        technicalControlTypes.DATA_PROTECTION
      ];
      mappings = {
        soc2 = [ "CC6.6" ];
        hipaa = [ "164.312(a)(2)(iv)" ];
        iso27001 = [ "A.10.1.1" ];
        pcidss = [ "3.4" ];
      };
      testingProcedures = [
        "Verify encryption at rest"
        "Review key management"
        "Test key rotation"
      ];
      patterns = [
        patterns.INTERCEPTOR
      ];
      metadata = {
        tags = [ "technical" "encryption" ];
        automatable = true;
        priority = "high";
        baseline = "moderate";
      };
    };
  };

  # System and Information Integrity Family (SI)
  systemIntegrity = {
    si_4 = mkControl {
      id = "SI-4";
      name = "Information System Monitoring";
      category = "System and Information Integrity";
      description = ''
        The organization monitors the information system to detect attacks,
        indicators of potential attacks, and unauthorized local, network, and
        remote connections.
      '';
      requirements = [
        "Real-time monitoring"
        "Intrusion detection/prevention"
        "Monitoring tool deployment"
        "Alert generation and response"
        "Monitoring coverage"
      ];
      evidenceTypes = [
        evidenceTypes.LOG
        evidenceTypes.METRIC
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Implement OpenTelemetry for distributed tracing.
        Use Prometheus for metrics.
        Grafana for visualization.
        Automated alerting for anomalies.
        SIEM integration for correlation.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.MONITORING
        technicalControlTypes.INCIDENT_RESPONSE
      ];
      mappings = {
        soc2 = [ "CC7.1" "CC7.2" ];
        hipaa = [ "164.308(a)(1)(ii)(D)" ];
        iso27001 = [ "A.12.4.1" ];
        pcidss = [ "10.6" "11.4" ];
      };
      testingProcedures = [
        "Review monitoring coverage"
        "Test alerting rules"
        "Verify incident response integration"
      ];
      patterns = [
        patterns.INTERCEPTOR
        patterns.ASPECT
      ];
      metadata = {
        tags = [ "technical" "monitoring" ];
        automatable = true;
        priority = "high";
        baseline = "moderate";
      };
    };

    si_7 = mkControl {
      id = "SI-7";
      name = "Software, Firmware, and Information Integrity";
      category = "System and Information Integrity";
      description = ''
        The organization employs integrity verification tools to detect
        unauthorized changes to software, firmware, and information.
      '';
      requirements = [
        "Integrity verification mechanisms"
        "Automated integrity checks"
        "Alert on unauthorized changes"
        "Cryptographic hashing"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.CODE_REVIEW
      ];
      implementationGuidance = ''
        Use code signing for deployments.
        Container image signing and verification.
        File integrity monitoring.
        Immutable infrastructure patterns.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.DATA_PROTECTION
        technicalControlTypes.CONFIGURATION_MANAGEMENT
      ];
      mappings = {
        hipaa = [ "164.312(c)(1)" ];
        iso27001 = [ "A.12.2.1" ];
      };
      testingProcedures = [
        "Test integrity verification"
        "Verify automated checks"
        "Review alerting procedures"
      ];
      patterns = [ ];
      metadata = {
        tags = [ "technical" "data-protection" ];
        automatable = true;
        baseline = "moderate";
      };
    };
  };

  # Configuration Management Family (CM)
  configurationManagement = {
    cm_3 = mkControl {
      id = "CM-3";
      name = "Configuration Change Control";
      category = "Configuration Management";
      description = ''
        The organization determines the types of changes to the information
        system that are configuration-controlled, reviews proposed
        configuration-controlled changes, and approves or disapproves changes
        with explicit consideration for security impact.
      '';
      requirements = [
        "Configuration change approval process"
        "Security impact analysis"
        "Documented configuration changes"
        "Testing before deployment"
        "Change rollback capability"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.CODE_REVIEW
      ];
      implementationGuidance = ''
        Use GitOps for configuration management.
        Pull request reviews for all changes.
        Automated security scanning in CI/CD.
        OpenTelemetry spans for change tracking.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.CONFIGURATION_MANAGEMENT
      ];
      mappings = {
        soc2 = [ "CC8.1" ];
        iso27001 = [ "A.12.1.2" ];
      };
      testingProcedures = [
        "Review change control process"
        "Verify approval workflows"
        "Test rollback procedures"
      ];
      patterns = [
        patterns.DECORATOR
      ];
      metadata = {
        tags = [ "administrative" "change-management" ];
        automatable = true;
        baseline = "moderate";
      };
    };

    cm_4 = mkControl {
      id = "CM-4";
      name = "Security Impact Analysis";
      category = "Configuration Management";
      description = ''
        The organization analyzes changes to the information system to determine
        potential security impacts prior to change implementation.
      '';
      requirements = [
        "Security impact analysis for all changes"
        "Document security considerations"
        "Approval based on impact assessment"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.CODE_REVIEW
      ];
      implementationGuidance = ''
        Security review checklist in pull request template.
        Automated security scanning (SAST/DAST).
        Architecture review for significant changes.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.CONFIGURATION_MANAGEMENT
      ];
      mappings = {
        soc2 = [ "CC8.1" ];
        iso27001 = [ "A.12.1.2" ];
      };
      testingProcedures = [
        "Review impact analysis procedures"
        "Verify security reviews"
      ];
      patterns = [ ];
      metadata = {
        tags = [ "administrative" "change-management" ];
        automatable = false;
        baseline = "moderate";
      };
    };
  };
in

{
  inherit accessControl auditAccountability identificationAuthentication
    systemCommunications systemIntegrity configurationManagement;

  # All FedRAMP controls as a flat list
  allControls =
    builtins.attrValues accessControl ++
    builtins.attrValues auditAccountability ++
    builtins.attrValues identificationAuthentication ++
    builtins.attrValues systemCommunications ++
    builtins.attrValues systemIntegrity ++
    builtins.attrValues configurationManagement;
}
