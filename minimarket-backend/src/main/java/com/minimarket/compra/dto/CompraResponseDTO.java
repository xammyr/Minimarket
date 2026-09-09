package com.minimarket.compra.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;

public record CompraResponseDTO(
    Long id,
    String numeroComprobante,
    Long proveedorId,
    String proveedorNombre,
    Long usuarioId,
    String usuarioNombre,
    BigDecimal subtotal,
    BigDecimal igv,
    BigDecimal total,
    String estado,
    OffsetDateTime fechaCompra,
    List<CompraDetalleResponseDTO> detalles
) {}
