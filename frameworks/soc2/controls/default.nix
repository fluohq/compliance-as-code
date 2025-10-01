{ schema }:

let
  inherit (schema) mkControl evidenceTypes riskLevels technicalControlTypes patterns;

  # Common Criteria Controls
  cc = {
    # CC6: Logical and Physical Access Controls
    cc6_1 = mkControl {
      id = "CC6.1";
      name = "Logical Access - Authorization";
      category = "Logical and Physical Access Controls";
      description = ''
        The entity implements logical access security software, infrastructure,
        and architectures over protected information assets to protect them from
        security events to meet the entity's objectives.
      '';
      requirements = [
        "Implement access control lists (ACLs)"
        "Define user roles and permissions"
        "Enforce least privilege principle"
        "Maintain separation of duties"
        "Regular access reviews"
      ];
      evidenceTypes = [
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.CONFIG
        evidenceTypes.LOG
        evidenceTypes.CODE_REVIEW
      ];
      implementationGuidance = ''
        Implement role-based access control (RBAC) with clear separation between
        user roles. All access decisions should be logged and auditable.
        Use tenant isolation to ensure data separation in multi-tenant systems.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.ACCESS_CONTROL
        technicalControlTypes.AUTHORIZATION
        technicalControlTypes.LOGGING
      ];
      mappings = {
        hipaa = [ "164.312(a)(1)" ];
        fedramp = [ "AC-2" "AC-3" ];
        iso27001 = [ "A.9.2.1" "A.9.4.1" ];
        pcidss = [ "7.1" "8.1" ];
      };
      testingProcedures = [
        "Verify RBAC implementation"
        "Test unauthorized access attempts"
        "Review access logs"
        "Validate tenant isolation"
      ];
      patterns = [
        patterns.INTERCEPTOR
        patterns.MIDDLEWARE
        patterns.POLICY
      ];
      validations = [
        "All protected resources require authentication"
        "Authorization decisions are logged"
        "Access is denied by default"
      ];
      metadata = {
        tags = [ "technical" "access-control" ];
        automatable = true;
        priority = "high";
      };
    };

    cc6_2 = mkControl {
      id = "CC6.2";
      name = "Access Control - User Registration";
      category = "Logical and Physical Access Controls";
      description = ''
        Prior to issuing system credentials and granting system access, the entity
        registers and authorizes new internal and external users whose access is
        administered by the entity.
      '';
      requirements = [
        "Formal user registration process"
        "Manager approval for access requests"
        "Background checks for sensitive access"
        "Documentation of access justification"
        "Automated provisioning workflows"
      ];
      evidenceTypes = [
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.DOCUMENTATION
        evidenceTypes.LOG
      ];
      implementationGuidance = ''
        Implement automated user provisioning with approval workflows.
        Integrate with identity providers (SSO/SAML) where possible.
        Track all access grants with justification and approval chain.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.ACCESS_CONTROL
        technicalControlTypes.AUTHENTICATION
      ];
      mappings = {
        hipaa = [ "164.308(a)(3)(ii)(B)" ];
        fedramp = [ "AC-2" "IA-2" ];
        iso27001 = [ "A.9.2.1" ];
        pcidss = [ "8.1.3" "8.1.4" ];
      };
      testingProcedures = [
        "Review user provisioning logs"
        "Validate approval workflows"
        "Test unauthorized provisioning attempts"
      ];
      patterns = [
        patterns.MIDDLEWARE
        patterns.DECORATOR
      ];
      metadata = {
        tags = [ "administrative" "access-control" ];
        automatable = true;
      };
    };

    cc6_3 = mkControl {
      id = "CC6.3";
      name = "Access Control - De-provisioning";
      category = "Logical and Physical Access Controls";
      description = ''
        The entity authorizes, modifies, or removes access to data, software,
        functions, and other protected information assets based on roles,
        responsibilities, or the system design and changes.
      '';
      requirements = [
        "Automated deprovisioning on termination"
        "Regular access reviews"
        "Role change handling"
        "Orphaned account detection"
        "Audit trail of access changes"
      ];
      evidenceTypes = [
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.LOG
        evidenceTypes.CONFIG
      ];
      implementationGuidance = ''
        Implement automated deprovisioning triggered by HR system events.
        Conduct quarterly access reviews to identify orphaned accounts.
        Log all access modifications with before/after state.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.ACCESS_CONTROL
        technicalControlTypes.LOGGING
      ];
      mappings = {
        hipaa = [ "164.308(a)(3)(ii)(C)" ];
        fedramp = [ "AC-2" ];
        iso27001 = [ "A.9.2.6" ];
        pcidss = [ "8.1.3" ];
      };
      testingProcedures = [
        "Review deprovisioning logs"
        "Test automated deprovisioning"
        "Identify orphaned accounts"
      ];
      patterns = [
        patterns.INTERCEPTOR
        patterns.POLICY
      ];
      metadata = {
        tags = [ "technical" "access-control" ];
        automatable = true;
        priority = "high";
      };
    };

    cc6_6 = mkControl {
      id = "CC6.6";
      name = "Encryption - Data at Rest";
      category = "Logical and Physical Access Controls";
      description = ''
        The entity implements logical access security measures to protect against
        threats from sources outside its system boundaries.
      '';
      requirements = [
        "Encrypt sensitive data at rest"
        "Use strong encryption algorithms (AES-256)"
        "Secure key management"
        "Regular key rotation"
        "Hardware security modules (HSM) for key storage"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.SCAN
        evidenceTypes.CODE_REVIEW
        evidenceTypes.CERTIFICATE
      ];
      implementationGuidance = ''
        Use database-level encryption or application-level encryption for sensitive data.
        Store encryption keys in a separate key management service (KMS).
        Implement automatic key rotation policies.
      '';
      riskLevel = riskLevels.CRITICAL;
      technicalControls = [
        technicalControlTypes.ENCRYPTION
        technicalControlTypes.DATA_PROTECTION
        technicalControlTypes.CONFIGURATION_MANAGEMENT
      ];
      mappings = {
        hipaa = [ "164.312(a)(2)(iv)" ];
        fedramp = [ "SC-28" ];
        iso27001 = [ "A.10.1.1" ];
        pcidss = [ "3.4" "3.5" ];
      };
      testingProcedures = [
        "Verify encryption at rest configuration"
        "Test key rotation procedures"
        "Review encryption algorithms"
        "Validate key storage security"
      ];
      patterns = [
        patterns.DECORATOR
        patterns.INTERCEPTOR
      ];
      validations = [
        "All sensitive data is encrypted at rest"
        "Encryption keys are stored securely"
        "Key rotation is automated"
      ];
      metadata = {
        tags = [ "technical" "encryption" ];
        automatable = true;
        priority = "critical";
      };
    };

    cc6_7 = mkControl {
      id = "CC6.7";
      name = "Encryption - Data in Transit";
      category = "Logical and Physical Access Controls";
      description = ''
        The entity restricts the transmission, movement, and removal of information
        to authorized internal and external users and processes, and protects it
        during transmission, movement, or removal.
      '';
      requirements = [
        "Use TLS 1.2+ for all communications"
        "Implement certificate management"
        "Enforce HTTPS for web applications"
        "Encrypt API communications"
        "Secure file transfer protocols"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.SCAN
        evidenceTypes.CERTIFICATE
        evidenceTypes.CODE_REVIEW
      ];
      implementationGuidance = ''
        Enforce TLS 1.3 for all external communications.
        Use mutual TLS (mTLS) for service-to-service communication.
        Implement certificate pinning for mobile applications.
        Regularly scan for weak ciphers and protocols.
      '';
      riskLevel = riskLevels.CRITICAL;
      technicalControls = [
        technicalControlTypes.ENCRYPTION
        technicalControlTypes.NETWORK_SECURITY
        technicalControlTypes.CONFIGURATION_MANAGEMENT
      ];
      mappings = {
        hipaa = [ "164.312(e)(1)" ];
        fedramp = [ "SC-8" ];
        iso27001 = [ "A.13.2.1" ];
        pcidss = [ "4.1" "4.2" ];
      };
      testingProcedures = [
        "Scan for TLS version support"
        "Test certificate validity"
        "Verify cipher suite configuration"
        "Test unencrypted connections"
      ];
      patterns = [
        patterns.MIDDLEWARE
        patterns.INTERCEPTOR
      ];
      validations = [
        "All communications use TLS 1.2+"
        "Certificates are valid and trusted"
        "Weak ciphers are disabled"
      ];
      metadata = {
        tags = [ "technical" "encryption" ];
        automatable = true;
        priority = "critical";
      };
    };

    # CC7: System Operations
    cc7_1 = mkControl {
      id = "CC7.1";
      name = "System Operations - Detection";
      category = "System Operations";
      description = ''
        To meet its objectives, the entity uses detection and monitoring procedures
        to identify (1) changes to configurations that result in the introduction
        of new vulnerabilities, and (2) susceptibilities to newly discovered
        vulnerabilities.
      '';
      requirements = [
        "Real-time monitoring of system events"
        "Automated alerting for security events"
        "Log aggregation and analysis"
        "Anomaly detection"
        "Security information and event management (SIEM)"
      ];
      evidenceTypes = [
        evidenceTypes.LOG
        evidenceTypes.METRIC
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.SCAN
      ];
      implementationGuidance = ''
        Implement distributed tracing with OpenTelemetry.
        Use spans to track all security-relevant operations.
        Set up automated alerts for anomalies.
        Integrate with SIEM solutions for correlation.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.MONITORING
        technicalControlTypes.LOGGING
        technicalControlTypes.INCIDENT_RESPONSE
      ];
      mappings = {
        hipaa = [ "164.308(a)(1)(ii)(D)" ];
        fedramp = [ "SI-4" "AU-6" ];
        iso27001 = [ "A.12.4.1" ];
        pcidss = [ "10.6" "11.4" ];
      };
      testingProcedures = [
        "Verify monitoring coverage"
        "Test alerting rules"
        "Review log retention"
        "Validate anomaly detection"
      ];
      patterns = [
        patterns.INTERCEPTOR
        patterns.ASPECT
        patterns.DECORATOR
      ];
      validations = [
        "All security events are logged"
        "Alerts are triggered for anomalies"
        "Logs are retained for required period"
      ];
      metadata = {
        tags = [ "technical" "monitoring" ];
        automatable = true;
        priority = "high";
      };
    };

    cc7_2 = mkControl {
      id = "CC7.2";
      name = "System Operations - Monitoring";
      category = "System Operations";
      description = ''
        The entity monitors system components and the operation of those components
        for anomalies that are indicative of malicious acts, natural disasters,
        and errors affecting the entity's ability to meet its objectives.
      '';
      requirements = [
        "Continuous system monitoring"
        "Performance metrics tracking"
        "Health checks and status monitoring"
        "Automated incident response"
        "Capacity planning and alerts"
      ];
      evidenceTypes = [
        evidenceTypes.METRIC
        evidenceTypes.LOG
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Use Prometheus for metrics collection.
        Implement Grafana dashboards for visualization.
        Set up health check endpoints for all services.
        Configure auto-scaling based on metrics.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.MONITORING
        technicalControlTypes.INCIDENT_RESPONSE
      ];
      mappings = {
        hipaa = [ "164.308(a)(1)(ii)(D)" ];
        fedramp = [ "SI-4" ];
        iso27001 = [ "A.12.4.1" ];
        pcidss = [ "10.6" ];
      };
      testingProcedures = [
        "Review monitoring coverage"
        "Test alerting thresholds"
        "Validate health checks"
      ];
      patterns = [
        patterns.INTERCEPTOR
        patterns.MIDDLEWARE
      ];
      metadata = {
        tags = [ "technical" "monitoring" ];
        automatable = true;
      };
    };

    # CC8: Change Management
    cc8_1 = mkControl {
      id = "CC8.1";
      name = "Change Management - Authorization";
      category = "Change Management";
      description = ''
        The entity authorizes, designs, develops or acquires, configures,
        documents, tests, approves, and implements changes to infrastructure,
        data, software, and procedures to meet its objectives.
      '';
      requirements = [
        "Formal change approval process"
        "Change documentation and tracking"
        "Testing before deployment"
        "Rollback procedures"
        "Change review and audit"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.TEST
        evidenceTypes.CODE_REVIEW
      ];
      implementationGuidance = ''
        Implement GitOps workflows with pull request approvals.
        Use automated testing in CI/CD pipelines.
        Maintain change logs with OpenTelemetry spans.
        Implement canary deployments for risk reduction.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.CONFIGURATION_MANAGEMENT
        technicalControlTypes.LOGGING
      ];
      mappings = {
        hipaa = [ "164.308(a)(8)" ];
        fedramp = [ "CM-3" "CM-4" ];
        iso27001 = [ "A.12.1.2" "A.14.2.2" ];
        pcidss = [ "6.4" ];
      };
      testingProcedures = [
        "Review change request process"
        "Verify approval workflows"
        "Test rollback procedures"
      ];
      patterns = [
        patterns.DECORATOR
        patterns.INTERCEPTOR
      ];
      metadata = {
        tags = [ "administrative" "change-management" ];
        automatable = true;
      };
    };
  };
in

{
  inherit cc;

  # All SOC 2 controls as a flat list
  allControls = builtins.attrValues cc;
}
