{ schema }:

let
  inherit (schema) mkControl evidenceTypes riskLevels technicalControlTypes patterns;

  # GDPR (General Data Protection Regulation) Controls
  # Article 5 - Principles relating to processing of personal data
  principles = {
    art_5_1_a = mkControl {
      id = "Art.5(1)(a)";
      name = "Lawfulness, Fairness and Transparency";
      category = "Principles";
      description = ''
        Personal data shall be processed lawfully, fairly and in a transparent
        manner in relation to the data subject ('lawfulness, fairness and transparency').
      '';
      requirements = [
        "Establish lawful basis for processing"
        "Document legal basis for each processing activity"
        "Provide clear privacy notices"
        "Transparent data processing practices"
        "Communicate processing purposes to data subjects"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.LOG
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Document the legal basis for all data processing activities.
        Implement privacy notices that clearly explain data collection and use.
        Maintain records of processing activities (ROPA).
        Log all data processing with legal basis annotations.
      '';
      riskLevel = riskLevels.CRITICAL;
      technicalControls = [
        technicalControlTypes.LOGGING
        technicalControlTypes.DATA_PROTECTION
      ];
      canonicalObjectives = [
        "DATA.CLASSIFY.LIFECYCLE.RETENTION"
      ];
      testingProcedures = [
        "Review privacy notices"
        "Verify legal basis documentation"
        "Test transparency of data processing"
      ];
      patterns = [
        patterns.DECORATOR
      ];
      metadata = {
        tags = [ "administrative" "data-protection" ];
        automatable = true;
        priority = "critical";
      };
    };

    art_5_1_b = mkControl {
      id = "Art.5(1)(b)";
      name = "Purpose Limitation";
      category = "Principles";
      description = ''
        Personal data shall be collected for specified, explicit and legitimate
        purposes and not further processed in a manner that is incompatible with
        those purposes ('purpose limitation').
      '';
      requirements = [
        "Define specific purposes before collection"
        "Document processing purposes"
        "Prevent processing beyond stated purposes"
        "Regular purpose compliance reviews"
        "Purpose-based access controls"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.CONFIG
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Tag all personal data with its collection purpose.
        Implement purpose-based access controls.
        Log data access with purpose validation.
        Alert on data use outside of documented purposes.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.ACCESS_CONTROL
        technicalControlTypes.DATA_PROTECTION
        technicalControlTypes.LOGGING
      ];
      canonicalObjectives = [
        "DATA.CLASSIFY.LIFECYCLE.RETENTION"
      ];
      testingProcedures = [
        "Review purpose documentation"
        "Test purpose-based access controls"
        "Verify purpose limitation enforcement"
      ];
      patterns = [
        patterns.POLICY
        patterns.INTERCEPTOR
      ];
      metadata = {
        tags = [ "technical" "data-protection" ];
        automatable = true;
        priority = "high";
      };
    };

    art_5_1_c = mkControl {
      id = "Art.5(1)(c)";
      name = "Data Minimisation";
      category = "Principles";
      description = ''
        Personal data shall be adequate, relevant and limited to what is necessary
        in relation to the purposes for which they are processed ('data minimisation').
      '';
      requirements = [
        "Collect only necessary data"
        "Regular data minimization reviews"
        "Remove unnecessary data fields"
        "Justify data collection necessity"
        "Automated data minimization checks"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.CODE_REVIEW
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Review data collection forms to remove unnecessary fields.
        Implement data collection justification documentation.
        Regular audits of stored data to identify unused fields.
        Automated detection of excessive data collection.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.DATA_PROTECTION
      ];
      canonicalObjectives = [
        "DATA.CLASSIFY.MINIMIZE.STORAGE"
      ];
      testingProcedures = [
        "Review data collection practices"
        "Verify data necessity justification"
        "Audit stored personal data"
      ];
      patterns = [
        patterns.POLICY
      ];
      metadata = {
        tags = [ "administrative" "data-protection" ];
        automatable = true;
        priority = "high";
      };
    };

    art_5_1_d = mkControl {
      id = "Art.5(1)(d)";
      name = "Accuracy";
      category = "Principles";
      description = ''
        Personal data shall be accurate and, where necessary, kept up to date;
        every reasonable step must be taken to ensure that personal data that are
        inaccurate, having regard to the purposes for which they are processed,
        are erased or rectified without delay ('accuracy').
      '';
      requirements = [
        "Data accuracy validation"
        "Mechanisms for data correction"
        "Regular data accuracy reviews"
        "User-initiated data updates"
        "Inaccurate data deletion procedures"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.TEST
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Implement data validation at input.
        Provide user interfaces for data correction.
        Regular data quality audits.
        Automated detection of stale data.
        Quick rectification processes (within 30 days).
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.DATA_PROTECTION
      ];
      canonicalObjectives = [
        "DATA.INTEGRITY.VALIDATE.CHECKSUM"
      ];
      testingProcedures = [
        "Test data validation mechanisms"
        "Verify correction procedures"
        "Review data accuracy processes"
      ];
      patterns = [
        patterns.INTERCEPTOR
      ];
      metadata = {
        tags = [ "technical" "data-protection" ];
        automatable = true;
      };
    };

    art_5_1_e = mkControl {
      id = "Art.5(1)(e)";
      name = "Storage Limitation";
      category = "Principles";
      description = ''
        Personal data shall be kept in a form which permits identification of data
        subjects for no longer than is necessary for the purposes for which the
        personal data are processed ('storage limitation').
      '';
      requirements = [
        "Define retention periods for all data"
        "Automated data deletion after retention period"
        "Regular retention compliance reviews"
        "Pseudonymization after retention period"
        "Document retention justifications"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.DOCUMENTATION
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Implement automated data retention policies.
        Tag all personal data with retention period.
        Scheduled jobs for data deletion/anonymization.
        Log all data retention decisions.
        Regular audits of data age.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.DATA_PROTECTION
        technicalControlTypes.CONFIGURATION_MANAGEMENT
      ];
      canonicalObjectives = [
        "DATA.CLASSIFY.LIFECYCLE.RETENTION"
        "DATA.CLASSIFY.LIFECYCLE.DISPOSAL"
      ];
      testingProcedures = [
        "Review retention policies"
        "Test automated deletion"
        "Verify retention period enforcement"
      ];
      patterns = [
        patterns.POLICY
      ];
      validations = [
        "All personal data has defined retention period"
        "Automated deletion is configured"
        "Retention periods are documented"
      ];
      metadata = {
        tags = [ "technical" "data-protection" ];
        automatable = true;
        priority = "high";
      };
    };

    art_5_1_f = mkControl {
      id = "Art.5(1)(f)";
      name = "Integrity and Confidentiality";
      category = "Principles";
      description = ''
        Personal data shall be processed in a manner that ensures appropriate
        security of the personal data, including protection against unauthorised
        or unlawful processing and against accidental loss, destruction or damage,
        using appropriate technical or organisational measures ('integrity and confidentiality').
      '';
      requirements = [
        "Encryption of personal data at rest"
        "Encryption of personal data in transit"
        "Access controls for personal data"
        "Data breach detection and response"
        "Regular security assessments"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.SCAN
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.TEST
      ];
      implementationGuidance = ''
        Implement AES-256 encryption for personal data at rest.
        Use TLS 1.3 for all data transmission.
        Role-based access control with least privilege.
        Automated breach detection and alerting.
        Regular penetration testing and security audits.
      '';
      riskLevel = riskLevels.CRITICAL;
      technicalControls = [
        technicalControlTypes.ENCRYPTION
        technicalControlTypes.ACCESS_CONTROL
        technicalControlTypes.MONITORING
      ];
      canonicalObjectives = [
        "DATA.ENCRYPT.REST.SENSITIVE"
        "DATA.ENCRYPT.TRANSIT.TLS"
        "IAM.AUTHZ.ACCESS.LEAST_PRIVILEGE"
      ];
      testingProcedures = [
        "Verify encryption at rest"
        "Test TLS configuration"
        "Review access controls"
        "Test breach detection"
      ];
      patterns = [
        patterns.INTERCEPTOR
        patterns.MIDDLEWARE
      ];
      validations = [
        "All personal data is encrypted at rest"
        "All transmissions use TLS 1.2+"
        "Access controls are enforced"
      ];
      metadata = {
        tags = [ "technical" "encryption" "access-control" ];
        automatable = true;
        priority = "critical";
      };
    };
  };

  # Article 6 - Lawfulness of processing
  lawfulness = {
    art_6_1 = mkControl {
      id = "Art.6(1)";
      name = "Lawful Basis for Processing";
      category = "Lawfulness of Processing";
      description = ''
        Processing shall be lawful only if and to the extent that at least one
        of the following applies: consent, contract, legal obligation, vital
        interests, public task, or legitimate interests.
      '';
      requirements = [
        "Document legal basis for each processing activity"
        "Obtain and record consent when required"
        "Validate legal basis before processing"
        "Regular legal basis reviews"
        "Provide legal basis information to data subjects"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.LOG
      ];
      implementationGuidance = ''
        Create a legal basis registry for all processing activities.
        Implement consent management platform for consent tracking.
        Tag all data processing with legal basis.
        Automated legal basis validation before data access.
      '';
      riskLevel = riskLevels.CRITICAL;
      technicalControls = [
        technicalControlTypes.ACCESS_CONTROL
        technicalControlTypes.LOGGING
      ];
      canonicalObjectives = [ ];
      testingProcedures = [
        "Review legal basis documentation"
        "Verify consent mechanisms"
        "Test legal basis enforcement"
      ];
      patterns = [
        patterns.POLICY
        patterns.INTERCEPTOR
      ];
      metadata = {
        tags = [ "administrative" "legal" ];
        automatable = true;
        priority = "critical";
      };
    };
  };

  # Article 12 - Transparent information
  transparency = {
    art_12 = mkControl {
      id = "Art.12";
      name = "Transparent Information and Communication";
      category = "Transparency";
      description = ''
        The controller shall take appropriate measures to provide any information
        and any communication relating to processing to the data subject in a
        concise, transparent, intelligible and easily accessible form, using clear
        and plain language.
      '';
      requirements = [
        "Clear privacy notices"
        "Accessible privacy information"
        "Plain language communication"
        "Timely responses to data subject requests"
        "Free access to information"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Create clear, concise privacy notices.
        Implement privacy dashboard for data subjects.
        Automated privacy notice generation.
        Track and respond to information requests within 30 days.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [ ];
      canonicalObjectives = [ ];
      testingProcedures = [
        "Review privacy notices for clarity"
        "Test accessibility of privacy information"
        "Verify response timeframes"
      ];
      patterns = [ ];
      metadata = {
        tags = [ "administrative" "transparency" ];
        automatable = false;
      };
    };
  };

  # Article 15 - Right of access
  dataSubjectRights = {
    art_15 = mkControl {
      id = "Art.15";
      name = "Right of Access by the Data Subject";
      category = "Data Subject Rights";
      description = ''
        The data subject shall have the right to obtain from the controller
        confirmation as to whether or not personal data concerning him or her
        are being processed, and access to the personal data.
      '';
      requirements = [
        "Implement data access request process"
        "Provide data in structured format"
        "Respond within 30 days"
        "Verify data subject identity"
        "Free of charge for first request"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.LOG
      ];
      implementationGuidance = ''
        Build self-service data access portal.
        Automated data export functionality.
        Identity verification process.
        Track request timestamps and responses.
        Generate data reports in machine-readable format.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.ACCESS_CONTROL
        technicalControlTypes.AUTHENTICATION
      ];
      canonicalObjectives = [ ];
      testingProcedures = [
        "Test data access request process"
        "Verify identity verification"
        "Test data export functionality"
        "Verify response timeframe"
      ];
      patterns = [
        patterns.POLICY
      ];
      metadata = {
        tags = [ "technical" "data-subject-rights" ];
        automatable = true;
        priority = "high";
      };
    };

    art_16 = mkControl {
      id = "Art.16";
      name = "Right to Rectification";
      category = "Data Subject Rights";
      description = ''
        The data subject shall have the right to obtain from the controller
        without undue delay the rectification of inaccurate personal data
        concerning him or her.
      '';
      requirements = [
        "Data correction mechanism"
        "Respond to rectification requests within 30 days"
        "Notify third parties of corrections"
        "Verify data subject identity"
        "Log all corrections"
      ];
      evidenceTypes = [
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.LOG
        evidenceTypes.DOCUMENTATION
      ];
      implementationGuidance = ''
        Implement data correction API/UI.
        Track rectification requests and responses.
        Automated notification to data recipients.
        Log all data modifications with reason.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.DATA_PROTECTION
        technicalControlTypes.LOGGING
      ];
      canonicalObjectives = [ ];
      testingProcedures = [
        "Test rectification process"
        "Verify notification to third parties"
        "Test correction logging"
      ];
      patterns = [
        patterns.INTERCEPTOR
      ];
      metadata = {
        tags = [ "technical" "data-subject-rights" ];
        automatable = true;
      };
    };

    art_17 = mkControl {
      id = "Art.17";
      name = "Right to Erasure (Right to be Forgotten)";
      category = "Data Subject Rights";
      description = ''
        The data subject shall have the right to obtain from the controller the
        erasure of personal data concerning him or her without undue delay where
        certain grounds apply.
      '';
      requirements = [
        "Data deletion mechanism"
        "Respond to erasure requests within 30 days"
        "Notify third parties of erasures"
        "Document erasure exceptions"
        "Complete data removal across all systems"
      ];
      evidenceTypes = [
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.LOG
        evidenceTypes.DOCUMENTATION
      ];
      implementationGuidance = ''
        Implement cascading deletion across all data stores.
        Track erasure requests and completion.
        Automated notification to data recipients.
        Maintain erasure logs for compliance.
        Handle legal retention exceptions.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.DATA_PROTECTION
        technicalControlTypes.LOGGING
      ];
      canonicalObjectives = [
        "DATA.CLASSIFY.LIFECYCLE.DISPOSAL"
      ];
      testingProcedures = [
        "Test erasure process"
        "Verify complete data removal"
        "Test notification to third parties"
        "Verify erasure logging"
      ];
      patterns = [
        patterns.POLICY
      ];
      validations = [
        "Erasure removes all personal data"
        "Third parties are notified"
        "Erasure is logged"
      ];
      metadata = {
        tags = [ "technical" "data-subject-rights" ];
        automatable = true;
        priority = "high";
      };
    };

    art_18 = mkControl {
      id = "Art.18";
      name = "Right to Restriction of Processing";
      category = "Data Subject Rights";
      description = ''
        The data subject shall have the right to obtain from the controller
        restriction of processing where certain conditions apply.
      '';
      requirements = [
        "Processing restriction mechanism"
        "Mark restricted data"
        "Prevent processing of restricted data"
        "Notify data subject before lifting restriction"
        "Track restriction requests"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.LOG
      ];
      implementationGuidance = ''
        Implement data restriction flags in database.
        Access control enforcement for restricted data.
        Automated alerts on restricted data access attempts.
        Track restriction lifecycle.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.ACCESS_CONTROL
        technicalControlTypes.DATA_PROTECTION
      ];
      canonicalObjectives = [ ];
      testingProcedures = [
        "Test restriction mechanism"
        "Verify processing prevention"
        "Test restriction lifting notification"
      ];
      patterns = [
        patterns.INTERCEPTOR
      ];
      metadata = {
        tags = [ "technical" "data-subject-rights" ];
        automatable = true;
      };
    };

    art_20 = mkControl {
      id = "Art.20";
      name = "Right to Data Portability";
      category = "Data Subject Rights";
      description = ''
        The data subject shall have the right to receive the personal data
        concerning him or her in a structured, commonly used and machine-readable
        format and have the right to transmit those data to another controller.
      '';
      requirements = [
        "Export data in machine-readable format (JSON, CSV, XML)"
        "Include all personal data"
        "Respond within 30 days"
        "Direct transmission to another controller if requested"
        "Free of charge"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.TEST
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Build data export API in standard formats.
        Implement direct data transmission capability.
        Track portability requests and completions.
        Automated data packaging and delivery.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.DATA_PROTECTION
      ];
      canonicalObjectives = [ ];
      testingProcedures = [
        "Test data export formats"
        "Verify data completeness"
        "Test direct transmission"
      ];
      patterns = [ ];
      metadata = {
        tags = [ "technical" "data-subject-rights" ];
        automatable = true;
      };
    };

    art_21 = mkControl {
      id = "Art.21";
      name = "Right to Object";
      category = "Data Subject Rights";
      description = ''
        The data subject shall have the right to object, on grounds relating to
        his or her particular situation, to processing of personal data which is
        based on legitimate interests or the performance of a task in the public
        interest.
      '';
      requirements = [
        "Objection handling process"
        "Stop processing upon objection"
        "Document compelling legitimate grounds"
        "Respond within 30 days"
        "Provide opt-out mechanisms"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.LOG
      ];
      implementationGuidance = ''
        Implement objection request handling.
        Automated processing cessation upon objection.
        Track objection requests and responses.
        Provide easy opt-out mechanisms.
      '';
      riskLevel = riskLevels.MEDIUM;
      technicalControls = [
        technicalControlTypes.ACCESS_CONTROL
        technicalControlTypes.DATA_PROTECTION
      ];
      canonicalObjectives = [ ];
      testingProcedures = [
        "Test objection process"
        "Verify processing cessation"
        "Test opt-out mechanisms"
      ];
      patterns = [
        patterns.POLICY
      ];
      metadata = {
        tags = [ "technical" "data-subject-rights" ];
        automatable = true;
      };
    };
  };

  # Article 25 - Data protection by design and by default
  dataProtection = {
    art_25 = mkControl {
      id = "Art.25";
      name = "Data Protection by Design and by Default";
      category = "Data Protection Principles";
      description = ''
        The controller shall implement appropriate technical and organisational
        measures to ensure that, by default, only personal data which are
        necessary for each specific purpose are processed.
      '';
      requirements = [
        "Privacy by design in system architecture"
        "Default to minimal data collection"
        "Privacy impact assessments"
        "Regular privacy reviews"
        "Built-in privacy controls"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.CODE_REVIEW
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Conduct privacy impact assessments for new features.
        Default configurations minimize data collection.
        Privacy controls in system architecture.
        Regular privacy design reviews.
        Automated privacy compliance checks.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.DATA_PROTECTION
        technicalControlTypes.CONFIGURATION_MANAGEMENT
      ];
      canonicalObjectives = [
        "DATA.CLASSIFY.MINIMIZE.STORAGE"
      ];
      testingProcedures = [
        "Review system architecture for privacy"
        "Verify default configurations"
        "Conduct privacy impact assessments"
      ];
      patterns = [
        patterns.POLICY
      ];
      metadata = {
        tags = [ "technical" "data-protection" ];
        automatable = true;
        priority = "high";
      };
    };
  };

  # Article 32 - Security of processing
  security = {
    art_32 = mkControl {
      id = "Art.32";
      name = "Security of Processing";
      category = "Security";
      description = ''
        The controller and processor shall implement appropriate technical and
        organisational measures to ensure a level of security appropriate to the risk.
      '';
      requirements = [
        "Pseudonymisation and encryption"
        "Confidentiality, integrity, availability, and resilience"
        "Ability to restore availability and access"
        "Regular testing and evaluation of security measures"
        "Risk-based security approach"
      ];
      evidenceTypes = [
        evidenceTypes.CONFIG
        evidenceTypes.TEST
        evidenceTypes.SCAN
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Implement encryption for all personal data.
        Pseudonymization where possible.
        Regular security testing and penetration tests.
        Backup and disaster recovery procedures.
        Security monitoring and incident response.
      '';
      riskLevel = riskLevels.CRITICAL;
      technicalControls = [
        technicalControlTypes.ENCRYPTION
        technicalControlTypes.MONITORING
        technicalControlTypes.BACKUP
        technicalControlTypes.INCIDENT_RESPONSE
      ];
      canonicalObjectives = [
        "DATA.ENCRYPT.REST.SENSITIVE"
        "DATA.ENCRYPT.TRANSIT.TLS"
        "OPS.MONITOR.DETECT.CONTINUOUS"
      ];
      testingProcedures = [
        "Verify encryption implementation"
        "Test backup and recovery"
        "Conduct security assessments"
        "Test incident response"
      ];
      patterns = [
        patterns.INTERCEPTOR
        patterns.MIDDLEWARE
      ];
      validations = [
        "All personal data is encrypted"
        "Regular security testing is performed"
        "Backup procedures are in place"
      ];
      metadata = {
        tags = [ "technical" "security" "encryption" ];
        automatable = true;
        priority = "critical";
      };
    };
  };

  # Article 33 - Notification of breach
  breach = {
    art_33 = mkControl {
      id = "Art.33";
      name = "Notification of Personal Data Breach to Supervisory Authority";
      category = "Breach Notification";
      description = ''
        In the case of a personal data breach, the controller shall without undue
        delay and, where feasible, not later than 72 hours after having become
        aware of it, notify the supervisory authority.
      '';
      requirements = [
        "Breach detection mechanisms"
        "Notification to supervisory authority within 72 hours"
        "Document nature of breach"
        "Document affected data subjects"
        "Describe measures taken"
      ];
      evidenceTypes = [
        evidenceTypes.LOG
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.DOCUMENTATION
      ];
      implementationGuidance = ''
        Implement automated breach detection.
        Incident response procedures with timelines.
        Breach notification templates and processes.
        Track breach notifications and responses.
        Regular breach response drills.
      '';
      riskLevel = riskLevels.CRITICAL;
      technicalControls = [
        technicalControlTypes.MONITORING
        technicalControlTypes.INCIDENT_RESPONSE
        technicalControlTypes.LOGGING
      ];
      canonicalObjectives = [
        "OPS.MONITOR.DETECT.ANOMALY"
      ];
      testingProcedures = [
        "Test breach detection"
        "Review notification procedures"
        "Conduct breach response drills"
      ];
      patterns = [
        patterns.INTERCEPTOR
      ];
      metadata = {
        tags = [ "technical" "incident-response" ];
        automatable = true;
        priority = "critical";
      };
    };

    art_34 = mkControl {
      id = "Art.34";
      name = "Communication of Personal Data Breach to Data Subject";
      category = "Breach Notification";
      description = ''
        When the personal data breach is likely to result in a high risk to the
        rights and freedoms of natural persons, the controller shall communicate
        the breach to the data subject without undue delay.
      '';
      requirements = [
        "Risk assessment of breach impact"
        "Notification to affected data subjects"
        "Clear description of breach nature"
        "Contact point for information"
        "Describe measures taken and recommended"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.AUDIT_TRAIL
        evidenceTypes.LOG
      ];
      implementationGuidance = ''
        Risk assessment framework for breaches.
        Automated data subject notification system.
        Breach notification templates.
        Track data subject notifications.
        Provide support channels for affected individuals.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.INCIDENT_RESPONSE
      ];
      canonicalObjectives = [ ];
      testingProcedures = [
        "Test risk assessment process"
        "Review notification templates"
        "Test data subject notification system"
      ];
      patterns = [ ];
      metadata = {
        tags = [ "administrative" "incident-response" ];
        automatable = true;
        priority = "high";
      };
    };
  };

  # Article 35 - Data protection impact assessment
  assessment = {
    art_35 = mkControl {
      id = "Art.35";
      name = "Data Protection Impact Assessment";
      category = "Impact Assessment";
      description = ''
        Where a type of processing is likely to result in a high risk to the
        rights and freedoms of natural persons, the controller shall carry out
        an assessment of the impact of the envisioned processing operations on
        the protection of personal data.
      '';
      requirements = [
        "Conduct DPIA for high-risk processing"
        "Systematic description of processing"
        "Assessment of necessity and proportionality"
        "Risk assessment to data subjects"
        "Measures to address risks"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        DPIA framework and templates.
        Risk assessment methodology.
        Stakeholder consultation process.
        Regular DPIA reviews.
        Document DPIA outcomes and mitigations.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [ ];
      canonicalObjectives = [ ];
      testingProcedures = [
        "Review DPIA procedures"
        "Verify DPIA completion for high-risk processing"
        "Review risk mitigation measures"
      ];
      patterns = [ ];
      metadata = {
        tags = [ "administrative" "risk-assessment" ];
        automatable = false;
        priority = "high";
      };
    };
  };

  # Article 30 - Records of processing activities
  records = {
    art_30 = mkControl {
      id = "Art.30";
      name = "Records of Processing Activities";
      category = "Accountability";
      description = ''
        Each controller and processor shall maintain a record of processing
        activities under its responsibility.
      '';
      requirements = [
        "Maintain ROPA (Record of Processing Activities)"
        "Document processing purposes"
        "Document data categories"
        "Document data recipients"
        "Document data transfers"
        "Document retention periods"
        "Document security measures"
      ];
      evidenceTypes = [
        evidenceTypes.DOCUMENTATION
        evidenceTypes.AUDIT_TRAIL
      ];
      implementationGuidance = ''
        Create and maintain comprehensive ROPA.
        Automated ROPA generation from system metadata.
        Regular ROPA reviews and updates.
        ROPA available to supervisory authority.
      '';
      riskLevel = riskLevels.HIGH;
      technicalControls = [
        technicalControlTypes.LOGGING
        technicalControlTypes.CONFIGURATION_MANAGEMENT
      ];
      canonicalObjectives = [ ];
      testingProcedures = [
        "Review ROPA completeness"
        "Verify ROPA accuracy"
        "Test ROPA update procedures"
      ];
      patterns = [
        patterns.DECORATOR
      ];
      metadata = {
        tags = [ "administrative" "accountability" ];
        automatable = true;
        priority = "high";
      };
    };
  };
in

{
  inherit principles lawfulness transparency dataSubjectRights dataProtection
    security breach assessment records;

  # All GDPR controls as a flat list
  allControls =
    builtins.attrValues principles ++
    builtins.attrValues lawfulness ++
    builtins.attrValues transparency ++
    builtins.attrValues dataSubjectRights ++
    builtins.attrValues dataProtection ++
    builtins.attrValues security ++
    builtins.attrValues breach ++
    builtins.attrValues assessment ++
    builtins.attrValues records;
}
