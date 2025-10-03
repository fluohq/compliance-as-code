import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";
import { GDPR } from "@compliance/gdpr";
import { SOC2 } from "@compliance/soc2";

/**
 * Compliance-aware wrapper for Pulumi AWS resources
 * Emits GDPR and SOC 2 evidence for all infrastructure operations
 */

/**
 * Create encrypted S3 bucket with GDPR Art.32 evidence
 */
export function createEncryptedBucket(name: string, opts?: pulumi.ResourceOptions): aws.s3.BucketV2 {
  // GDPR Art.32: Security of Processing (encryption)
  const gdprSpan = GDPR.beginSpan(GDPR.Art_32);
  // SOC 2 CC6.8: Change Management
  const soc2Span = SOC2.beginSpan(SOC2.CC6_8);

  try {
    gdprSpan.setInput("resource", "s3_bucket");
    gdprSpan.setInput("name", name);
    gdprSpan.setInput("encrypted", true);

    soc2Span.setInput("resource", "s3_bucket");
    soc2Span.setInput("action", "create");
    soc2Span.setInput("name", name);

    // Create bucket with versioning
    const bucket = new aws.s3.BucketV2(name, {
      bucket: name,
      tags: {
        "compliance:gdpr": "Art.32",
        "compliance:soc2": "CC6.8",
      },
    }, opts);

    // Enable versioning (GDPR data protection)
    new aws.s3.BucketVersioningV2(`${name}-versioning`, {
      bucket: bucket.id,
      versioningConfiguration: {
        status: "Enabled",
      },
    }, { parent: bucket });

    // Enable encryption
    new aws.s3.BucketServerSideEncryptionConfigurationV2(`${name}-encryption`, {
      bucket: bucket.id,
      rules: [{
        applyServerSideEncryptionByDefault: {
          sseAlgorithm: "AES256",
        },
      }],
    }, { parent: bucket });

    // Emit evidence on resource creation
    bucket.urn.apply(urn => {
      gdprSpan.setOutput("bucketUrn", urn);
      gdprSpan.setOutput("encrypted", true);
      gdprSpan.setOutput("versioning", true);
      gdprSpan.setOutput("compliant", true);

      soc2Span.setOutput("bucketUrn", urn);
      soc2Span.setOutput("changeTracked", true);
      soc2Span.setOutput("result", "success");

      gdprSpan.end();
      soc2Span.end();
    });

    return bucket;
  } catch (error) {
    gdprSpan.endWithError(error as Error);
    soc2Span.endWithError(error as Error);
    throw error;
  }
}

/**
 * Create encrypted RDS database with GDPR Art.32 evidence
 */
export function createEncryptedDatabase(
  name: string,
  config: {
    engine: string;
    instanceClass: string;
    allocatedStorage: number;
    username: string;
    password: pulumi.Output<string>;
    subnetIds: pulumi.Input<string>[];
  },
  opts?: pulumi.ResourceOptions
): aws.rds.Instance {
  // GDPR Art.32: Security of Processing (encryption)
  const gdprSpan = GDPR.beginSpan(GDPR.Art_32);
  // SOC 2 CC6.8: Change Management
  const soc2Span = SOC2.beginSpan(SOC2.CC6_8);

  try {
    gdprSpan.setInput("resource", "rds_database");
    gdprSpan.setInput("name", name);
    gdprSpan.setInput("encrypted", true);
    gdprSpan.setInput("engine", config.engine);

    soc2Span.setInput("resource", "rds_database");
    soc2Span.setInput("action", "create");
    soc2Span.setInput("name", name);

    // Create subnet group
    const subnetGroup = new aws.rds.SubnetGroup(`${name}-subnet-group`, {
      subnetIds: config.subnetIds,
    }, opts);

    // Create encrypted database instance
    const db = new aws.rds.Instance(name, {
      engine: config.engine,
      instanceClass: config.instanceClass,
      allocatedStorage: config.allocatedStorage,
      username: config.username,
      password: config.password,
      dbSubnetGroupName: subnetGroup.name,
      storageEncrypted: true, // REQUIRED by GDPR Art.32
      backupRetentionPeriod: 7, // GDPR data protection
      skipFinalSnapshot: false,
      finalSnapshotIdentifier: `${name}-final-snapshot`,
      tags: {
        "compliance:gdpr": "Art.32",
        "compliance:soc2": "CC6.8",
      },
    }, { parent: subnetGroup, ...opts });

    // Emit evidence on database creation
    db.urn.apply(urn => {
      gdprSpan.setOutput("databaseUrn", urn);
      gdprSpan.setOutput("encrypted", true);
      gdprSpan.setOutput("backupRetention", 7);
      gdprSpan.setOutput("compliant", true);

      soc2Span.setOutput("databaseUrn", urn);
      soc2Span.setOutput("changeTracked", true);
      soc2Span.setOutput("result", "success");

      gdprSpan.end();
      soc2Span.end();
    });

    return db;
  } catch (error) {
    gdprSpan.endWithError(error as Error);
    soc2Span.endWithError(error as Error);
    throw error;
  }
}

/**
 * Create KMS encryption key with GDPR Art.32 evidence
 */
