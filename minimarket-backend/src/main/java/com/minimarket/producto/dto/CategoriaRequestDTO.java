package com.minimarket.producto.dto;
import jakarta.validation.constraints.*;
public record CategoriaRequestDTO(@NotBlank @Size(max=80) String nombre, @Size(max=200) String descripcion, Long categoriaPadreId) {}
