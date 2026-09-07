package com.minimarket.producto.dto;
import java.time.OffsetDateTime;
public record CategoriaResponseDTO(Long id,String nombre,String descripcion,Long categoriaPadreId,String categoriaPadreNombre,Boolean activo,OffsetDateTime createdAt) {}
