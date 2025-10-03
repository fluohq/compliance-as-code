package compliance

import (
	"context"
	"fmt"
	"time"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/trace"
)

// SOC 2 compliance controls
const (
	CC6_1 = "CC6.1" // Logical Access Controls
	CC6_6 = "CC6.6" // Logical and Physical Access Controls
	CC6_8 = "CC6.8" // Change Management
	CC7_2 = "CC7.2" // System Monitoring
)

var soc2Tracer = otel.Tracer("compliance-soc2")

// SOC2Span represents a SOC 2 compliance evidence span
type SOC2Span struct {
	span  trace.Span
	ctx   context.Context
	start time.Time
}

// BeginSOC2Span starts a new SOC 2 evidence span
func BeginSOC2Span(ctx context.Context, control string) *SOC2Span {
	spanCtx, span := soc2Tracer.Start(ctx, "soc2."+control)

	span.SetAttributes(
		attribute.String("compliance.framework", "soc2"),
		attribute.String("compliance.control", control),
		attribute.String("compliance.type", "evidence"),
	)

	return &SOC2Span{
		span:  span,
		ctx:   spanCtx,
		start: time.Now(),
	}
}

// SetInput adds an input attribute to the evidence span
func (s *SOC2Span) SetInput(key string, value interface{}) {
	s.setAttribute("input."+key, value)
}

// SetOutput adds an output attribute to the evidence span
func (s *SOC2Span) SetOutput(key string, value interface{}) {
	s.setAttribute("output."+key, value)
}

// End completes the evidence span successfully
func (s *SOC2Span) End() {
	s.span.SetAttributes(
		attribute.String("compliance.result", "success"),
		attribute.Int64("compliance.duration_ms", time.Since(s.start).Milliseconds()),
	)
	s.span.End()
}

// EndWithError completes the evidence span with an error
func (s *SOC2Span) EndWithError(err error) {
	s.span.SetAttributes(
		attribute.String("compliance.result", "failure"),
		attribute.String("compliance.error", err.Error()),
		attribute.Int64("compliance.duration_ms", time.Since(s.start).Milliseconds()),
	)
	s.span.RecordError(err)
	s.span.End()
}

func (s *SOC2Span) setAttribute(key string, value interface{}) {
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
