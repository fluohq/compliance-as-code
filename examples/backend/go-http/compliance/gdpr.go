package compliance

import (
	"context"
	"fmt"
	"time"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/trace"
)

// GDPR compliance controls
const (
	Art_15  = "Art.15"  // Right of Access
	Art_17  = "Art.17"  // Right to Erasure
	Art_51f = "Art.5(1)(f)" // Security of Processing
	Art_32  = "Art.32"  // Security of Processing
)

var tracer = otel.Tracer("compliance-gdpr")

// GDPRSpan represents a compliance evidence span
type GDPRSpan struct {
	span  trace.Span
	ctx   context.Context
	start time.Time
}

// BeginGDPRSpan starts a new GDPR evidence span
func BeginGDPRSpan(ctx context.Context, control string) *GDPRSpan {
	spanCtx, span := tracer.Start(ctx, "gdpr."+control)

	span.SetAttributes(
		attribute.String("compliance.framework", "gdpr"),
		attribute.String("compliance.control", control),
		attribute.String("compliance.type", "evidence"),
	)

	return &GDPRSpan{
		span:  span,
		ctx:   spanCtx,
		start: time.Now(),
	}
}

// SetInput adds an input attribute to the evidence span
func (s *GDPRSpan) SetInput(key string, value interface{}) {
	s.setAttribute("input."+key, value)
}

// SetOutput adds an output attribute to the evidence span
func (s *GDPRSpan) SetOutput(key string, value interface{}) {
	s.setAttribute("output."+key, value)
}

// End completes the evidence span successfully
func (s *GDPRSpan) End() {
	s.span.SetAttributes(
		attribute.String("compliance.result", "success"),
		attribute.Int64("compliance.duration_ms", time.Since(s.start).Milliseconds()),
	)
	s.span.End()
}

// EndWithError completes the evidence span with an error
func (s *GDPRSpan) EndWithError(err error) {
	s.span.SetAttributes(
		attribute.String("compliance.result", "failure"),
		attribute.String("compliance.error", err.Error()),
		attribute.Int64("compliance.duration_ms", time.Since(s.start).Milliseconds()),
	)
	s.span.RecordError(err)
	s.span.End()
}

func (s *GDPRSpan) setAttribute(key string, value interface{}) {
	switch v := value.(type) {
	case string:
		s.span.SetAttributes(attribute.String(key, v))
	case int:
		s.span.SetAttributes(attribute.Int(key, v))
	case int64:
		s.span.SetAttributes(attribute.Int64(key, v))
	case bool:
		s.span.SetAttributes(attribute.Bool(key, v))
	default:
		s.span.SetAttributes(attribute.String(key, fmt.Sprintf("%v", v)))
	}
}
