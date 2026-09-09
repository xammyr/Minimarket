package com.minimarket.compra.dto;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.util.List;

public record CompraRequestDTO(
    @NotNull Long proveedorId,
    @NotEmpty String numeroComprobante,
    @NotEmpty List<CompraDetalleRequestDTO> detalles
) {}
