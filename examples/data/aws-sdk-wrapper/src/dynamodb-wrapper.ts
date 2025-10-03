import { DynamoDBClient, GetItemCommand, PutItemCommand, DeleteItemCommand, QueryCommand, ScanCommand } from '@aws-sdk/client-dynamodb';
import { marshall, unmarshall } from '@aws-sdk/util-dynamodb';
import { GDPR } from '@compliance/gdpr';
import { SOC2 } from '@compliance/soc2';

export interface DynamoDBConfig {
  region: string;
  endpoint?: string;
  credentials?: {
    accessKeyId: string;
    secretAccessKey: string;
  };
}

export class ComplianceDynamoDBClient {
  private client: DynamoDBClient;

  constructor(config: DynamoDBConfig) {
    this.client = new DynamoDBClient(config);
  }

  /**
   * Get item from DynamoDB - implements GDPR Right of Access (Art.15)
   */
  async getItem(tableName: string, key: Record<string, any>, userId?: string): Promise<any> {
    const span = GDPR.beginSpan(GDPR.Art_15);

    try {
      span.setInput('tableName', tableName);
      span.setInput('key', JSON.stringify(key));
      if (userId) {
        span.setInput('userId', userId);
      }
      span.setInput('operation', 'DynamoDB.GetItem');

      const command = new GetItemCommand({
        TableName: tableName,
        Key: marshall(key),
      });

      const response = await this.client.send(command);
      const item = response.Item ? unmarshall(response.Item) : null;

      span.setOutput('recordsReturned', item ? 1 : 0);
      span.end();

      return item;
    } catch (error) {
      span.endWithError(error as Error);
      throw error;
    }
  }

  /**
   * Put item to DynamoDB - implements GDPR Security of Processing (Art.5(1)(f)) + SOC 2 CC6.1
   */
  async putItem(tableName: string, item: Record<string, any>, userId?: string): Promise<any> {
    const gdprSpan = GDPR.beginSpan(GDPR.Art_51f);
    const soc2Span = SOC2.beginSpan(SOC2.CC6_1);

    try {
      gdprSpan.setInput('tableName', tableName);
      gdprSpan.setInput('operation', 'DynamoDB.PutItem');
      if (userId) {
        gdprSpan.setInput('userId', userId);
      }

      soc2Span.setInput('tableName', tableName);
      soc2Span.setInput('action', 'write_item');

      const command = new PutItemCommand({
        TableName: tableName,
        Item: marshall(item),
      });

      const response = await this.client.send(command);

      gdprSpan.setOutput('recordsCreated', 1);
      gdprSpan.setOutput('itemStored', true);

      soc2Span.setOutput('authorized', true);
      soc2Span.setOutput('result', 'success');

      gdprSpan.end();
      soc2Span.end();

      return response;
    } catch (error) {
      gdprSpan.endWithError(error as Error);
      soc2Span.endWithError(error as Error);
      throw error;
    }
  }

  /**
   * Delete item from DynamoDB - implements GDPR Right to Erasure (Art.17)
   */
  async deleteItem(tableName: string, key: Record<string, any>, userId?: string): Promise<any> {
    const span = GDPR.beginSpan(GDPR.Art_17);

    try {
      span.setInput('tableName', tableName);
      span.setInput('key', JSON.stringify(key));
      if (userId) {
        span.setInput('userId', userId);
      }
      span.setInput('operation', 'DynamoDB.DeleteItem');

      const command = new DeleteItemCommand({
        TableName: tableName,
        Key: marshall(key),
      });

      const response = await this.client.send(command);

      span.setOutput('deletedRecords', 1);
      span.end();

      return response;
    } catch (error) {
      span.endWithError(error as Error);
      throw error;
    }
  }

  /**
   * Query items from DynamoDB - implements GDPR Right of Access (Art.15)
   */
  async query(
    tableName: string,
    keyConditionExpression: string,
    expressionAttributeValues: Record<string, any>,
    userId?: string
  ): Promise<any[]> {
    const span = GDPR.beginSpan(GDPR.Art_15);

    try {
      span.setInput('tableName', tableName);
      span.setInput('keyConditionExpression', keyConditionExpression);
      if (userId) {
        span.setInput('userId', userId);
      }
      span.setInput('operation', 'DynamoDB.Query');

      const command = new QueryCommand({
        TableName: tableName,
        KeyConditionExpression: keyConditionExpression,
        ExpressionAttributeValues: marshall(expressionAttributeValues),
      });

      const response = await this.client.send(command);
      const items = response.Items?.map(item => unmarshall(item)) || [];

      span.setOutput('recordsReturned', items.length);
      span.end();

      return items;
    } catch (error) {
      span.endWithError(error as Error);
      throw error;
    }
  }

  /**
   * Scan items from DynamoDB - implements GDPR Right of Access (Art.15)
   * Note: Scan operations should be used cautiously for compliance due to performance
   */
  async scan(tableName: string, filterExpression?: string, userId?: string): Promise<any[]> {
    const span = GDPR.beginSpan(GDPR.Art_15);

    try {
      span.setInput('tableName', tableName);
      if (filterExpression) {
        span.setInput('filterExpression', filterExpression);
      }
      if (userId) {
        span.setInput('userId', userId);
      }
      span.setInput('operation', 'DynamoDB.Scan');

      const command = new ScanCommand({
        TableName: tableName,
        FilterExpression: filterExpression,
      });

      const response = await this.client.send(command);
      const items = response.Items?.map(item => unmarshall(item)) || [];

      span.setOutput('recordsReturned', items.length);
      span.setOutput('scannedCount', response.ScannedCount);
      span.end();

      return items;
    } catch (error) {
      span.endWithError(error as Error);
      throw error;
    }
  }
}
