package com.minimarket.compra.dto;

import java.math.BigDecimal;

public record CompraDetalleResponseDTO(
    Long id,
    Long productoId,
    String productoNombre,
    BigDecimal cantidad,
    BigDecimal precioUnitario,
    BigDecimal subtotal
) {}
