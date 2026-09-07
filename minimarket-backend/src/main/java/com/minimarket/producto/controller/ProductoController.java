package com.minimarket.producto.controller;

import org.springframework.security.access.prepost.PreAuthorize;
import com.minimarket.common.ApiResponse;
import com.minimarket.producto.dto.ProductoRequestDTO;
import com.minimarket.producto.dto.ProductoResponseDTO;
import com.minimarket.producto.service.ProductoService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/**
 * Ejemplo de modulo COMPLETO (entity -> repository -> service -> DTO -> controller).
 * Los demas modulos (cliente/, venta/, caja/, ...) hoy solo traen entity/repository;
 * cuando les toque su fase, replicar este mismo patron.
 */
@RestController
@RequestMapping("/api/productos")
@RequiredArgsConstructor
@Tag(name = "Productos", description = "Catalogo de productos")
public class ProductoController {

    private final ProductoService productoService;

    @GetMapping
    @PreAuthorize("hasAuthority('PRODUCTO_VER')")
    public ApiResponse<Page<ProductoResponseDTO>> listar(
            @RequestParam(required = false) String busqueda,
            Pageable pageable) {
        return ApiResponse.ok(productoService.listar(busqueda, pageable));
    }

    @GetMapping("/barcode/{codigoBarras}")
    @PreAuthorize("hasAuthority('PRODUCTO_VER')")
    public ApiResponse<ProductoResponseDTO> obtenerPorCodigoBarras(@PathVariable String codigoBarras) {
        return ApiResponse.ok(productoService.obtenerPorCodigoBarras(codigoBarras));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAuthority('PRODUCTO_VER')")
    public ApiResponse<ProductoResponseDTO> obtener(@PathVariable Long id) {
        return ApiResponse.ok(productoService.obtenerPorId(id));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAuthority('PRODUCTO_CREAR')")
    public ApiResponse<ProductoResponseDTO> crear(@Valid @RequestBody ProductoRequestDTO request) {
        return ApiResponse.ok(productoService.crear(request), "Producto creado");
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAuthority('PRODUCTO_EDITAR')")
    public ApiResponse<ProductoResponseDTO> actualizar(@PathVariable Long id,
                                                         @Valid @RequestBody ProductoRequestDTO request) {
        return ApiResponse.ok(productoService.actualizar(id, request), "Producto actualizado");
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAuthority('PRODUCTO_EDITAR')")
    public ApiResponse<Void> desactivar(@PathVariable Long id) {
        productoService.desactivar(id);
        return ApiResponse.ok(null, "Producto desactivado");
    }
}
