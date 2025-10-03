package com.example.compliance.route;

import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.model.rest.RestBindingMode;
import com.compliance.evidence.gdpr.GDPR;
import com.compliance.evidence.gdpr.ComplianceSpan;
import com.compliance.evidence.soc2.SOC2;

import java.util.HashMap;
import java.util.Map;

/**
 * Camel routes with compliance evidence capture.
 *
 * Shows how to integrate compliance evidence into Camel routes:
 * - REST endpoints with evidence
 * - Message processing with compliance tracking
 * - Error handling with evidence
 */
public class UserDataRoute extends RouteBuilder {

    // In-memory user store for demo
    private static final Map<String, User> userStore = new HashMap<>();

    static {
        // Seed data
        userStore.put("123", new User("123", "alice@example.com", "Alice"));
        userStore.put("456", new User("456", "bob@example.com", "Bob"));
    }

    @Override
    public void configure() throws Exception {
        // Configure REST
        restConfiguration()
            .component("jetty")
            .host("localhost")
            .port(8080)
            .bindingMode(RestBindingMode.json)
            .dataFormatProperty("prettyPrint", "true")
            .enableCORS(true);

        // REST API
        rest("/user")
            .get("/{id}")
                .to("direct:getUser")
            .post()
                .type(User.class)
                .to("direct:createUser")
            .delete("/{id}")
                .to("direct:deleteUser");

        // GET /user/{id} - GDPR Art.15: Right of Access
        from("direct:getUser")
            .routeId("get-user")
            .log("Getting user: ${header.id}")
            .process(exchange -> {
                String userId = exchange.getIn().getHeader("id", String.class);

                // Begin compliance evidence
                ComplianceSpan span = GDPR.beginSpan(GDPR.Art_15);
                span.setInput("userId", userId);
                span.setInput("operation", "data_access");

                try {
                    User user = userStore.get(userId);
                    if (user == null) {
                        span.endWithError(new RuntimeException("User not found"));
                        exchange.getIn().setHeader("CamelHttpResponseCode", 404);
                        exchange.getIn().setBody(Map.of("error", "User not found"));
                    } else {
                        span.setOutput("email", user.getEmail());
                        span.setOutput("recordsReturned", 1);
                        span.end();
                        exchange.getIn().setBody(user);
                    }
                } catch (Exception e) {
                    span.endWithError(e);
                    throw e;
                }
            });

        // POST /user - GDPR Art.5(1)(f) + SOC 2 CC6.1
        from("direct:createUser")
            .routeId("create-user")
            .log("Creating user")
            .process(exchange -> {
                User user = exchange.getIn().getBody(User.class);

                // Multi-framework evidence
                ComplianceSpan gdprSpan = GDPR.beginSpan(GDPR.Art_51f);
                ComplianceSpan soc2Span = SOC2.beginSpan(SOC2.CC6_1);

                try {
                    // Generate ID
                    String userId = "user_" + System.currentTimeMillis();
                    user.setId(userId);

                    gdprSpan.setInput("email", user.getEmail());
                    gdprSpan.setInput("operation", "create_user");

                    soc2Span.setInput("userId", userId);
                    soc2Span.setInput("action", "create_user");
                    soc2Span.setInput("authorized", true);

                    // Store user
                    userStore.put(userId, user);

                    gdprSpan.setOutput("userId", userId);
                    gdprSpan.setOutput("recordsCreated", 1);
                    gdprSpan.end();

                    soc2Span.setOutput("result", "success");
                    soc2Span.end();

                    exchange.getIn().setHeader("CamelHttpResponseCode", 201);
                    exchange.getIn().setBody(user);
                } catch (Exception e) {
                    gdprSpan.endWithError(e);
                    soc2Span.endWithError(e);
                    throw e;
                }
            });

        // DELETE /user/{id} - GDPR Art.17: Right to Erasure
        from("direct:deleteUser")
            .routeId("delete-user")
            .log("Deleting user: ${header.id}")
            .process(exchange -> {
                String userId = exchange.getIn().getHeader("id", String.class);

                // Begin compliance evidence
                ComplianceSpan span = GDPR.beginSpan(GDPR.Art_17);
                span.setInput("userId", userId);
                span.setInput("operation", "data_erasure");

                try {
                    int deleted = 0;
                    if (userStore.containsKey(userId)) {
                        userStore.remove(userId);
                        deleted = 1;
                    }

                    span.setOutput("deletedRecords", deleted);
                    span.setOutput("tablesCleared", 1);
                    span.end();

                    exchange.getIn().setHeader("CamelHttpResponseCode", 204);
                    exchange.getIn().setBody(null);
                } catch (Exception e) {
                    span.endWithError(e);
                    throw e;
                }
            });
    }

    // Simple User class
    public static class User {
        private String id;
        private String email;
        private String name;

        public User() {}

        public User(String id, String email, String name) {
            this.id = id;
            this.email = email;
            this.name = name;
        }

        public String getId() { return id; }
        public void setId(String id) { this.id = id; }

        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }

        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
    }
}
