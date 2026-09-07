package com.minimarket.common;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.time.OffsetDateTime;

/**
 * Envoltorio estandar de respuesta de la API (convencion definida en la Fase 1
 * del plan: "Definir convenciones de nombres, errores, respuestas API y DTOs").
 * Todo endpoint responde con esta forma, exito o error, para que el frontend
 * tenga un contrato unico y predecible.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public record ApiResponse<T>(
        boolean success,
        T data,
        String message,
        OffsetDateTime timestamp
) {
    public static <T> ApiResponse<T> ok(T data) {
        return new ApiResponse<>(true, data, null, OffsetDateTime.now());
    }

    public static <T> ApiResponse<T> ok(T data, String message) {
        return new ApiResponse<>(true, data, message, OffsetDateTime.now());
    }

    public static <T> ApiResponse<T> error(String message) {
        return new ApiResponse<>(false, null, message, OffsetDateTime.now());
    }
}
