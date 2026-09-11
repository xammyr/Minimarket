package com.minimarket;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import org.springframework.cache.annotation.EnableCaching;

@SpringBootApplication
@EnableCaching
public class MinimarketBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(MinimarketBackendApplication.class, args);
        System.out.println("WA");
    }
}
