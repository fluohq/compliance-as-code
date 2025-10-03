# Snowflake Wrapper - Compliance Evidence

> **Status**: 📝 Placeholder - Contribution Welcome

## Why This Example Matters

Data warehouse queries need compliance evidence for:
- **GDPR Art.15**: Right of Access - Track data exports
- **HIPAA §164.312(a)(1)**: Access Control - Who queried PHI
- **SOC 2 CC6.1**: Authorization - Every query execution
- **SOC 2 CC7.2**: Monitoring - Query patterns and anomalies

Every Snowflake query is a potential GDPR data subject request that needs evidence.

## What This Example Would Show

### 1. Query Wrapper with Evidence

```typescript
import { createConnection } from 'snowflake-sdk';
import { GDPR } from '@compliance/gdpr';
import { SOC2 } from '@compliance/soc2';

export class ComplianceSnowflakeClient {
  private connection: any;

  constructor(config: SnowflakeConfig) {
    this.connection = createConnection(config);
  }

  /**
   * Execute SELECT query - implements GDPR Right of Access (Art.15)
   */
  async query(sql: string, binds?: any[], userId?: string): Promise<any[]> {
    const span = GDPR.beginSpan(GDPR.Art_15);

    try {
      span.setInput('sql', sql);
      span.setInput('database', this.connection.database);
      if (userId) {
        span.setInput('userId', userId);
      }

      const results = await this.executeQuery(sql, binds);

      span.setOutput('recordsReturned', results.length);
      span.setOutput('tablesAccessed', this.extractTables(sql));
      span.end();

      return results;
    } catch (error) {
      span.endWithError(error as Error);
      throw error;
    }
  }

  /**
   * Execute INSERT - implements SOC 2 CC6.1 (Authorization)
   */
  async insert(table: string, data: Record<string, any>, userId?: string): Promise<void> {
    const span = SOC2.beginSpan(SOC2.CC6_1);

    try {
      span.setInput('table', table);
      span.setInput('action', 'insert');
      if (userId) {
        span.setInput('userId', userId);
      }

      const columns = Object.keys(data);
      const values = Object.values(data);
      const sql = `INSERT INTO ${table} (${columns.join(', ')}) VALUES (${columns.map(() => '?').join(', ')})`;

      await this.executeQuery(sql, values);

      span.setOutput('authorized', true);
      span.setOutput('result', 'success');
      span.setOutput('recordsInserted', 1);
      span.end();
    } catch (error) {
      span.endWithError(error as Error);
      throw error;
    }
  }

  /**
   * Execute DELETE - implements GDPR Right to Erasure (Art.17)
   */
  async delete(table: string, where: string, binds?: any[], userId?: string): Promise<number> {
    const span = GDPR.beginSpan(GDPR.Art_17);

    try {
      span.setInput('table', table);
      span.setInput('where', where);
      if (userId) {
        span.setInput('userId', userId);
      }

      const sql = `DELETE FROM ${table} WHERE ${where}`;
      const result = await this.executeQuery(sql, binds);

      const deleted = result.rowsAffected || 0;
      span.setOutput('deletedRecords', deleted);
      span.setOutput('tablesCleared', 1);
      span.end();

      return deleted;
    } catch (error) {
      span.endWithError(error as Error);
      throw error;
    }
  }

  private async executeQuery(sql: string, binds?: any[]): Promise<any> {
    return new Promise((resolve, reject) => {
      this.connection.execute({
        sqlText: sql,
        binds: binds,
        complete: (err: Error, stmt: any, rows: any[]) => {
          if (err) {
            reject(err);
          } else {
            resolve(rows);
          }
        },
      });
    });
  }

  private extractTables(sql: string): string[] {
    // Simple regex to extract table names from SQL
    const matches = sql.match(/FROM\\s+(\\w+)|JOIN\\s+(\\w+)/gi) || [];
    return [...new Set(matches.map(m => m.split(/\\s+/)[1]))];
  }
}
```

### 2. GDPR Data Subject Request

```typescript
export class GDPRDataSubjectRequest {
  constructor(private snowflake: ComplianceSnowflakeClient) {}

  /**
   * Handle GDPR Art.15 - Right of Access
   * Export all user data from Snowflake
   */
  async exportUserData(userId: string): Promise<UserData> {
    const span = GDPR.beginSpan(GDPR.Art_15);

    try {
      span.setInput('userId', userId);
      span.setInput('requestType', 'data_export');

      // Query user profile
      const profile = await this.snowflake.query(
        'SELECT * FROM users WHERE user_id = ?',
        [userId],
        userId
      );

      // Query user activities
      const activities = await this.snowflake.query(
        'SELECT * FROM user_activities WHERE user_id = ? ORDER BY created_at DESC',
        [userId],
        userId
      );

      // Query user orders
      const orders = await this.snowflake.query(
        'SELECT * FROM orders WHERE user_id = ?',
        [userId],
        userId
      );

      const totalRecords = profile.length + activities.length + orders.length;
      span.setOutput('recordsReturned', totalRecords);
      span.setOutput('tablesAccessed', ['users', 'user_activities', 'orders']);
      span.end();

      return {
        profile: profile[0],
        activities,
        orders,
      };
    } catch (error) {
      span.endWithError(error as Error);
      throw error;
    }
  }

  /**
   * Handle GDPR Art.17 - Right to Erasure
   * Delete all user data from Snowflake
   */
  async deleteUserData(userId: string): Promise<DeletionReport> {
    const span = GDPR.beginSpan(GDPR.Art_17);

    try {
      span.setInput('userId', userId);
      span.setInput('requestType', 'data_deletion');

      let totalDeleted = 0;

      // Delete from users table
      totalDeleted += await this.snowflake.delete('users', 'user_id = ?', [userId], userId);

      // Delete from activities table
      totalDeleted += await this.snowflake.delete('user_activities', 'user_id = ?', [userId], userId);

      // Anonymize orders (keep for business records)
      await this.snowflake.query(
        'UPDATE orders SET user_id = NULL, email = NULL WHERE user_id = ?',
        [userId],
        userId
      );

      span.setOutput('deletedRecords', totalDeleted);
      span.setOutput('tablesCleared', 2);
      span.setOutput('tablesAnonymized', 1);
      span.end();

      return {
        deleted: totalDeleted,
        anonymized: 1,
        tables: ['users', 'user_activities', 'orders'],
      };
    } catch (error) {
      span.endWithError(error as Error);
      throw error;
    }
  }
}
```

