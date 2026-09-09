package com.minimarket.compra.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;

public record CompraDetalleRequestDTO(
    @NotNull Long productoId,
    @NotNull @Positive BigDecimal cantidad,
    @NotNull @Positive BigDecimal precioUnitario
) {}
