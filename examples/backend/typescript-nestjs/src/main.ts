import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  console.log('=' .repeat(50));
  console.log('NestJS Compliance Evidence Example');
  console.log('=' .repeat(50));
  console.log();
  console.log('Frameworks: GDPR, SOC 2');
  console.log('Controls: Art.15, Art.17, Art.5(1)(f), CC6.1');
  console.log();
  console.log('Endpoints:');
  console.log('  GET    /health              - Health check');
  console.log('  GET    /user/:id            - Get user (GDPR Art.15)');
  console.log('  GET    /users               - List users (GDPR Art.15)');
  console.log('  POST   /user                - Create user (GDPR + SOC2)');
  console.log('  DELETE /user/:id            - Delete user (GDPR Art.17)');
  console.log();
  console.log('Evidence emitted as OpenTelemetry spans');
  console.log('Configure OTEL_EXPORTER_OTLP_ENDPOINT to export');
  console.log('=' .repeat(50));

  await app.listen(3000);
}
bootstrap();
