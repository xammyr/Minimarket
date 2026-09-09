package com.minimarket.compra.controller;

import com.minimarket.common.ApiResponse;
import com.minimarket.compra.dto.CompraRequestDTO;
import com.minimarket.compra.dto.CompraResponseDTO;
import com.minimarket.compra.service.CompraService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/compras")
@RequiredArgsConstructor
public class CompraController {

    private final CompraService compraService;

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'CAJERO')")
    public ResponseEntity<ApiResponse<CompraResponseDTO>> registrarCompra(@RequestBody @Valid CompraRequestDTO request) {
        CompraResponseDTO response = compraService.registrarCompra(request);
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.ok(response, "Compra registrada exitosamente"));
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'CAJERO')")
    public ResponseEntity<ApiResponse<Page<CompraResponseDTO>>> listar(Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.ok(compraService.listar(pageable)));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'CAJERO')")
    public ResponseEntity<ApiResponse<CompraResponseDTO>> obtener(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(compraService.obtener(id)));
    }

    @PostMapping("/{id}/anular")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Void>> anular(@PathVariable Long id, @RequestParam String motivo) {
        compraService.anular(id, motivo);
        return ResponseEntity.ok(ApiResponse.ok(null, "Compra anulada exitosamente"));
    }
}
