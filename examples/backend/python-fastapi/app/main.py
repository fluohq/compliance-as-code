"""
FastAPI with compliance evidence using decorators.

This example demonstrates:
- GDPR Art.15: Right of Access (data retrieval)
- GDPR Art.17: Right to Erasure (data deletion)
- GDPR Art.5(1)(f): Security of Processing
- SOC 2 CC6.1: Logical Access - Authorization
"""

from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, EmailStr
from typing import Dict, Optional
import uuid

# Import generated compliance modules
# These would be generated from your compliance-as-code framework
from compliance.gdpr import GDPR, ComplianceSpan
from compliance.soc2 import SOC2

app = FastAPI(
    title="Compliance Evidence API",
    description="FastAPI with GDPR and SOC 2 evidence",
    version="1.0.0"
)

# In-memory user store for demo
users_db: Dict[str, "User"] = {}


class User(BaseModel):
    id: Optional[str] = None
    email: EmailStr
    name: str


class UserResponse(BaseModel):
    id: str
    email: str
    name: str


# Seed data
users_db["123"] = User(id="123", email="alice@example.com", name="Alice")
users_db["456"] = User(id="456", email="bob@example.com", name="Bob")


@app.get("/health")
async def health():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "version": "1.0.0",
        "compliance": {
            "frameworks": ["GDPR", "SOC2"],
            "controls": ["Art.15", "Art.17", "Art.5(1)(f)", "CC6.1"]
        }
    }


@app.get("/user/{user_id}", response_model=UserResponse)
async def get_user(user_id: str):
    """
    Get user data - GDPR Art.15: Right of Access.

    Emits compliance evidence for data access.
    """
    # Begin compliance evidence
    span = GDPR.begin_span(GDPR.Art_15)
    span.set_input("userId", user_id)
    span.set_input("operation", "data_access")

    try:
        if user_id not in users_db:
            span.end_with_error(Exception("User not found"))
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        user = users_db[user_id]
        span.set_output("email", user.email)
        span.set_output("recordsReturned", 1)
        span.end()

        return user

    except HTTPException:
        raise
    except Exception as e:
        span.end_with_error(e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )


@app.get("/users", response_model=list[UserResponse])
async def list_users():
    """
    List all users - GDPR Art.15: Right of Access.
    """
    span = GDPR.begin_span(GDPR.Art_15)
    span.set_input("operation", "list_all")

    try:
        user_list = list(users_db.values())
        span.set_output("recordsReturned", len(user_list))
        span.end()

        return user_list

    except Exception as e:
        span.end_with_error(e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )


@app.post("/user", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(user: User):
    """
    Create user - GDPR Art.5(1)(f) + SOC 2 CC6.1.

    Multi-framework evidence for security of processing and authorization.
    """
    # Multi-framework evidence
    gdpr_span = GDPR.begin_span(GDPR.Art_51f)
    soc2_span = SOC2.begin_span(SOC2.CC6_1)

    try:
        # Generate user ID
        user_id = str(uuid.uuid4())
        user.id = user_id

        gdpr_span.set_input("email", user.email)
        gdpr_span.set_input("operation", "create_user")

        soc2_span.set_input("userId", user_id)
        soc2_span.set_input("action", "create_user")
        soc2_span.set_input("authorized", True)

        # Store user
        users_db[user_id] = user

        gdpr_span.set_output("userId", user_id)
        gdpr_span.set_output("recordsCreated", 1)
        gdpr_span.end()

        soc2_span.set_output("result", "success")
        soc2_span.end()

        return user

    except Exception as e:
        gdpr_span.end_with_error(e)
        soc2_span.end_with_error(e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )


@app.delete("/user/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(user_id: str):
    """
    Delete user - GDPR Art.17: Right to Erasure.

    Emits evidence proving data deletion.
    """
    span = GDPR.begin_span(GDPR.Art_17)
    span.set_input("userId", user_id)
    span.set_input("operation", "data_erasure")

    try:
        deleted = 0
        if user_id in users_db:
            del users_db[user_id]
            deleted = 1

        span.set_output("deletedRecords", deleted)
        span.set_output("tablesCleared", 1)
        span.end()

        return None

    except Exception as e:
        span.end_with_error(e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )


if __name__ == "__main__":
    import uvicorn

    print("=" * 50)
    print("FastAPI Compliance Evidence Example")
    print("=" * 50)
    print()
    print("Frameworks: GDPR, SOC 2")
    print("Controls: Art.15, Art.17, Art.5(1)(f), CC6.1")
    print()
    print("Endpoints:")
    print("  GET    /health              - Health check")
    print("  GET    /user/{id}           - Get user (GDPR Art.15)")
    print("  GET    /users               - List users (GDPR Art.15)")
    print("  POST   /user                - Create user (GDPR + SOC2)")
    print("  DELETE /user/{id}           - Delete user (GDPR Art.17)")
    print()
    print("Evidence emitted as OpenTelemetry spans")
    print("Configure OTEL_EXPORTER_OTLP_ENDPOINT to export")
    print("=" * 50)
    print()

    uvicorn.run(app, host="0.0.0.0", port=8000)
