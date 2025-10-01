{ schema }:

let
  inherit (schema) mkControl evidenceTypes riskLevels technicalControlTypes patterns;

  # HIPAA Security Rule Controls
  # § 164.312 Technical Safeguards
  technical = {
    access_control = mkControl {
      id = "164.312(a)(1)";
      name = "Access Control";
      category = "Technical Safeguards";
      description = ''
        Implement technical policies and procedures for electronic information
        systems that maintain electronic protected health information to allow
        access only to those persons or software programs that have been granted
        access rights.
      '';
      requirements = [
        "Unique user identification (Required)"
        "Emergency access procedure (Required)"
        "Automatic logoff (Addressable)"
        "Encryption and decryption (Addressable)"
      ];
      evidenceTypes = [
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.CONFIG
        evidenceTypes.LOG
        evidenceTypes.DOCUMENTATION
      ];
      implementationGuidance = ''
        Implement role-based access control with unique user identifiers.
        Maintain emergency access procedures (break-glass accounts).
        Configure automatic session timeouts.
        Document encryption decisions for ePHI.
      '';
      riskLevel = riskLevels.CRITICAL;
      technicalControls = [
        technicalControlTypes.ACCESS_CONTROL
        technicalControlTypes.AUTHENTICATION
        technicalControlTypes.AUTHORIZATION
      ];
      mappings = {
        soc2 = ["CC6.1" "CC6.2"];
        fedramp = ["AC-2" "AC-11"];
        iso27001 = ["A.9.2.1" "A.9.4.2"];
        pcidss = ["7.1" "8.1"];
      };
      testingProcedures = [
        "Verify unique user identification"
        "Test emergency access procedures"
        "Validate automatic logoff"
        "Review encryption implementation"
      ];
      patterns = [
        patterns.INTERCEPTOR
        patterns.MIDDLEWARE
        patterns.POLICY
      ];
      validations = [
        "Every user has unique identifier"
        "Emergency access is documented and logged"
        "Sessions timeout after inactivity"
      ];
      metadata = {
        tags = ["technical" "required" "access-control"];
        automatable = true;
        priority = "critical";
        addressable = false; # Required control
      };
    };

    unique_user_id = mkControl {
      id = "164.312(a)(2)(i)";
      name = "Unique User Identification";
      category = "Technical Safeguards - Access Control";
      description = ''
        Assign a unique name and/or number for identifying and tracking user identity.
      '';
      requirements = [
        "Unique identifier for each user"
        "No shared accounts"
        "User identification in all audit logs"
        "Deactivation of terminated user IDs"
      ];
      evidenceTypes = [
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.CONFIG
        evidenceTypes.LOG
      ];
      implementationGuidance = ''
        Use email addresses or employee IDs as unique identifiers.
        Integrate with SSO/SAML for identity management.
        Log user identifier with every action.
        Automated deactivation on user termination.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.AUTHENTICATION
        technicalControlTypes.ACCESS_CONTROL
      ];
      mappings = {
        soc2 = ["CC6.2"];
        fedramp = ["IA-2" "IA-4"];
        iso27001 = ["A.9.2.1"];
        pcidss = ["8.1"];
      };
      testingProcedures = [
        "Review user account list for duplicates"
        "Verify no shared credentials"
        "Check audit logs for user identifiers"
      ];
      patterns = [
        patterns.DECORATOR
        patterns.INTERCEPTOR
      ];
      metadata = {
        tags = ["technical" "required" "authentication"];
        automatable = true;
        addressable = false;
      };
    };

    emergency_access = mkControl {
      id = "164.312(a)(2)(ii)";
      name = "Emergency Access Procedure";
      category = "Technical Safeguards - Access Control";
      description = ''
        Establish (and implement as needed) procedures for obtaining necessary
        electronic protected health information during an emergency.
      '';
      requirements = [
        "Documented emergency access procedures"
        "Break-glass account procedures"
        "Emergency access logging"
        "Post-emergency access review"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.LOG
      ];
      implementationGuidance = ''
        Create break-glass accounts with elevated privileges.
        Implement multi-factor authentication for emergency access.
        Alert security team on emergency access use.
        Conduct post-incident review of emergency access.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.ACCESS_CONTROL
        technicalControlTypes.INCIDENT_RESPONSE
        technicalControlTypes.LOGGING
      ];
      mappings = {
        soc2 = ["CC6.1"];
        fedramp = ["AC-2"];
        iso27001 = ["A.9.2.1"];
      };
      testingProcedures = [
        "Review emergency access documentation"
        "Test break-glass procedures"
        "Verify emergency access logging"
      ];
      patterns = [
        patterns.POLICY
        patterns.INTERCEPTOR
      ];
      metadata = {
        tags = ["administrative" "required" "incident-response"];
        automatable = false;
        addressable = false;
      };
    };

    audit_controls = mkControl {
      id = "164.312(b)";
      name = "Audit Controls";
      category = "Technical Safeguards";
      description = ''
        Implement hardware, software, and/or procedural mechanisms that record
        and examine activity in information systems that contain or use electronic
        protected health information.
      '';
      requirements = [
        "Log all access to ePHI"
        "Log system activity"
        "Log security events"
        "Regular audit log review"
        "Audit log protection"
      ];
      evidenceTypes = [
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.LOG
        evidenceTypes.CONFIG
        evidenceTypes.DOCUMENTATION
      ];
      implementationGuidance = ''
        Implement comprehensive logging with OpenTelemetry.
        Use distributed tracing for cross-system audit trails.
        Store logs in tamper-proof storage.
        Automated log analysis and alerting.
        Retain logs for required period (typically 6 years).
      '';
      riskLevel = riskLevels.CRITICAL;
      technicalControls = [
        technicalControlTypes.LOGGING
        technicalControlTypes.MONITORING
        technicalControlTypes.DATA_PROTECTION
      ];
      mappings = {
        soc2 = ["CC7.1" "CC7.2"];
        fedramp = ["AU-2" "AU-3" "AU-6"];
        iso27001 = ["A.12.4.1"];
        pcidss = ["10.1" "10.2" "10.3"];
      };
      testingProcedures = [
        "Verify logging coverage for ePHI access"
        "Review audit log retention"
        "Test log tampering detection"
        "Validate log analysis procedures"
      ];
      patterns = [
        patterns.INTERCEPTOR
        patterns.ASPECT
        patterns.DECORATOR
      ];
      validations = [
        "All ePHI access is logged"
        "Logs are tamper-proof"
        "Logs are reviewed regularly"
      ];
      metadata = {
        tags = ["technical" "required" "logging"];
        automatable = true;
        priority = "critical";
        addressable = false;
      };
    };

    integrity = mkControl {
      id = "164.312(c)(1)";
      name = "Integrity";
      category = "Technical Safeguards";
      description = ''
        Implement policies and procedures to protect electronic protected health
        information from improper alteration or destruction.
      '';
      requirements = [
        "Data integrity verification mechanisms"
        "Checksums or hashes for data validation"
        "Digital signatures for critical data"
        "Version control for data changes"
        "Tamper detection"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.CODE_REVIEW
        evidenceTypes.TEST
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Use cryptographic hashes to verify data integrity.
        Implement immutable audit logs.
        Use database triggers to track data modifications.
        Digital signatures for critical transactions.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.DATA_PROTECTION
        technicalControlTypes.LOGGING
      ];
      mappings = {
        soc2 = ["CC6.6"];
        fedramp = ["SI-7"];
        iso27001 = ["A.12.2.1"];
        pcidss = ["11.5"];
      };
      testingProcedures = [
        "Test integrity verification mechanisms"
        "Verify tamper detection"
        "Review integrity validation procedures"
      ];
      patterns = [
        patterns.INTERCEPTOR
        patterns.DECORATOR
      ];
      metadata = {
        tags = ["technical" "addressable" "data-protection"];
        automatable = true;
        addressable = true;
      };
    };

    authentication = mkControl {
      id = "164.312(d)";
      name = "Person or Entity Authentication";
      category = "Technical Safeguards";
      description = ''
        Implement procedures to verify that a person or entity seeking access
        to electronic protected health information is the one claimed.
      '';
      requirements = [
        "Multi-factor authentication"
        "Password policies"
        "Account lockout policies"
        "Session management"
        "Authentication logging"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.LOG
        evidenceTypes.TEST
      ];
      implementationGuidance = ''
        Implement MFA for all user accounts.
        Integrate with enterprise identity providers (WorkOS, Auth0, Okta).
        Enforce strong password policies.
        Log all authentication attempts.
      '';
      riskLevel = riskLevels.CRITICAL;
      technicalControls = [
        technicalControlTypes.AUTHENTICATION
        technicalControlTypes.LOGGING
      ];
      mappings = {
        soc2 = ["CC6.1"];
        fedramp = ["IA-2" "IA-5"];
        iso27001 = ["A.9.2.1" "A.9.4.2"];
        pcidss = ["8.2" "8.3"];
      };
      testingProcedures = [
        "Verify MFA implementation"
        "Test password policies"
        "Review authentication logs"
        "Test account lockout"
      ];
      patterns = [
        patterns.MIDDLEWARE
        patterns.INTERCEPTOR
      ];
      validations = [
        "MFA is enforced for all users"
        "Password policies meet requirements"
        "Authentication failures are logged"
      ];
      metadata = {
        tags = ["technical" "required" "authentication"];
        automatable = true;
        priority = "critical";
        addressable = false;
      };
    };

    transmission_security = mkControl {
      id = "164.312(e)(1)";
      name = "Transmission Security";
      category = "Technical Safeguards";
      description = ''
        Implement technical security measures to guard against unauthorized access
        to electronic protected health information that is being transmitted over
        an electronic communications network.
      '';
      requirements = [
        "Encryption in transit (TLS 1.2+)"
        "Network segmentation"
        "VPN for remote access"
        "Secure APIs"
        "Certificate management"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.SCAN
        evidenceTypes.CERTIFICATE
        evidenceTypes.CODE_REVIEW
      ];
      implementationGuidance = ''
        Enforce TLS 1.3 for all external communications.
        Use mutual TLS for service-to-service communication.
        Implement API gateway with authentication.
        Regular certificate rotation.
      '';
      riskLevel = riskLevels.CRITICAL;
      technicalControls = [
        technicalControlTypes.ENCRYPTION
        technicalControlTypes.NETWORK_SECURITY
      ];
      mappings = {
        soc2 = ["CC6.7"];
        fedramp = ["SC-8" "SC-13"];
        iso27001 = ["A.13.2.1"];
        pcidss = ["4.1" "4.2"];
      };
      testingProcedures = [
        "Scan for TLS configuration"
        "Test certificate validity"
        "Verify encryption in transit"
      ];
      patterns = [
        patterns.MIDDLEWARE
        patterns.INTERCEPTOR
      ];
      validations = [
        "All transmissions use TLS 1.2+"
        "Certificates are valid"
        "Weak ciphers are disabled"
      ];
      metadata = {
        tags = ["technical" "addressable" "encryption"];
        automatable = true;
        priority = "critical";
        addressable = true;
      };
    };
  };

  # § 164.308 Administrative Safeguards
  administrative = {
    security_management = mkControl {
      id = "164.308(a)(1)(ii)(D)";
      name = "Information System Activity Review";
      category = "Administrative Safeguards";
      description = ''
        Implement procedures to regularly review records of information system
        activity, such as audit logs, access reports, and security incident
        tracking reports.
      '';
      requirements = [
        "Regular audit log review"
        "Automated log analysis"
        "Security incident tracking"
        "Trend analysis"
        "Documented review procedures"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.LOG
        evidenceTypes.METRIC
      ];
      implementationGuidance = ''
        Implement automated log analysis with SIEM.
        Schedule regular log reviews.
        Use OpenTelemetry for comprehensive system visibility.
        Create dashboards in Grafana for monitoring.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.MONITORING
        technicalControlTypes.LOGGING
        technicalControlTypes.INCIDENT_RESPONSE
      ];
      mappings = {
        soc2 = ["CC7.1" "CC7.2"];
        fedramp = ["AU-6" "SI-4"];
        iso27001 = ["A.12.4.1"];
        pcidss = ["10.6"];
      };
      testingProcedures = [
        "Review log analysis procedures"
        "Verify regular review schedule"
        "Test automated alerting"
      ];
      patterns = [
        patterns.ASPECT
        patterns.INTERCEPTOR
      ];
      metadata = {
        tags = ["administrative" "required" "monitoring"];
        automatable = true;
        addressable = false;
      };
    };

    workforce_clearance = mkControl {
      id = "164.308(a)(3)(ii)(B)";
      name = "Workforce Clearance Procedure";
      category = "Administrative Safeguards";
      description = ''
        Implement procedures to determine that the access of a workforce member
        to electronic protected health information is appropriate.
      '';
      requirements = [
        "Access authorization procedures"
        "Background checks"
        "Documented access justification"
        "Regular access reviews"
        "Approval workflows"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Implement approval workflows for access requests.
        Document justification for all access grants.
        Conduct quarterly access reviews.
        Automated access provisioning with approvals.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.ACCESS_CONTROL
      ];
      mappings = {
        soc2 = ["CC6.2"];
        fedramp = ["AC-2"];
        iso27001 = ["A.9.2.1"];
        pcidss = ["7.1"];
      };
      testingProcedures = [
        "Review access authorization process"
        "Verify background check procedures"
        "Test approval workflows"
      ];
      patterns = [
        patterns.POLICY
      ];
      metadata = {
        tags = ["administrative" "addressable"];
        automatable = true;
        addressable = true;
      };
    };

    termination = mkControl {
      id = "164.308(a)(3)(ii)(C)";
      name = "Termination Procedures";
      category = "Administrative Safeguards";
      description = ''
        Implement procedures for terminating access to electronic protected health
        information when the employment of, or other arrangement with, a workforce
        member ends.
      '';
      requirements = [
        "Automated deprovisioning"
        "Immediate access revocation"
        "Equipment recovery procedures"
        "Exit interviews"
        "Access review post-termination"
      ];
      evidenceTypes = [
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.LOG
        evidenceTypes.DOCUMENTATION
      ];
      implementationGuidance = ''
        Integrate with HR system for termination triggers.
        Automated deprovisioning across all systems.
        Log all termination events.
        Post-termination access audit.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.ACCESS_CONTROL
        technicalControlTypes.LOGGING
      ];
      mappings = {
        soc2 = ["CC6.3"];
        fedramp = ["AC-2"];
        iso27001 = ["A.9.2.6"];
        pcidss = ["8.1.3"];
      };
      testingProcedures = [
        "Test automated deprovisioning"
        "Review termination logs"
        "Verify access revocation timing"
      ];
      patterns = [
        patterns.INTERCEPTOR
        patterns.POLICY
      ];
      metadata = {
        tags = ["administrative" "addressable" "access-control"];
        automatable = true;
        addressable = true;
        priority = "high";
      };
    };
  };

  # § 164.316 Policies and Procedures and Documentation Requirements
  documentation = {
    policies_procedures = mkControl {
      id = "164.316(a)";
      name = "Policies and Procedures";
      category = "Documentation";
      description = ''
        Implement reasonable and appropriate policies and procedures to comply
        with the standards, implementation specifications, or other requirements
        of this subpart.
      '';
      requirements = [
        "Written security policies"
        "Documented procedures"
        "Regular policy review and updates"
        "Policy distribution to workforce"
        "Policy acknowledgment tracking"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Use AI to generate policies from code.
        Version control for policy documents.
        Automated policy distribution.
        Track policy acknowledgments.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.CONFIGURATION_MANAGEMENT
      ];
      mappings = {
        soc2 = ["CC8.1"];
        fedramp = ["PL-1"];
        iso27001 = ["A.5.1"];
      };
      testingProcedures = [
        "Review policy documents"
        "Verify policy distribution"
        "Check acknowledgment records"
      ];
      patterns = [];
      metadata = {
        tags = ["administrative" "required" "documentation"];
        automatable = false;
        addressable = false;
      };
    };
  };
in

{
  inherit technical administrative documentation;

  # All HIPAA controls as a flat list
  allControls =
    builtins.attrValues technical ++
    builtins.attrValues administrative ++
    builtins.attrValues documentation;
}