### 3. Query Monitoring with Evidence

```typescript
export class QueryMonitor {
  constructor(private snowflake: ComplianceSnowflakeClient) {}

  /**
   * Monitor query patterns for anomalies
   * Implements SOC 2 CC7.2 - System Monitoring
   */
  async monitorQueries(timeWindow: number = 3600): Promise<QueryStats> {
    const span = SOC2.beginSpan(SOC2.CC7_2);

    try {
      span.setInput('timeWindow', timeWindow);
      span.setInput('monitoring', 'query_patterns');

      const queries = await this.snowflake.query(`
        SELECT
          user_name,
          query_text,
          execution_time,
          rows_produced,
          bytes_scanned
        FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
        WHERE start_time >= DATEADD(second, -${timeWindow}, CURRENT_TIMESTAMP())
        ORDER BY start_time DESC
      `);

      const stats = this.analyzeQueries(queries);

      span.setOutput('queriesAnalyzed', queries.length);
      span.setOutput('anomaliesDetected', stats.anomalies.length);
      span.setOutput('avgExecutionTime', stats.avgExecutionTime);
      span.end();

      return stats;
    } catch (error) {
      span.endWithError(error as Error);
      throw error;
    }
  }

  private analyzeQueries(queries: any[]): QueryStats {
    const anomalies = queries.filter(q =>
      q.execution_time > 60000 || // Queries over 1 minute
      q.rows_produced > 1000000    // Large data exports
    );

    const avgExecutionTime = queries.reduce((sum, q) => sum + q.execution_time, 0) / queries.length;

    return {
      total: queries.length,
      anomalies,
      avgExecutionTime,
    };
  }
}
```

### 4. Evidence Queries

```promql
# All Snowflake queries (GDPR Art.15)
{compliance.control="Art.15", database=~".*"}

# Data deletion requests (GDPR Art.17)
{compliance.control="Art.17", tablesCleared>0}

# Large data exports (potential compliance risk)
{compliance.control="Art.15", recordsReturned>10000}

# Unauthorized access attempts
{compliance.framework="soc2", compliance.control="CC6.1", authorized="false"}

# Query anomalies
{compliance.control="CC7.2", anomaliesDetected>0}
```

## How to Implement This Example

### Step 1: Install Snowflake SDK

```bash
npm install snowflake-sdk
npm install @compliance/gdpr @compliance/soc2
```

### Step 2: Wrap Snowflake Connection

```typescript
import { ComplianceSnowflakeClient } from './snowflake-wrapper';

const sf = new ComplianceSnowflakeClient({
  account: 'your-account',
  username: 'your-username',
  password: 'your-password',
  warehouse: 'COMPUTE_WH',
  database: 'PRODUCTION',
  schema: 'PUBLIC',
});

// Every query emits evidence
const users = await sf.query('SELECT * FROM users WHERE email = ?', ['alice@example.com'], 'alice');
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

### Step 4: Test with Real Snowflake

```bash
# Set credentials
export SNOWFLAKE_ACCOUNT=your-account
export SNOWFLAKE_USERNAME=your-username
export SNOWFLAKE_PASSWORD=your-password

# Run demo
nix run
```

## Benefits

1. **Complete audit trail** - Every query tracked with evidence
2. **GDPR compliance** - Data subject requests with evidence
3. **Anomaly detection** - Monitor for unusual query patterns
4. **Query attribution** - Know who accessed what data

## Challenges

- Snowflake SDK is callback-based (need to promisify)
- Query parsing to extract tables is non-trivial
- Large result sets need streaming
- Need to handle Snowflake-specific errors

## Contributing

Want to implement this example?

1. Create `ComplianceSnowflakeClient` class
2. Wrap query execution with evidence spans
3. Implement GDPR data subject request handlers
4. Add query monitoring with SOC 2 evidence
5. Create Nix flake for reproducible build
6. Test with real Snowflake account
7. Submit pull request

See **[../../../CONTRIBUTING.md](../../../CONTRIBUTING.md)** for guidelines.

---

**Every query is evidence.**
