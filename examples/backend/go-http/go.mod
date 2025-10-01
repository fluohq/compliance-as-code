module github.com/fluohq/compliance-as-code/examples/go-http

go 1.22

require (
	github.com/fluohq/compliance-as-code/gdpr v0.0.0
	github.com/fluohq/compliance-as-code/soc2 v0.0.0
	go.opentelemetry.io/otel v1.24.0
	go.opentelemetry.io/otel/trace v1.24.0
)

replace (
	github.com/fluohq/compliance-as-code/gdpr => ../../../frameworks/generators/result/gdpr
	github.com/fluohq/compliance-as-code/soc2 => ../../../frameworks/generators/result/soc2
)
