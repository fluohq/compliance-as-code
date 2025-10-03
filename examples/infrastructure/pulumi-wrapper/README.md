# Pulumi Wrapper - Compliance Evidence

TypeScript wrappers for Pulumi AWS resources that automatically emit GDPR and SOC 2 compliance evidence.

## What This Demonstrates

- **Infrastructure-as-Code Compliance**: Every Pulumi resource emits compliance evidence
- **Built-in Security Controls**: Enforce encryption, versioning, and access controls
- **Declarative Evidence**: Evidence emitted during resource creation/deletion
- **Production Ready**: Works with real AWS resources via Pulumi

## Compliance Controls

| Resource | Control | Enforcement | Evidence |
|----------|---------|-------------|----------|
| S3 Bucket | GDPR Art.32 | Encryption + versioning required | Bucket encrypted, versioning enabled |
| RDS Database | GDPR Art.32 | Storage encryption required | Database encrypted, backups enabled |
| KMS Key | GDPR Art.32 | Key rotation enabled | Encryption key created |
| VPC | GDPR Art.5(1)(f) | Flow logs required | Network isolation, monitoring enabled |
| All Resources | SOC 2 CC6.8 | Change tracking | Resource creation/deletion logged |

## How It Works

### Encrypted S3 Bucket

```typescript
import { createEncryptedBucket } from './src';

// GDPR Art.32: Encryption enforced automatically
const bucket = createEncryptedBucket("user-data-bucket");

// Evidence emitted:
// {
//   framework: "gdpr",
//   control: "Art.32",
//   resource: "s3_bucket",
//   encrypted: true,
//   versioning: true,
//   compliant: true
// }
```

### Encrypted RDS Database

```typescript
import { createEncryptedDatabase } from './src';

const db = createEncryptedDatabase("user-database", {
  engine: "postgres",
  instanceClass: "db.t3.micro",
  allocatedStorage: 20,
  username: "admin",
  password: dbPassword,
  subnetIds: [subnet1.id, subnet2.id],
});

// Evidence emitted:
// {
//   framework: "gdpr",
//   control: "Art.32",
//   resource: "rds_database",
//   encrypted: true,
//   backupRetention: 7,
//   compliant: true
// }
```

### Secure VPC with Flow Logs

```typescript
import { createSecureVPC } from './src';

const vpc = createSecureVPC("app-vpc", {
  cidrBlock: "10.0.0.0/16",
});

// Evidence emitted:
// {
//   framework: "gdpr",
//   control: "Art.5(1)(f)",
//   resource: "vpc",
//   flowLogsEnabled: true,
//   compliant: true
// }
//
// {
//   framework: "soc2",
//   control: "CC6.6",
//   resource: "vpc",
//   accessControlsEnabled: true
// }
```

### KMS Encryption Key

```typescript
import { createEncryptionKey } from './src';

const key = createEncryptionKey("user-data-key", {
  description: "Encryption key for user data",
  deletionWindowInDays: 30,
});

// Evidence emitted:
// {
//   framework: "gdpr",
//   control: "Art.32",
//   resource: "kms_key",
//   rotationEnabled: true,
//   compliant: true
// }
```

## Running the Example

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Pulumi

```bash
# Configure AWS
pulumi config set aws:region us-east-1

# Set database password
pulumi config set --secret db-password YourSecurePassword123

# Configure OpenTelemetry
pulumi config set compliance:otel-endpoint http://localhost:4318
```

### 3. Deploy Infrastructure

```bash
# Preview changes
pulumi preview

# Deploy
pulumi up

# Check outputs
pulumi stack output
```

### 4. Query Evidence

```bash
# Evidence automatically sent to OpenTelemetry endpoint
# Query your observability backend (Jaeger, Honeycomb, etc.)
```

### 5. Destroy Infrastructure

```bash
# Destroy (emits GDPR Art.17 evidence)
pulumi destroy
```

## Evidence Attributes

Each resource creation emits spans with these attributes:

