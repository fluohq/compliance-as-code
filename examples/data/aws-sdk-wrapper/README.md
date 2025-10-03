# AWS SDK Wrapper - Compliance Evidence

TypeScript wrapper for AWS SDK (S3 and DynamoDB) that automatically emits compliance evidence using OpenTelemetry.

## What This Demonstrates

- **Transparent Evidence Capture**: Wrap AWS SDK calls to emit compliance evidence without changing business logic
- **Multi-Service Coverage**: S3 and DynamoDB operations with GDPR + SOC 2 evidence
- **Real AWS Integration**: Works with real AWS services or LocalStack for local testing
- **Reusable Pattern**: Shows how to wrap any SDK to add compliance evidence

## Compliance Controls

| Operation | GDPR | SOC 2 | Evidence Emitted |
|-----------|------|-------|------------------|
| S3 GetObject | Art.15 | - | Access to user data |
| S3 PutObject | Art.5(1)(f) | CC6.1 | Secure storage + authorization |
| S3 DeleteObject | Art.17 | - | Right to erasure |
| S3 ListObjects | Art.15 | - | Data inventory |
| DynamoDB GetItem | Art.15 | - | Access to user data |
| DynamoDB PutItem | Art.5(1)(f) | CC6.1 | Secure storage + authorization |
| DynamoDB DeleteItem | Art.17 | - | Right to erasure |
| DynamoDB Query | Art.15 | - | Data access |

## How It Works

### S3 Wrapper

```typescript
import { ComplianceS3Client } from './s3-wrapper';

const s3 = new ComplianceS3Client({
  region: 'us-east-1',
});

// GDPR Art.15: Right of Access
const data = await s3.getObject('user-data', 'users/123/profile.json', '123');
// Emits span: {framework=gdpr, control=Art.15, operation=S3.GetObject, userId=123}

// GDPR Art.5(1)(f) + SOC 2 CC6.1: Secure storage
await s3.putObject('user-data', 'users/123/profile.json', userData, '123');
// Emits spans:
//   {framework=gdpr, control=Art.5(1)(f), operation=S3.PutObject, encrypted=true}
//   {framework=soc2, control=CC6.1, action=write_object, authorized=true}

// GDPR Art.17: Right to Erasure
await s3.deleteObject('user-data', 'users/123/profile.json', '123');
// Emits span: {framework=gdpr, control=Art.17, operation=S3.DeleteObject, deletedRecords=1}
```

### DynamoDB Wrapper

```typescript
import { ComplianceDynamoDBClient } from './dynamodb-wrapper';

const dynamodb = new ComplianceDynamoDBClient({
  region: 'us-east-1',
});

// GDPR Art.15: Right of Access
const user = await dynamodb.getItem('Users', { userId: '123' }, '123');
// Emits span: {framework=gdpr, control=Art.15, operation=DynamoDB.GetItem}

// GDPR Art.5(1)(f) + SOC 2 CC6.1: Secure storage
await dynamodb.putItem('Users', { userId: '123', email: 'alice@example.com' }, '123');
// Emits spans for secure storage and authorization

// GDPR Art.17: Right to Erasure
await dynamodb.deleteItem('Users', { userId: '123' }, '123');
// Emits span: {framework=gdpr, control=Art.17, deletedRecords=1}
```

## Running the Example

### With LocalStack (Recommended)

```bash
# Start LocalStack
docker run -d -p 4566:4566 localstack/localstack

# Create test resources
nix run .#setup

# Run demo
nix run

# Query evidence
nix run .#query
```

### With Real AWS

```bash
# Configure AWS credentials
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_REGION=us-east-1

# Configure OpenTelemetry
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318

# Run demo
nix run
```

## Evidence Attributes

Each operation emits spans with these attributes:

**Input Attributes:**
- `compliance.framework`: "gdpr" or "soc2"
- `compliance.control`: "Art.15", "Art.17", "Art.5(1)(f)", "CC6.1"
- `operation`: AWS SDK operation name
- `tableName` / `bucket`: Resource identifier
- `key`: Object key or item key
- `userId`: User identifier (if provided)

**Output Attributes:**
- `recordsReturned`: Number of records accessed
- `recordsCreated`: Number of records created
- `deletedRecords`: Number of records deleted
- `encrypted`: Whether data is encrypted
- `authorized`: Whether operation was authorized
- `result`: Operation result

## Integration Patterns

### 1. Drop-in Replacement

```typescript
// Before
import { S3Client } from '@aws-sdk/client-s3';
const s3 = new S3Client({ region: 'us-east-1' });

// After
import { ComplianceS3Client } from '@compliance/aws-sdk-wrapper';
const s3 = new ComplianceS3Client({ region: 'us-east-1' });
```

### 2. Conditional Wrapping

```typescript
const s3 = process.env.COMPLIANCE_MODE === 'enabled'
  ? new ComplianceS3Client(config)
  : new S3Client(config);
```

### 3. Middleware Approach

```typescript
class MyApp {
  constructor(private s3: ComplianceS3Client | S3Client) {}

  async getUserData(userId: string) {
    return this.s3.getObject('user-data', `users/${userId}/profile.json`, userId);
  }
}
```

## Design Decisions

### Why Wrap vs Middleware?

AWS SDK v3 doesn't have a clean middleware API for adding compliance spans. Wrapping provides:
- Type safety with TypeScript
- Clear ownership of compliance evidence
- Easy to test and reason about
- No need to modify SDK internals

### Performance

- **Overhead**: ~1-2ms per operation for span creation
- **Sampling**: Configure OpenTelemetry sampler to reduce overhead
- **Async**: Span export is asynchronous, doesn't block operations

### Alternative: Lambda Layer

For AWS Lambda, consider a Lambda layer that wraps the SDK:

```typescript
// Lambda layer wrapper
import { S3Client } from '@aws-sdk/client-s3';
import { ComplianceS3Client } from '@compliance/aws-sdk-wrapper';

export const S3 = ComplianceS3Client;
export { DynamoDB } from './dynamodb-wrapper';
```

## Testing

```bash
# Build
nix build

# Run tests (TODO: add tests)
npm test

# Type check
npm run build
```

## Contributing

Contributions welcome! Potential improvements:
- Additional AWS services (RDS, Kinesis, SQS, etc.)
- Batch operation support
- Custom compliance frameworks
- Performance benchmarks
- Integration tests with LocalStack

---

**Compliance is observable infrastructure.**
