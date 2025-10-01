# Python FastAPI with Compliance Evidence

> **Status**: 📝 Placeholder - Contribution Welcome

## Why This Example Matters

FastAPI is a modern Python web framework with:
- **Async/await** - High performance I/O
- **Type hints** - Compile-time type safety
- **Pydantic** - Automatic data validation
- **OpenAPI** - Built-in API documentation

Compliance evidence should integrate seamlessly with FastAPI's decorator pattern and dependency injection system.

## What This Example Would Show

### 1. Decorator-Based Evidence

```python
from fastapi import FastAPI, Depends
from compliance.gdpr import gdpr_evidence, GDPRControls, EvidenceType

app = FastAPI()

@app.get("/users/{user_id}")
@gdpr_evidence(
    control=GDPRControls.Art_15,
    evidence_type=EvidenceType.AUDIT_TRAIL,
    description="Retrieve user personal data"
)
async def get_user(user_id: str):
    user = await db.users.find_one({"id": user_id})
    return user

@app.delete("/users/{user_id}")
@gdpr_evidence(
    control=GDPRControls.Art_17,
    evidence_type=EvidenceType.AUDIT_TRAIL,
    description="Delete all user data"
)
async def delete_user(user_id: str):
    deleted = await db.users.delete_many({"user_id": user_id})
    return {"deleted_count": deleted.deleted_count}
```

### 2. Dependency Injection Integration

```python
from fastapi import Depends
from compliance.soc2 import ComplianceContext, soc2_evidence

async def get_compliance_context() -> ComplianceContext:
    """Dependency that tracks compliance evidence"""
    return ComplianceContext()

@app.post("/users")
@soc2_evidence(control=SOC2Controls.CC6_1)
async def create_user(
    user: UserCreate,
    compliance: ComplianceContext = Depends(get_compliance_context)
):
    # Evidence automatically captured via dependency
    return await db.users.insert_one(user.dict())
```

### 3. Async Evidence Emission

```python
@gdpr_evidence(control=GDPRControls.Art_15)
async def get_user_data(user_id: str):
    # Async OpenTelemetry span emission
    async with tracer.start_as_current_span("compliance.evidence") as span:
        span.set_attribute("compliance.framework", "gdpr")
        span.set_attribute("compliance.control", "Art.15")

        user = await db.users.find_one({"id": user_id})
        orders = await db.orders.find({"user_id": user_id}).to_list(100)

        span.set_attribute("output.recordsReturned", len(orders))

        return {"user": user, "orders": orders}
```

### 4. Pydantic Model Integration

```python
from pydantic import BaseModel, Field
from compliance.annotations import Redact, PII

class UserCreate(BaseModel):
    email: str = Field(..., description="User email")
    password: str = Field(..., redact=True)  # Excluded from evidence
    ssn: str = Field(..., pii=True)  # Hashed in evidence

@app.post("/users")
@gdpr_evidence(control=GDPRControls.Art_51f)
async def create_user(user: UserCreate):
    # Pydantic automatically redacts sensitive fields in evidence
    return await save_user(user)
```

## How to Implement This Example

### Step 1: Create Python Decorator

```python
# compliance/gdpr.py
import functools
from opentelemetry import trace

tracer = trace.get_tracer(__name__)

def gdpr_evidence(control, evidence_type=EvidenceType.AUDIT_TRAIL, description=""):
    def decorator(func):
        @functools.wraps(func)
        async def async_wrapper(*args, **kwargs):
            with tracer.start_as_current_span("compliance.evidence") as span:
                span.set_attribute("compliance.framework", "gdpr")
                span.set_attribute("compliance.control", str(control))
                span.set_attribute("compliance.evidence_type", evidence_type)

                try:
                    result = await func(*args, **kwargs)
                    span.set_attribute("compliance.result", "success")
                    return result
                except Exception as e:
                    span.set_attribute("compliance.result", "failure")
                    span.set_attribute("compliance.error", str(e))
                    span.record_exception(e)
                    raise

        @functools.wraps(func)
        def sync_wrapper(*args, **kwargs):
            # Similar but for sync functions
            pass

        return async_wrapper if asyncio.iscoroutinefunction(func) else sync_wrapper
    return decorator
```

### Step 2: Generate Python Code

```bash
cd frameworks/generators
nix build .#py-gdpr
cp -r result/compliance/ fastapi-app/
```

### Step 3: FastAPI Middleware

```python
from fastapi import Request
from compliance.middleware import ComplianceMiddleware

app.add_middleware(
    ComplianceMiddleware,
    frameworks=["gdpr", "soc2"],
    otel_endpoint="http://localhost:4318"
)
```

### Step 4: Create Example Application

- REST API with CRUD operations
- OpenTelemetry integration
- Pydantic model validation
- Async database operations (Motor/MongoDB)
- Docker Compose with OTEL collector

## Benefits

1. **Pythonic** - Natural decorator pattern
2. **Type-safe** - Pydantic validation
3. **Async** - Non-blocking evidence emission
4. **Zero overhead** - Evidence captured in background
5. **OpenAPI integration** - Compliance visible in API docs

## Challenges

- Python decorators work differently than Java annotations
- Need to handle both sync and async functions
- OpenTelemetry Python SDK has different API than Java
- Pydantic integration for automatic redaction

## Contributing

Want to implement this example?

1. Fork the repository
2. Create `examples/backend/python-fastapi/`
3. Implement the decorator in generated code
4. Create working FastAPI application
5. Add Nix flake for reproducible build
6. Test with OpenTelemetry collector
7. Submit pull request

See **[../../../CONTRIBUTING.md](../../../CONTRIBUTING.md)** for guidelines.

---

**Async evidence is fast evidence.**