**Input Attributes:**
- `compliance.framework`: "gdpr" or "soc2"
- `compliance.control`: "Art.32", "Art.5(1)(f)", "CC6.8", etc.
- `resource`: Resource type (s3_bucket, rds_database, vpc, etc.)
- `name`: Resource name
- `action`: "create", "update", "destroy"

**Output Attributes:**
- `compliant`: Whether resource meets compliance requirements
- `encrypted`: Whether encryption is enabled
- `versioning`: Whether versioning is enabled
- `flowLogsEnabled`: Whether VPC flow logs are enabled
- `rotationEnabled`: Whether key rotation is enabled
- `result`: Operation result

## Integration Patterns

### 1. Drop-in Replacement

```typescript
// Before
import * as aws from "@pulumi/aws";
const bucket = new aws.s3.BucketV2("my-bucket", { bucket: "my-bucket" });

// After
import { createEncryptedBucket } from "@compliance/pulumi-wrapper";
const bucket = createEncryptedBucket("my-bucket");
```

### 2. Conditional Wrapping

```typescript
const bucket = process.env.COMPLIANCE_MODE === "enabled"
  ? createEncryptedBucket("my-bucket")
  : new aws.s3.BucketV2("my-bucket", { bucket: "my-bucket" });
```

### 3. Custom Wrappers

```typescript
export function createMyAppInfra(name: string) {
  const key = createEncryptionKey(`${name}-key`, {
    description: "App encryption key",
  });

  const bucket = createEncryptedBucket(`${name}-bucket`, {
    dependsOn: [key],
  });

  const vpc = createSecureVPC(`${name}-vpc`, {
    cidrBlock: "10.0.0.0/16",
  });

  return { key, bucket, vpc };
}
```

## Example Pulumi Program

Complete example in [index.ts](index.ts):

```typescript
import { createEncryptedBucket, createEncryptedDatabase, createSecureVPC } from "./src";

// Create VPC
const vpc = createSecureVPC("app-vpc", {
  cidrBlock: "10.0.0.0/16",
});

// Create encrypted bucket
const bucket = createEncryptedBucket("user-data-bucket");

// Create encrypted database
const db = createEncryptedDatabase("user-database", {
  engine: "postgres",
  instanceClass: "db.t3.micro",
  allocatedStorage: 20,
  username: "admin",
  password: config.requireSecret("db-password"),
  subnetIds: [subnet1.id, subnet2.id],
});

export const bucketUrn = bucket.urn;
export const databaseUrn = db.urn;
export const vpcUrn = vpc.urn;
```

## Evidence Queries

```promql
# All Pulumi operations
{compliance.framework=~"gdpr|soc2"}

# Non-compliant resources
{compliance.compliant="false"}

# Encryption violations (GDPR Art.32)
{compliance.control="Art.32", encrypted="false"}

# Resource changes (SOC 2 CC6.8)
{compliance.control="CC6.8", action=~"create|destroy"}

# VPC flow logs (SOC 2 CC6.6)
{compliance.control="CC6.6", flowLogsEnabled="true"}
```

## Design Decisions

### Why Wrappers?

Pulumi's component resource model makes wrapping natural:
- Type-safe TypeScript wrappers
- Compose resources with evidence
- Reusable across projects
- No Pulumi core modifications needed

### Resource Tagging

All resources are tagged with compliance metadata:

```typescript
tags: {
  "compliance:gdpr": "Art.32",
  "compliance:soc2": "CC6.8",
}
```

This enables AWS Config rules and cost allocation by compliance framework.

### Evidence Timing

Evidence is emitted when resource URN is available (after creation). This ensures:
- Evidence includes actual resource identifiers
- Failed creations don't emit success evidence
- Evidence accurately reflects resource state

## Testing

```bash
# Build
npm run build

# Deploy to test stack
pulumi stack select test
pulumi up

# Verify evidence in observability backend

# Destroy test stack
pulumi destroy
```

## Contributing

Contributions welcome! Potential improvements:
- Additional AWS resources (Lambda, ECS, etc.)
- Azure and GCP support
- Custom compliance frameworks
- Policy-as-code validation (Pulumi Policy)
- Automated testing with Pulumi Test Framework

---

**Infrastructure-as-code meets compliance-as-code.**
