import * as pulumi from "@pulumi/pulumi";
import { createEncryptedBucket, createEncryptedDatabase, createEncryptionKey, createSecureVPC } from "./src";

// Example Pulumi program using compliance wrappers

const config = new pulumi.Config();

// GDPR Art.32: Create KMS encryption key
const kmsKey = createEncryptionKey("user-data-key", {
  description: "Encryption key for user data",
  deletionWindowInDays: 30,
});

// GDPR Art.32: Create encrypted S3 bucket for user data
const userDataBucket = createEncryptedBucket("user-data-bucket", {
  dependsOn: [kmsKey],
});

// GDPR Art.5(1)(f): Create secure VPC
const vpc = createSecureVPC("app-vpc", {
  cidrBlock: "10.0.0.0/16",
  enableDnsHostnames: true,
  enableDnsSupport: true,
});

// Create private subnets for database
const privateSubnet1 = new pulumi.aws.ec2.Subnet("private-subnet-1", {
  vpcId: vpc.id,
  cidrBlock: "10.0.1.0/24",
  availabilityZone: "us-east-1a",
  tags: { Name: "private-subnet-1" },
}, { parent: vpc });

const privateSubnet2 = new pulumi.aws.ec2.Subnet("private-subnet-2", {
  vpcId: vpc.id,
  cidrBlock: "10.0.2.0/24",
  availabilityZone: "us-east-1b",
  tags: { Name: "private-subnet-2" },
}, { parent: vpc });

// GDPR Art.32: Create encrypted RDS database
const dbPassword = config.requireSecret("db-password");
const userDatabase = createEncryptedDatabase("user-database", {
  engine: "postgres",
  instanceClass: "db.t3.micro",
  allocatedStorage: 20,
  username: "admin",
  password: dbPassword,
  subnetIds: [privateSubnet1.id, privateSubnet2.id],
}, {
  dependsOn: [vpc, kmsKey],
});

// Export resource URNs
export const bucketUrn = userDataBucket.urn;
export const databaseUrn = userDatabase.urn;
export const vpcUrn = vpc.urn;
export const kmsKeyId = kmsKey.id;

console.log("Infrastructure deployed with compliance evidence");
console.log("Check OpenTelemetry backend for GDPR + SOC 2 spans");
