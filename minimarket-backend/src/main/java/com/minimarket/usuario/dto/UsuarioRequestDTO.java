package com.minimarket.usuario.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import java.util.Set;

@Data
public class UsuarioRequestDTO {
    @NotBlank(message = "El nombre de usuario es obligatorio")
    private String username;

    private String password;

    @NotBlank(message = "Los nombres son obligatorios")
    private String nombres;

    @NotBlank(message = "Los apellidos son obligatorios")
    private String apellidos;

    @Email(message = "Email inválido")
    private String email;

    private String telefono;

    private Boolean activo;

    private Set<Long> rolesIds;
}
