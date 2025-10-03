# Terraform Provider - Compliance Evidence

> **Status**: 📝 Placeholder - Contribution Welcome

## Why This Example Matters

Infrastructure-as-code needs compliance evidence for:
- **SOC 2 CC6.8**: Change Management - Track all infrastructure changes
- **SOC 2 CC7.2**: System Monitoring - Monitor infrastructure state
- **GDPR Art.32**: Security of Processing - Verify encryption configuration
- **Audit Trail**: Every `terraform apply` needs evidence

Terraform provisions infrastructure but doesn't emit compliance evidence. This provider fills that gap.

## What This Example Would Show

### 1. Custom Terraform Provider with Evidence

```go
package provider

import (
	"context"
	"github.com/fluohq/compliance-as-code/gdpr"
	"github.com/fluohq/compliance-as-code/soc2"
	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
)

// Provider returns the compliance-aware Terraform provider
func Provider() *schema.Provider {
	return &schema.Provider{
		Schema: map[string]*schema.Schema{
			"otel_endpoint": {
				Type:        schema.TypeString,
				Optional:    true,
				DefaultFunc: schema.EnvDefaultFunc("OTEL_EXPORTER_OTLP_ENDPOINT", ""),
			},
		},
		ResourcesMap: map[string]*schema.Resource{
			"compliance_database":        resourceDatabase(),
			"compliance_storage_bucket":  resourceStorageBucket(),
			"compliance_encryption_key":  resourceEncryptionKey(),
		},
		DataSourcesMap: map[string]*schema.Resource{
			"compliance_audit_log": dataSourceAuditLog(),
		},
		ConfigureContextFunc: providerConfigure,
	}
}

func providerConfigure(ctx context.Context, d *schema.ResourceData) (interface{}, diag.Diagnostics) {
	// Initialize OpenTelemetry
	return &Config{
		OTELEndpoint: d.Get("otel_endpoint").(string),
	}, nil
}
```

### 2. Database Resource with Encryption Evidence

```go
func resourceDatabase() *schema.Resource {
	return &schema.Resource{
		CreateContext: resourceDatabaseCreate,
		ReadContext:   resourceDatabaseRead,
		UpdateContext: resourceDatabaseUpdate,
		DeleteContext: resourceDatabaseDelete,

		Schema: map[string]*schema.Schema{
			"name": {
				Type:     schema.TypeString,
				Required: true,
			},
			"encrypted": {
				Type:     schema.TypeBool,
				Required: true,
			},
			"encryption_key_id": {
				Type:     schema.TypeString,
				Optional: true,
			},
		},
	}
}

func resourceDatabaseCreate(ctx context.Context, d *schema.ResourceData, meta interface{}) diag.Diagnostics {
	// GDPR Art.32: Security of Processing (encryption)
	gdprSpan := gdpr.BeginSpan(gdpr.Art_32)
	defer gdprSpan.End()

	// SOC 2 CC6.8: Change Management
	soc2Span := soc2.BeginSpan(soc2.CC6_8)
	defer soc2Span.End()

	name := d.Get("name").(string)
	encrypted := d.Get("encrypted").(bool)

	gdprSpan.SetInput("resource", "database")
	gdprSpan.SetInput("name", name)
	gdprSpan.SetInput("encrypted", encrypted)

	soc2Span.SetInput("resource", "database")
	soc2Span.SetInput("action", "create")
	soc2Span.SetInput("name", name)

	// Enforce encryption requirement
	if !encrypted {
		gdprSpan.SetOutput("compliant", false)
		gdprSpan.SetOutput("error", "encryption_required")
		return diag.Errorf("GDPR Art.32: Database must be encrypted")
	}

	keyID := d.Get("encryption_key_id").(string)
	if keyID == "" {
		return diag.Errorf("encryption_key_id required when encrypted=true")
	}

	// Create database (simulated)
	dbID := createDatabase(name, encrypted, keyID)
	d.SetId(dbID)

	gdprSpan.SetOutput("compliant", true)
	gdprSpan.SetOutput("encrypted", true)
	gdprSpan.SetOutput("encryptionKeyId", keyID)
	gdprSpan.SetOutput("databaseId", dbID)

	soc2Span.SetOutput("changeTracked", true)
	soc2Span.SetOutput("databaseId", dbID)
	soc2Span.SetOutput("result", "success")

	return nil
}

func resourceDatabaseDelete(ctx context.Context, d *schema.ResourceData, meta interface{}) diag.Diagnostics {
	// SOC 2 CC6.8: Change Management (deletion)
	span := soc2.BeginSpan(soc2.CC6_8)
	defer span.End()

	span.SetInput("resource", "database")
	span.SetInput("action", "delete")
	span.SetInput("databaseId", d.Id())

	// Delete database
	if err := deleteDatabase(d.Id()); err != nil {
		span.SetOutput("result", "failure")
		span.SetOutput("error", err.Error())
		return diag.FromErr(err)
	}

	span.SetOutput("changeTracked", true)
	span.SetOutput("result", "success")

	return nil
}
```

