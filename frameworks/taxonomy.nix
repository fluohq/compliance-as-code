# Canonical Security Control Taxonomy
# This defines abstract security controls that all compliance frameworks map to.
# Think of this as the ontology - frameworks are instances that reference these concepts.
#
# Structure:
#   Domain -> Category -> Capability -> Control Objective
#
# Frameworks map their specific requirements to Control Objectives,
# creating a graph where we can traverse to find relationships.

{
  # Root taxonomy definition
  taxonomy = {
    # Identity and Access Management Domain
    identity_access = {
      id = "IAM";
      name = "Identity and Access Management";
      description = "Controls related to identifying users, managing their access rights, and authenticating their identity";

      categories = {
        # User Lifecycle Management
        user_lifecycle = {
          id = "IAM.LIFECYCLE";
          name = "User Lifecycle Management";
          description = "Managing user accounts from creation to termination";

          capabilities = {
            provisioning = {
              id = "IAM.LIFECYCLE.PROVISION";
              name = "User Provisioning";
              description = "Creating and enabling user accounts";

              objectives = {
                registration = {
                  id = "IAM.LIFECYCLE.PROVISION.REGISTER";
                  name = "User Registration";
                  description = "Formal process for registering new users and assigning access rights";
                  canonical = true;
                };

                approval = {
                  id = "IAM.LIFECYCLE.PROVISION.APPROVE";
                  name = "Access Approval";
                  description = "Approval workflow for granting access rights";
                  canonical = true;
                };
              };
            };

            deprovisioning = {
              id = "IAM.LIFECYCLE.DEPROVISION";
              name = "User Deprovisioning";
              description = "Disabling and removing user accounts";

              objectives = {
                termination = {
                  id = "IAM.LIFECYCLE.DEPROVISION.TERMINATE";
                  name = "Access Termination";
                  description = "Immediate removal of access rights upon employment termination";
                  canonical = true;
                };

                inactive = {
                  id = "IAM.LIFECYCLE.DEPROVISION.INACTIVE";
                  name = "Inactive Account Management";
                  description = "Disabling accounts after period of inactivity";
                  canonical = true;
                };
              };
            };
          };
        };

        # Authentication
        authentication = {
          id = "IAM.AUTH";
          name = "Authentication";
          description = "Verifying user identity";

          capabilities = {
            identity_verification = {
              id = "IAM.AUTH.VERIFY";
              name = "Identity Verification";
              description = "Proving user identity before granting access";

              objectives = {
                unique_identifier = {
                  id = "IAM.AUTH.VERIFY.UNIQUE_ID";
                  name = "Unique User Identification";
                  description = "Each user must have a unique identifier";
                  canonical = true;
                };

                multi_factor = {
                  id = "IAM.AUTH.VERIFY.MFA";
                  name = "Multi-Factor Authentication";
                  description = "Require multiple authentication factors";
                  canonical = true;
                };
              };
            };

            credential_management = {
              id = "IAM.AUTH.CREDENTIAL";
              name = "Credential Management";
              description = "Managing authentication credentials";

              objectives = {
                password_complexity = {
                  id = "IAM.AUTH.CREDENTIAL.COMPLEXITY";
                  name = "Password Complexity";
                  description = "Enforce strong password requirements";
                  canonical = true;
                };

                password_rotation = {
                  id = "IAM.AUTH.CREDENTIAL.ROTATION";
                  name = "Password Rotation";
                  description = "Periodic password changes and history enforcement";
                  canonical = true;
                };
              };
            };

            session_management = {
              id = "IAM.AUTH.SESSION";
              name = "Session Management";
              description = "Managing authenticated sessions";

              objectives = {
                timeout = {
                  id = "IAM.AUTH.SESSION.TIMEOUT";
                  name = "Session Timeout";
                  description = "Automatic session termination after inactivity";
                  canonical = true;
                };

                lockout = {
                  id = "IAM.AUTH.SESSION.LOCKOUT";
                  name = "Account Lockout";
                  description = "Lock account after failed authentication attempts";
                  canonical = true;
                };
              };
            };
          };
        };

        # Authorization
        authorization = {
          id = "IAM.AUTHZ";
          name = "Authorization";
          description = "Controlling access to resources";

          capabilities = {
            access_control = {
              id = "IAM.AUTHZ.ACCESS";
              name = "Access Control";
              description = "Enforcing access control decisions";

              objectives = {
                least_privilege = {
                  id = "IAM.AUTHZ.ACCESS.LEAST_PRIVILEGE";
                  name = "Least Privilege";
                  description = "Grant minimum access necessary for job function";
                  canonical = true;
                };

                role_based = {
                  id = "IAM.AUTHZ.ACCESS.RBAC";
                  name = "Role-Based Access Control";
                  description = "Access based on assigned roles";
                  canonical = true;
                };

                deny_default = {
                  id = "IAM.AUTHZ.ACCESS.DENY_DEFAULT";
                  name = "Deny by Default";
                  description = "All access denied unless explicitly granted";
                  canonical = true;
                };
              };
            };
          };
        };
      };
    };

    # Data Protection Domain
    data_protection = {
      id = "DATA";
      name = "Data Protection";
      description = "Controls related to protecting data confidentiality, integrity, and availability";

      categories = {
        # Encryption
        encryption = {
          id = "DATA.ENCRYPT";
          name = "Encryption";
          description = "Cryptographic protection of data";

          capabilities = {
            at_rest = {
              id = "DATA.ENCRYPT.REST";
              name = "Encryption at Rest";
              description = "Protecting stored data with encryption";

              objectives = {
                sensitive_data = {
                  id = "DATA.ENCRYPT.REST.SENSITIVE";
                  name = "Encrypt Sensitive Data at Rest";
                  description = "All sensitive data must be encrypted when stored";
                  canonical = true;
                };

                strong_algorithms = {
                  id = "DATA.ENCRYPT.REST.ALGORITHM";
                  name = "Strong Encryption Algorithms";
                  description = "Use approved cryptographic algorithms (AES-256, etc.)";
                  canonical = true;
                };
              };
            };

            in_transit = {
              id = "DATA.ENCRYPT.TRANSIT";
              name = "Encryption in Transit";
              description = "Protecting transmitted data with encryption";

              objectives = {
                tls = {
                  id = "DATA.ENCRYPT.TRANSIT.TLS";
                  name = "TLS for Transmission";
                  description = "Use TLS 1.2+ for all data transmissions";
                  canonical = true;
                };

                certificate_management = {
                  id = "DATA.ENCRYPT.TRANSIT.CERT";
                  name = "Certificate Management";
                  description = "Proper management of TLS certificates";
                  canonical = true;
                };
              };
            };

            key_management = {
              id = "DATA.ENCRYPT.KEY";
              name = "Key Management";
              description = "Managing cryptographic keys";

              objectives = {
                secure_storage = {
                  id = "DATA.ENCRYPT.KEY.STORAGE";
                  name = "Secure Key Storage";
                  description = "Store keys in HSM or secure key management system";
                  canonical = true;
                };

                key_rotation = {
                  id = "DATA.ENCRYPT.KEY.ROTATION";
                  name = "Key Rotation";
                  description = "Regular rotation of encryption keys";
                  canonical = true;
                };
              };
            };
          };
        };

        # Data Integrity
        integrity = {
          id = "DATA.INTEGRITY";
          name = "Data Integrity";
          description = "Ensuring data is not improperly altered";

          capabilities = {
            validation = {
              id = "DATA.INTEGRITY.VALIDATE";
              name = "Integrity Validation";
              description = "Verifying data has not been tampered with";

              objectives = {
                checksums = {
                  id = "DATA.INTEGRITY.VALIDATE.CHECKSUM";
                  name = "Integrity Checksums";
                  description = "Use cryptographic hashes to verify data integrity";
                  canonical = true;
                };

                tamper_detection = {
                  id = "DATA.INTEGRITY.VALIDATE.TAMPER";
                  name = "Tamper Detection";
                  description = "Detect unauthorized modifications to data";
                  canonical = true;
                };
              };
            };
          };
        };

        # Data Classification and Handling
        classification = {
          id = "DATA.CLASSIFY";
          name = "Data Classification";
          description = "Categorizing and handling data based on sensitivity";

          capabilities = {
            lifecycle = {
              id = "DATA.CLASSIFY.LIFECYCLE";
              name = "Data Lifecycle Management";
              description = "Managing data through its lifecycle";

              objectives = {
                retention = {
                  id = "DATA.CLASSIFY.LIFECYCLE.RETENTION";
                  name = "Data Retention";
                  description = "Define and enforce data retention policies";
                  canonical = true;
                };

                disposal = {
                  id = "DATA.CLASSIFY.LIFECYCLE.DISPOSAL";
                  name = "Secure Disposal";
                  description = "Securely delete data when no longer needed";
                  canonical = true;
                };
              };
            };

            minimization = {
              id = "DATA.CLASSIFY.MINIMIZE";
              name = "Data Minimization";
              description = "Limit collection and storage of sensitive data";

              objectives = {
                storage_limitation = {
                  id = "DATA.CLASSIFY.MINIMIZE.STORAGE";
                  name = "Minimize Data Storage";
                  description = "Store only necessary sensitive data";
                  canonical = true;
                };

                masking = {
                  id = "DATA.CLASSIFY.MINIMIZE.MASK";
                  name = "Data Masking";
                  description = "Mask sensitive data when displayed";
                  canonical = true;
                };
              };
            };
          };
        };
      };
    };

    # System Operations Domain
    operations = {
      id = "OPS";
      name = "System Operations";
      description = "Controls related to secure system operations and monitoring";

      categories = {
        # Monitoring and Detection
        monitoring = {
          id = "OPS.MONITOR";
          name = "Monitoring and Detection";
          description = "Detecting security events and anomalies";

          capabilities = {
            event_detection = {
              id = "OPS.MONITOR.DETECT";
              name = "Event Detection";
              description = "Real-time detection of security events";

              objectives = {
                continuous_monitoring = {
                  id = "OPS.MONITOR.DETECT.CONTINUOUS";
                  name = "Continuous Monitoring";
                  description = "Real-time monitoring of system activity";
                  canonical = true;
                };

                anomaly_detection = {
                  id = "OPS.MONITOR.DETECT.ANOMALY";
                  name = "Anomaly Detection";
                  description = "Identify unusual patterns indicating security issues";
                  canonical = true;
                };

                intrusion_detection = {
                  id = "OPS.MONITOR.DETECT.INTRUSION";
                  name = "Intrusion Detection";
                  description = "Detect unauthorized access attempts";
                  canonical = true;
                };
              };
            };
          };
        };

        # Logging and Audit
        logging = {
          id = "OPS.LOG";
          name = "Logging and Audit";
          description = "Recording system and user activity";

          capabilities = {
            audit_logging = {
              id = "OPS.LOG.AUDIT";
              name = "Audit Logging";
              description = "Comprehensive logging of security-relevant events";

              objectives = {
                comprehensive = {
                  id = "OPS.LOG.AUDIT.COMPREHENSIVE";
                  name = "Comprehensive Logging";
                  description = "Log all security-relevant events";
                  canonical = true;
                };

                content_requirements = {
                  id = "OPS.LOG.AUDIT.CONTENT";
                  name = "Log Content Requirements";
                  description = "Logs must include who, what, when, where, outcome";
                  canonical = true;
                };

                protection = {
                  id = "OPS.LOG.AUDIT.PROTECT";
                  name = "Log Protection";
                  description = "Protect logs from tampering and unauthorized access";
                  canonical = true;
                };
              };
            };

            log_review = {
              id = "OPS.LOG.REVIEW";
              name = "Log Review";
              description = "Regular review and analysis of logs";

              objectives = {
                regular_review = {
                  id = "OPS.LOG.REVIEW.REGULAR";
                  name = "Regular Log Review";
                  description = "Periodic review of audit logs for anomalies";
                  canonical = true;
                };

                retention = {
                  id = "OPS.LOG.REVIEW.RETENTION";
                  name = "Log Retention";
                  description = "Retain logs for required period";
                  canonical = true;
                };
              };
            };
          };
        };
      };
    };

    # Change Management Domain
    change_management = {
      id = "CHANGE";
      name = "Change Management";
      description = "Controls related to managing system changes";

      categories = {
        # Configuration Management
        configuration = {
          id = "CHANGE.CONFIG";
          name = "Configuration Management";
          description = "Managing system configurations and changes";

          capabilities = {
            change_control = {
              id = "CHANGE.CONFIG.CONTROL";
              name = "Change Control";
              description = "Formal change control process";

              objectives = {
                approval = {
                  id = "CHANGE.CONFIG.CONTROL.APPROVE";
                  name = "Change Approval";
                  description = "All changes require approval before implementation";
                  canonical = true;
                };

                testing = {
                  id = "CHANGE.CONFIG.CONTROL.TEST";
                  name = "Change Testing";
                  description = "Test changes before production deployment";
                  canonical = true;
                };

                documentation = {
                  id = "CHANGE.CONFIG.CONTROL.DOCUMENT";
                  name = "Change Documentation";
                  description = "Document all changes and their rationale";
                  canonical = true;
                };

                rollback = {
                  id = "CHANGE.CONFIG.CONTROL.ROLLBACK";
                  name = "Rollback Capability";
                  description = "Ability to rollback failed changes";
                  canonical = true;
                };
              };
            };

            security_impact = {
              id = "CHANGE.CONFIG.SECURITY";
              name = "Security Impact Analysis";
              description = "Analyze security impact of changes";

              objectives = {
                impact_analysis = {
                  id = "CHANGE.CONFIG.SECURITY.ANALYZE";
                  name = "Security Impact Analysis";
                  description = "Evaluate security implications before implementing changes";
                  canonical = true;
                };
              };
            };
          };
        };
      };
    };

    # Security Operations Domain
    security_operations = {
      id = "SECOPS";
      name = "Security Operations";
      description = "Controls related to security operations and incident response";

      categories = {
        # Vulnerability Management
        vulnerability = {
          id = "SECOPS.VULN";
          name = "Vulnerability Management";
          description = "Identifying and remediating vulnerabilities";

          capabilities = {
            scanning = {
              id = "SECOPS.VULN.SCAN";
              name = "Vulnerability Scanning";
              description = "Regular scanning for vulnerabilities";

              objectives = {
                regular_scanning = {
                  id = "SECOPS.VULN.SCAN.REGULAR";
                  name = "Regular Vulnerability Scanning";
                  description = "Periodic scanning for system vulnerabilities";
                  canonical = true;
                };
              };
            };

            malware_protection = {
              id = "SECOPS.VULN.MALWARE";
              name = "Malware Protection";
              description = "Protection against malicious software";

              objectives = {
                anti_malware = {
                  id = "SECOPS.VULN.MALWARE.PROTECT";
                  name = "Anti-Malware Protection";
                  description = "Deploy and maintain anti-malware solutions";
                  canonical = true;
                };
              };
            };
          };
        };
      };
    };
  };

  # Helper function to get control objective by ID
  getObjective = objectiveId:
    let
      # Split ID into parts (e.g., "IAM.LIFECYCLE.PROVISION.REGISTER")
      parts = builtins.split "\\." objectiveId;

      # Navigate the taxonomy tree
      # This is a simplified version - full implementation would recursively traverse
      findInTaxonomy = taxonomy: parts:
        if builtins.length parts == 0 then null
        else if builtins.length parts == 1 then taxonomy
        else
          let head = builtins.head parts;
              tail = builtins.tail parts;
          in if builtins.hasAttr head taxonomy
             then findInTaxonomy (builtins.getAttr head taxonomy) tail
             else null;
    in findInTaxonomy taxonomy parts;

  # Find all framework controls that map to a given canonical objective
  findMappedControls = frameworks: objectiveId:
    let
      # For each framework, find controls that map to this objective
      frameworkMappings = builtins.map (framework:
        {
          frameworkId = framework.id;
          frameworkName = framework.name;
          controls = builtins.filter (control:
            builtins.elem objectiveId (control.canonicalObjectives or [])
          ) framework.controls;
        }
      ) frameworks;
    in builtins.filter (fm: builtins.length fm.controls > 0) frameworkMappings;
}