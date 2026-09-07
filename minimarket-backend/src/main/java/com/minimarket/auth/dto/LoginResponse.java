package com.minimarket.auth.dto;
import java.util.Set;
public record LoginResponse(String token, String type, long expiresInSeconds, Long usuarioId,
                            String username, String nombreCompleto, Set<String> roles, Set<String> permisos) {}
