package com.example.compliance;

import org.apache.camel.main.Main;
import com.example.compliance.route.UserDataRoute;

/**
 * Main application for Camel with compliance evidence.
 *
 * This demonstrates:
 * - GDPR Art.15: Right of Access (data retrieval)
 * - GDPR Art.17: Right to Erasure (data deletion)
 * - GDPR Art.5(1)(f): Security of Processing
 * - SOC 2 CC6.1: Logical Access - Authorization
 */
public class Application {

    public static void main(String[] args) throws Exception {
        Main main = new Main();

        // Add routes
        main.configure().addRoutesBuilder(new UserDataRoute());

        // Configure
        main.configure().setDurationMaxSeconds(0); // Run indefinitely

        System.out.println("===============================================");
        System.out.println("Camel Compliance Evidence Example");
        System.out.println("===============================================");
        System.out.println();
        System.out.println("Frameworks: GDPR, SOC 2");
        System.out.println("Controls: Art.15, Art.17, Art.5(1)(f), CC6.1");
        System.out.println();
        System.out.println("Endpoints:");
        System.out.println("  http://localhost:8080/user/{id}     - GET user (GDPR Art.15)");
        System.out.println("  http://localhost:8080/user/{id}     - DELETE user (GDPR Art.17)");
        System.out.println("  http://localhost:8080/user          - POST create user");
        System.out.println();
        System.out.println("Evidence is emitted as OpenTelemetry spans");
        System.out.println("Configure OTEL_EXPORTER_OTLP_ENDPOINT to export");
        System.out.println("===============================================");

        // Run
        main.run(args);
    }
}
