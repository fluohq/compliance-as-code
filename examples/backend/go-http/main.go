package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"sync/atomic"

	"github.com/fluohq/compliance-as-code/examples/go-http/compliance"
)

var (
	version    = "1.0.0"
	requestID  int64
	inMemoryDB = make(map[string]*User)
)

type User struct {
	ID    string `json:"id"`
	Email string `json:"email"`
	Name  string `json:"name"`
}

type ErrorResponse struct {
	Error   string `json:"error"`
	Message string `json:"message"`
}

// Get user data - implements GDPR Right of Access (Art.15)
func getUser(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	// Add compliance evidence to context
	span := compliance.BeginGDPRSpan(ctx, compliance.Art_15)
	defer span.End()

	userID := r.URL.Query().Get("id")
	if userID == "" {
		span.EndWithError(fmt.Errorf("missing user id"))
		writeError(w, http.StatusBadRequest, "missing user id parameter")
		return
	}

	span.SetInput("userId", userID)
	span.SetInput("http.method", r.Method)
	span.SetInput("http.path", r.URL.Path)

	// Fetch user from in-memory DB
	user, exists := inMemoryDB[userID]
	if !exists {
		span.EndWithError(fmt.Errorf("user not found"))
		writeError(w, http.StatusNotFound, "user not found")
		return
	}

	span.SetOutput("email", user.Email)
	span.SetOutput("recordsReturned", 1)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(user)
}

// Delete user data - implements GDPR Right to Erasure (Art.17)
func deleteUser(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	// Add compliance evidence
	span := compliance.BeginGDPRSpan(ctx, compliance.Art_17)
	defer span.End()

	userID := r.URL.Query().Get("id")
	if userID == "" {
		span.EndWithError(fmt.Errorf("missing user id"))
		writeError(w, http.StatusBadRequest, "missing user id parameter")
		return
	}

	span.SetInput("userId", userID)
	span.SetInput("http.method", r.Method)

	// Delete user
	deleted := 0
	if _, exists := inMemoryDB[userID]; exists {
		delete(inMemoryDB, userID)
		deleted = 1
	}

	span.SetOutput("deletedRecords", deleted)
	span.SetOutput("tablesCleared", 1)

	w.WriteHeader(http.StatusNoContent)
}

// Create user - implements GDPR Security of Processing (Art.5(1)(f)) + SOC 2 Authorization (CC6.1)
func createUser(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	// Multi-framework evidence
	gdprSpan := compliance.BeginGDPRSpan(ctx, compliance.Art_51f)
	defer gdprSpan.End()

	soc2Span := compliance.BeginSOC2Span(ctx, compliance.CC6_1)
	defer soc2Span.End()

	var user User
	if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
		gdprSpan.EndWithError(err)
		soc2Span.EndWithError(err)
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	// Generate ID
	reqID := atomic.AddInt64(&requestID, 1)
	user.ID = fmt.Sprintf("user_%d", reqID)

	gdprSpan.SetInput("email", user.Email)
	gdprSpan.SetInput("http.method", r.Method)

	soc2Span.SetInput("userId", user.ID)
	soc2Span.SetInput("action", "create_user")

	// Save to in-memory DB (password would be hashed in real implementation)
	inMemoryDB[user.ID] = &user

	gdprSpan.SetOutput("userId", user.ID)
	gdprSpan.SetOutput("recordsCreated", 1)

	soc2Span.SetOutput("authorized", true)
	soc2Span.SetOutput("result", "success")

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(user)
}

// List all users - for demo purposes
func listUsers(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()

	span := compliance.BeginGDPRSpan(ctx, compliance.Art_15)
	defer span.End()

	span.SetInput("http.method", r.Method)
	span.SetInput("http.path", r.URL.Path)

	users := make([]*User, 0, len(inMemoryDB))
	for _, user := range inMemoryDB {
		users = append(users, user)
	}

	span.SetOutput("recordsReturned", len(users))

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(users)
}

// Health check
func health(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"status":  "healthy",
		"version": version,
		"compliance": map[string]interface{}{
			"frameworks": []string{"GDPR", "SOC2"},
			"controls":   []string{"Art.15", "Art.17", "Art.5(1)(f)", "CC6.1"},
		},
	})
}

func writeError(w http.ResponseWriter, status int, message string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(ErrorResponse{
		Error:   http.StatusText(status),
		Message: message,
	})
}

func main() {
	// Seed some data
	inMemoryDB["123"] = &User{
		ID:    "123",
		Email: "alice@example.com",
		Name:  "Alice",
	}
	inMemoryDB["456"] = &User{
		ID:    "456",
		Email: "bob@example.com",
		Name:  "Bob",
	}

	http.HandleFunc("/health", health)
	http.HandleFunc("/user", func(w http.ResponseWriter, r *http.Request) {
		switch r.Method {
		case http.MethodGet:
			if r.URL.Query().Get("id") != "" {
				getUser(w, r)
			} else {
				listUsers(w, r)
			}
		case http.MethodPost:
			createUser(w, r)
		case http.MethodDelete:
			deleteUser(w, r)
		default:
			writeError(w, http.StatusMethodNotAllowed, "method not allowed")
		}
	})

	log.Printf("Starting Compliance HTTP Server v%s on :8080", version)
	log.Println("Frameworks: GDPR, SOC 2")
	log.Println("Controls: Art.15, Art.17, Art.5(1)(f), CC6.1")
	log.Println("")
	log.Println("Endpoints:")
	log.Println("  GET    /health             - Health check")
	log.Println("  GET    /user?id=123        - Get user (GDPR Art.15)")
	log.Println("  GET    /user               - List users (GDPR Art.15)")
	log.Println("  POST   /user               - Create user (GDPR Art.5(1)(f), SOC2 CC6.1)")
	log.Println("  DELETE /user?id=123        - Delete user (GDPR Art.17)")
	log.Println("")
	log.Println("Configure OTEL_EXPORTER_OTLP_ENDPOINT to emit evidence spans")

	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
}
