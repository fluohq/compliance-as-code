# NestJS with Compliance Evidence

> **Status**: 📝 Placeholder - Contribution Welcome

## Why This Example Matters

NestJS is an enterprise TypeScript framework with:
- **Dependency Injection** - Angular-style providers
- **Decorators** - Method and class decorators
- **Interceptors** - AOP-style cross-cutting concerns
- **OpenAPI** - Built-in Swagger integration

Compliance evidence fits perfectly with NestJS's decorator and interceptor architecture.

## What This Example Would Show

### 1. Method Decorators with Evidence

```typescript
import { Controller, Get, Post, Delete, Param, Body } from '@nestjs/common';
import { GDPREvidence, GDPRControls, EvidenceType } from '@compliance/gdpr';
import { SOC2Evidence, SOC2Controls } from '@compliance/soc2';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get(':id')
  @GDPREvidence({
    control: GDPRControls.Art_15,
    evidenceType: EvidenceType.AUDIT_TRAIL,
    description: 'Retrieve user personal data'
  })
  async getUser(@Param('id') id: string) {
    return this.usersService.findOne(id);
  }

  @Delete(':id')
  @GDPREvidence({
    control: GDPRControls.Art_17,
    evidenceType: EvidenceType.AUDIT_TRAIL,
    description: 'Delete all user data'
  })
  async deleteUser(@Param('id') id: string) {
    return this.usersService.deleteAll(id);
  }

  @Post()
  @GDPREvidence({ control: GDPRControls.Art_51f })
  @SOC2Evidence({ control: SOC2Controls.CC6_1 })
  async createUser(@Body() createUserDto: CreateUserDto) {
    return this.usersService.create(createUserDto);
  }
}
```

### 2. Global Interceptor for Evidence

```typescript
import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { trace } from '@opentelemetry/api';

@Injectable()
export class ComplianceInterceptor implements NestInterceptor {
  constructor(private reflector: Reflector) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const gdprEvidence = this.reflector.get<GDPREvidenceMetadata>(
      'gdpr:evidence',
      context.getHandler()
    );

    if (!gdprEvidence) {
      return next.handle();
    }

    const tracer = trace.getTracer('compliance-nestjs');
    const span = tracer.startSpan('compliance.evidence', {
      attributes: {
        'compliance.framework': 'gdpr',
        'compliance.control': gdprEvidence.control,
        'compliance.evidence_type': gdprEvidence.evidenceType,
      }
    });

    const start = Date.now();

    return next.handle().pipe(
      tap({
        next: (result) => {
          span.setAttribute('compliance.result', 'success');
          span.setAttribute('compliance.duration_ms', Date.now() - start);
          span.end();
        },
        error: (error) => {
          span.setAttribute('compliance.result', 'failure');
          span.setAttribute('compliance.error', error.message);
          span.recordException(error);
          span.end();
        }
      })
    );
  }
}
```

### 3. Module Configuration

```typescript
import { Module } from '@nestjs/common';
import { APP_INTERCEPTOR } from '@nestjs/core';
import { ComplianceInterceptor } from './compliance.interceptor';
import { ComplianceModule } from '@compliance/nestjs';

@Module({
  imports: [
    ComplianceModule.forRoot({
      frameworks: ['gdpr', 'soc2', 'hipaa'],
      otelEndpoint: 'http://localhost:4318',
      redactPatterns: ['password', 'ssn', 'creditCard']
    })
  ],
  providers: [
    {
      provide: APP_INTERCEPTOR,
      useClass: ComplianceInterceptor,
    }
  ]
})
export class AppModule {}
```

### 4. Service Layer Evidence

```typescript
import { Injectable } from '@nestjs/common';
import { GDPREvidence, GDPRControls } from '@compliance/gdpr';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  @GDPREvidence({ control: GDPRControls.Art_15 })
  async findOne(id: string): Promise<User> {
    return this.usersRepository.findOne({ where: { id } });
  }

  @GDPREvidence({ control: GDPRControls.Art_17 })
  async deleteAll(userId: string): Promise<{ deleted: number }> {
    const result = await this.usersRepository.delete({ id: userId });
    return { deleted: result.affected || 0 };
  }
}
```

## How to Implement This Example

### Step 1: Generate TypeScript Code

```bash
cd frameworks/generators
nix build .#ts-gdpr
nix build .#ts-soc2
```

### Step 2: Create NestJS Interceptor

The interceptor extracts metadata from decorators and creates OpenTelemetry spans automatically.

### Step 3: Integrate with Dependency Injection

```typescript
@Injectable()
export class ComplianceService {
  constructor(
    @Inject('OTEL_TRACER') private tracer: Tracer
  ) {}

  createEvidenceSpan(metadata: EvidenceMetadata): Span {
    return this.tracer.startSpan('compliance.evidence', {
      attributes: {
        'compliance.framework': metadata.framework,
        'compliance.control': metadata.control
      }
    });
  }
}
```

### Step 4: Create Example Application

- REST API with TypeORM
- Swagger/OpenAPI documentation
- OpenTelemetry integration
- Docker Compose setup

## Benefits

1. **Framework-native** - Uses NestJS decorators and interceptors
2. **Type-safe** - Full TypeScript support
3. **DI integration** - Compliance as injectable service
4. **OpenAPI** - Compliance visible in Swagger docs
5. **Enterprise-ready** - Follows NestJS best practices

## Challenges

- TypeScript decorators are experimental
- Need to integrate with NestJS reflection system
- Interceptors must handle async operations
- OpenTelemetry integration with NestJS lifecycle

## Contributing

Want to implement this example?

1. Fork the repository
2. Create NestJS interceptor for evidence capture
3. Integrate with generated TypeScript code
4. Add TypeORM/Prisma database integration
5. Create Nix flake for reproducible build
6. Test with OpenTelemetry collector
7. Submit pull request

See **[../../../CONTRIBUTING.md](../../../CONTRIBUTING.md)** for guidelines.

---

**Decorators are evidence.**
