package com.example.compliance.aspect;

import com.compliance.annotations.*;
import io.opentelemetry.api.OpenTelemetry;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.Tracer;
import io.opentelemetry.context.Scope;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.stereotype.Component;

@Aspect
@Component
public class ComplianceEvidenceAspect {

    private final Tracer tracer;

    public ComplianceEvidenceAspect(OpenTelemetry openTelemetry) {
        this.tracer = openTelemetry.getTracer("compliance-spring-boot");
    }

    @Around("@annotation(gdprEvidence)")
    public Object captureGDPREvidence(
        ProceedingJoinPoint joinPoint,
        GDPREvidence gdprEvidence
    ) throws Throwable {
        return captureEvidence(joinPoint, "gdpr", gdprEvidence.control().toString(),
                              gdprEvidence.evidenceType().toString());
    }

    @Around("@annotation(soc2Evidence)")
    public Object captureSOC2Evidence(
        ProceedingJoinPoint joinPoint,
        SOC2Evidence soc2Evidence
    ) throws Throwable {
        return captureEvidence(joinPoint, "soc2", soc2Evidence.control().toString(),
                              soc2Evidence.evidenceType().toString());
    }

    private Object captureEvidence(
        ProceedingJoinPoint joinPoint,
        String framework,
        String control,
        String evidenceType
    ) throws Throwable {

        Span span = tracer.spanBuilder("compliance.evidence")
            .setAttribute("compliance.framework", framework)
            .setAttribute("compliance.control", control)
            .setAttribute("compliance.evidence_type", evidenceType)
            .setAttribute("spring.bean", joinPoint.getTarget().getClass().getSimpleName())
            .setAttribute("spring.method", joinPoint.getSignature().getName())
            .startSpan();

        try (Scope scope = span.makeCurrent()) {
            // Record method arguments as inputs
            Object[] args = joinPoint.getArgs();
            for (int i = 0; i < args.length; i++) {
                if (args[i] != null) {
                    span.setAttribute("input.arg" + i, args[i].toString());
                }
            }

            // Execute method
            long start = System.currentTimeMillis();
            Object result = joinPoint.proceed();
            long duration = System.currentTimeMillis() - start;

            // Record success
            span.setAttribute("compliance.duration_ms", duration);
            span.setAttribute("compliance.result", "success");

            return result;

        } catch (Exception e) {
            span.setAttribute("compliance.result", "failure");
            span.setAttribute("compliance.error", e.getMessage());
            span.recordException(e);
            throw e;
        } finally {
            span.end();
        }
    }
}
