# AWS SDK Wrapper with Compliance Evidence

> **Status**: 📝 Placeholder - Contribution Welcome

## Why This Example Matters

AWS SDK operations need compliance evidence for:
- **HIPAA §164.312(a)(1)**: Access Control - Track who accessed PHI
- **SOC 2 CC6.1**: Authorization - Every S3/DynamoDB operation
- **GDPR Art.32**: Security of Processing - Data encryption evidence

Every S3 upload, DynamoDB query, and EC2 launch should emit evidence.

## What This Example Would Show

### 1. S3 Wrapper with Evidence

```typescript
import { S3Client, PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { GDPREvidence, GDPRControls } from '@compliance/gdpr';
import { trace } from '@opentelemetry/api';

export class ComplianceS3Client {
  private client: S3Client;
  private tracer = trace.getTracer('aws-sdk-compliance');

  constructor(config: S3ClientConfig) {
    this.client = new S3Client(config);
  }

  @GDPREvidence({ control: GDPRControls.Art_51f })
  async putObject(params: PutObjectCommandInput): Promise<PutObjectCommandOutput> {
    const span = this.tracer.startSpan('s3.putObject', {
      attributes: {
        'compliance.framework': 'gdpr',
        'compliance.control': 'Art.5(1)(f)',
        'aws.service': 's3',
        'aws.operation': 'PutObject',
        's3.bucket': params.Bucket,
        's3.key': params.Key,
      }
    });

    try {
      const result = await this.client.send(new PutObjectCommand(params));

      span.setAttribute('s3.etag', result.ETag);
      span.setAttribute('s3.encryption', result.ServerSideEncryption || 'none');
      span.setAttribute('compliance.result', 'success');

      return result;
    } catch (error) {
      span.setAttribute('compliance.result', 'failure');
      span.recordException(error);
      throw error;
    } finally {
      span.end();
    }
  }

  @GDPREvidence({ control: GDPRControls.Art_15 })
  async getObject(params: GetObjectCommandInput): Promise<GetObjectCommandOutput> {
    // Similar evidence capture for data access
    const span = this.tracer.startSpan('s3.getObject', {
      attributes: {
        'compliance.control': 'Art.15',
        's3.bucket': params.Bucket,
        's3.key': params.Key,
      }
    });

    try {
      const result = await this.client.send(new GetObjectCommand(params));
      span.setAttribute('s3.content_length', result.ContentLength);
      return result;
    } finally {
      span.end();
    }
  }
}
```

### 2. DynamoDB Wrapper with Evidence

```typescript
import { DynamoDBClient, GetItemCommand, DeleteItemCommand } from '@aws-sdk/client-dynamodb';

export class ComplianceDynamoDBClient {
  @GDPREvidence({ control: GDPRControls.Art_15 })
  async getItem(params: GetItemCommandInput): Promise<GetItemCommandOutput> {
    const span = this.tracer.startSpan('dynamodb.getItem', {
      attributes: {
        'compliance.framework': 'gdpr',
        'compliance.control': 'Art.15',
        'aws.service': 'dynamodb',
        'dynamodb.table': params.TableName,
        'dynamodb.key': JSON.stringify(params.Key),
      }
    });

    try {
      const result = await this.client.send(new GetItemCommand(params));
      span.setAttribute('dynamodb.item_found', !!result.Item);
      return result;
    } finally {
      span.end();
    }
  }

  @GDPREvidence({ control: GDPRControls.Art_17 })
  async deleteItem(params: DeleteItemCommandInput): Promise<DeleteItemCommandOutput> {
    const span = this.tracer.startSpan('dynamodb.deleteItem', {
      attributes: {
        'compliance.control': 'Art.17',
        'dynamodb.table': params.TableName,
      }
    });

    try {
      const result = await this.client.send(new DeleteItemCommand(params));
      span.setAttribute('compliance.result', 'success');
      return result;
    } finally {
      span.end();
    }
  }
}
```

### 3. Proxy Pattern for All AWS Services

