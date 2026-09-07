package com.minimarket.producto.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

/** DTO de salida: solo lo que el frontend necesita, con nombres ya "aplanados". */
public record ProductoResponseDTO(
        Long id,
        String codigoInterno,
        String codigoBarras,
        String nombre,
        String descripcion,
        Long categoriaId,
        String categoriaNombre,
        Long marcaId,
        String marcaNombre,
        Long unidadMedidaId,
        String unidadMedidaAbreviatura,
        BigDecimal precioCompra,
        BigDecimal precioVenta,
        boolean afectoIgv,
        BigDecimal stockActual,
        BigDecimal stockMinimo,
        boolean controlaStock,
        boolean activo,
        OffsetDateTime creadoEn
) {
}
