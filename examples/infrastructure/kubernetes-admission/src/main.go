package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/fluohq/compliance-as-code/examples/kubernetes-admission/compliance"
	admissionv1 "k8s.io/api/admission/v1"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// AdmissionController validates Kubernetes resources for compliance
type AdmissionController struct{}

// ServeHTTP handles admission webhook requests
func (ac *AdmissionController) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	var admissionReview admissionv1.AdmissionReview

	if err := json.NewDecoder(r.Body).Decode(&admissionReview); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	response := ac.handleAdmission(admissionReview.Request)
	admissionReview.Response = response

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(admissionReview)
}

// handleAdmission processes admission request and emits compliance evidence
func (ac *AdmissionController) handleAdmission(req *admissionv1.AdmissionRequest) *admissionv1.AdmissionResponse {
	ctx := context.Background()

	// SOC 2 CC6.1: Authorization - validate resource creation
	soc2Span := compliance.BeginSOC2Span(ctx, compliance.CC6_1)
	defer soc2Span.End()

	soc2Span.SetInput("resource", req.Kind.Kind)
	soc2Span.SetInput("namespace", req.Namespace)
	soc2Span.SetInput("operation", string(req.Operation))
	soc2Span.SetInput("user", req.UserInfo.Username)

	switch req.Kind.Kind {
	case "Pod":
		return ac.validatePod(ctx, req, soc2Span)
	case "Secret":
		return ac.validateSecret(ctx, req, soc2Span)
	case "PersistentVolumeClaim":
		return ac.validatePVC(ctx, req, soc2Span)
	default:
		soc2Span.SetOutput("authorized", true)
		soc2Span.SetOutput("result", "allowed")
		return &admissionv1.AdmissionResponse{
			Allowed: true,
		}
	}
}

// validatePod ensures pods meet GDPR security requirements
func (ac *AdmissionController) validatePod(ctx context.Context, req *admissionv1.AdmissionRequest, soc2Span *compliance.SOC2Span) *admissionv1.AdmissionResponse {
	// GDPR Art.5(1)(f): Security of Processing
	gdprSpan := compliance.BeginGDPRSpan(ctx, compliance.Art_51f)
	defer gdprSpan.End()

	gdprSpan.SetInput("resource", "Pod")
	gdprSpan.SetInput("namespace", req.Namespace)
	gdprSpan.SetInput("validation", "security_controls")

	var pod corev1.Pod
	if err := json.Unmarshal(req.Object.Raw, &pod); err != nil {
		return denyAdmission(err.Error(), gdprSpan, soc2Span)
	}

	violations := []string{}

	// Check: Containers must not run as root
	for _, container := range pod.Spec.Containers {
		if container.SecurityContext == nil || container.SecurityContext.RunAsNonRoot == nil || !*container.SecurityContext.RunAsNonRoot {
			violations = append(violations, fmt.Sprintf("Container %s must run as non-root (GDPR Art.5(1)(f))", container.Name))
		}

		// Check: ReadOnlyRootFilesystem required for data protection
		if container.SecurityContext == nil || container.SecurityContext.ReadOnlyRootFilesystem == nil || !*container.SecurityContext.ReadOnlyRootFilesystem {
			violations = append(violations, fmt.Sprintf("Container %s must have read-only root filesystem", container.Name))
		}
	}

	// Check: Pod must not use host network (data isolation)
	if pod.Spec.HostNetwork {
		violations = append(violations, "Pod must not use host network (data isolation required)")
	}

	// Check: Pod must not use host PID namespace
	if pod.Spec.HostPID {
		violations = append(violations, "Pod must not use host PID namespace")
	}

	if len(violations) > 0 {
		gdprSpan.SetOutput("violations", violations)
		gdprSpan.SetOutput("compliant", false)
		soc2Span.SetOutput("authorized", false)
		soc2Span.SetOutput("result", "denied")
		return denyAdmission(fmt.Sprintf("Pod violates GDPR security requirements: %v", violations), gdprSpan, soc2Span)
	}

	gdprSpan.SetOutput("compliant", true)
	gdprSpan.SetOutput("securityControlsValidated", 4)
	soc2Span.SetOutput("authorized", true)
	soc2Span.SetOutput("result", "allowed")

	return &admissionv1.AdmissionResponse{
		Allowed: true,
	}
}

