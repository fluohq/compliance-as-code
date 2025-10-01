{ schema }:

let
  inherit (schema) mkControl evidenceTypes riskLevels technicalControlTypes patterns;

  # PCI DSS v4.0 Requirements
  # Requirement 3: Protect Stored Account Data
  dataProtection = {
    req_3_1 = mkControl {
      id = "3.1";
      name = "Account Data Storage";
      category = "Protect Stored Account Data";
      description = ''
        Processes and mechanisms for protecting stored account data are
        defined and understood.
      '';
      requirements = [
        "Document data retention and disposal policies"
        "Identify all locations where account data is stored"
        "Minimize storage of sensitive data"
        "Delete data when no longer needed"
        "Quarterly verification of data storage"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.CONFIG
      ];
      implementationGuidance = ''
        Create data inventory of all systems storing payment data.
        Document retention policies (minimum 3 months for logs).
        Automated data deletion after retention period.
        Quarterly data storage audits.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.DATA_PROTECTION
        technicalControlTypes.CONFIGURATION_MANAGEMENT
      ];
      mappings = {
        iso27001 = ["A.8.32"];
      };
      testingProcedures = [
        "Review data inventory"
        "Verify retention policies"
        "Test automated deletion"
      ];
      patterns = [
        patterns.POLICY
      ];
      metadata = {
        tags = ["administrative" "data-protection"];
        automatable = true;
        priority = "high";
      };
    };

    req_3_4 = mkControl {
      id = "3.4";
      name = "Cryptographic Protection - At Rest";
      category = "Protect Stored Account Data";
      description = ''
        Primary Account Numbers (PAN) are protected with strong cryptography
        whenever they are stored.
      '';
      requirements = [
        "Encrypt PAN at rest using strong cryptography"
        "Use approved algorithms (AES-256)"
        "Secure key management"
        "Protect cryptographic keys"
        "Document encryption procedures"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.CODE_REVIEW
        evidenceTypes.SCAN
        evidenceTypes.DOCUMENTATION
      ];
      implementationGuidance = ''
        Use AES-256 encryption for all stored payment data.
        Database-level encryption or application-level encryption.
        Store keys in HSM or cloud KMS.
        Key rotation every 90 days minimum.
      '';
      riskLevel = riskLevels.CRITICAL;
      technicalControls = [
        technicalControlTypes.ENCRYPTION
        technicalControlTypes.DATA_PROTECTION
      ];
      mappings = {
        soc2 = ["CC6.6"];
        hipaa = ["164.312(a)(2)(iv)"];
        fedramp = ["SC-28"];
        iso27001 = ["A.10.1.1"];
      };
      testingProcedures = [
        "Verify encryption at rest"
        "Review encryption algorithms"
        "Test key management"
      ];
      patterns = [
        patterns.INTERCEPTOR
        patterns.DECORATOR
      ];
      validations = [
        "All PAN is encrypted at rest"
        "Strong cryptography is used"
        "Keys are securely stored"
      ];
      metadata = {
        tags = ["technical" "encryption"];
        automatable = true;
        priority = "critical";
      };
    };

    req_3_5 = mkControl {
      id = "3.5";
      name = "Primary Account Number Rendering";
      category = "Protect Stored Account Data";
      description = ''
        Primary Account Number (PAN) is secured wherever it is displayed.
      '';
      requirements = [
        "Mask PAN when displayed"
        "Show maximum first 6 and last 4 digits"
        "Justified business need for full PAN display"
        "Document display requirements"
      ];
      evidenceTypes = [
        evidenceTypes.CODE_REVIEW
        evidenceTypes.SCREENSHOT
        evidenceTypes.DOCUMENTATION
      ];
      implementationGuidance = ''
        Implement PAN masking in all UI components.
        API responses mask PAN by default.
        Full PAN display requires special permissions.
        Audit all full PAN displays.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.DATA_PROTECTION
      ];
      mappings = {
        iso27001 = ["A.10.1.1"];
      };
      testingProcedures = [
        "Review UI for PAN masking"
        "Test API responses"
        "Verify display permissions"
      ];
      patterns = [
        patterns.DECORATOR
      ];
      metadata = {
        tags = ["technical" "data-protection"];
        automatable = true;
        priority = "high";
      };
    };

    req_3_6 = mkControl {
      id = "3.6";
      name = "Cryptographic Key Management";
      category = "Protect Stored Account Data";
      description = ''
        Cryptographic keys used to protect stored account data are secured.
      '';
      requirements = [
        "Key generation procedures"
        "Secure key storage"
        "Key distribution controls"
        "Key rotation procedures"
        "Key destruction procedures"
        "Split knowledge and dual control"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.CONFIG
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Use cloud KMS (AWS KMS, Azure Key Vault, GCP KMS) or HSM.
        Automated key rotation (every 90 days).
        No cleartext keys in configuration or code.
        Multi-party key management for sensitive operations.
      '';
      riskLevel = riskLevels.CRITICAL;
      technicalControls = [
        technicalControlTypes.ENCRYPTION
        technicalControlTypes.DATA_PROTECTION
      ];
      mappings = {
        iso27001 = ["A.10.1.2"];
        fedramp = ["SC-13"];
      };
      testingProcedures = [
        "Review key management procedures"
        "Verify key storage security"
        "Test key rotation"
      ];
      patterns = [];
      metadata = {
        tags = ["technical" "encryption"];
        automatable = true;
        priority = "critical";
      };
    };
  };

  # Requirement 4: Protect Cardholder Data with Strong Cryptography During Transmission
  transmissionSecurity = {
    req_4_1 = mkControl {
      id = "4.1";
      name = "Cryptographic Protection - In Transit";
      category = "Protect During Transmission";
      description = ''
        Processes and mechanisms for protecting cardholder data with strong
        cryptography during transmission over open, public networks are
        defined and understood.
      '';
      requirements = [
        "Document transmission security policies"
        "Use strong cryptography for transmission"
        "TLS 1.2 or higher"
        "No weak protocols (SSL, early TLS)"
        "Certificate management"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.CONFIG
        evidenceTypes.SCAN
        evidenceTypes.CERTIFICATE
      ];
      implementationGuidance = ''
        Enforce TLS 1.3 for all external communications.
        Disable SSLv3, TLS 1.0, TLS 1.1.
        Use only strong cipher suites.
        Automated certificate renewal (Let's Encrypt).
        Regular vulnerability scans.
      '';
      riskLevel = riskLevels.CRITICAL;
      technicalControls = [
        technicalControlTypes.ENCRYPTION
        technicalControlTypes.NETWORK_SECURITY
      ];
      mappings = {
        soc2 = ["CC6.7"];
        hipaa = ["164.312(e)(1)"];
        fedramp = ["SC-8"];
        iso27001 = ["A.13.2.1"];
      };
      testingProcedures = [
        "Scan for TLS version"
        "Test cipher suites"
        "Verify certificate validity"
      ];
      patterns = [
        patterns.MIDDLEWARE
      ];
      validations = [
        "All transmissions use TLS 1.2+"
        "Weak protocols are disabled"
        "Certificates are valid"
      ];
      metadata = {
        tags = ["technical" "encryption"];
        automatable = true;
        priority = "critical";
      };
    };

    req_4_2 = mkControl {
      id = "4.2";
      name = "Transmission Security - Implementation";
      category = "Protect During Transmission";
      description = ''
        PAN is protected with strong cryptography whenever it is sent over
        open, public networks.
      '';
      requirements = [
        "TLS/SSL for all PAN transmissions"
        "No PAN via unencrypted channels"
        "End-to-end encryption for sensitive data"
        "Verify encryption implementation"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.SCAN
        evidenceTypes.CODE_REVIEW
      ];
      implementationGuidance = ''
        HTTPS for all web traffic.
        TLS for all API communications.
        Encrypt PAN before storage in browser (if necessary).
        No PAN in URLs or logs.
      '';
      riskLevel = riskLevels.CRITICAL;
      technicalControls = [
        technicalControlTypes.ENCRYPTION
        technicalControlTypes.NETWORK_SECURITY
      ];
      mappings = {
        soc2 = ["CC6.7"];
        hipaa = ["164.312(e)(1)"];
        fedramp = ["SC-8"];
        iso27001 = ["A.13.2.1"];
      };
      testingProcedures = [
        "Test all PAN transmission paths"
        "Verify TLS enforcement"
        "Review code for unencrypted transmissions"
      ];
      patterns = [
        patterns.MIDDLEWARE
        patterns.INTERCEPTOR
      ];
      metadata = {
        tags = ["technical" "encryption"];
        automatable = true;
        priority = "critical";
      };
    };
  };

  # Requirement 7: Restrict Access to System Components and Cardholder Data
  accessControl = {
    req_7_1 = mkControl {
      id = "7.1";
      name = "Access Control Policies";
      category = "Restrict Access";
      description = ''
        Processes and mechanisms for restricting access to system components
        and cardholder data by business need to know are defined and
        understood.
      '';
      requirements = [
        "Document access control policies"
        "Define roles and responsibilities"
        "Implement least privilege"
        "Need-to-know basis"
        "Regular access reviews"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.CONFIG
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Implement RBAC with clearly defined roles.
        Tenant isolation in multi-tenant systems.
        Default deny for all resources.
        Quarterly access reviews.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.ACCESS_CONTROL
        technicalControlTypes.AUTHORIZATION
      ];
      mappings = {
        soc2 = ["CC6.1"];
        hipaa = ["164.312(a)(1)"];
        fedramp = ["AC-3"];
        iso27001 = ["A.9.2.2" "A.9.4.1"];
      };
      testingProcedures = [
        "Review access control policies"
        "Verify RBAC implementation"
        "Test least privilege enforcement"
      ];
      patterns = [
        patterns.POLICY
        patterns.INTERCEPTOR
      ];
      metadata = {
        tags = ["administrative" "access-control"];
        automatable = true;
        priority = "high";
      };
    };
  };

  # Requirement 8: Identify Users and Authenticate Access
  authentication = {
    req_8_1 = mkControl {
      id = "8.1";
      name = "User Identification and Authentication";
      category = "Identify and Authenticate Users";
      description = ''
        Processes and mechanisms for identifying and authenticating users are
        defined and understood.
      '';
      requirements = [
        "Unique user identification"
        "Authentication before access"
        "Multi-factor authentication"
        "No shared accounts"
        "Document authentication procedures"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.CONFIG
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Integrate with enterprise IdP (WorkOS, Auth0, Okta).
        Enforce MFA for all users.
        Use email or employee ID as unique identifier.
        No shared service accounts.
      '';
      riskLevel = riskLevels.CRITICAL;
      technicalControls = [
        technicalControlTypes.AUTHENTICATION
        technicalControlTypes.ACCESS_CONTROL
      ];
      mappings = {
        soc2 = ["CC6.1" "CC6.2"];
        hipaa = ["164.312(a)(2)(i)" "164.312(d)"];
        fedramp = ["IA-2" "AC-2"];
        iso27001 = ["A.9.2.1"];
      };
      testingProcedures = [
        "Verify unique user IDs"
        "Test MFA enforcement"
        "Review authentication logs"
      ];
      patterns = [
        patterns.MIDDLEWARE
        patterns.INTERCEPTOR
      ];
      validations = [
        "All users have unique IDs"
        "MFA is enforced"
        "No shared accounts exist"
      ];
      metadata = {
        tags = ["technical" "authentication"];
        automatable = true;
        priority = "critical";
      };
    };

    req_8_2 = mkControl {
      id = "8.2";
      name = "Strong Authentication";
      category = "Identify and Authenticate Users";
      description = ''
        Strong authentication for users and administrators is established
        and managed.
      '';
      requirements = [
        "Multi-factor authentication"
        "Password complexity requirements"
        "Password change procedures"
        "Account lockout policies"
        "Session management"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.TEST
        evidenceTypes.LOG
      ];
      implementationGuidance = ''
        MFA for all user types (not just admins).
        Minimum 12-character passwords with complexity.
        Account lockout after 6 failed attempts.
        15-minute session timeout.
      '';
      riskLevel = riskLevels.CRITICAL;
      technicalControls = [
        technicalControlTypes.AUTHENTICATION
      ];
      mappings = {
        soc2 = ["CC6.1"];
        hipaa = ["164.312(d)"];
        fedramp = ["IA-2" "IA-5"];
        iso27001 = ["A.9.4.2" "A.9.4.3"];
      };
      testingProcedures = [
        "Test MFA enforcement"
        "Verify password policies"
        "Test account lockout"
        "Verify session timeout"
      ];
      patterns = [
        patterns.MIDDLEWARE
        patterns.POLICY
      ];
      metadata = {
        tags = ["technical" "authentication"];
        automatable = true;
        priority = "critical";
      };
    };

    req_8_1_3 = mkControl {
      id = "8.1.3";
      name = "Account Termination";
      category = "Identify and Authenticate Users";
      description = ''
        User access is terminated immediately upon termination of user
        relationship with the entity.
      '';
      requirements = [
        "Immediate access termination"
        "Automated deprovisioning"
        "Equipment return procedures"
        "Access review post-termination"
      ];
      evidenceTypes = [
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.LOG
        evidenceTypes.DOCUMENTATION
      ];
      implementationGuidance = ''
        Integrate with HR system for termination triggers.
        Automated account disable on termination.
        Log all termination events.
        Post-termination access audit.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.ACCESS_CONTROL
      ];
      mappings = {
        soc2 = ["CC6.3"];
        hipaa = ["164.308(a)(3)(ii)(C)"];
        fedramp = ["AC-2"];
        iso27001 = ["A.9.2.6"];
      };
      testingProcedures = [
        "Test automated deprovisioning"
        "Review termination logs"
        "Verify access removal timing"
      ];
      patterns = [
        patterns.INTERCEPTOR
        patterns.POLICY
      ];
      metadata = {
        tags = ["technical" "access-control"];
        automatable = true;
        priority = "high";
      };
    };

    req_8_1_4 = mkControl {
      id = "8.1.4";
      name = "Inactive Account Management";
      category = "Identify and Authenticate Users";
      description = ''
        User accounts that have been inactive for 90 days or more are
        removed or disabled.
      '';
      requirements = [
        "Detect inactive accounts (90 days)"
        "Automated account disable"
        "Regular inactive account reviews"
        "Document inactive account procedures"
      ];
      evidenceTypes = [
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.CONFIG
        evidenceTypes.LOG
      ];
      implementationGuidance = ''
        Automated daily check for inactive accounts.
        Disable after 90 days of no login.
        Weekly report of disabled accounts.
        Manual review for exceptions.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.ACCESS_CONTROL
      ];
      mappings = {
        soc2 = ["CC6.3"];
        fedramp = ["AC-2"];
        iso27001 = ["A.9.2.6"];
      };
      testingProcedures = [
        "Review inactive account detection"
        "Test automated disable"
        "Verify 90-day threshold"
      ];
      patterns = [
        patterns.POLICY
      ];
      metadata = {
        tags = ["technical" "access-control"];
        automatable = true;
      };
    };

    req_8_2_3 = mkControl {
      id = "8.2.3";
      name = "Password Complexity";
      category = "Identify and Authenticate Users";
      description = ''
        User passwords/passphrases meet minimum strength requirements.
      '';
      requirements = [
        "Minimum 12 characters (15 for privileged)"
        "Contains uppercase and lowercase letters"
        "Contains numbers"
        "Contains special characters"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.TEST
      ];
      implementationGuidance = ''
        Delegate to enterprise IdP when possible.
        If managing passwords: enforce complexity via policy.
        Use Bcrypt or Argon2 for hashing.
        Test password strength on creation.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.AUTHENTICATION
      ];
      mappings = {
        fedramp = ["IA-5"];
        iso27001 = ["A.9.4.3"];
      };
      testingProcedures = [
        "Test password complexity enforcement"
        "Verify minimum length"
        "Test character requirements"
      ];
      patterns = [
        patterns.POLICY
      ];
      metadata = {
        tags = ["technical" "authentication"];
        automatable = true;
        priority = "high";
      };
    };

    req_8_2_4 = mkControl {
      id = "8.2.4";
      name = "Password Change";
      category = "Identify and Authenticate Users";
      description = ''
        User passwords/passphrases are changed periodically and cannot be
        the same as any of the last four passwords used.
      '';
      requirements = [
        "Password change every 90 days"
        "Prevent reuse of last 4 passwords"
        "Force change on first login"
        "Change on suspected compromise"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.TEST
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        90-day password expiration policy.
        Store password hashes in history (last 4).
        Temporary password requires immediate change.
        Log all password changes.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.AUTHENTICATION
      ];
      mappings = {
        fedramp = ["IA-5"];
        iso27001 = ["A.9.4.3"];
      };
      testingProcedures = [
        "Test password expiration"
        "Verify password history"
        "Test password reuse prevention"
      ];
      patterns = [
        patterns.POLICY
      ];
      metadata = {
        tags = ["technical" "authentication"];
        automatable = true;
      };
    };
  };

  # Requirement 10: Log and Monitor All Access
  logging = {
    req_10_1 = mkControl {
      id = "10.1";
      name = "Audit Logging Processes";
      category = "Log and Monitor Access";
      description = ''
        Processes and mechanisms for logging and monitoring all access to
        system components and cardholder data are defined and documented.
      '';
      requirements = [
        "Document logging policies"
        "Define audit log requirements"
        "Log retention policy"
        "Log review procedures"
        "Automated log analysis"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.CONFIG
        evidenceTypes.LOG
      ];
      implementationGuidance = ''
        OpenTelemetry for comprehensive logging.
        Structured logs (JSON format).
        Minimum 1-year retention (3 months online).
        Automated log analysis with SIEM.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.LOGGING
        technicalControlTypes.MONITORING
      ];
      mappings = {
        soc2 = ["CC7.1"];
        hipaa = ["164.312(b)"];
        fedramp = ["AU-2"];
        iso27001 = ["A.12.4.1"];
      };
      testingProcedures = [
        "Review logging policies"
        "Verify log retention"
        "Test log analysis procedures"
      ];
      patterns = [
        patterns.INTERCEPTOR
        patterns.ASPECT
      ];
      metadata = {
        tags = ["administrative" "logging"];
        automatable = true;
        priority = "high";
      };
    };

    req_10_2 = mkControl {
      id = "10.2";
      name = "Audit Log Content";
      category = "Log and Monitor Access";
      description = ''
        Audit logs are implemented to support the detection of anomalies
        and suspicious activity, and the forensic analysis of events.
      '';
      requirements = [
        "Log user access to cardholder data"
        "Log administrative actions"
        "Log access to audit logs"
        "Log invalid logical access attempts"
        "Log changes to identification/authentication"
        "Log initialization of audit logs"
      ];
      evidenceTypes = [
        evidenceTypes.LOG
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Comprehensive event logging with OpenTelemetry.
        Include: user_id, timestamp, action, resource, outcome.
        Tenant context in all logs.
        Failed access attempts logged.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.LOGGING
      ];
      mappings = {
        soc2 = ["CC7.1"];
        hipaa = ["164.312(b)"];
        fedramp = ["AU-2" "AU-3"];
        iso27001 = ["A.12.4.1"];
      };
      testingProcedures = [
        "Review log content requirements"
        "Verify all required events logged"
        "Test log completeness"
      ];
      patterns = [
        patterns.INTERCEPTOR
        patterns.DECORATOR
      ];
      metadata = {
        tags = ["technical" "logging"];
        automatable = true;
        priority = "high";
      };
    };

    req_10_3 = mkControl {
      id = "10.3";
      name = "Audit Log Details";
      category = "Log and Monitor Access";
      description = ''
        Audit logs capture all required details for each auditable event.
      '';
      requirements = [
        "User identification"
        "Type of event"
        "Date and time"
        "Success or failure indication"
        "Origination of event"
        "Identity/name of affected data/system/resource"
      ];
      evidenceTypes = [
        evidenceTypes.LOG
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Structured logging with standard fields.
        ISO 8601 timestamps.
        Include trace_id for distributed tracing.
        Source IP and user agent.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.LOGGING
      ];
      mappings = {
        soc2 = ["CC7.1"];
        hipaa = ["164.312(b)"];
        fedramp = ["AU-3"];
        iso27001 = ["A.12.4.1"];
      };
      testingProcedures = [
        "Review sample audit records"
        "Verify all required fields"
        "Test log format compliance"
      ];
      patterns = [
        patterns.INTERCEPTOR
      ];
      metadata = {
        tags = ["technical" "logging"];
        automatable = true;
        priority = "high";
      };
    };

    req_10_6 = mkControl {
      id = "10.6";
      name = "Audit Log Review";
      category = "Log and Monitor Access";
      description = ''
        Audit logs are reviewed to identify anomalies or suspicious activity.
      '';
      requirements = [
        "Daily review of security events"
        "Periodic review of other logs"
        "Automated log analysis"
        "Follow up on exceptions"
        "Document review process"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.METRIC
      ];
      implementationGuidance = ''
        Automated log analysis with SIEM.
        Real-time alerts for critical events.
        Daily review of security events.
        Weekly review of general logs.
        ML-based anomaly detection.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.MONITORING
        technicalControlTypes.INCIDENT_RESPONSE
      ];
      mappings = {
        soc2 = ["CC7.2"];
        hipaa = ["164.308(a)(1)(ii)(D)"];
        fedramp = ["AU-6"];
        iso27001 = ["A.12.4.1"];
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
        tags = ["administrative" "monitoring"];
        automatable = true;
      };
    };
  };

  # Requirement 11: Test Security of Systems and Networks
  testing = {
    req_11_4 = mkControl {
      id = "11.4";
      name = "Intrusion Detection and Prevention";
      category = "Test Security";
      description = ''
        External and internal intrusions are detected and prevented/responded to.
      '';
      requirements = [
        "Intrusion detection systems"
        "Critical system monitoring"
        "Alert generation"
        "Security monitoring tools"
        "Incident response procedures"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.LOG
        evidenceTypes.DOCUMENTATION
      ];
      implementationGuidance = ''
        OpenTelemetry for comprehensive monitoring.
        Anomaly detection with ML.
        Real-time alerting for suspicious activity.
        Integration with incident response.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.MONITORING
        technicalControlTypes.INCIDENT_RESPONSE
      ];
      mappings = {
        soc2 = ["CC7.1" "CC7.2"];
        hipaa = ["164.308(a)(1)(ii)(D)"];
        fedramp = ["SI-4"];
        iso27001 = ["A.12.4.1"];
      };
      testingProcedures = [
        "Review IDS/IPS configuration"
        "Test alert generation"
        "Verify monitoring coverage"
      ];
      patterns = [
        patterns.INTERCEPTOR
      ];
      metadata = {
        tags = ["technical" "monitoring"];
        automatable = true;
        priority = "high";
      };
    };

    req_5_1 = mkControl {
      id = "5.1";
      name = "Malware Protection";
      category = "Protect Against Malware";
      description = ''
        Processes and mechanisms for protecting all systems and networks
        from malicious software are defined and understood.
      '';
      requirements = [
        "Anti-malware solution deployment"
        "Regular malware scans"
        "Automatic updates"
        "Malware detection and response"
        "User awareness"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.SCAN
        evidenceTypes.DOCUMENTATION
      ];
      implementationGuidance = ''
        Container image scanning in CI/CD.
        Regular vulnerability scanning.
        Immutable infrastructure.
        Security awareness training.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.VULNERABILITY_MANAGEMENT
      ];
      mappings = {
        iso27001 = ["A.12.2.1"];
      };
      testingProcedures = [
        "Verify anti-malware deployment"
        "Review scan results"
        "Test detection capabilities"
      ];
      patterns = [];
      metadata = {
        tags = ["technical" "security"];
        automatable = true;
      };
    };
  };

  # Requirement 6: Develop and Maintain Secure Systems
  secureDevelopment = {
    req_6_4 = mkControl {
      id = "6.4";
      name = "Change Control";
      category = "Secure Systems";
      description = ''
        Public-facing web applications are protected against attacks through
        ongoing review and change control procedures.
      '';
      requirements = [
        "Change control procedures"
        "Security impact analysis"
        "Testing before deployment"
        "Approval workflows"
        "Rollback capability"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.CODE_REVIEW
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        GitOps workflow with pull requests.
        Automated security testing (SAST/DAST).
        Security review for all changes.
        Deployment tracking with OpenTelemetry.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.CONFIGURATION_MANAGEMENT
      ];
      mappings = {
        soc2 = ["CC8.1"];
        hipaa = ["164.308(a)(8)"];
        fedramp = ["CM-3"];
        iso27001 = ["A.12.1.2" "A.14.2.2"];
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
        tags = ["administrative" "change-management"];
        automatable = true;
      };
    };
  };
in

{
  inherit dataProtection transmissionSecurity accessControl authentication
          logging testing secureDevelopment;

  # All PCI-DSS controls as a flat list
  allControls =
    builtins.attrValues dataProtection ++
    builtins.attrValues transmissionSecurity ++
    builtins.attrValues accessControl ++
    builtins.attrValues authentication ++
    builtins.attrValues logging ++
    builtins.attrValues testing ++
    builtins.attrValues secureDevelopment;
}