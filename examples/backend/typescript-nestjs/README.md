# NestJS with Compliance Evidence

Complete NestJS application with GDPR and SOC 2 compliance evidence using decorators and dependency injection.

## Quick Start

```bash
nix build
nix run
nix run .#test
```

Server runs on http://localhost:3000

## Endpoints

- GET /health - Health check
- GET /user/:id - Get user (GDPR Art.15)
- GET /user - List users (GDPR Art.15)
- POST /user - Create user (GDPR + SOC2)
- DELETE /user/:id - Delete user (GDPR Art.17)

## Evidence Emitted

All operations emit OpenTelemetry spans with compliance metadata.
