package com.example.compliance;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.EnableAspectJAutoProxy;

@SpringBootApplication
@EnableAspectJAutoProxy
public class Application {
    public static void main(String[] args) {
        System.out.println("Starting Compliance Spring Boot Example");
        System.out.println("Frameworks: GDPR, SOC 2, HIPAA");
        System.out.println("Controls: Art.15, Art.17, Art.5(1)(f), CC6.1, §164.312(a)(1)");
        System.out.println("");
        SpringApplication.run(Application.class, args);
    }
}
