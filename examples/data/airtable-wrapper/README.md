# Airtable Wrapper - Compliance Evidence

> **Status**: 📝 Placeholder - Contribution Welcome

## Why This Example Matters

Low-code/no-code tools like Airtable need compliance evidence for:
- **GDPR Art.15**: Right of Access - Track data retrieval
- **GDPR Art.17**: Right to Erasure - Delete user records
- **SOC 2 CC6.1**: Authorization - Who modified what
- **SOC 2 CC6.8**: Change Management - Audit trail of changes

Airtable stores business-critical data but lacks built-in compliance evidence. This wrapper fills that gap.

## What This Example Would Show

### 1. Airtable Client Wrapper

```typescript
import Airtable from 'airtable';
import { GDPR } from '@compliance/gdpr';
import { SOC2 } from '@compliance/soc2';

export class ComplianceAirtableClient {
  private base: any;

  constructor(apiKey: string, baseId: string) {
    Airtable.configure({ apiKey });
    this.base = Airtable.base(baseId);
  }

  /**
   * Get record - implements GDPR Right of Access (Art.15)
   */
  async getRecord(table: string, recordId: string, userId?: string): Promise<any> {
    const span = GDPR.beginSpan(GDPR.Art_15);

    try {
      span.setInput('table', table);
      span.setInput('recordId', recordId);
      if (userId) {
        span.setInput('userId', userId);
      }

      const record = await this.base(table).find(recordId);

      span.setOutput('recordsReturned', 1);
      span.setOutput('recordId', record.id);
      span.end();

      return record;
    } catch (error) {
      span.endWithError(error as Error);
      throw error;
    }
  }

  /**
   * Create record - implements SOC 2 CC6.1 (Authorization)
   */
  async createRecord(table: string, fields: Record<string, any>, userId?: string): Promise<any> {
    const span = SOC2.beginSpan(SOC2.CC6_1);

    try {
      span.setInput('table', table);
      span.setInput('action', 'create_record');
      if (userId) {
        span.setInput('userId', userId);
      }

      const record = await this.base(table).create(fields);

      span.setOutput('authorized', true);
      span.setOutput('result', 'success');
      span.setOutput('recordId', record.id);
      span.setOutput('recordsCreated', 1);
      span.end();

      return record;
    } catch (error) {
      span.endWithError(error as Error);
      throw error;
    }
  }

  /**
   * Update record - implements SOC 2 CC6.8 (Change Management)
   */
  async updateRecord(
    table: string,
    recordId: string,
    fields: Record<string, any>,
    userId?: string
  ): Promise<any> {
    const gdprSpan = GDPR.beginSpan(GDPR.Art_51f);
    const soc2Span = SOC2.beginSpan(SOC2.CC6_8);

    try {
      gdprSpan.setInput('table', table);
      gdprSpan.setInput('recordId', recordId);

      soc2Span.setInput('table', table);
      soc2Span.setInput('recordId', recordId);
      soc2Span.setInput('action', 'update_record');
      soc2Span.setInput('changedFields', Object.keys(fields));

      if (userId) {
        gdprSpan.setInput('userId', userId);
        soc2Span.setInput('userId', userId);
      }

      const record = await this.base(table).update(recordId, fields);

      gdprSpan.setOutput('recordsUpdated', 1);
      soc2Span.setOutput('changeTracked', true);
      soc2Span.setOutput('result', 'success');

      gdprSpan.end();
      soc2Span.end();

      return record;
    } catch (error) {
      gdprSpan.endWithError(error as Error);
      soc2Span.endWithError(error as Error);
      throw error;
    }
  }

  /**
   * Delete record - implements GDPR Right to Erasure (Art.17)
   */
  async deleteRecord(table: string, recordId: string, userId?: string): Promise<void> {
    const span = GDPR.beginSpan(GDPR.Art_17);

    try {
      span.setInput('table', table);
      span.setInput('recordId', recordId);
      if (userId) {
        span.setInput('userId', userId);
      }

      await this.base(table).destroy(recordId);

      span.setOutput('deletedRecords', 1);
      span.setOutput('recordId', recordId);
      span.end();
    } catch (error) {
      span.endWithError(error as Error);
      throw error;
    }
  }

  /**
   * List records - implements GDPR Right of Access (Art.15)
   */
  async listRecords(
    table: string,
    options?: {
      filterByFormula?: string;
      maxRecords?: number;
      view?: string;
    },
    userId?: string
  ): Promise<any[]> {
    const span = GDPR.beginSpan(GDPR.Art_15);

    try {
      span.setInput('table', table);
      if (options?.filterByFormula) {
        span.setInput('filter', options.filterByFormula);
      }
      if (userId) {
        span.setInput('userId', userId);
      }

      const records: any[] = [];
      await this.base(table)
        .select(options || {})
        .eachPage((pageRecords: any[], fetchNextPage: Function) => {
          records.push(...pageRecords);
          fetchNextPage();
        });

      span.setOutput('recordsReturned', records.length);
      span.end();

      return records;
    } catch (error) {
      span.endWithError(error as Error);
      throw error;
    }
  }
}
```

