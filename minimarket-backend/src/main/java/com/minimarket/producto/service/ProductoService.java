package com.minimarket.producto.service;

import com.minimarket.producto.dto.ProductoRequestDTO;
import com.minimarket.producto.dto.ProductoResponseDTO;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface ProductoService {

    Page<ProductoResponseDTO> listar(String busqueda, Pageable pageable);

    ProductoResponseDTO obtenerPorId(Long id);

    ProductoResponseDTO obtenerPorCodigoBarras(String codigoBarras);

    ProductoResponseDTO crear(ProductoRequestDTO request);

    ProductoResponseDTO actualizar(Long id, ProductoRequestDTO request);

    void desactivar(Long id);
}
