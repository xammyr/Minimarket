package com.minimarket.usuario.dto;

import lombok.Data;
import java.time.OffsetDateTime;
import java.util.List;

@Data
public class UsuarioResponseDTO {
    private Long id;
    private String username;
    private String nombres;
    private String apellidos;
    private String email;
    private String telefono;
    private Boolean activo;
    private OffsetDateTime ultimoAcceso;
    private List<String> roles;
}
