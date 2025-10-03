FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./
COPY ../../../gdpr ../../../gdpr
COPY ../../../soc2 ../../../soc2

# Download dependencies
RUN go mod download

# Copy source
COPY src/ ./src/

# Build
RUN CGO_ENABLED=0 GOOS=linux go build -o admission-controller ./src/main.go

# Final image
FROM gcr.io/distroless/static-debian11:nonroot

COPY --from=builder /app/admission-controller /admission-controller

EXPOSE 8443

ENTRYPOINT ["/admission-controller"]