### 3. Storage Bucket Resource with GDPR Evidence

```go
func resourceStorageBucket() *schema.Resource {
	return &schema.Resource{
		CreateContext: resourceStorageBucketCreate,
		DeleteContext: resourceStorageBucketDelete,

		Schema: map[string]*schema.Schema{
			"name": {
				Type:     schema.TypeString,
				Required: true,
			},
			"versioning_enabled": {
				Type:     schema.TypeBool,
				Default:  true,
			},
			"lifecycle_policy": {
				Type:     schema.TypeString,
				Optional: true,
			},
		},
	}
}

func resourceStorageBucketCreate(ctx context.Context, d *schema.ResourceData, meta interface{}) diag.Diagnostics {
	// GDPR Art.5(1)(f): Security of Processing
	gdprSpan := gdpr.BeginSpan(gdpr.Art_51f)
	defer gdprSpan.End()

	name := d.Get("name").(string)
	versioning := d.Get("versioning_enabled").(bool)

	gdprSpan.SetInput("resource", "storage_bucket")
	gdprSpan.SetInput("name", name)
	gdprSpan.SetInput("versioning", versioning)

	// Enforce versioning for data protection
	if !versioning {
		gdprSpan.SetOutput("compliant", false)
		return diag.Errorf("GDPR Art.5(1)(f): Bucket must have versioning enabled")
	}

	bucketID := createBucket(name, versioning)
	d.SetId(bucketID)

	gdprSpan.SetOutput("compliant", true)
	gdprSpan.SetOutput("bucketId", bucketID)
	gdprSpan.SetOutput("versioning", versioning)

	return nil
}

func resourceStorageBucketDelete(ctx context.Context, d *schema.ResourceData, meta interface{}) diag.Diagnostics {
	// GDPR Art.17: Right to Erasure (data deletion)
	gdprSpan := gdpr.BeginSpan(gdpr.Art_17)
	defer gdprSpan.End()

	// SOC 2 CC6.8: Change Management
	soc2Span := soc2.BeginSpan(soc2.CC6_8)
	defer soc2Span.End()

	gdprSpan.SetInput("resource", "storage_bucket")
	gdprSpan.SetInput("bucketId", d.Id())

	soc2Span.SetInput("resource", "storage_bucket")
	soc2Span.SetInput("action", "delete")
	soc2Span.SetInput("bucketId", d.Id())

	if err := deleteBucket(d.Id()); err != nil {
		gdprSpan.SetOutput("result", "failure")
		soc2Span.SetOutput("result", "failure")
		return diag.FromErr(err)
	}

	gdprSpan.SetOutput("bucketDeleted", true)
	soc2Span.SetOutput("changeTracked", true)

	return nil
}
```

### 4. Audit Log Data Source

```go
func dataSourceAuditLog() *schema.Resource {
	return &schema.Resource{
		ReadContext: dataSourceAuditLogRead,

		Schema: map[string]*schema.Schema{
			"resource_type": {
				Type:     schema.TypeString,
				Required: true,
			},
			"time_range": {
				Type:     schema.TypeString,
				Optional: true,
				Default:  "24h",
			},
			"events": {
				Type:     schema.TypeList,
				Computed: true,
				Elem: &schema.Resource{
					Schema: map[string]*schema.Schema{
						"timestamp": {Type: schema.TypeString, Computed: true},
						"action":    {Type: schema.TypeString, Computed: true},
						"resource":  {Type: schema.TypeString, Computed: true},
						"compliant": {Type: schema.TypeBool, Computed: true},
					},
				},
			},
		},
	}
}

func dataSourceAuditLogRead(ctx context.Context, d *schema.ResourceData, meta interface{}) diag.Diagnostics {
	// SOC 2 CC7.2: System Monitoring
	span := soc2.BeginSpan(soc2.CC7_2)
	defer span.End()

	resourceType := d.Get("resource_type").(string)
	timeRange := d.Get("time_range").(string)

	span.SetInput("resourceType", resourceType)
	span.SetInput("timeRange", timeRange)
	span.SetInput("action", "audit_log_query")

	// Query audit logs from observability backend
	events := queryAuditLogs(resourceType, timeRange)

	d.SetId(fmt.Sprintf("%s-%s", resourceType, time.Now().Format(time.RFC3339)))
	d.Set("events", events)

	span.SetOutput("eventsReturned", len(events))
	span.SetOutput("monitoring", "audit_log")

	return nil
}
```