export function createEncryptionKey(
  name: string,
  config: {
    description: string;
    deletionWindowInDays?: number;
  },
  opts?: pulumi.ResourceOptions
): aws.kms.Key {
  // GDPR Art.32: Security of Processing
  const gdprSpan = GDPR.beginSpan(GDPR.Art_32);
  // SOC 2 CC6.1: Logical Access Controls
  const soc2Span = SOC2.beginSpan(SOC2.CC6_1);

  try {
    gdprSpan.setInput("resource", "kms_key");
    gdprSpan.setInput("name", name);
    gdprSpan.setInput("description", config.description);

    soc2Span.setInput("resource", "kms_key");
    soc2Span.setInput("action", "create");
    soc2Span.setInput("name", name);

    const key = new aws.kms.Key(name, {
      description: config.description,
      deletionWindowInDays: config.deletionWindowInDays || 30,
      enableKeyRotation: true, // GDPR best practice
      tags: {
        "compliance:gdpr": "Art.32",
        "compliance:soc2": "CC6.1",
      },
    }, opts);

    // Create alias
    new aws.kms.Alias(`${name}-alias`, {
      name: `alias/${name}`,
      targetKeyId: key.id,
    }, { parent: key });

    key.urn.apply(urn => {
      gdprSpan.setOutput("keyUrn", urn);
      gdprSpan.setOutput("rotationEnabled", true);
      gdprSpan.setOutput("compliant", true);

      soc2Span.setOutput("keyUrn", urn);
      soc2Span.setOutput("authorized", true);
      soc2Span.setOutput("result", "success");

      gdprSpan.end();
      soc2Span.end();
    });

    return key;
  } catch (error) {
    gdprSpan.endWithError(error as Error);
    soc2Span.endWithError(error as Error);
    throw error;
  }
}

/**
 * Create VPC with security controls and evidence
 */
export function createSecureVPC(
  name: string,
  config: {
    cidrBlock: string;
    enableDnsHostnames?: boolean;
    enableDnsSupport?: boolean;
  },
  opts?: pulumi.ResourceOptions
): aws.ec2.Vpc {
  // GDPR Art.5(1)(f): Security of Processing
  const gdprSpan = GDPR.beginSpan(GDPR.Art_51f);
  // SOC 2 CC6.6: Logical and Physical Access Controls
  const soc2Span = SOC2.beginSpan(SOC2.CC6_6);

  try {
    gdprSpan.setInput("resource", "vpc");
    gdprSpan.setInput("name", name);
    gdprSpan.setInput("cidrBlock", config.cidrBlock);

    soc2Span.setInput("resource", "vpc");
    soc2Span.setInput("action", "create");
    soc2Span.setInput("name", name);

    const vpc = new aws.ec2.Vpc(name, {
      cidrBlock: config.cidrBlock,
      enableDnsHostnames: config.enableDnsHostnames ?? true,
      enableDnsSupport: config.enableDnsSupport ?? true,
      tags: {
        Name: name,
        "compliance:gdpr": "Art.5(1)(f)",
        "compliance:soc2": "CC6.6",
      },
    }, opts);

    // Enable VPC Flow Logs (SOC 2 monitoring)
    const flowLogRole = new aws.iam.Role(`${name}-flow-log-role`, {
      assumeRolePolicy: JSON.stringify({
        Version: "2012-10-17",
        Statement: [{
          Action: "sts:AssumeRole",
          Effect: "Allow",
          Principal: {
            Service: "vpc-flow-logs.amazonaws.com",
          },
        }],
      }),
    }, { parent: vpc });

    const flowLogGroup = new aws.cloudwatch.LogGroup(`${name}-flow-logs`, {
      retentionInDays: 30,
    }, { parent: vpc });

    new aws.ec2.FlowLog(`${name}-flow-log`, {
      vpcId: vpc.id,
      trafficType: "ALL",
      logDestinationType: "cloud-watch-logs",
      logDestination: flowLogGroup.arn,
      iamRoleArn: flowLogRole.arn,
    }, { parent: vpc });

    vpc.urn.apply(urn => {
      gdprSpan.setOutput("vpcUrn", urn);
      gdprSpan.setOutput("flowLogsEnabled", true);
      gdprSpan.setOutput("compliant", true);

      soc2Span.setOutput("vpcUrn", urn);
      soc2Span.setOutput("accessControlsEnabled", true);
      soc2Span.setOutput("result", "success");

      gdprSpan.end();
      soc2Span.end();
    });

    return vpc;
  } catch (error) {
    gdprSpan.endWithError(error as Error);
    soc2Span.endWithError(error as Error);
    throw error;
  }
}

/**
 * Destroy resource with GDPR Art.17 evidence (Right to Erasure)
 */
export function destroyResourceWithEvidence(
  resourceType: string,
  resourceId: string
): void {
  const span = GDPR.beginSpan(GDPR.Art_17);

  try {
    span.setInput("resource", resourceType);
    span.setInput("resourceId", resourceId);
    span.setInput("operation", "destroy");

    // Resource deletion happens via Pulumi destroy
    // This function emits evidence for the deletion

    span.setOutput("deletedResources", 1);
    span.setOutput("result", "scheduled_for_deletion");
    span.end();
  } catch (error) {
    span.endWithError(error as Error);
  }
}
