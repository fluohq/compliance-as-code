# Terraform with Compliance Evidence

> **Status**: 📝 Placeholder - Contribution Welcome

## Why This Example Matters

Terraform manages infrastructure-as-code, but compliance frameworks require evidence of:
- **FedRAMP CM-3**: Configuration Change Control
- **ISO 27001 A.12.1.2**: Change Management
- **SOC 2 CC8.1**: Change Management Process

Every `terraform apply` should emit immutable evidence of what changed, who approved it, and why.

## What This Example Would Show

### 1. Terraform Wrapper with Evidence

```go
// compliance-terraform wrapper
package main

import (
    "context"
    "os/exec"
    "github.com/fluohq/compliance-as-code/fedramp"
)

func terraformApply(ctx context.Context, changeTicket string) error {
    // Emit evidence for configuration change
    span := fedramp.BeginEvidence(ctx, fedramp.CM_3)
    defer span.End()

    span.SetInput("change.ticket", changeTicket)
    span.SetInput("terraform.workspace", getCurrentWorkspace())

    // Get plan
    plan, err := exec.Command("terraform", "plan", "-json").Output()
    if err != nil {
        span.EndWithError(err)
        return err
    }

    // Parse and record changes
    changes := parseTerraformPlan(plan)
    span.SetInput("change.resources", len(changes))
    span.SetInput("change.summary", summarizeChanges(changes))

    // Apply changes
    output, err := exec.Command("terraform", "apply", "-auto-approve").Output()
    if err != nil {
        span.EndWithError(err)
        return err
    }

    span.SetOutput("apply.result", "success")
    span.SetOutput("apply.output", string(output))

    return nil
}
```

### 2. Terraform Provider with Evidence

```hcl
# Custom provider that emits evidence
terraform {
  required_providers {
    compliance = {
      source = "fluohq/compliance"
      version = "~> 1.0"
    }
  }
}

provider "compliance" {
  framework = "fedramp"
  otel_endpoint = "http://localhost:4318"
}

# Evidence emitted for every resource change
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  # Compliance metadata
  compliance_controls = ["CM-2", "CM-3", "SI-7"]
  change_ticket = "CHG-2025-001"
  approved_by = "security-team"
}
```

### 3. Pre/Post Apply Hooks

```bash
#!/bin/bash
# pre-apply-hook.sh

# Emit evidence before apply
otel-cli span background \
  --service "terraform" \
  --name "terraform.pre_apply" \
  --attrs "compliance.framework=fedramp" \
  --attrs "compliance.control=CM-3" \
  --attrs "change.ticket=$CHANGE_TICKET" \
  --attrs "terraform.workspace=$(terraform workspace show)"

# Generate and save plan
terraform plan -out=tfplan

# Parse plan for evidence
terraform show -json tfplan | jq '{
  resources_to_create: [.resource_changes[] | select(.change.actions == ["create"]) | .address],
  resources_to_update: [.resource_changes[] | select(.change.actions == ["update"]) | .address],
  resources_to_delete: [.resource_changes[] | select(.change.actions == ["delete"]) | .address]
}' | otel-cli span event --name "terraform.plan_summary" --attrs @-

# Apply with evidence
terraform apply tfplan

# Complete evidence span
otel-cli span end --attrs "terraform.result=success"
```

### 4. Atlantis Integration

```yaml
# atlantis.yaml - GitOps for Terraform
version: 3
projects:
- name: production
  dir: terraform/prod
  workflow: compliance-workflow

workflows:
  compliance-workflow:
    plan:
      steps:
      - run: |
          # Start compliance evidence span
          otel-cli span background --name "terraform.plan" \
            --attrs "compliance.framework=fedramp" \
            --attrs "compliance.control=CM-2" \
            --attrs "pr.number=$PULL_NUM" \
            --attrs "pr.author=$PULL_AUTHOR"
      - init
      - plan
    apply:
      steps:
      - run: |
          # Evidence for apply
          otel-cli span background --name "terraform.apply" \
            --attrs "compliance.control=CM-3" \
            --attrs "change.ticket=$CHANGE_TICKET"
      - apply
      - run: |
          # Complete evidence
          otel-cli span end --attrs "terraform.result=success"
```

## How to Implement This Example

### Step 1: Create Terraform Wrapper

```bash
# compliance-terraform CLI
go build -o compliance-terraform main.go

# Wraps terraform commands
compliance-terraform apply --change-ticket CHG-001
```

### Step 2: Parse Terraform Plan

```go
func parseTerraformPlan(planJSON []byte) []ResourceChange {
    var plan TerraformPlan
    json.Unmarshal(planJSON, &plan)

    var changes []ResourceChange
    for _, rc := range plan.ResourceChanges {
        changes = append(changes, ResourceChange{
            Address: rc.Address,
            Type:    rc.Type,
            Actions: rc.Change.Actions,
        })
    }
    return changes
}
```

### Step 3: Emit Evidence

```go
span.SetInput("change.resources_created", countByAction(changes, "create"))
span.SetInput("change.resources_updated", countByAction(changes, "update"))
span.SetInput("change.resources_deleted", countByAction(changes, "delete"))
```

### Step 4: Query Evidence

```promql
# All infrastructure changes
{compliance.framework="fedramp", compliance.control="CM-3"}

# Changes by ticket
{change.ticket="CHG-2025-001"}

# Failed applies
{terraform.result="failure"}

# Who changed what
{terraform.workspace="production", change.approved_by="security-team"}
```

## Benefits

1. **Every change tracked** - Complete audit trail
2. **GitOps compatible** - Works with Atlantis, Terraform Cloud
3. **Change ticket enforcement** - No apply without ticket
4. **Approval tracking** - Who approved each change

## Challenges

- Requires wrapping or hooking Terraform
- Need to parse Terraform plan JSON
- Integration with existing CI/CD pipelines
- OpenTelemetry in Terraform workflows

## Contributing

Want to implement this example?

1. Create Go wrapper for terraform CLI
2. Parse terraform plan JSON
3. Emit OpenTelemetry spans with evidence
4. Integrate with Atlantis or Terraform Cloud
5. Create Nix flake for reproducible build
6. Test with real infrastructure changes
7. Submit pull request

See **[../../../CONTRIBUTING.md](../../../CONTRIBUTING.md)** for guidelines.

---

**Infrastructure is evidence.**
