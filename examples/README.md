# Compliance as Code Examples

This directory contains working examples showing how to integrate compliance evidence into various frameworks and tools.

## Working Examples

### Backend Frameworks

- **[Java Spring Boot](./backend/java-spring-boot/)** - REST API with @GDPREvidence annotations
- **[Go HTTP Server](./backend/go-http/)** - HTTP server with context-based evidence
- **[Python FastAPI](./backend/python-fastapi/)** - Async API with decorator-based evidence
- **[TypeScript NestJS](./backend/typescript-nestjs/)** - DI framework with evidence decorators

### Data & Cloud

- **[AWS SDK Wrapper](./data/aws-sdk-wrapper/)** - TypeScript wrapper emitting evidence for S3/DynamoDB operations

### Infrastructure

- **[Nix Flake](./infrastructure/nix-flake/)** - Build evidence for Nix derivations

## Placeholder Examples (README only)

These examples explain the use case but need external dependencies or accounts to implement:

### Backend Frameworks

- **[Apache Camel](./backend/java-camel/)** - Integration patterns with evidence
- **[Python Django](./backend/python-django/)** - Full-stack framework with ORM evidence
- **[TypeScript Express](./backend/typescript-express/)** - Minimal middleware approach
- **[TypeScript tRPC](./backend/typescript-trpc/)** - Type-safe RPC with evidence

### Frontend

- **[Next.js App](./frontend/nextjs-app/)** - Server actions with evidence
- **[HTMX App](./frontend/htmx-app/)** - Hypermedia with server-side evidence

### Data & Cloud

- **[Snowflake Wrapper](./data/snowflake-wrapper/)** - Data warehouse query evidence
- **[Airtable Wrapper](./data/airtable-wrapper/)** - Low-code tool evidence

### Infrastructure

- **[Kubernetes Admission Webhook](./infrastructure/kubernetes/)** - Admission control with evidence
- **[Terraform Wrapper](./infrastructure/terraform/)** - Infrastructure changes with evidence
- **[AWS CDK](./infrastructure/aws-cdk/)** - CDK aspects for evidence
- **[Pulumi](./infrastructure/pulumi/)** - Dynamic provider with evidence
- **[KCL](./infrastructure/kcl-lang/)** - Configuration validation with evidence

## Example Structure

Each working example follows this structure:

```
example-name/
├── README.md           # What it demonstrates
├── flake.nix           # Nix build configuration
├── src/                # Source code
└── tests/              # Test suite
```

Each placeholder follows this structure:

```
example-name/
└── README.md           # Why it matters, what it would show, how to contribute
```

## Running Examples

### Working Examples

```bash
# Build and run
cd examples/backend/java-spring-boot
nix build
nix run

# Or use the flake directly
nix run github:fluohq/compliance-as-code#example-java-spring-boot
```

### Contributing Examples

See **[../CONTRIBUTING.md](../CONTRIBUTING.md)** for guidelines on adding new examples.

We especially welcome:
- Examples for frameworks not yet covered
- Real-world integration patterns
- Performance optimizations
- Alternative evidence capture strategies

## Philosophy

Examples should:
- **Be minimal** - Focus on compliance integration, not the framework itself
- **Be runnable** - Use Nix for reproducible builds
- **Show real value** - Demonstrate evidence capture that matters for audits
- **Explain tradeoffs** - Discuss performance, complexity, and alternatives

---

**Compliance is observable infrastructure.**
