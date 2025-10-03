import { ComplianceS3Client } from './s3-wrapper';
import { ComplianceDynamoDBClient } from './dynamodb-wrapper';

async function demonstrateS3() {
  console.log('=== S3 Compliance Operations ===\n');

  const s3 = new ComplianceS3Client({
    region: 'us-east-1',
    endpoint: 'http://localhost:4566', // LocalStack for demo
  });

  try {
    // GDPR Art.5(1)(f) + SOC 2 CC6.1: Create user data
    console.log('1. Uploading user data (GDPR Art.5(1)(f) + SOC 2 CC6.1)...');
    await s3.putObject('user-data', 'users/123/profile.json', JSON.stringify({
      userId: '123',
      email: 'alice@example.com',
      name: 'Alice',
    }), '123');
    console.log('   ✓ Data uploaded with encryption evidence\n');

    // GDPR Art.15: Access user data
    console.log('2. Retrieving user data (GDPR Art.15)...');
    const userProfile = await s3.getObject('user-data', 'users/123/profile.json', '123');
    console.log('   ✓ Data retrieved with access evidence\n');

    // GDPR Art.15: List user data
    console.log('3. Listing user files (GDPR Art.15)...');
    const userFiles = await s3.listObjects('user-data', 'users/123/', '123');
    console.log(`   ✓ Found ${userFiles.KeyCount} files\n`);

    // GDPR Art.17: Delete user data
    console.log('4. Deleting user data (GDPR Art.17)...');
    await s3.deleteObject('user-data', 'users/123/profile.json', '123');
    console.log('   ✓ Data deleted with erasure evidence\n');

  } catch (error) {
    console.error('S3 Error:', error);
  }
}

async function demonstrateDynamoDB() {
  console.log('=== DynamoDB Compliance Operations ===\n');

  const dynamodb = new ComplianceDynamoDBClient({
    region: 'us-east-1',
    endpoint: 'http://localhost:4566', // LocalStack for demo
  });

  try {
    // GDPR Art.5(1)(f) + SOC 2 CC6.1: Create user record
    console.log('1. Creating user record (GDPR Art.5(1)(f) + SOC 2 CC6.1)...');
    await dynamodb.putItem('Users', {
      userId: '123',
      email: 'alice@example.com',
      name: 'Alice',
      createdAt: new Date().toISOString(),
    }, '123');
    console.log('   ✓ Record created with authorization evidence\n');

    // GDPR Art.15: Get user record
    console.log('2. Retrieving user record (GDPR Art.15)...');
    const user = await dynamodb.getItem('Users', { userId: '123' }, '123');
    console.log('   ✓ Record retrieved:', user?.email, '\n');

    // GDPR Art.15: Query user activities
    console.log('3. Querying user activities (GDPR Art.15)...');
    const activities = await dynamodb.query(
      'UserActivities',
      'userId = :userId',
      { ':userId': '123' },
      '123'
    );
    console.log(`   ✓ Found ${activities.length} activities\n`);

    // GDPR Art.17: Delete user record
    console.log('4. Deleting user record (GDPR Art.17)...');
    await dynamodb.deleteItem('Users', { userId: '123' }, '123');
    console.log('   ✓ Record deleted with erasure evidence\n');

  } catch (error) {
    console.error('DynamoDB Error:', error);
  }
}

async function main() {
  console.log('AWS SDK Compliance Wrapper Demo\n');
  console.log('This demonstrates how to wrap AWS SDK calls with compliance evidence.\n');
  console.log('Configure OTEL_EXPORTER_OTLP_ENDPOINT to emit evidence spans.\n');
  console.log('---\n');

  await demonstrateS3();
  console.log('\n');
  await demonstrateDynamoDB();

  console.log('\n✓ Demo complete. Check your observability backend for evidence.');
}

main().catch(console.error);

export { ComplianceS3Client, ComplianceDynamoDBClient };
