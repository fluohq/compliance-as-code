# Compliance Control Schema
# This defines the canonical structure for all compliance controls
# Controls defined in this format can be transformed into any target language

{
  # mkControl creates a standardized control definition
  mkControl =
    {
      # Unique identifier for the control
      id
    , # Human-readable name
      name
    , # Framework-specific categorization
      category
    , # Detailed description of what the control requires
      description
    , # Implementation requirements and guidance
      requirements ? [ ]
    , # Evidence types that demonstrate compliance
      evidenceTypes ? [ ]
    , # Suggested implementation methods
      implementationGuidance ? ""
    , # Risk level if control is not implemented
      riskLevel ? "medium"
    , # low, medium, high, critical
      # Technical implementation hints
      technicalControls ? [ ]
    , # Canonical security objectives this control satisfies (list of taxonomy IDs)
      # e.g., ["IAM.AUTH.VERIFY.UNIQUE_ID", "IAM.AUTHZ.ACCESS.DENY_DEFAULT"]
      canonicalObjectives ? [ ]
    , # DEPRECATED: Legacy cross-framework mappings (use canonicalObjectives instead)
      # Will be automatically converted to canonical objectives in future versions
      mappings ? { }
    , # Testing procedures
      testingProcedures ? [ ]
    , # Common implementation patterns
      patterns ? [ ]
    , # Validation rules
      validations ? [ ]
    , # Metadata
      metadata ? { }
    ,
    }: {
      inherit id name category description requirements evidenceTypes
        implementationGuidance riskLevel technicalControls canonicalObjectives
        mappings testingProcedures patterns validations metadata;

      # Control type classification
      type =
        if (builtins.elem "technical" (metadata.tags or [ ]))
        then "technical"
        else if (builtins.elem "administrative" (metadata.tags or [ ]))
        then "administrative"
        else if (builtins.elem "physical" (metadata.tags or [ ]))
        then "physical"
        else "operational";
    };

  # mkFramework creates a framework definition with its controls
  mkFramework =
    {
      # Framework identifier
      id
    , # Full name
      name
    , # Short description
      description
    , # Version of the framework
      version
    , # Issuing organization
      organization
    , # URL to official documentation
      url ? ""
    , # List of control definitions
      controls
    , # Framework-specific metadata
      metadata ? { }
    ,
    }: {
      inherit id name description version organization url controls metadata;

      # Helper to find control by ID
      getControl = controlId:
        builtins.head (builtins.filter (c: c.id == controlId) controls);

      # Get all controls by category
      getControlsByCategory = category:
        builtins.filter (c: c.category == category) controls;

      # Get controls by risk level
      getControlsByRisk = riskLevel:
        builtins.filter (c: c.riskLevel == riskLevel) controls;
    };

  # Evidence type definitions
  evidenceTypes = {
    LOG = "log";
    METRIC = "metric";
    CONFIG = "config";
    TEST = "test";
    AUDIT_TRAIL = "audit_trail";
    SCAN = "scan";
    CERTIFICATE = "certificate";
    DOCUMENTATION = "documentation";
    SCREENSHOT = "screenshot";
    CODE_REVIEW = "code_review";
    PENETRATION_TEST = "penetration_test";
    VULNERABILITY_SCAN = "vulnerability_scan";
  };

  # Evidence field types - what data should be captured in spans
  evidenceFieldTypes = {
    TIMESTAMP = "timestamp";
    TRACE_ID = "trace_id";
    SPAN_ID = "span_id";
    USER_ID = "user_id";
    ACTION = "action";
    RESOURCE = "resource";
    RESULT = "result";
    DURATION = "duration";
    ERROR = "error";
    SIDE_EFFECTS = "side_effects";
    INPUT_HASH = "input_hash";
    OUTPUT_HASH = "output_hash";
  };

  # Redaction strategies for sensitive data
  redactionStrategies = {
    EXCLUDE = "exclude"; # Don't include in evidence
    REDACT = "redact"; # Replace with "<redacted>"
    HASH = "hash"; # SHA-256 hash for correlation
    TRUNCATE = "truncate"; # Show first/last N chars
    ENCRYPT = "encrypt"; # Encrypt with evidence key
  };

  # OpenTelemetry semantic conventions for compliance
  otelConventions = {
    COMPLIANCE_FRAMEWORK = "compliance.framework";
    COMPLIANCE_CONTROL = "compliance.control";
    COMPLIANCE_EVIDENCE_TYPE = "compliance.evidence_type";
    COMPLIANCE_RISK_LEVEL = "compliance.risk_level";
    COMPLIANCE_RESULT = "compliance.result";
    COMPLIANCE_USER_ID = "compliance.user_id";
    COMPLIANCE_ACTION = "compliance.action";
    COMPLIANCE_RESOURCE = "compliance.resource";
    COMPLIANCE_DURATION = "compliance.duration_ms";
    COMPLIANCE_SIDE_EFFECTS = "compliance.side_effects";
  };

  # Common sensitive field patterns (auto-redacted)
  sensitivePatterns = [
    "password"
    "passwd"
    "pwd"
    "token"
    "apiKey"
    "api_key"
    "secret"
    "privateKey"
    "private_key"
    "ssn"
    "creditCard"
    "credit_card"
    "cvv"
    "pin"
  ];

  # Language capabilities and evidence patterns
  languagePatterns = {
    # Languages with decorators/annotations
    HAS_DECORATORS = {
      java = {
        pattern = "annotations";
        example = "@GDPREvidence(control = GDPRControls.Art_51f)";
        description = "Runtime annotations with full reflection support";
      };
      typescript = {
        pattern = "decorators";
        example = "@GDPREvidence({ control: GDPRControls.Art_51f })";
        description = "Experimental decorators (requires tsconfig experimentalDecorators)";
      };
      python = {
        pattern = "decorators";
        example = "@gdpr_evidence(control='Art.5(1)(f)')";
        description = "Native function decorators with @ syntax";
      };
      csharp = {
        pattern = "attributes";
        example = "[GDPREvidence(Control = GDPRControls.Art_51f)]";
        description = "Attributes with runtime reflection";
      };
    };

    # Languages with context threading
    HAS_CONTEXT = {
      go = {
        pattern = "context";
        example = "ctx = gdpr.WithEvidence(ctx, gdpr.Art_51f)";
        description = "Thread evidence through context.Context (idiomatic Go)";
      };
      rust = {
        pattern = "context";
        example = "let _guard = gdpr::evidence(gdpr::Art_51f).enter();";
        description = "RAII-based context guards";
      };
    };

    # Languages requiring explicit wrappers
    NEEDS_WRAPPERS = {
      javascript = {
        pattern = "wrapper";
        example = "withGDPREvidence({ control: 'Art.5(1)(f)' }, fn)";
        description = "Higher-order function wrappers";
      };
      c = {
        pattern = "manual";
        example = "span = gdpr_begin_evidence(GDPR_ART_51F);";
        description = "Explicit function calls for span management";
      };
    };

    # Languages with macro support
    HAS_MACROS = {
      rust = {
        pattern = "macro";
        example = "#[gdpr_evidence(control = \"Art.5(1)(f)\")]";
        description = "Procedural macros for compile-time code generation";
      };
      c = {
        pattern = "macro";
        example = "GDPR_EVIDENCE(Art_51f) { ... }";
        description = "Preprocessor macros (limited capability)";
      };
    };
  };

  # Risk level definitions
  riskLevels = {
    LOW = "low";
    MEDIUM = "medium";
    HIGH = "high";
    CRITICAL = "critical";
  };

  # Common technical control types
  technicalControlTypes = {
    ENCRYPTION = "encryption";
    ACCESS_CONTROL = "access_control";
    AUTHENTICATION = "authentication";
    AUTHORIZATION = "authorization";
    LOGGING = "logging";
    MONITORING = "monitoring";
    BACKUP = "backup";
    NETWORK_SECURITY = "network_security";
    DATA_PROTECTION = "data_protection";
    INCIDENT_RESPONSE = "incident_response";
    VULNERABILITY_MANAGEMENT = "vulnerability_management";
    CONFIGURATION_MANAGEMENT = "configuration_management";
  };

  # Common implementation patterns
  patterns = {
    DECORATOR = "decorator";
    INTERCEPTOR = "interceptor";
    MIDDLEWARE = "middleware";
    ASPECT = "aspect";
    POLICY = "policy";
    FILTER = "filter";
  };
}
