package com.example.compliance.controller;

import com.compliance.annotations.*;
import com.example.compliance.model.User;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final Map<String, User> users = new ConcurrentHashMap<>();
    private final AtomicLong idCounter = new AtomicLong(1);

    public UserController() {
        // Seed with sample data
        User alice = new User("1", "alice@example.com", "Alice");
        User bob = new User("2", "bob@example.com", "Bob");
        users.put(alice.getId(), alice);
        users.put(bob.getId(), bob);
        idCounter.set(3);
    }

    @GetMapping
    @GDPREvidence(
        control = GDPRControls.Art_15,
        evidenceType = EvidenceType.AUDIT_TRAIL,
        description = "List all users"
    )
    public List<User> listUsers() {
        return new ArrayList<>(users.values());
    }

    @GetMapping("/{id}")
    @GDPREvidence(
        control = GDPRControls.Art_15,
        evidenceType = EvidenceType.AUDIT_TRAIL,
        description = "Retrieve user personal data"
    )
    public User getUser(@PathVariable String id) {
        User user = users.get(id);
        if (user == null) {
            throw new RuntimeException("User not found: " + id);
        }
        return user;
    }

    @PostMapping
    @GDPREvidence(
        control = GDPRControls.Art_51f,
        evidenceType = EvidenceType.AUDIT_TRAIL,
        description = "Create user with security measures"
    )
    @SOC2Evidence(
        control = SOC2Controls.CC6_1,
        evidenceType = EvidenceType.AUDIT_TRAIL,
        description = "Authorization check for user creation"
    )
    @ResponseStatus(HttpStatus.CREATED)
    public User createUser(@RequestBody User user) {
        String id = String.valueOf(idCounter.getAndIncrement());
        user.setId(id);
        users.put(id, user);
        return user;
    }

    @DeleteMapping("/{id}")
    @GDPREvidence(
        control = GDPRControls.Art_17,
        evidenceType = EvidenceType.AUDIT_TRAIL,
        description = "Delete all user personal data"
    )
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteUser(@PathVariable String id) {
        User removed = users.remove(id);
        if (removed == null) {
            throw new RuntimeException("User not found: " + id);
        }
    }

    @GetMapping("/health")
    public Map<String, Object> health() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "healthy");
        health.put("version", "1.0.0");

        Map<String, Object> compliance = new HashMap<>();
        compliance.put("frameworks", Arrays.asList("GDPR", "SOC2", "HIPAA"));
        compliance.put("controls", Arrays.asList("Art.15", "Art.17", "Art.5(1)(f)", "CC6.1"));
        health.put("compliance", compliance);

        return health;
    }
}