// validateSecret ensures secrets are encrypted at rest
func (ac *AdmissionController) validateSecret(ctx context.Context, req *admissionv1.AdmissionRequest, soc2Span *compliance.SOC2Span) *admissionv1.AdmissionResponse {
	// GDPR Art.32: Security of Processing (encryption)
	gdprSpan := compliance.BeginGDPRSpan(ctx, compliance.Art_32)
	defer gdprSpan.End()

	gdprSpan.SetInput("resource", "Secret")
	gdprSpan.SetInput("namespace", req.Namespace)
	gdprSpan.SetInput("validation", "encryption_at_rest")

	var secret corev1.Secret
	if err := json.Unmarshal(req.Object.Raw, &secret); err != nil {
		return denyAdmission(err.Error(), gdprSpan, soc2Span)
	}

	// Check annotations for encryption evidence
	if secret.Annotations == nil {
		secret.Annotations = make(map[string]string)
	}

	// Require encryption-at-rest annotation
	if _, ok := secret.Annotations["encryption.kubernetes.io/provider"]; !ok {
		gdprSpan.SetOutput("encrypted", false)
		gdprSpan.SetOutput("compliant", false)
		soc2Span.SetOutput("authorized", false)
		return denyAdmission("Secret must have encryption.kubernetes.io/provider annotation (GDPR Art.32)", gdprSpan, soc2Span)
	}

	gdprSpan.SetOutput("encrypted", true)
	gdprSpan.SetOutput("compliant", true)
	gdprSpan.SetOutput("encryptionProvider", secret.Annotations["encryption.kubernetes.io/provider"])
	soc2Span.SetOutput("authorized", true)
	soc2Span.SetOutput("result", "allowed")

	return &admissionv1.AdmissionResponse{
		Allowed: true,
	}
}

// validatePVC ensures persistent volumes are encrypted
func (ac *AdmissionController) validatePVC(ctx context.Context, req *admissionv1.AdmissionRequest, soc2Span *compliance.SOC2Span) *admissionv1.AdmissionResponse {
	// GDPR Art.5(1)(f): Security of Processing (data at rest)
	gdprSpan := compliance.BeginGDPRSpan(ctx, compliance.Art_51f)
	defer gdprSpan.End()

	gdprSpan.SetInput("resource", "PersistentVolumeClaim")
	gdprSpan.SetInput("namespace", req.Namespace)
	gdprSpan.SetInput("validation", "volume_encryption")

	var pvc corev1.PersistentVolumeClaim
	if err := json.Unmarshal(req.Object.Raw, &pvc); err != nil {
		return denyAdmission(err.Error(), gdprSpan, soc2Span)
	}

	// Check for encrypted storage class
	if pvc.Spec.StorageClassName == nil || *pvc.Spec.StorageClassName == "" {
		gdprSpan.SetOutput("encrypted", false)
		return denyAdmission("PVC must specify encrypted storage class (GDPR Art.5(1)(f))", gdprSpan, soc2Span)
	}

	storageClass := *pvc.Spec.StorageClassName
	encryptedClasses := []string{"encrypted-gp3", "encrypted-ssd", "gp3-encrypted"}

	encrypted := false
	for _, class := range encryptedClasses {
		if storageClass == class {
			encrypted = true
			break
		}
	}

	if !encrypted {
		gdprSpan.SetOutput("encrypted", false)
		gdprSpan.SetOutput("storageClass", storageClass)
		return denyAdmission(fmt.Sprintf("PVC must use encrypted storage class, got: %s", storageClass), gdprSpan, soc2Span)
	}

	gdprSpan.SetOutput("encrypted", true)
	gdprSpan.SetOutput("storageClass", storageClass)
	gdprSpan.SetOutput("compliant", true)
	soc2Span.SetOutput("authorized", true)
	soc2Span.SetOutput("result", "allowed")

	return &admissionv1.AdmissionResponse{
		Allowed: true,
	}
}

func denyAdmission(message string, gdprSpan *compliance.GDPRSpan, soc2Span *compliance.SOC2Span) *admissionv1.AdmissionResponse {
	gdprSpan.SetOutput("result", "denied")
	soc2Span.SetOutput("result", "denied")

	return &admissionv1.AdmissionResponse{
		Allowed: false,
		Result: &metav1.Status{
			Message: message,
		},
	}
}

func main() {
	controller := &AdmissionController{}

	http.HandleFunc("/validate", controller.ServeHTTP)
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("OK"))
	})

	fmt.Println("Starting Kubernetes admission controller on :8443")
	fmt.Println("Emitting compliance evidence for GDPR + SOC 2")
	if err := http.ListenAndServeTLS(":8443", "/certs/tls.crt", "/certs/tls.key", nil); err != nil {
		panic(err)
	}
}