```typescript
export function createComplianceProxy<T>(
  client: T,
  framework: string,
  control: string
): T {
  return new Proxy(client, {
    get(target, prop) {
      const original = target[prop];

      if (typeof original === 'function') {
        return function(...args: any[]) {
          const span = tracer.startSpan(`aws.${prop}`, {
            attributes: {
              'compliance.framework': framework,
              'compliance.control': control,
              'aws.operation': prop,
            }
          });

          try {
            const result = original.apply(target, args);

            if (result instanceof Promise) {
              return result
                .then(r => {
                  span.setAttribute('compliance.result', 'success');
                  return r;
                })
                .finally(() => span.end());
            }

            return result;
          } catch (error) {
            span.recordException(error);
            throw error;
          } finally {
            if (!(result instanceof Promise)) {
              span.end();
            }
          }
        };
      }

      return original;
    }
  });
}

// Usage
const s3 = createComplianceProxy(
  new S3Client({}),
  'gdpr',
  'Art.5(1)(f)'
);
```

### 4. Evidence for Data Encryption

```typescript
@GDPREvidence({ control: GDPRControls.Art_32 })
async uploadWithEncryption(bucket: string, key: string, data: Buffer) {
  const span = this.tracer.startSpan('s3.uploadEncrypted');

  // Ensure encryption
  const params = {
    Bucket: bucket,
    Key: key,
    Body: data,
    ServerSideEncryption: 'AES256', // Required by GDPR Art.32
  };

  const result = await this.s3.putObject(params);

  span.setAttribute('encryption.algorithm', result.ServerSideEncryption);
  span.setAttribute('encryption.key_id', result.SSEKMSKeyId);
  span.setAttribute('compliance.evidence_type', 'encryption');

  return result;
}
```

## How to Implement This Example

### Step 1: Create Wrapper Classes

```typescript
// Generate TypeScript code
nix build ../../../frameworks/generators#ts-gdpr

// Create wrapper
export class ComplianceAWSWrapper {
  s3: ComplianceS3Client;
  dynamodb: ComplianceDynamoDBClient;
  // ... other services
}
```

### Step 2: Instrument All Operations

Use decorators or proxies to automatically emit evidence for every AWS API call.

### Step 3: Test with Real AWS Services

```typescript
const aws = new ComplianceAWSWrapper({
  region: 'us-east-1',
  compliance: {
    frameworks: ['gdpr', 'hipaa'],
    otelEndpoint: 'http://localhost:4318'
  }
});

// Every operation emits evidence
await aws.s3.putObject({ Bucket: 'my-bucket', Key: 'file.txt', Body: buffer });
await aws.dynamodb.getItem({ TableName: 'users', Key: { id: { S: '123' } } });
```

### Step 4: Query Evidence

```promql
# All S3 operations
{aws.service="s3"}

# Data access (GDPR Art.15)
{compliance.control="Art.15", aws.service="dynamodb"}

# Data deletion (GDPR Art.17)
{compliance.control="Art.17"}

# Encryption evidence
{compliance.evidence_type="encryption"}
```

## Benefits

1. **Zero code changes** - Drop-in replacement for AWS SDK
2. **Complete audit trail** - Every API call tracked
3. **Encryption enforcement** - Fail if encryption missing
4. **Multi-service** - Works with S3, DynamoDB, EC2, etc.

## Challenges

- Need to wrap every AWS SDK client
- TypeScript decorators work differently than Java
- Performance overhead for high-volume operations
- AWS SDK v3 modular architecture

## Contributing

Want to implement this example?

1. Create wrapper classes for S3, DynamoDB
2. Integrate with generated TypeScript code
3. Add proxy pattern for automatic instrumentation
4. Test with real AWS services
5. Create Nix flake for reproducible build
6. Add performance benchmarks
7. Submit pull request

See **[../../../CONTRIBUTING.md](../../../CONTRIBUTING.md)** for guidelines.

---

**Every cloud operation is evidence.**