### 5. Example Terraform Configuration

```hcl
terraform {
  required_providers {
    compliance = {
      source  = "fluohq/compliance"
      version = "~> 1.0"
    }
  }
}

provider "compliance" {
  otel_endpoint = "http://localhost:4318"
}

# GDPR Art.32: Encrypted database
resource "compliance_database" "user_data" {
  name              = "user-database"
  encrypted         = true
  encryption_key_id = "arn:aws:kms:us-east-1:123456789:key/abc"

  # Evidence emitted:
  # - GDPR Art.32: encryption validation
  # - SOC 2 CC6.8: change tracking
}

# GDPR Art.5(1)(f): Storage with versioning
resource "compliance_storage_bucket" "backups" {
  name               = "user-backups"
  versioning_enabled = true
  lifecycle_policy   = "30-day-retention"

  # Evidence emitted:
  # - GDPR Art.5(1)(f): security controls validated
  # - SOC 2 CC6.8: bucket creation tracked
}

# Query audit logs
data "compliance_audit_log" "recent_changes" {
  resource_type = "database"
  time_range    = "7d"
}

output "recent_database_changes" {
  value = data.compliance_audit_log.recent_changes.events
}
```

### 6. Evidence Queries

```promql
# All Terraform operations (SOC 2 CC6.8)
{compliance.control="CC6.8", resource=~"database|storage_bucket"}

# Non-compliant resource attempts
{compliance.compliant="false"}

# Encryption violations (GDPR Art.32)
{compliance.control="Art.32", encrypted="false"}

# Resource deletions (GDPR Art.17)
{compliance.control="Art.17", action="delete"}

# Audit log queries (SOC 2 CC7.2)
{compliance.control="CC7.2", monitoring="audit_log"}
```

## How to Implement This Example

### Step 1: Create Provider Structure

```bash
mkdir -p terraform-provider-compliance/internal/provider
cd terraform-provider-compliance
go mod init github.com/fluohq/terraform-provider-compliance
```

### Step 2: Implement Resources

```go
// Create provider.go, resource_database.go, resource_storage_bucket.go
// Add GDPR and SOC 2 evidence spans to all CRUD operations
```

### Step 3: Build and Install

```bash
go build -o terraform-provider-compliance
mkdir -p ~/.terraform.d/plugins/fluohq.com/compliance/compliance/1.0.0/darwin_arm64
mv terraform-provider-compliance ~/.terraform.d/plugins/fluohq.com/compliance/compliance/1.0.0/darwin_arm64/
```

### Step 4: Test with Terraform

```bash
terraform init
terraform plan
terraform apply
```

### Step 5: Query Evidence

```bash
# Query OpenTelemetry backend for evidence
curl http://localhost:4318/v1/traces | jq '.resourceSpans[] | select(.scopeSpans[].spans[].attributes[] | select(.key=="compliance.framework"))'
```

## Benefits

1. **Infrastructure Compliance**: Every Terraform operation has evidence
2. **Policy Enforcement**: Block non-compliant resources at plan time
3. **Audit Trail**: Complete history of infrastructure changes
4. **Integration**: Works with existing Terraform workflows

## Challenges

- Terraform plugin SDK is complex
- Need to handle state management correctly
- Provider registry requires signing
- Testing infrastructure code is non-trivial

## Alternative: Terraform Wrapper

Instead of a custom provider, wrap `terraform` CLI:

```go
func TerraformApply(dir string) error {
	span := soc2.BeginSpan(soc2.CC6_8)
	defer span.End()

	span.SetInput("command", "terraform apply")
	span.SetInput("directory", dir)

	cmd := exec.Command("terraform", "apply", "-auto-approve")
	cmd.Dir = dir

	if err := cmd.Run(); err != nil {
		span.SetOutput("result", "failure")
		return err
	}

	span.SetOutput("result", "success")
	span.SetOutput("changeTracked", true)
	return nil
}
```

## Contributing

Want to implement this example?

1. Create Terraform provider skeleton
2. Implement database and storage bucket resources
3. Add GDPR and SOC 2 evidence to CRUD operations
4. Create audit log data source
5. Write integration tests
6. Create Nix flake for reproducible build
7. Submit pull request

See **[../../../CONTRIBUTING.md](../../../CONTRIBUTING.md)** for guidelines.

---

**Infrastructure-as-code is compliance-as-code.**
