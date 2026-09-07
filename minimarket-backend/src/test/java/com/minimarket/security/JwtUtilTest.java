package com.minimarket.security;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Prueba unitaria simple (no requiere Spring ni base de datos) para dejar
 * un ejemplo de test funcionando desde el primer commit, siguiendo la
 * convencion de pruebas definida en la Fase 1.
 */
class JwtUtilTest {

    private final JwtUtil jwtUtil = new JwtUtil(
            "clave-de-prueba-superlarga-solo-para-tests-1234567890",
            60L
    );

    @Test
    void generaYValidaUnTokenCorrectamente() {
        String token = jwtUtil.generateToken("admin");

        assertEquals("admin", jwtUtil.extractUsername(token));
        assertTrue(jwtUtil.isTokenValid(token, "admin"));
    }

    @Test
    void rechazaElTokenParaOtroUsuario() {
        String token = jwtUtil.generateToken("admin");

        assertTrue(!jwtUtil.isTokenValid(token, "otro-usuario"));
    }
}