### 2. GDPR Data Subject Request Handler

```typescript
export class AirtableGDPRHandler {
  constructor(private airtable: ComplianceAirtableClient) {}

  /**
   * Export all user data from Airtable
   * Implements GDPR Art.15 - Right of Access
   */
  async exportUserData(userEmail: string): Promise<UserData> {
    const span = GDPR.beginSpan(GDPR.Art_15);

    try {
      span.setInput('userEmail', userEmail);
      span.setInput('requestType', 'data_export');

      // Find user in Contacts table
      const contacts = await this.airtable.listRecords(
        'Contacts',
        { filterByFormula: `{Email} = '${userEmail}'` },
        userEmail
      );

      if (contacts.length === 0) {
        throw new Error('User not found');
      }

      const userId = contacts[0].id;

      // Get user's orders
      const orders = await this.airtable.listRecords(
        'Orders',
        { filterByFormula: `{Contact} = '${userId}'` },
        userEmail
      );

      // Get user's support tickets
      const tickets = await this.airtable.listRecords(
        'Support Tickets',
        { filterByFormula: `{Contact} = '${userId}'` },
        userEmail
      );

      const totalRecords = contacts.length + orders.length + tickets.length;
      span.setOutput('recordsReturned', totalRecords);
      span.setOutput('tablesAccessed', ['Contacts', 'Orders', 'Support Tickets']);
      span.end();

      return {
        contact: contacts[0].fields,
        orders: orders.map(o => o.fields),
        tickets: tickets.map(t => t.fields),
      };
    } catch (error) {
      span.endWithError(error as Error);
      throw error;
    }
  }

  /**
   * Delete all user data from Airtable
   * Implements GDPR Art.17 - Right to Erasure
   */
  async deleteUserData(userEmail: string): Promise<DeletionReport> {
    const span = GDPR.beginSpan(GDPR.Art_17);

    try {
      span.setInput('userEmail', userEmail);
      span.setInput('requestType', 'data_deletion');

      // Find user
      const contacts = await this.airtable.listRecords(
        'Contacts',
        { filterByFormula: `{Email} = '${userEmail}'` },
        userEmail
      );

      if (contacts.length === 0) {
        throw new Error('User not found');
      }

      const userId = contacts[0].id;
      let totalDeleted = 0;

      // Delete orders
      const orders = await this.airtable.listRecords(
        'Orders',
        { filterByFormula: `{Contact} = '${userId}'` },
        userEmail
      );

      for (const order of orders) {
        await this.airtable.deleteRecord('Orders', order.id, userEmail);
        totalDeleted++;
      }

      // Delete support tickets
      const tickets = await this.airtable.listRecords(
        'Support Tickets',
        { filterByFormula: `{Contact} = '${userId}'` },
        userEmail
      );

      for (const ticket of tickets) {
        await this.airtable.deleteRecord('Support Tickets', ticket.id, userEmail);
        totalDeleted++;
      }

      // Delete contact
      await this.airtable.deleteRecord('Contacts', userId, userEmail);
      totalDeleted++;

      span.setOutput('deletedRecords', totalDeleted);
      span.setOutput('tablesCleared', 3);
      span.end();

      return {
        deleted: totalDeleted,
        tables: ['Contacts', 'Orders', 'Support Tickets'],
      };
    } catch (error) {
      span.endWithError(error as Error);
      throw error;
    }
  }
}
```

