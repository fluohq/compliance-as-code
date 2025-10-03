"""
Django views with compliance evidence.

Demonstrates:
- GDPR Art.15: Right of Access
- GDPR Art.17: Right to Erasure
- GDPR Art.5(1)(f): Security of Processing
- SOC 2 CC6.1: Authorization
"""

from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
import json

# Import generated compliance modules
from compliance.gdpr import GDPR
from compliance.soc2 import SOC2

# In-memory user store for demo
users_db = {
    "123": {"id": "123", "email": "alice@example.com", "name": "Alice"},
    "456": {"id": "456", "email": "bob@example.com", "name": "Bob"},
}


def health(request):
    """Health check endpoint."""
    return JsonResponse({
        "status": "healthy",
        "version": "1.0.0",
        "compliance": {
            "frameworks": ["GDPR", "SOC2"],
            "controls": ["Art.15", "Art.17", "Art.5(1)(f)", "CC6.1"]
        }
    })


@require_http_methods(["GET"])
def get_user(request, user_id):
    """
    Get user data - GDPR Art.15: Right of Access.

    Emits compliance evidence for data access.
    """
    span = GDPR.begin_span(GDPR.Art_15)
    span.set_input("userId", user_id)
    span.set_input("operation", "data_access")

    try:
        if user_id not in users_db:
            span.end_with_error(Exception("User not found"))
            return JsonResponse(
                {"error": "User not found"},
                status=404
            )

        user = users_db[user_id]
        span.set_output("email", user["email"])
        span.set_output("recordsReturned", 1)
        span.end()

        return JsonResponse(user)

    except Exception as e:
        span.end_with_error(e)
        return JsonResponse(
            {"error": str(e)},
            status=500
        )


@require_http_methods(["GET"])
def list_users(request):
    """List all users - GDPR Art.15: Right of Access."""
    span = GDPR.begin_span(GDPR.Art_15)
    span.set_input("operation", "list_all")

    try:
        user_list = list(users_db.values())
        span.set_output("recordsReturned", len(user_list))
        span.end()

        return JsonResponse(user_list, safe=False)

    except Exception as e:
        span.end_with_error(e)
        return JsonResponse(
            {"error": str(e)},
            status=500
        )


@csrf_exempt
@require_http_methods(["POST"])
def create_user(request):
    """
    Create user - GDPR Art.5(1)(f) + SOC 2 CC6.1.

    Multi-framework evidence for security and authorization.
    """
    gdpr_span = GDPR.begin_span(GDPR.Art_51f)
    soc2_span = SOC2.begin_span(SOC2.CC6_1)

    try:
        data = json.loads(request.body)

        # Generate user ID
        import uuid
        user_id = str(uuid.uuid4())

        user = {
            "id": user_id,
            "email": data.get("email"),
            "name": data.get("name")
        }

        gdpr_span.set_input("email", user["email"])
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

        return JsonResponse(user, status=201)

    except Exception as e:
        gdpr_span.end_with_error(e)
        soc2_span.end_with_error(e)
        return JsonResponse(
            {"error": str(e)},
            status=500
        )


@csrf_exempt
@require_http_methods(["DELETE"])
def delete_user(request, user_id):
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

        return JsonResponse({}, status=204)

    except Exception as e:
        span.end_with_error(e)
        return JsonResponse(
            {"error": str(e)},
            status=500
        )
