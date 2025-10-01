{ schema }:

let
  inherit (schema) mkControl evidenceTypes riskLevels technicalControlTypes patterns;

  # ISO/IEC 27001:2022 Annex A Controls
  # A.9 Access Control
  accessControl = {
    a_9_2_1 = mkControl {
      id = "A.9.2.1";
      name = "User Registration and De-registration";
      category = "Access Control";
      description = ''
        A formal user registration and de-registration process shall be
        implemented to enable assignment of access rights.
      '';
      requirements = [
        "Formal user registration process"
        "User de-registration process"
        "Access rights assignment procedures"
        "Review and approval of access requests"
        "Timely removal of access rights"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.LOG
      ];
      implementationGuidance = ''
        Implement automated user provisioning workflow.
        Integrate with HR system for lifecycle events.
        Approval workflows for access requests.
        Automated deprovisioning on termination.
        Regular access reviews (quarterly).
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.ACCESS_CONTROL
        technicalControlTypes.AUTHENTICATION
      ];
      mappings = {
        soc2 = ["CC6.2" "CC6.3"];
        hipaa = ["164.308(a)(3)(ii)(B)" "164.308(a)(3)(ii)(C)"];
        fedramp = ["AC-2"];
        pcidss = ["8.1"];
      };
      testingProcedures = [
        "Review user registration process"
        "Test approval workflows"
        "Verify deprovisioning procedures"
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

    a_9_2_2 = mkControl {
      id = "A.9.2.2";
      name = "User Access Provisioning";
      category = "Access Control";
      description = ''
        A formal user access provisioning process shall be implemented to
        assign or revoke access rights for all user types to all systems
        and services.
      '';
      requirements = [
        "Formal access provisioning process"
        "Role-based access assignment"
        "Least privilege principle"
        "Separation of duties"
        "Access review and recertification"
      ];
      evidenceTypes = [
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.CONFIG
        evidenceTypes.LOG
      ];
      implementationGuidance = ''
        Implement RBAC with tenant isolation.
        Automated provisioning based on role.
        Log all access grants and revocations.
        Quarterly access recertification.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.ACCESS_CONTROL
        technicalControlTypes.AUTHORIZATION
      ];
      mappings = {
        soc2 = ["CC6.1"];
        hipaa = ["164.312(a)(1)"];
        fedramp = ["AC-2" "AC-3"];
        pcidss = ["7.1"];
      };
      testingProcedures = [
        "Review provisioning process"
        "Test RBAC implementation"
        "Verify least privilege"
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

    a_9_2_6 = mkControl {
      id = "A.9.2.6";
      name = "Removal or Adjustment of Access Rights";
      category = "Access Control";
      description = ''
        The access rights of all employees and external party users to
        information and other associated assets shall be removed upon
        termination of their employment, contract or agreement, or adjusted
        upon change.
      '';
      requirements = [
        "Immediate access removal on termination"
        "Access adjustment on role change"
        "Return of assets"
        "Disable accounts promptly"
        "Review of retained access"
      ];
      evidenceTypes = [
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.LOG
        evidenceTypes.DOCUMENTATION
      ];
      implementationGuidance = ''
        Automated deprovisioning triggered by HR system.
        Immediate account disable on termination.
        Role change triggers access review.
        Log all access removals and adjustments.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.ACCESS_CONTROL
      ];
      mappings = {
        soc2 = ["CC6.3"];
        hipaa = ["164.308(a)(3)(ii)(C)"];
        fedramp = ["AC-2"];
        pcidss = ["8.1.3"];
      };
      testingProcedures = [
        "Test automated deprovisioning"
        "Review termination procedures"
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

    a_9_4_1 = mkControl {
      id = "A.9.4.1";
      name = "Information Access Restriction";
      category = "Access Control";
      description = ''
        Access to information and application system functions shall be
        restricted in accordance with the access control policy.
      '';
      requirements = [
        "Access control policy definition"
        "Enforcement of access restrictions"
        "Deny by default"
        "Explicit authorization required"
        "Access logging"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.CODE_REVIEW
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Implement policy-based access control.
        All resources deny access by default.
        Explicit grants only.
        Log all access decisions.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.AUTHORIZATION
        technicalControlTypes.ACCESS_CONTROL
      ];
      mappings = {
        soc2 = ["CC6.1"];
        hipaa = ["164.312(a)(1)"];
        fedramp = ["AC-3"];
        pcidss = ["7.1"];
      };
      testingProcedures = [
        "Test default deny behavior"
        "Verify authorization enforcement"
        "Review access logs"
      ];
      patterns = [
        patterns.INTERCEPTOR
        patterns.POLICY
      ];
      validations = [
        "All resources deny by default"
        "Authorization is enforced"
        "Access decisions are logged"
      ];
      metadata = {
        tags = ["technical" "access-control"];
        automatable = true;
        priority = "high";
      };
    };

    a_9_4_2 = mkControl {
      id = "A.9.4.2";
      name = "Secure Log-on Procedures";
      category = "Access Control";
      description = ''
        Where required by the access control policy, access to systems and
        applications shall be controlled by a secure log-on procedure.
      '';
      requirements = [
        "User authentication required"
        "Multi-factor authentication"
        "Session timeout"
        "Limited login attempts"
        "Security warnings displayed"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.LOG
        evidenceTypes.TEST
      ];
      implementationGuidance = ''
        Enforce MFA for all users.
        15-minute session timeout.
        Account lockout after 5 failed attempts.
        Display security warnings/terms.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.AUTHENTICATION
        technicalControlTypes.ACCESS_CONTROL
      ];
      mappings = {
        soc2 = ["CC6.1"];
        hipaa = ["164.312(d)"];
        fedramp = ["IA-2" "AC-11"];
        pcidss = ["8.2"];
      };
      testingProcedures = [
        "Test MFA enforcement"
        "Verify session timeout"
        "Test account lockout"
      ];
      patterns = [
        patterns.MIDDLEWARE
        patterns.INTERCEPTOR
      ];
      metadata = {
        tags = ["technical" "authentication"];
        automatable = true;
        priority = "high";
      };
    };

    a_9_4_3 = mkControl {
      id = "A.9.4.3";
      name = "Password Management System";
      category = "Access Control";
      description = ''
        Password management systems shall be interactive and shall ensure
        quality passwords.
      '';
      requirements = [
        "Strong password requirements"
        "Password change capability"
        "Password quality enforcement"
        "Password history"
        "Secure password storage"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.TEST
        evidenceTypes.CODE_REVIEW
      ];
      implementationGuidance = ''
        Minimum 12 characters, complexity requirements.
        Bcrypt/Argon2 for password hashing.
        Prevent password reuse (last 5).
        Force change on first login.
        Integrate with enterprise IdP when possible.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.AUTHENTICATION
      ];
      mappings = {
        hipaa = ["164.312(d)"];
        fedramp = ["IA-5"];
        pcidss = ["8.2.3" "8.2.4"];
      };
      testingProcedures = [
        "Test password complexity"
        "Verify password hashing"
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

  # A.10 Cryptography
  cryptography = {
    a_10_1_1 = mkControl {
      id = "A.10.1.1";
      name = "Policy on the Use of Cryptographic Controls";
      category = "Cryptography";
      description = ''
        A policy on the use of cryptographic controls for protection of
        information shall be developed and implemented.
      '';
      requirements = [
        "Cryptographic policy documentation"
        "Approved algorithms specification"
        "Key management procedures"
        "Encryption requirements"
        "Regular policy review"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.CONFIG
        evidenceTypes.CODE_REVIEW
      ];
      implementationGuidance = ''
        Document approved algorithms (AES-256, RSA-2048+, SHA-256+).
        Define encryption requirements for data at rest and in transit.
        Key management procedures (generation, storage, rotation).
        Regular cryptographic reviews.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.ENCRYPTION
        technicalControlTypes.DATA_PROTECTION
      ];
      mappings = {
        soc2 = ["CC6.6" "CC6.7"];
        hipaa = ["164.312(a)(2)(iv)" "164.312(e)(2)(ii)"];
        fedramp = ["SC-13" "SC-28"];
        pcidss = ["3.4" "3.5"];
      };
      testingProcedures = [
        "Review cryptographic policy"
        "Verify approved algorithms"
        "Test key management"
      ];
      patterns = [];
      metadata = {
        tags = ["administrative" "encryption"];
        automatable = false;
        priority = "high";
      };
    };

    a_10_1_2 = mkControl {
      id = "A.10.1.2";
      name = "Key Management";
      category = "Cryptography";
      description = ''
        A policy on the use, protection and lifetime of cryptographic keys
        shall be developed and implemented through their whole lifecycle.
      '';
      requirements = [
        "Key generation procedures"
        "Secure key storage (HSM/KMS)"
        "Key rotation policy"
        "Key backup and recovery"
        "Key destruction procedures"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.CONFIG
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Use cloud KMS or HSM for key storage.
        Automated key rotation (annual minimum).
        Backup keys to separate secure location.
        Document key lifecycle procedures.
      '';
      riskLevel = riskLevels.CRITICAL;
      technicalControls = [
        technicalControlTypes.ENCRYPTION
        technicalControlTypes.DATA_PROTECTION
      ];
      mappings = {
        soc2 = ["CC6.6"];
        hipaa = ["164.312(a)(2)(iv)"];
        fedramp = ["SC-13"];
        pcidss = ["3.5" "3.6"];
      };
      testingProcedures = [
        "Review key management procedures"
        "Test key rotation"
        "Verify key storage security"
      ];
      patterns = [];
      metadata = {
        tags = ["technical" "encryption"];
        automatable = true;
        priority = "critical";
      };
    };
  };

  # A.12 Operations Security
  operationsSecurity = {
    a_12_1_2 = mkControl {
      id = "A.12.1.2";
      name = "Change Management";
      category = "Operations Security";
      description = ''
        Changes to the organization, business processes, information processing
        facilities and systems that affect information security shall be
        controlled.
      '';
      requirements = [
        "Change control procedures"
        "Change approval process"
        "Testing before deployment"
        "Rollback procedures"
        "Change documentation"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.CODE_REVIEW
      ];
      implementationGuidance = ''
        GitOps workflow with pull request approvals.
        Automated testing in CI/CD.
        Security review for all changes.
        OpenTelemetry tracking of deployments.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.CONFIGURATION_MANAGEMENT
      ];
      mappings = {
        soc2 = ["CC8.1"];
        hipaa = ["164.308(a)(8)"];
        fedramp = ["CM-3" "CM-4"];
        pcidss = ["6.4"];
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

    a_12_2_1 = mkControl {
      id = "A.12.2.1";
      name = "Controls Against Malware";
      category = "Operations Security";
      description = ''
        Detection, prevention and recovery controls to protect against malware
        shall be implemented, combined with appropriate user awareness.
      '';
      requirements = [
        "Anti-malware software"
        "Regular malware scans"
        "Malware detection and response"
        "User awareness training"
        "Update procedures"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.SCAN
        evidenceTypes.LOG
        evidenceTypes.DOCUMENTATION
      ];
      implementationGuidance = ''
        Container image scanning in CI/CD.
        Regular vulnerability scanning.
        Immutable infrastructure to prevent malware persistence.
        Security awareness training for users.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.VULNERABILITY_MANAGEMENT
      ];
      mappings = {
        fedramp = ["SI-3"];
        pcidss = ["5.1"];
      };
      testingProcedures = [
        "Verify anti-malware coverage"
        "Review scan results"
        "Test detection and response"
      ];
      patterns = [];
      metadata = {
        tags = ["technical" "security"];
        automatable = true;
      };
    };

    a_12_4_1 = mkControl {
      id = "A.12.4.1";
      name = "Event Logging";
      category = "Operations Security";
      description = ''
        Event logs recording user activities, exceptions, faults and information
        security events shall be produced, kept and regularly reviewed.
      '';
      requirements = [
        "Comprehensive event logging"
        "Security event capture"
        "User activity logging"
        "Regular log review"
        "Log retention"
      ];
      evidenceTypes = [
        evidenceTypes.LOG
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.CONFIG
      ];
      implementationGuidance = ''
        OpenTelemetry for distributed tracing.
        Structured logging (JSON format).
        Log aggregation and analysis.
        Automated log review with SIEM.
        Retain logs for required period.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.LOGGING
        technicalControlTypes.MONITORING
      ];
      mappings = {
        soc2 = ["CC7.1" "CC7.2"];
        hipaa = ["164.312(b)"];
        fedramp = ["AU-2" "AU-3"];
        pcidss = ["10.1" "10.2"];
      };
      testingProcedures = [
        "Verify logging coverage"
        "Review log content"
        "Test log retention"
      ];
      patterns = [
        patterns.INTERCEPTOR
        patterns.ASPECT
      ];
      validations = [
        "All security events are logged"
        "Logs contain required information"
        "Logs are reviewed regularly"
      ];
      metadata = {
        tags = ["technical" "logging"];
        automatable = true;
        priority = "high";
      };
    };

    a_12_4_3 = mkControl {
      id = "A.12.4.3";
      name = "Administrator and Operator Logs";
      category = "Operations Security";
      description = ''
        System administrator and system operator activities shall be logged
        and the logs protected and regularly reviewed.
      '';
      requirements = [
        "Admin activity logging"
        "Privileged operation logging"
        "Log protection"
        "Regular review of admin logs"
      ];
      evidenceTypes = [
        evidenceTypes.LOG
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Dedicated logging for privileged operations.
        Tamper-proof log storage.
        Weekly review of admin logs.
        Automated alerts for suspicious admin activity.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.LOGGING
        technicalControlTypes.MONITORING
      ];
      mappings = {
        hipaa = ["164.312(b)"];
        fedramp = ["AU-2" "AU-9"];
        pcidss = ["10.1"];
      };
      testingProcedures = [
        "Verify admin logging"
        "Test log protection"
        "Review log analysis procedures"
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
  };

  # A.13 Communications Security
  communicationsSecurity = {
    a_13_2_1 = mkControl {
      id = "A.13.2.1";
      name = "Information Transfer Policies and Procedures";
      category = "Communications Security";
      description = ''
        Formal transfer policies, procedures and controls shall be in place
        to protect the transfer of information through the use of all types
        of communication facilities.
      '';
      requirements = [
        "Data transfer policies"
        "Encryption in transit"
        "TLS 1.2+ for all communications"
        "Secure API protocols"
        "Transfer logging"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.CONFIG
        evidenceTypes.SCAN
        evidenceTypes.CERTIFICATE
      ];
      implementationGuidance = ''
        Enforce TLS 1.3 for all communications.
        Mutual TLS for service-to-service.
        API gateway with authentication.
        Log all data transfers.
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
        pcidss = ["4.1" "4.2"];
      };
      testingProcedures = [
        "Review transfer policies"
        "Test TLS configuration"
        "Verify certificate validity"
      ];
      patterns = [
        patterns.MIDDLEWARE
      ];
      validations = [
        "All transfers use TLS 1.2+"
        "Certificates are valid"
        "Transfers are logged"
      ];
      metadata = {
        tags = ["technical" "encryption"];
        automatable = true;
        priority = "critical";
      };
    };
  };

  # A.14 System Acquisition, Development and Maintenance
  development = {
    a_14_2_2 = mkControl {
      id = "A.14.2.2";
      name = "System Change Control Procedures";
      category = "System Acquisition, Development and Maintenance";
      description = ''
        Changes to systems within the development lifecycle shall be controlled
        by the use of formal change control procedures.
      '';
      requirements = [
        "Formal change control"
        "Version control"
        "Testing requirements"
        "Approval workflows"
        "Change documentation"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.CODE_REVIEW
      ];
      implementationGuidance = ''
        Git-based version control.
        Pull request workflow with reviews.
        Automated testing (unit, integration, security).
        Deployment tracking with OpenTelemetry.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.CONFIGURATION_MANAGEMENT
      ];
      mappings = {
        soc2 = ["CC8.1"];
        fedramp = ["CM-3"];
      };
      testingProcedures = [
        "Review change control procedures"
        "Verify version control usage"
        "Test approval workflows"
      ];
      patterns = [
        patterns.DECORATOR
      ];
      metadata = {
        tags = ["administrative" "development"];
        automatable = true;
      };
    };
  };

  # A.8 Asset Management
  assetManagement = {
    a_8_32 = mkControl {
      id = "A.8.32";
      name = "Handling of Records";
      category = "Asset Management";
      description = ''
        Records shall be classified and handled in accordance with the record
        retention requirements.
      '';
      requirements = [
        "Data classification scheme"
        "Retention policy definition"
        "Secure disposal procedures"
        "Retention enforcement"
        "Audit of retention compliance"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.CONFIG
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Define data classification levels (public, internal, confidential, restricted).
        Automated retention policies (e.g., 7 years for audit logs).
        Secure deletion for expired data.
        Regular compliance audits.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.DATA_PROTECTION
        technicalControlTypes.CONFIGURATION_MANAGEMENT
      ];
      mappings = {
        soc2 = ["CC8.1"];
        hipaa = ["164.316(b)(2)(i)"];
        pcidss = ["3.1"];
      };
      testingProcedures = [
        "Review data classification"
        "Verify retention policies"
        "Test disposal procedures"
      ];
      patterns = [
        patterns.POLICY
      ];
      metadata = {
        tags = ["administrative" "data-protection"];
        automatable = true;
      };
    };
  };
in

{
  inherit accessControl cryptography operationsSecurity communicationsSecurity
          development assetManagement;

  # All ISO 27001 controls as a flat list
  allControls =
    builtins.attrValues accessControl ++
    builtins.attrValues cryptography ++
    builtins.attrValues operationsSecurity ++
    builtins.attrValues communicationsSecurity ++
    builtins.attrValues development ++
    builtins.attrValues assetManagement;
}