### 3. Webhook Integration with Evidence

```typescript
export class AirtableWebhookHandler {
  constructor(private airtable: ComplianceAirtableClient) {}

  /**
   * Handle Airtable webhook
   * Implements SOC 2 CC6.8 - Change Management
   */
  async handleWebhook(payload: AirtableWebhookPayload): Promise<void> {
    const span = SOC2.beginSpan(SOC2.CC6_8);

    try {
      span.setInput('webhookId', payload.webhook.id);
      span.setInput('baseId', payload.base.id);
      span.setInput('action', 'webhook_received');

      // Process each change
      for (const change of payload.changes) {
        const changeSpan = SOC2.beginSpan(SOC2.CC6_8);

        changeSpan.setInput('table', change.table);
        changeSpan.setInput('recordId', change.record.id);
        changeSpan.setInput('changeType', change.type);
        changeSpan.setInput('changedFields', Object.keys(change.fields || {}));

        changeSpan.setOutput('changeTracked', true);
        changeSpan.setOutput('timestamp', change.timestamp);
        changeSpan.end();
      }

      span.setOutput('changesProcessed', payload.changes.length);
      span.end();
    } catch (error) {
      span.endWithError(error as Error);
      throw error;
    }
  }
}
```

### 4. Evidence Queries

```promql
# All Airtable record accesses (GDPR Art.15)
{compliance.control="Art.15", table=~".*"}

# Data deletion requests (GDPR Art.17)
{compliance.control="Art.17", deletedRecords>0}

# Record changes (SOC 2 CC6.8)
{compliance.control="CC6.8", changeTracked="true"}

# Unauthorized access attempts
{compliance.framework="soc2", compliance.control="CC6.1", authorized="false"}
```

## How to Implement This Example

### Step 1: Install Airtable SDK

```bash
npm install airtable
npm install @compliance/gdpr @compliance/soc2
```

### Step 2: Wrap Airtable Client

```typescript
import { ComplianceAirtableClient } from './airtable-wrapper';

const airtable = new ComplianceAirtableClient(
  process.env.AIRTABLE_API_KEY!,
  process.env.AIRTABLE_BASE_ID!
);

// Every operation emits evidence
const contact = await airtable.getRecord('Contacts', 'rec123', 'alice@example.com');
await airtable.createRecord('Orders', { Product: 'Widget', Quantity: 5 }, 'alice@example.com');
```

### Step 3: Configure OpenTelemetry

```typescript
import { NodeTracerProvider } from '@opentelemetry/sdk-trace-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';

const provider = new NodeTracerProvider();
provider.addSpanProcessor(new BatchSpanProcessor(
  new OTLPTraceExporter({ url: 'http://localhost:4318/v1/traces' })
));
provider.register();
```

### Step 4: Test with Real Airtable

```bash
# Set credentials
export AIRTABLE_API_KEY=your-api-key
export AIRTABLE_BASE_ID=your-base-id

# Run demo
nix run
```

## Benefits

1. **Compliance for no-code tools** - Bring compliance to Airtable
2. **GDPR data subject requests** - Automated export and deletion
3. **Audit trail** - Track all changes with evidence
4. **Integration ready** - Works with Airtable webhooks

## Challenges

- Airtable API is paginated (need to handle page iteration)
- Formula syntax for filtering is Airtable-specific
- Rate limits need to be handled gracefully
- Linked records add complexity to GDPR deletion

## Contributing

Want to implement this example?

1. Create `ComplianceAirtableClient` class
2. Wrap CRUD operations with evidence spans
3. Implement GDPR data subject request handlers
4. Add webhook handler with SOC 2 evidence
5. Create Nix flake for reproducible build
6. Test with real Airtable base
7. Submit pull request

See **[../../../CONTRIBUTING.md](../../../CONTRIBUTING.md)** for guidelines.

---

**Low-code tools need compliance too.**
