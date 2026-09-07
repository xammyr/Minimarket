package com.minimarket.producto.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

/**
 * DTO de entrada. Convencion del proyecto (Fase 1): nunca se expone la
 * entidad JPA directamente en el contrato de la API.
 */
public record ProductoRequestDTO(

        @NotBlank @Size(max = 30)
        String codigoInterno,

        @Size(max = 30)
        String codigoBarras,

        @NotBlank @Size(max = 150)
        String nombre,

        String descripcion,

        @NotNull
        Long categoriaId,

        Long marcaId,

        @NotNull
        Long unidadMedidaId,

        Long proveedorId,

        @NotNull @DecimalMin(value = "0.0")
        BigDecimal precioCompra,

        @NotNull @DecimalMin(value = "0.0")
        BigDecimal precioVenta,

        @NotNull
        Boolean afectoIgv,

        @NotNull @DecimalMin(value = "0.0")
        BigDecimal stockMinimo,

        @NotNull
        Boolean controlaStock
) {
}
