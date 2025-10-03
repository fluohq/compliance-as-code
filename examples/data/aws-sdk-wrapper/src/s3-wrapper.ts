import { S3Client, GetObjectCommand, PutObjectCommand, DeleteObjectCommand, ListObjectsV2Command } from '@aws-sdk/client-s3';
import { GDPR } from '@compliance/gdpr';
import { SOC2 } from '@compliance/soc2';

export interface S3Config {
  region: string;
  endpoint?: string;
  credentials?: {
    accessKeyId: string;
    secretAccessKey: string;
  };
}

export class ComplianceS3Client {
  private client: S3Client;

  constructor(config: S3Config) {
    this.client = new S3Client(config);
  }

  /**
   * Get object from S3 - implements GDPR Right of Access (Art.15)
   */
  async getObject(bucket: string, key: string, userId?: string): Promise<any> {
    const span = GDPR.beginSpan(GDPR.Art_15);

    try {
      span.setInput('bucket', bucket);
      span.setInput('key', key);
      if (userId) {
        span.setInput('userId', userId);
      }
      span.setInput('operation', 'S3.GetObject');

      const command = new GetObjectCommand({ Bucket: bucket, Key: key });
      const response = await this.client.send(command);

      span.setOutput('contentLength', response.ContentLength);
      span.setOutput('contentType', response.ContentType);
      span.setOutput('recordsReturned', 1);
      span.end();

      return response;
    } catch (error) {
      span.endWithError(error as Error);
      throw error;
    }
  }

  /**
   * Put object to S3 - implements GDPR Security of Processing (Art.5(1)(f)) + SOC 2 CC6.1
   */
  async putObject(bucket: string, key: string, body: any, userId?: string): Promise<any> {
    const gdprSpan = GDPR.beginSpan(GDPR.Art_51f);
    const soc2Span = SOC2.beginSpan(SOC2.CC6_1);

    try {
      gdprSpan.setInput('bucket', bucket);
      gdprSpan.setInput('key', key);
      gdprSpan.setInput('operation', 'S3.PutObject');
      if (userId) {
        gdprSpan.setInput('userId', userId);
      }

      soc2Span.setInput('bucket', bucket);
      soc2Span.setInput('key', key);
      soc2Span.setInput('action', 'write_object');

      const command = new PutObjectCommand({ Bucket: bucket, Key: key, Body: body });
      const response = await this.client.send(command);

      gdprSpan.setOutput('etag', response.ETag);
      gdprSpan.setOutput('encrypted', !!response.ServerSideEncryption);
      gdprSpan.setOutput('recordsCreated', 1);

      soc2Span.setOutput('authorized', true);
      soc2Span.setOutput('result', 'success');
      soc2Span.setOutput('etag', response.ETag);

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
   * Delete object from S3 - implements GDPR Right to Erasure (Art.17)
   */
  async deleteObject(bucket: string, key: string, userId?: string): Promise<any> {
    const span = GDPR.beginSpan(GDPR.Art_17);

    try {
      span.setInput('bucket', bucket);
      span.setInput('key', key);
      if (userId) {
        span.setInput('userId', userId);
      }
      span.setInput('operation', 'S3.DeleteObject');

      const command = new DeleteObjectCommand({ Bucket: bucket, Key: key });
      const response = await this.client.send(command);

      span.setOutput('deletedRecords', 1);
      span.setOutput('deleteMarker', response.DeleteMarker);
      span.end();

      return response;
    } catch (error) {
      span.endWithError(error as Error);
      throw error;
    }
  }

  /**
   * List objects in S3 bucket - implements GDPR Right of Access (Art.15)
   */
  async listObjects(bucket: string, prefix?: string, userId?: string): Promise<any> {
    const span = GDPR.beginSpan(GDPR.Art_15);

    try {
      span.setInput('bucket', bucket);
      if (prefix) {
        span.setInput('prefix', prefix);
      }
      if (userId) {
        span.setInput('userId', userId);
      }
      span.setInput('operation', 'S3.ListObjectsV2');

      const command = new ListObjectsV2Command({ Bucket: bucket, Prefix: prefix });
      const response = await this.client.send(command);

      span.setOutput('recordsReturned', response.KeyCount || 0);
      span.setOutput('isTruncated', response.IsTruncated);
      span.end();

      return response;
    } catch (error) {
      span.endWithError(error as Error);
      throw error;
    }
  }
}
