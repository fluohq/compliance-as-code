# Kubernetes with Compliance Evidence

> **Status**: 📝 Placeholder - Contribution Welcome

## Why This Example Matters

Kubernetes clusters require compliance evidence for:
- **FedRAMP** - Configuration management (CM-2, CM-3, CM-6)
- **ISO 27001** - Change control (A.12.1.2)
- **SOC 2** - Logical access controls (CC6.1, CC6.2)

Every deployment, scaling event, and configuration change should emit compliance evidence.

## What This Example Would Show

### 1. Admission Webhook with Evidence

```go
package main

import (
    "context"
    admissionv1 "k8s.io/api/admission/v1"
    corev1 "k8s.io/api/core/v1"
    "github.com/fluohq/compliance-as-code/fedramp"
)

func validatePod(ctx context.Context, req *admissionv1.AdmissionRequest) error {
    // Emit evidence for configuration validation
    span := fedramp.BeginEvidence(ctx, fedramp.CM_6)
    defer span.End()

    var pod corev1.Pod
    if err := json.Unmarshal(req.Object.Raw, &pod); err != nil {
        span.EndWithError(err)
        return err
    }

    span.SetInput("pod.name", pod.Name)
    span.SetInput("pod.namespace", pod.Namespace)

    // Validate security context
    if pod.Spec.SecurityContext == nil {
        return errors.New("SecurityContext required")
    }

    span.SetOutput("validation.result", "approved")
    return nil
}
```

### 2. Operator with Evidence Tracking

```go
func (r *DeploymentReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    // Track configuration changes with FedRAMP CM-3
    span := fedramp.BeginEvidence(ctx, fedramp.CM_3)
    defer span.End()

    span.SetInput("deployment.name", req.Name)
    span.SetInput("deployment.namespace", req.Namespace)

    var deployment appsv1.Deployment
    if err := r.Get(ctx, req.NamespacedName, &deployment); err != nil {
        span.EndWithError(err)
        return ctrl.Result{}, err
    }

    // Apply configuration
    oldReplicas := deployment.Spec.Replicas
    newReplicas := int32(3) // From desired state

    if oldReplicas != newReplicas {
        deployment.Spec.Replicas = &newReplicas
        if err := r.Update(ctx, &deployment); err != nil {
            span.EndWithError(err)
            return ctrl.Result{}, err
        }

        span.SetOutput("change.type", "scale")
        span.SetOutput("change.oldReplicas", oldReplicas)
        span.SetOutput("change.newReplicas", newReplicas)
    }

    return ctrl.Result{}, nil
}
```

### 3. kubectl Plugin with Evidence

```go
// kubectl-compliance plugin
func applyWithEvidence(ctx context.Context, manifest string) error {
    span := fedramp.BeginEvidence(ctx, fedramp.CM_2)
    defer span.End()

    span.SetInput("manifest.file", manifest)

    // Parse manifest
    obj, err := parseKubernetesYAML(manifest)
    if err != nil {
        span.EndWithError(err)
        return err
    }

    span.SetInput("resource.kind", obj.GetKind())
    span.SetInput("resource.name", obj.GetName())

    // Apply to cluster
    if err := kubectlApply(manifest); err != nil {
        span.EndWithError(err)
        return err
    }

    span.SetOutput("change.action", "create")
    span.SetOutput("change.result", "success")

    return nil
}
```

### 4. GitOps Integration (ArgoCD/Flux)

```yaml
# Evidence emitted for every sync
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  annotations:
    compliance.framework: "fedramp"
    compliance.controls: "CM-2,CM-3"
    compliance.change-ticket: "CHG-2025-001"
spec:
  source:
    repoURL: https://github.com/org/repo
    path: k8s/
  destination:
    server: https://kubernetes.default.svc
  # Webhook emits evidence on sync
  syncPolicy:
    automated:
      prune: true
```

## How to Implement This Example

### Step 1: Create Admission Webhook

```bash
# Use kubebuilder or operator-sdk
kubebuilder init --domain compliance.io
kubebuilder create webhook --group core --version v1 --kind Pod
```

### Step 2: Integrate Go Evidence Code

```bash
cd frameworks/generators
nix build .#go-fedramp
cp -r result/fedramp/ operator/pkg/compliance/
```

### Step 3: Deploy with Evidence

```yaml
# webhook-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: compliance-webhook
spec:
  template:
    spec:
      containers:
      - name: webhook
        image: compliance-webhook:latest
        env:
        - name: OTEL_EXPORTER_OTLP_ENDPOINT
          value: "http://otel-collector:4318"
        - name: COMPLIANCE_FRAMEWORKS
          value: "fedramp,iso27001"
```

### Step 4: Query Evidence

```promql
# All Kubernetes configuration changes
{compliance.framework="fedramp", compliance.controls=~"CM-.*"}

# Who deployed what and when
{compliance.control="CM-3", k8s.resource.kind="Deployment"}

# Failed validations
{compliance.result="failure", k8s.admission.operation="CREATE"}
```

## Benefits

1. **Automatic evidence** - Every cluster change tracked
2. **GitOps compatible** - Works with ArgoCD, Flux
3. **Policy enforcement** - Admission webhooks block non-compliant changes
4. **Full audit trail** - Who, what, when, why for every change

## Challenges

- Requires custom admission webhook or operator
- Need OpenTelemetry sidecar in cluster
- Performance impact on API server
- Evidence for external changes (kubectl apply)

## Contributing

Want to implement this example?

1. Create admission webhook with kubebuilder
2. Integrate Go compliance code
3. Deploy OTEL collector to cluster
4. Test with various Kubernetes resources
5. Create Nix flake for reproducible build
6. Add Grafana dashboard for evidence
7. Submit pull request

See **[../../../CONTRIBUTING.md](../../../CONTRIBUTING.md)** for guidelines.

---

**Every kubectl apply is evidence.**
